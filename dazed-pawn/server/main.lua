ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterServerEvent('dazed-pawn:giveReward')
AddEventHandler('dazed-pawn:giveReward', function(item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    reward = Config.Reward.item

    xPlayer.addInventoryItem(reward, 1)
end)