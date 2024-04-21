-----------------------------------------------------------------------------------------------------------------------------------------
-- vRP - PROJECT QAP - VERSION 0.0.1
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNEL
-----------------------------------------------------------------------------------------------------------------------------------------
vQAPZIN = {}
Tunnel.bindInterface("qap_project_pedagio",vQAPZIN)
vSERVER = Tunnel.getInterface("qap_project_pedagio")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD 01
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Wait(1000)
	if not HasStreamedTextureDictLoaded("qapzinscripts") then
		RequestStreamedTextureDict("qapzinscripts", true)
		while not HasStreamedTextureDictLoaded("qapzinscripts") do
			Wait(1)
		end
	end 
    while true do
		local timeDistance = 1000
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped)
		if IsPedInAnyVehicle(ped) then
			if GetPedInVehicleSeat(vehicle,-1) == ped then 
				local pedcds = GetEntityCoords(ped)
				for k,v in pairs(config.coordenadasPedagio) do
					local vehClass = GetVehicleClass(vehicle)
					local distance = #(pedcds - vector3(v[1],v[2],v[3]))
					if distance <= 100.0 then
						timeDistance = 5
						DrawMarker(9,v[1],v[2],v[3],-20.0,25.0,0.0,10.0,90.0,100.0,2.5,2.5,2.5,255,255,255,255,true,false,false,false,"qapzinscripts","qapzin_scripts",false)
						if distance <= 5.0 then
							v[5] = true

							if config.alowListVehicles[vehClass] then 
								AddText("VEICULOS DO ESTADO ESTÃO LIBERADOS.")
								v[4] = true
							else
								if not v[4] then 
									AddText("BEM-VINDO AO PEDÁGIO DA CCR! PRESSIONE ~r~E~w~ PARA REALIZAR O PAGAMENTO DA TAXA.")
									if IsControlJustPressed(1, 38) then
										local payment = vSERVER.pagarPedagio(k,vehClass,GetVehicleNumberPlateText(vehicle),GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),v[6])
										if payment then 
											v[4] = true
										end  
									end
								else
									AddText("PAGAMENTO EFETUADO! BOA VIAGEM!")
								end 
							end
						elseif not v[4] and v[5] then
							vSERVER.requestPolice(GetVehicleNumberPlateText(vehicle),GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),v[1],v[2],v[3],v[6])
							v[4] = false 
							v[5] = false
						end
					else
						v[4] = false 
						v[5] = false
					end
				end
			end 
		end
		Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION 02 
-----------------------------------------------------------------------------------------------------------------------------------------
function AddText(TextType)
	SetTextFont(4)
	SetTextScale(0.50,0.50)
	SetTextColour(255,255,255,180)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(TextType)
	DrawText(0.5,0.93)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINT F8
-----------------------------------------------------------------------------------------------------------------------------------------
print("[QAP] - PEDAGIO LOAD")