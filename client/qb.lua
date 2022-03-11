CreateThread(function()
    if Config.Framework ~= "qb" then return end
    local QBCore
    while not QBCore do
        QBCore = exports["qb-core"]:GetCoreObject()
        Wait(500)
    end
    while not QBCore.Functions.GetPlayerData() or not QBCore.Functions.GetPlayerData().job do
        Wait(500)
    end

    function ConfirmTransfer(data)
        local label, billId, playerName, playerId, oldData = table.unpack(data)

        exports["qb-menu"]:openMenu({
            {
                header = Strings["confirm_transfer"]:format(label, playerName),
                isMenuHeader = true
            },
            {
                header = Strings["yes"],
                params = {
                    event = function()
                        TriggerServerEvent("loaf_billing:transfer_bill", billId, playerId)
                    end,
                    isAction = true
                }
            },
            {
                header = Strings["no"],
                params = {
                    event = TransferMenu,
                    args = oldData,
                    isAction = true
                }
            }
        })
    end

    function TransferMenu(data)
        local label, billId, oldData = table.unpack(data)
        local elements = {
            {
                header = Strings["who_transfer"],
                isMenuHeader = true
            }
        }
        for _, v in pairs(GetPlayers()) do
            table.insert(elements, {
                header = v.name,
                params = {
                    event = ConfirmTransfer,
                    args = {label, billId, v.name, v.serverId, data},
                    isAction = true
                }
            })
        end
        table.insert(elements, {
            header = Strings["back"], 
            params = {
                event = BillMenu, 
                args = oldData, 
                isAction = true
            }
        })

        exports["qb-menu"]:openMenu(elements)
    end

    function BillMenu(data)
        local label, billId, signed = table.unpack(data)
        local elements = {
            {
                header = label,
                isMenuHeader = true
            },
            {
                header = Strings["view_bill"],
                params = {
                    event = OpenBill,
                    args = billId,
                    isAction = true
                }
            }
        }
        if signed then
            table.insert(elements, {
                header = Strings["transfer_bill"],
                params = {
                    event = TransferMenu,
                    args = {label, billId, data},
                    isAction = true
                }
            })
        end
        table.insert(elements, {header = Strings["back"], params = {event = BillsMenu, args = signed, isAction = true}})

        exports["qb-menu"]:openMenu(elements)
    end

    function BillsMenu(signed)
        local elements = {
            {
                header = Strings[(signed and "" or "un") .. "signed_bills"],
                isMenuHeader = true
            }
        }

        for k, v in pairs(bills) do
            local colour = v.signed and "springgreen" or "lightcoral"
            local signedText = Strings[v.signed and "signed_bill" or "unsigned_bill"]

            local label = Strings["bill_item"]:format(signedText, v.description)
            if v.signed == signed then
                table.insert(elements, {
                    header = label,
                    params = {
                        event = BillMenu,
                        args = {label, v.id, signed},
                        isAction = true
                    }
                })
            end
        end

        if #elements == 1 then
            table.insert(elements, {header = Strings["no_bills"], params = {event = OpenBillsMenu, isAction = true}})
        else
            table.insert(elements, {header = Strings["back"], params = {event = OpenBillsMenu, isAction = true}})
        end

        exports["qb-menu"]:openMenu(elements)
    end

    function OpenBillsMenu()
        exports["qb-menu"]:openMenu({
            {
                header = Strings["select_menu"],
                isMenuHeader = true
            },
            {
                header = Strings["unsigned_bill"],
                params = {
                    event = BillsMenu,
                    args = false,
                    isAction = true
                }
            },
            {
                header = Strings["signed_bill"],
                params = {
                    event = BillsMenu,
                    args = true,
                    isAction = true
                }
            },
            {
                header = Strings["close"],
                params = {}
            }
        })
    end

    loaded = true
end)