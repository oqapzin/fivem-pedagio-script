-----------------------------------------------------------------------------------------------------------------------------------------
-- vRP - PROJECT QAP 
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNEL
-----------------------------------------------------------------------------------------------------------------------------------------
vQAPZIN = {}
Tunnel.bindInterface("qap_project_pedagio",vQAPZIN)
vCLIENT = Tunnel.getInterface("qap_project_pedagio")
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION PAGAR PEDAGIO
-----------------------------------------------------------------------------------------------------------------------------------------
function vQAPZIN.pagarPedagio(pedagioKey,vehClass,vehPlate,vehName,pedagio)
	local source = source
	local user_id = vRP.getUserId(source)

		if vRP.hasGroup(user_id,config.policiaPermissao) then 
			TriggerClientEvent("Notify",source,"sucesso","Policial Militar, você está liberado! Disponha da CCR.",2000)
			return true
		end 

		local vehiclePice = config.precoPagoPorTipoVeiculo[vehClass] or false 
		if vehiclePice then
			if false then
				TriggerClientEvent("Notify",source,"sucesso","Pedágio pago com sucesso. Boa viagem!",2000)
			else
				TriggerClientEvent("Notify",source,"vermelho","Dinheiro insuficiente.",5000)
				return false 
			end

			createLog(vehPlate,vehName,pedagio,"PAGAMENTO")

			return true, pedagioKey
		else
			print("[QACODES] Veiculo Model:"..vehClass.." não está cadastrado.")
		end 

		return false
	end 
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION REQUISITAR POLICIA
-----------------------------------------------------------------------------------------------------------------------------------------
function vQAPZIN.requestPolice(vehPlate,vehName,pedagioX,pedagioY,pedagioZ,pedagio)
	local source = source
	local user_id = vRP.getUserId(source)

	if vRP.hasGroup(user_id,config.policiaPermissao) then 
		TriggerClientEvent("Notify",source,"sucesso","Policial Militar, você está liberado! Disponha da CCR.",2000)
		return
	end 

	local vehPlateOwner = vRP.userPlate(vehPlate)

	if vehPlateOwner ~= user_id then 
		user_id = vehPlateOwner
		source = vRP.userSource(vehPlateOwner)
	end 

	vRP.addFines(user_id,2500)
	TriggerClientEvent("Notify",source,"azul","Você foi autuado em R$2500 por ultrapassar o pedágio "..pedagio,2000)

	local copAmount = vRP.numPermission(config.policiaPermissao)
	for k,v in pairs(copAmount) do
		async(function()
			TriggerClientEvent("NotifyPush",v,{ time = os.date("%H:%M"), code = "Ocorrência - Pedágio "..pedagio, title = "Veiculo não pagou o pedágio", x = pedagioX, y = pedagioX, z = pedagioY, vehicle = vehName.." - "..vehPlate, rgba = {140,35,35} })
		end)
	end
	createLog(vehPlate,vehName,pedagio,"FALTA DE PAGAMENTO")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
function createLog(vehPlate,vehName,pedagio,title)
	local log = {
		{
			["color"] = "14352384",
			["title"] = title or "",
			["description"] = "***[MODELO]: "..vehName.."\n[PLACA]: "..vehPlate.." "..os.date("\n[DATA]: %d/%m/%Y [HORA]: %Hh%Mmin%S").."***",
			["footer"] = {
				["text"] = "CCR - "..pedagio.."",
				["icon_url"] = "https://cdn.discordapp.com/attachments/780615034816036897/866544993552433192/qapzin_scripts.png",
			},
		}
	}	
	if config.pedagioLogs[pedagio] then 
		PerformHttpRequest(config.pedagioLogs[pedagio], function(err, text, headers) end, 'POST', json.encode({username = "QACODES", embeds = log}), { ['Content-Type'] = 'application/json' })
	else
		print("[QACODES] webhook "..pedagio.." está sem configuração.")
	end 
end 