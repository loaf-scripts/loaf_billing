CreateThread(function()
    if Config.Framework ~= "esx" then return end
    local ESX
    while not ESX do 
        TriggerEvent("esx:getSharedObject", function(obj) 
            ESX = obj 
        end)
        Wait(500)
    end
    while not ESX.GetPlayerData() or not ESX.GetPlayerData().job do
        Wait(250)
    end

    local function ConfirmTransfer(label, billId, playerName, playerId)
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "confirm_transfer", {
            title = Strings["confirm_transfer"]:format(label, playerName),
            align = Config.MenuAlign,
            elements = {
                {label = Strings["yes"], transfer = true},
                {label = Strings["no"]}
            }
        }, function(data, menu)
            if not data.current.transfer then
                menu.close()
                return
            end

            TriggerServerEvent("loaf_billing:transfer_bill", billId, playerId)
            ESX.UI.Menu.CloseAll()
        end, function(data, menu)
            menu.close()
        end)
    end

    local function TransferMenu(label, billId)
        local nearbyElements = {}
        for _, v in pairs(GetPlayers()) do
            table.insert(nearbyElements, {
                label = v.name,
                value = v.serverId
            })
        end

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "select_person", {
            title = Strings["who_transfer"],
            align = Config.MenuAlign,
            elements = nearbyElements
        }, function(data, menu)
            if not data.current.value then
                menu.close()
                return
            end
            ConfirmTransfer(label, billId, data.current.label, data.current.value)
        end, function(data, menu)
            menu.close()
        end)
    end

    local function BillMenu(label, billId, signed)
        local elements = {
            {label = Strings["view_bill"], value = "view"}
        }
        if signed then
            table.insert(elements, {label = Strings["transfer_bill"], value = "transfer"})
        end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "bill_menu", {
            title = label,
            align = Config.MenuAlign,
            elements = elements
        }, function(data, menu)
            if data.current.value == "view" then
                ESX.UI.Menu.CloseAll()
                OpenBill(billId)
            elseif data.current.value == "transfer" then
                TransferMenu(label, billId)
            end
        end, function(data, menu)
            menu.close()
        end)
    end

    local function BillsMenu(signed)
        local elements = {}
        for k, v in pairs(bills) do
            local colour = v.signed and "springgreen" or "lightcoral"
            local signedText = Strings[v.signed and "signed_bill" or "unsigned_bill"]
            if v.signed == signed then
                table.insert(elements, {
                    label = Strings["bill_item"]:format(("<span style='color:%s'>%s</span>"):format(colour, signedText), v.description),
                    id = v.id
                })
            end
        end

        if #elements == 0 then
            table.insert(elements, {label = Strings["no_bills"]})
        end

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "bills", {
            title = Strings[(signed and "" or "un") .. "signed_bills"],
            align = Config.MenuAlign,
            elements = elements
        }, function(data, menu)
            if not data.current.id then return end
            BillMenu(data.current.label, data.current.id, signed)
        end, function(data, menu)
            menu.close()
        end)
    end

    function OpenBillsMenu()
        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "select_menu", {
            title = Strings["select_menu"],
            align = Config.MenuAlign,
            elements = {
                {label = Strings["unsigned_bill"], value="unsigned"},
                {label = Strings["signed_bill"], value="signed"},
            }
        }, function(data, menu)
            BillsMenu(data.current.value == "signed")
        end, function(data, menu)
            menu.close()
        end)
    end

    loaded = true
end)