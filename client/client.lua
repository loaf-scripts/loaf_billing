local isOpen, currentBill
bills = {}

CreateThread(function()
    while not loaded do
        Wait(500)
    end
    lib = exports.loaf_lib:GetLib()
    bills = lib.TriggerCallbackSync("loaf_billing:get_bills")

    if Config.Command then
        RegisterCommand(Config.Command, OpenBillsMenu)
        if Config.Keybind.Enabled then
            RegisterKeyMapping(Config.Command, Strings["keybind"], Config.Keybind.Mapper, Config.Keybind.Parameter)
        end
    end
end)

RegisterNetEvent("loaf_billing:set_signed", function(billId)
    for k, v in pairs(bills) do
        if v.id == billId then
            v.signed = true
            return
        end
    end
end)
RegisterNetEvent("loaf_billing:remove_bill", function(billId)
    for i, v in pairs(bills) do
        if v.id == billId then
            table.remove(bills, i)
            break
        end
    end
end)
RegisterNetEvent("loaf_billing:add_bill", function(billData)
    table.insert(bills, billData)
end)

function OpenBill(billId)
    if isOpen then
        return
    end

    isOpen = true
    lib.TriggerCallback("loaf_billing:get_bill", function(billData)
        if not billData then
            print("unknown bill: " .. billId)
            isOpen = false
            return
        end

        currentBill = billId
        SetNuiFocus(true, true)
        TriggerScreenblurFadeIn(0)
        local lateAmount = math.floor((billData.interest / 100) * billData.amount)
        local lateTotal = math.floor(lateAmount * billData.late)
        SendNUIMessage({
            action = "show",
            
            signed = billData.signed,
            signature = billData.signature,

            interest = billData.interest, 
            late = billData.late,
            lateAmount = FormatNumber(lateAmount) .. ".00",
            lateTotal = FormatNumber(lateTotal) .. ".00",
            
            total = FormatNumber(lateTotal + billData.amount) .. ".00",

            to = {
                name = billData.billed_name
            },
            from = {
                name = billData.biller_name
            },
            invoice = {
                id = billId,
                issued = billData.issued,
                due = billData.due
            },
            info = {
                description = billData.description,
                price = FormatNumber(billData.amount) .. ".00"
            },
            company = {
                name = billData.company_name,
                company = billData.company
            },
        })
    end, billId)
end

function CloseNui() 
    isOpen = false
    currentBill = nil
    SetNuiFocus(false, false)
    TriggerScreenblurFadeOut(0)
end
RegisterNUICallback("close", CloseNui)

RegisterNUICallback("sign", function(base64, cb)
    if not currentBill then
        return
    end
    if not Config.Signature.SaveSignature then
        base64 = nil
    end
    TriggerServerEvent("loaf_billing:sign_bill", currentBill, base64)
    cb("")
    CloseNui() 
end)

-- misc functions
function FormatNumber(number)
    -- https://stackoverflow.com/questions/10989788/format-integer-in-lua
    return tostring(number):reverse():gsub("(%d%d%d)", "%1 "):reverse():gsub("^ ", "")
end

-- function to get nearby players
function GetPlayers()
    local found = {}
    for _, player in pairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local playerPed = GetPlayerPed(player)
            if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(playerPed)) <= 5.0 then
                local foundName, startedSearch, name = false, GetGameTimer(), GetPlayerName(player)
                
                if Config.UseRPName then
                    name = lib.TriggerCallbackSync("loaf_billing:get_name", GetPlayerServerId(player)) or name
                end

                found[#found+1] = {
                    serverId = GetPlayerServerId(player),
                    name = name  .. (" [%i]"):format(GetPlayerServerId(player))
                }
            end
        end
    end
    return found
end