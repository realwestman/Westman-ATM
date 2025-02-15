ESX = exports[Config.Engine]:getSharedObject()


RegisterServerEvent("westman_atm:GetPlayerEconomy", function()
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    local PlayersCash = xPlayer.getMoney()
    local PlayersBank = xPlayer.getAccount("bank").money

    TriggerClientEvent("westman_atm:SendPlayerEconomy", src, PlayersCash, PlayersBank)
end)

RegisterServerEvent("westman_atm:withdraw", function(withdraw)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    local PlayersCash = xPlayer.getMoney()
    local PlayersBank = xPlayer.getAccount("bank").money

    if PlayersBank >= tonumber(withdraw) then
    xPlayer.removeAccountMoney('bank', tonumber(withdraw))
    xPlayer.addMoney(tonumber(withdraw))

    PlayersCash = xPlayer.getMoney()
    PlayersBank = xPlayer.getAccount("bank").money

    TriggerClientEvent("westman_atm:UpdatePlayerEconomy", src, PlayersCash, PlayersBank)
    else
        TriggerClientEvent('esx:showNotification', src, "You don't have enough money to withdraw that amount of cash.")
    end
end)

RegisterServerEvent("westman_atm:deposit", function(deposit)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    local PlayersCash = xPlayer.getMoney()
    local PlayersBank = xPlayer.getAccount("bank").money

    if PlayersCash >= tonumber(deposit) then
    xPlayer.addAccountMoney('bank', tonumber(deposit))
    xPlayer.removeMoney(tonumber(deposit))

    PlayersCash = xPlayer.getMoney()
    PlayersBank = xPlayer.getAccount("bank").money

    TriggerClientEvent("westman_atm:UpdatePlayerEconomy", src, PlayersCash, PlayersBank)
    else
        TriggerClientEvent('esx:showNotification', src, "You don't have enough cash to deposit that amount of money.")
    end
end)


ESX.RegisterServerCallback('westman_atm:CheckItem', function(cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local inventory = xPlayer.getInventory()
    cb(inventory)
end)
