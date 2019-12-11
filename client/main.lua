----- Original Code from DiscWorldZA -----
---- Reworked version of Disc-Drugruns ---
--------- Modified by Dazedgenie ---------

ESX = nil
PlayerData = nil

isHidingRun = false
isRunActive = false
event_time_passed = 0.0

local currentPawnTask = {
    pointIndex = 0,
    runsLeft = 0,
    pawnIndex = 0
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

function pawnOpen()
	if GetClockHours() >= Config.openH or GetClockHours() >= Config.closeH then
		return true
	else
		return false
	end
end

--Register Points
Citizen.CreateThread(function()
    for k, v in pairs(Config.DeliveryPoints) do
        local marker = {
            name = v.name .. '_pawn_dp',
            type = 2,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to deliver at ' .. v.name,
            action = DeliverPawn,
            deliveryPointIndex = k,
            shouldDraw = function()
                return Config.DeliveryPoints[k].isDeliveryPointActive and not isHidingRun
            end
        }
        TriggerEvent('disc-base:registerMarker', marker)
    end

    for k, v in pairs(Config.StartingPoints) do
        local marker = {
            name = v.name .. '_pawn_sp',
            type = 29,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to start available pawn runs at ' .. v.name .. ' for $' .. Config.StartPrice,
            action = StartNewRun,
            shouldDraw = function()
                return not isRunActive
            end
        }
        TriggerEvent('disc-base:registerMarker', marker)
    end
end)

function disableAllPoints()
    for k, v in pairs(Config.DeliveryPoints) do
        Config.DeliveryPoints[k].isDeliveryPointActive = false
    end
end

function DeliverPawn()
    playerPed = GetPlayerPed(-1)
    math.randomseed(GetGameTimer())

    local notSeen = math.random(0, 100)
    --Take Pawn
    ESX.TriggerServerCallback('disc-base:takePlayerItem', function(tookItem)
        if not tookItem then
            TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_PARKING_METER', 0, true)
            exports['progressBars']:startUI(5000, "Handing over product")
            if notSeen < (Config.NotifyCopsPercentage * 4) then
                serverId = GetPlayerServerId(PlayerId())
                message = 'Dispatch Message: Stolen Goods Sale Attempt in progress'
                TriggerServerEvent('esx_addons_gcphone:startCall', 'police', message, coords)
            end
            
            if notSeen > (Config.NotifyNewsPercentage * 4) then
                serverId = GetPlayerServerId(PlayerId())
                message = 'Anonymous Tip: Stolen Goods Sale Attempt in progress'
                TriggerServerEvent('esx_addons_gcphone:startCall', 'journaliste', message, coords)
            end

            Citizen.Wait(5000)
            ClearPedTasksImmediately(playerPed)

            exports['mythic_notify']:SendAlert('error', 'You didn\'t bring the right pawn? You imbecile.')
            EndRuns()
            exports['mythic_notify']:SendAlert('error', 'Pawn Run has ended due to merchandise issue')
        else
            --Pay for Pawn
            local price = math.random(Config.Pawn[currentPawnTask.pawnIndex].price[1], Config.Pawn[currentPawnTask.pawnIndex].price[2])
            local luck = math.random(1,100)

            print('Your Luck Is:', luck)

            TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_PARKING_METER', 0, true)
            exports['progressBars']:startUI(5000, "Handing over product")

            if notSeen < Config.NotifyCopsPercentage then
                serverId = GetPlayerServerId(PlayerId())
                message = 'Dispatch Message: Stolen Goods Sale Attempt in progress'
                TriggerServerEvent('esx_addons_gcphone:startCall', 'police', message, coords)
            elseif notSeen > (100 - Config.NotifyNewsPercentage) then
                serverId = GetPlayerServerId(PlayerId())
                message = 'Anonymous Tip: Stolen Goods Sale Attempt in progress'
                TriggerServerEvent('esx_addons_gcphone:startCall', 'journaliste', message, coords)
            end

            Citizen.Wait(5000)

            ClearPedTasksImmediately(playerPed)
            if luck <= Config.rewardChance then 
                exports['mythic_notify']:SendAlert('success', 'Im feeling generous today have this')
                TriggerServerEvent('dazed-pawn:giveReward')
            elseif luck > Config.rewardChance then
                exports['mythic_notify']:SendAlert('success', 'Good, Here\'s $' .. price)
                TriggerServerEvent('disc-base:givePlayerMoney', price)
            end
            --Continue if has more runs
            GotoNextRun()
        end
    end, Config.Pawn[currentPawnTask.pawnIndex].item, 1)
end

function StartNewRun()
    if pawnOpen() == true then
        print(pawnOpen())
        print(GetClockHours() .. ':' .. GetClockMinutes())
        ESX.TriggerServerCallback('disc-base:takePlayerMoney', function(took)
            if not took then
                exports['mythic_notify']:SendAlert('error', 'You don\'t have enough money, you need $' .. Config.StartPrice)
                return
            end
            isRunActive = true
            isHidingRun = true
            event_time_passed = 0.0
            pawnCount = math.random(5, 10)
            pawnIndex = math.random(#Config.Pawn)
            currentPawnTask = {
                pointIndex = math.random(#Config.DeliveryPoints),
                runsLeft = pawnCount,
                pawnIndex = pawnIndex
            }
            exports['mythic_notify']:SendAlert('success', 'Starting pawn Run!')
            -- TriggerServerEvent('disc-base:givePlayerItem', Config.Pawn[pawnIndex].item, pawnCount)
            Config.DeliveryPoints[currentPawnTask.pointIndex].isDeliveryPointActive = true
        end, Config.StartPrice)
    elseif pawnOpen() == false then 
        print(pawnOpen())
        exports['mythic_notify']:SendAlert('error', 'We are closed for the day. Check back later.')
    end
end


function GotoNextRun()
    disableAllPoints()
    if currentPawnTask.runsLeft - 1 == 0 then
        EndRuns()
    else
        isHidingRun = true
        currentPawnTask = {
            pointIndex = math.random(#Config.DeliveryPoints),
            runsLeft = currentPawnTask.runsLeft - 1,
            pawnIndex = math.random(#Config.Pawn)
        }
        
        --CreatePed( 1, "mp_m_freemode_01", v.Pos[i].x, v.Pos[i].y, v.Pos[i].z,0.0, false, true )
        --CreatePed(PED_TYPE_PROSTITUTE --[[ integer ]], 349680864 --[[ Hash ]], Config.DeliveryPoints.vector3.x --[[ number ]], Config.DeliveryPoints.vector3.y --[[ number ]], Config.DeliveryPoints.vector3.z --[[ number ]], Config.DeliveryPoints.heading --[[ number ]], false --[[ boolean ]], true --[[ boolean ]])
        Config.DeliveryPoints[currentPawnTask.pointIndex].isDeliveryPointActive = true
    end
end

function EndRuns()
    isRunActive = false
    disableAllPoints()  
	event_time_passed = 0.0
end

-- CANCEL CHECK IN CASE PLAYER DIED OR TAKES TO LONG TO COMPLETE
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
				if isRunActive then

						if IsPedDeadOrDying(GetPlayerPed(-1)) then
							EndRuns()
							exports['mythic_notify']:SendAlert('error', 'Pawn Run has ended due to loss of consciousness!')
						end

						if event_time_passed > Config.Timeout then
							EndRuns()
							exports['mythic_notify']:SendAlert('error', 'Pawn Run has timed out!')
						end

						event_time_passed = event_time_passed + 5
				end
		end
end)

--Hiding Run
Citizen.CreateThread(function()
    while true do
        if isHidingRun then
            Citizen.Wait(1000)
            isHidingRun = false
            serverId = GetPlayerServerId(PlayerId())
            ESX.TriggerServerCallback('disc-gcphone:getNumber', function(number)
                coords = Config.DeliveryPoints[currentPawnTask.pointIndex].coords
                message = 'GPS: ' .. coords.x .. ', ' .. coords.y .. ' Im Looking to buy some ' .. Config.Pawn[currentPawnTask.pawnIndex].name
                TriggerServerEvent('disc-gcphone:sendMessageFrom', 'Client', number, message, serverId)
            end)
        end
        Citizen.Wait(5000)
    end
end)
