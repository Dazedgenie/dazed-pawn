ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

function PawnCounter(d, h, m)

    Config.PawnSold = Config.PawnSold + 5
    print('Pawn Lists Restocked')

end

Citizen.CreateThread(function()
    print("dazed-pawn: Started!")

	if Config.Restock then
		TriggerEvent("cron:runAt", 0, 1,PawnCounter)
		TriggerEvent("cron:runAt", 2, 1,PawnCounter)
		TriggerEvent("cron:runAt", 4, 1,PawnCounter)
		TriggerEvent("cron:runAt", 6, 1,PawnCounter)
		TriggerEvent("cron:runAt", 8, 1,PawnCounter)
		TriggerEvent("cron:runAt", 10, 1,PawnCounter)
		TriggerEvent("cron:runAt", 12, 1,PawnCounter)
		TriggerEvent("cron:runAt", 14, 1,PawnCounter)
		TriggerEvent("cron:runAt", 16, 1,PawnCounter)
		TriggerEvent("cron:runAt", 18, 1,PawnCounter)
		TriggerEvent("cron:runAt", 20, 1,PawnCounter)
		TriggerEvent("cron:runAt", 22, 1,PawnCounter)
	end
end)


RegisterServerEvent('dazed-pawn:giveReward')
AddEventHandler('dazed-pawn:giveReward', function(item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    reward = Config.Reward.item
    rewardq = Config.Reward.quantity

    xPlayer.addInventoryItem(reward, 1)
end)