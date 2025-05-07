ESX = exports["es_extended"]:getSharedObject()

local ATMPositions = Config.ATM
local NuiOpen = false


CreateThread(function()
    local NearATM = false
    while true do 
        local sleep = 2500
        local player = PlayerPedId()
        local PlayerCoords = GetEntityCoords(player)
        local ClosestDistance = math.huge

        for _, v in pairs(ATMPositions) do 
            local distance = #(PlayerCoords - v)
            if distance < ClosestDistance then 
                ClosestDistance = distance
            end
        end

        if ClosestDistance <= 3.0 then 
            if not NearATM then
                NearATM = true
            end
            lib.showTextUI("E - Open ATM") 
            sleep = 1

            if IsControlJustReleased(0, 38) then 
                if Config.Item.mandatory then
                    CheckForItem(ItemName, function(HasItem)
                        if HasItem then
                            TriggerServerEvent("westman_atm:GetPlayerEconomy")
                        else
                            ESX.ShowNotification("You don't carry a bank card...")
                        end
                    end)
                else 
                    TriggerServerEvent("westman_atm:GetPlayerEconomy")
                end
            end
        elseif NearATM then
            NearATM = false
            lib.hideTextUI()
        end
        Wait(sleep)
    end
end)

function CheckForItem(ItemName, callback)
    local ItemName = Config.Item.item
    ESX.TriggerServerCallback('westman_atm:CheckItem', function(inventory)
        local HasItem = false

        for _, item in pairs(inventory) do
            if item.name == ItemName and item.count >= 1 then
                HasItem = true
                break
            end
        end

        callback(HasItem)
    end)
end


RegisterNUICallback("withdraw", function(data, cb)
    local withdraw = data.ModifiedInput
    
    TriggerServerEvent("westman_atm:withdraw", withdraw)
end)

RegisterNUICallback("deposit", function(data, cb)
    local deposit = data.ModifiedInput

    TriggerServerEvent("westman_atm:deposit", deposit)
end)

RegisterNUICallback("close", function()
    local player = PlayerPedId()
    if NuiOpen then 
        OpenNUI()
        TaskPlayAnim(player, "mp_common", "givetake1_a", 8.0, -8, -1, 49, 0, false, false, false)
        Wait(3000)
        ClearPedTasks(player)
    end
end)


RegisterNetEvent("westman_atm:SendPlayerEconomy", function(PlayersCash, PlayersBank)
    local player = PlayerPedId()

    RequestAnimDict("mp_common")
        while not HasAnimDictLoaded("mp_common") do 
            Wait(0)
        end

    SendNUIMessage({
        action = "money",
        PlayersCash = PlayersCash, 
        PlayersBank = PlayersBank,
        Currency = Config.Currency,
        DepositButton = Config.DepositButton,
        WithdrawButton = Config.WithdrawButton,
        ATMTitle = Config.ATMTitle
    })
    OpenNUI()

    TaskPlayAnim(player, "mp_common", "givetake1_a", 8.0, -8, -1, 49, 0, false, false, false)
    Wait(3000)
    ClearPedTasks(player)
end)

RegisterNetEvent("westman_atm:UpdatePlayerEconomy", function(PlayersCash, PlayersBank)
    SendNUIMessage({
        action = "money",
        PlayersCash = PlayersCash, 
        PlayersBank = PlayersBank
    })
end)


function OpenNUI()
if not NuiOpen then 
    NuiOpen = true
    SendNUIMessage({
        action = "open"
    })
    SetNuiFocus(true, true)
else 
    NuiOpen = false
    SendNUIMessage({
        action = "close"
    })
    SetNuiFocus(false, false)
    end
end