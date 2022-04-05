CreateThread(function()
    if Config.Framework ~= "esx" then
        return
    end

    local ESX
    TriggerEvent("esx:getSharedObject", function(esx)
        ESX = esx
    end)

    function Notify(source, message)
        TriggerClientEvent("esx:showNotification", source, message)
    end

    function GetPlayerFromIdentifier(identifier)
        return ESX.GetPlayerFromIdentifier(identifier)?.source
    end

    function GetIdentifier(source)
        return ESX.GetPlayerFromId(source)?.identifier
    end

    function GetCompanyName(job)
        return MySQL.Sync.fetchScalar("SELECT `label` FROM `jobs` WHERE `name`=@job", {["@job"] = job})
    end

    function PayMoney(source, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            return true
        elseif xPlayer.getAccount("bank").money >= amount then
            xPlayer.removeAccountMoney("bank", amount)
            return true
        end
        return false
    end

    function GetName(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local firstName, lastName
        if xPlayer.get and xPlayer.get("firstName") and xPlayer.get("lastName") then
            firstName = xPlayer.get("firstName")
            lastName = xPlayer.get("lastName")
        else
            local name = MySQL.Sync.fetchAll("SELECT `firstname`, `lastname` FROM `users` WHERE `identifier`=@identifier", {["@identifier"] = GetIdentifier(source)})
            firstName, lastName = name[1]?.firstname or GetPlayerName(source), name[1]?.lastname or ""
        end

        return ("%s %s"):format(firstName, lastName)
    end

    function HasJob(source, job)
        return ESX.GetPlayerFromId(source)?.getJob().name == job
    end

    function AddCompanyMoney(company, amount)
        TriggerEvent("esx_addonaccount:getSharedAccount", "society_" .. company, function(account)
            if account then
                account.addMoney(amount)
            end
        end)
    end
end)
