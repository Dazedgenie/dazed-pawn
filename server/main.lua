ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

function RandomLoot()
    math.randomseed(GetGameTimer())
    local item = Config.Reward[math.random(1,#Config.Reward)]

    for i=1, #Config.Reward do
        return Config.Reward[math.random(#Config.Reward)]
    end
end

RegisterServerEvent('dazed-pawn:giveReward')
AddEventHandler('dazed-pawn:giveReward', function(item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local reward = RandomLoot()

    xPlayer.addInventoryItem(reward, 1)
end)