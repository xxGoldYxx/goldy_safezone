local notifIn = false
local notifOut = false
local shouldLoop = false
local inCombatMode = false
local closestZone = 1
local otherPlayerPed = GetPlayerPed(player)

Citizen.CreateThread(function()
	for k,zone in pairs(Config.CircleZones) do

		CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
	end
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #Config.zones, 1 do
			dist = Vdist(Config.zones[i].x, Config.zones[i].y, Config.zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

local timmer = 0
local inSafe = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(20)
		local player = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(Config.zones[closestZone].x, Config.zones[closestZone].y, Config.zones[closestZone].z, x, y, z)
		
		if inSafe then
			SetEntityInvincible(PlayerPedId(), true)
			SetPlayerInvincible(PlayerId(), true)
		else
			SetEntityInvincible(PlayerPedId(), false)
			SetPlayerInvincible(PlayerId(), false)
		end
			
		if dist <= 150.0 then 

			if not notifIn then					
				otherPlayerPed = PlayerPedId()
				local hash = GetHashKey(v)
				SetEntityInvincible(otherPlayerPed, true)							  
				NetworkSetFriendlyFireOption(false)
				SetPlayerInvincible(player, true)
				SetEntityInvincible(PlayerPedId(), true)
				SetPlayerInvincible(PlayerId(), true)												  
				SetEntityNoCollisionEntity(otherPlayerPed, pPed, true)
				ResetEntityAlpha(player)
			    ClearPlayerWantedLevel(PlayerId())
				inSafe = true

				-- NOTIFY IN HERE
				
				notifIn = true
				notifOut = false
			end
		else
			if not notifOut then
				SetEntityAlpha(otherPlayerPed, 75, false)
				local hash = GetHashKey(v)
				SetPlayerInvincible(player, false)
				ClearPedLastWeaponDamage(PlayerPedId())
				SetEntityCanBeDamaged(PlayerPedId(), true)
				NetworkSetFriendlyFireOption(true)
				SetCanAttackFriendly(PlayerPedId(), true, true)
				lib.hideTextUI()
				ResetEntityAlpha(otherPlayerPed)
				ResetEntityAlpha(otherPlayerPed)
				inSafe = false 
				notifOut = true
				notifIn = false
			end
		end
	end
end)

exports('insafe', function()
	return inSafe
end)

Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(1)
	
		if inSafe or timmer > 0 then
			local player = PlayerId()
			local playerPed = PlayerPedId()
		

			local carros = GetGamePool("CVehicle")

			
			for i = 1,#carros ,1 do
				local veh = GetVehiclePedIsIn(playerPed, false)
	
				if veh ~= 0 then
					SetEntityNoCollisionEntity(carros[i], veh, true)
				else
					SetEntityNoCollisionEntity(carros[i], playerPed, true)
				end
			end	

			for _, i in ipairs(GetActivePlayers()) do
				if i ~= PlayerId() then
				  	local closestPlayerPed = GetPlayerPed(i)
		  
				  	SetEntityNoCollisionEntity(closestPlayerPed, playerPed, true)
		  
				end
			end
		else
			local player = PlayerId()
		end
	end
end)

function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = AddBlipForRadius(coords, radius)

	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 2)
	SetBlipAlpha (blip, 128)

	-- create a blip in the middle
	blip = AddBlipForCoord(coords)

	SetBlipHighDetail(blip, true)
	SetBlipSprite (blip, sprite)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

