local secondsDay = 24 * 60 * 60
lib = exports.loaf_lib:GetLib()

lib.RegisterCallback("loaf_billing:get_name", function(source, cb, playerId)
    cb(GetName(playerId))
end)

RegisterNetEvent("loaf_billing:transfer_bill", function(billId, sendTo)
    local src = source
    MySQL.Async.fetchAll("SELECT `description`, `signed` FROM `loaf_invoices` WHERE `id`=@billId", {["@billId"] = billId}, function(res)
        if not res[1] then return end

        MySQL.Async.execute("UPDATE `loaf_invoices` SET `owner`=@sendTo WHERE `owner`=@identifier AND `id`=@billId", {
            ["@sendTo"] = GetIdentifier(sendTo),
            ["@identifier"] = GetIdentifier(src),
            ["@billId"] = billId
        }, function(rowsChanged)
            if rowsChanged == 1 then
                Notify(src, Strings["transferred_bill"]:format(res[1].description, GetName(sendTo)))
                Notify(sendTo, Strings["received_transfer"]:format(res[1].description, GetName(src)))

                TriggerClientEvent("loaf_billing:remove_bill", src, billId)
                TriggerClientEvent("loaf_billing:add_bill", sendTo, {
                    id = billId,
                    description = res[1].description,
                    signed = res[1].signed
                })
            end
        end)
    end)
end)

lib.RegisterCallback("loaf_billing:get_bill", function(source, cb, billId)
    MySQL.Async.fetchAll("SELECT * FROM `loaf_invoices` WHERE `id`=@billId AND `owner`=@identifier", {
        ["@billId"] = billId,
        ["@identifier"] = GetIdentifier(source)
    }, function(res)
        if not res[1] then cb(false) end
        -- translate date to YYYY-MM-DD format. Dividing by 1000 since sql stores time in milliseconds, whereas lua uses seconds
        local issued, due = math.floor(res[1].issued/1000), math.floor(res[1].due/1000)
        res[1].issued = os.date("%Y-%m-%d", issued)
        res[1].due = os.date("%Y-%m-%d", due)

        if not res[1].signed and (due < os.time() and os.date("%Y-%m-%d", due) ~= os.date("%Y-%m-%d")) then
            res[1].late = math.floor((os.time() - due) / secondsDay)
        end

        cb(res[1])
    end)
end)

lib.RegisterCallback("loaf_billing:get_bills", function(source, cb)
    MySQL.Async.fetchAll("SELECT `id`, `description`, `signed` FROM `loaf_invoices` WHERE `owner`=@identifier", {["@identifier"] = GetIdentifier(source)}, cb)
end)

function SendBill(biller, cb, billed, due, interest, amount, name, description, company)
    if not (
        (billed and GetPlayerName(billed)) and
        (type(due) == "number" and due > 0) and
        (type(interest) == "number" and interest >= 0 and interest <= 100) and
        (type(amount) == "number" and amount > 0) and
        (type(name) == "string") and
        (type(description) == "string") and
        (type(company) == "string")
    ) then
        return cb(false, "invalid_args")
    end

    if amount < Config.MinAmount or amount > Config.MaxAmount then
        return cb(false, "invalid_amount")
    end

    if not HasJob(biller, company) then
        return cb(false, "no_job")
    end

    local found, id
    while not found do
        Wait(50)
        id = lib.GenerateString(10)
        found = MySQL.Sync.fetchScalar("SELECT `id` FROM `loaf_invoices` WHERE `id`=@id", {["@id"] = id}) == nil
    end

    local sqlData = {
        ["@id"] = id,
        ["@biller"] = GetIdentifier(biller),
        ["@billerName"] = GetName(biller),
        ["@billed"] = GetIdentifier(billed),
        ["@billedName"] = GetName(billed),
        ["@owner"] = GetIdentifier(billed),
        ["@due"] = os.date("%Y-%m-%d", os.time() + secondsDay * due),
        ["@interest"] = interest,
        ["@amount"] = amount,
        ["@name"] = name,
        ["@description"] = description,
        ["@company"] = company,
        ["@company_name"] = GetCompanyName(company)
    }
    MySQL.Async.execute([[
        INSERT INTO `loaf_invoices` 
            (`id`, `biller`, `biller_name`, `billed`, `billed_name`, `owner`, `due`, `interest`, `amount`, `name`, `description`, `company`, `company_name`)
        VALUES
            (@id, @biller, @billerName, @billed, @billedName, @owner, @due, @interest, @amount, @name, @description, @company, @company_name)
    ]], sqlData, function()
        Notify(biller, Strings["sent_bill"]:format(amount, sqlData["@billedName"]))
        Notify(billed, Strings["received_bill"]:format(amount))
        TriggerClientEvent("loaf_billing:add_bill", billed, {
            id = id,
            description = description,
            signed = false
        })
        cb(id)
    end)
end

lib.RegisterCallback("loaf_billing:create_bill", SendBill)
if Config.ReplaceESXBilling then
    RegisterNetEvent("esx_billing:sendBill", function(billed, job, label, amount)
        local biller = source
        SendBill(biller, function(sent) end, billed, 30, 0, amount, label, label, job)
    end)
end
exports("CreateBill", SendBill)

RegisterNetEvent("loaf_billing:sign_bill", function(billId, base64)
    local src = source

    MySQL.Async.fetchAll("SELECT * FROM `loaf_invoices` WHERE `id`=@billId AND `owner`=@identifier", {
        ["@billId"] = billId,
        ["@identifier"] = GetIdentifier(src)
    }, function(res)
        if not res[1] then
            return
        end

        local totalAmount = res[1].amount
        -- Dividing by 1000 since sql stores time in milliseconds, whereas lua uses seconds
        local due, daysLate = math.floor(res[1].due/1000), 0
        if due < os.time() and os.date("%Y-%m-%d", due) ~= os.date("%Y-%m-%d") then
            daysLate = math.floor((os.time() - due) / secondsDay)
            totalAmount += math.floor(math.floor((res[1].interest / 100) * res[1].amount) * daysLate)
        end

        if not PayMoney(src, totalAmount) then
            Notify(src, Strings["no_money"])
            return
        end

        local image = ""
        if Config.Signature.SaveSignature then
            if Config.Signature.SaveAs == "imgur" then
                local base64Sub = string.sub(base64, #"data:image/png;base64," + 1, #base64)
                local uploadPromise = promise.new()
                PerformHttpRequest("https://api.imgur.com/3/image", function(code, data, headers)
                    if code == 200 then
                        image = json.decode(data).data.link
                    else
                        image = base64
                    end
                    uploadPromise:resolve()
                end, "POST", base64Sub, {
                    authorization = "Client-ID " .. ServerConfig.APIKey,
                    ["content-type"] = "multipart/form-data"
                })
                Citizen.Await(uploadPromise)
            elseif Config.Signature.SaveAs == "base64" then
                image = base64
            end
        end

        TriggerClientEvent("loaf_billing:set_signed", src, billId)

        local biller, billedName, amount, description = res[1]?.biller, res[1]?.billed_name, res[1]?.amount, res[1]?.description
        local billerSource = GetPlayerFromIdentifier(biller)
        if billerSource then
            Notify(billerSource, Strings["bill_paid"]:format(description, amount, billedName))
        end

        MySQL.Async.execute("UPDATE `loaf_invoices` SET `signed`=1, `signature`=@image, `late`=@late WHERE `id`=@billId", {
            ["@image"] = image,
            ["@billId"] = billId,
            ["@late"] = daysLate
        }, function()
            res[1].late = daysLate
            res[1].signed = true
            AddCompanyMoney(res[1].company, totalAmount)
            TriggerEvent("loaf_billing:bill_paid", res)
        end)
    end)
end)

exports("RemoveBill", function(billId)
    MySQL.Async.fetchScalar("SELECT `owner` FROM `loaf_invoices` WHERE `id`=@id", {
        ["@id"] = billId
    }, function(owner)
        if owner then
            MySQL.Async.execute("DELETE FROM `loaf_invoices` WHERE `id`=@id", {["@id"] = billId})

            local player = GetPlayerFromIdentifier(owner)
            if player then
                TriggerClientEvent("loaf_billing:remove_bill", player, billId)
            end
        end
    end)
end)

--- VERSION CHECK ---
CreateThread(function()
    PerformHttpRequest("https://loaf-scripts.com/versions/", function(err, text, headers) 
        if text then
            print(text)
        end
    end, "POST", json.encode({
        resource = "billing",
        version = GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "1.0.0"
    }), {["Content-Type"] = "application/json"})
end)
