-----------------------------------------
-- seven#1169
-----------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local hora = 0
local minuto = 0
local mes = ""
local diadomes = 0
local distancia = 10.001
local voz = "Normal"
local sBuffer = {}
local vBuffer = {}
local discord = false
local CintoSeguranca = false
local ExNoCarro = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATA E HORA
-----------------------------------------------------------------------------------------------------------------------------------------
function CalculateTimeToDisplay()
	hora = GetClockHours()
	minuto = GetClockMinutes()
	if hora <= 9 then
		hora = "0" .. hora
	end
	if minuto <= 9 then
		minuto = "0" .. minuto
	end
end

function CalculateDateToDisplay()
	mes = GetClockMonth()
	diadomes = GetClockDayOfMonth()
	if mes == 0 then
		mes = "01"
	elseif mes == 1 then
		mes = "02"
	elseif mes == 2 then
		mes = "03"
	elseif mes == 3 then
		mes = "04"
	elseif mes == 4 then
		mes = "05"
	elseif mes == 5 then
		mes = "06"
	elseif mes == 6 then
		mes = "07"
	elseif mes == 7 then
		mes = "08"
	elseif mes == 8 then
		mes = "09"
	elseif mes == 9 then
		mes = "10"
	elseif mes == 10 then
		mes = "11"
	elseif mes == 11 then
		mes = "12"
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CSS
-----------------------------------------------------------------------------------------------------------------------------------------
local css = [[
	.div_informacoes {
		bottom: 8%;
		right: 2%;
		position: absolute;
	}
	.texto {
		margin-right: 12px;
		height: 32px;
		font-family: Arial;
		font-size: 13px;
		text-shadow: 1px 1px #000;
		color: rgba(255,255,255,0.5);
		text-align: right;
		line-height: 16px;
		float: left;
	}
	.texto b {
		color: rgba(255,255,255,0.7);
	}
	.div_discord {
		bottom: 92%;
		right: 45%;
		position: absolute;
		float: center;
	}
]]
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("discord",function(source,args)
	if discord then
		vRP._removeDiv("discord")
		discord = false
	else
		vRP._setDiv("discord",css,"<div class=\"texto\"> <b> discord.gg/VMmcGxk </b></div>")
		discord = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerSpawned",function()
	NetworkSetTalkerProximity(distancia)
	vRP._setDiv("informacoes",css,"")
end)

function UpdateOverlay()
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped,false))
	local rua = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
	CalculateTimeToDisplay()
	CalculateDateToDisplay()
	NetworkClearVoiceChannel()
	NetworkSetTalkerProximity(distancia)

	vRP._setDivContent("informacoes","<div class=\"texto\"> Voz <b>"..voz.."</b> </br></br>Rua <b>"..rua.."</b></br> Data: <b>"..diadomes.."/"..mes.."</b> - Horário <b>"..hora..":"..minuto.."</b> </div>")
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		UpdateOverlay()
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local ped = PlayerPedId()
		local ui = GetMinimapAnchor()

		local health = GetEntityHealth(ped)-100
		local varSet1 = (ui.width-0.1182)*(health/100)

		local armor = GetPedArmour(ped)
		if armor > 100.0 then armor = 100.0 end
		local varSet2 = (ui.width-0.0735)*(armor/100)

		if IsPedInAnyVehicle(ped) then
			SetRadarZoom(1000)
			DisplayRadar(true)
			local carro = GetVehiclePedIsIn(ped,false)

			if CintoSeguranca then
			end
		else
			CintoSeguranca = false
			DisplayRadar(false)
		end

		drawRct(ui.x,ui.bottom_y-0.017,ui.width,0.015,30,30,30,255)
		drawRct(ui.x+0.002,ui.bottom_y-0.014,ui.width-0.0735,0.009,50,100,50,255)
		drawRct(ui.x+0.002,ui.bottom_y-0.014,varSet1,0.009,80,156,81,255)
		drawRct(ui.x+0.0715,ui.bottom_y-0.014,ui.width-0.0735,0.009,40,90,117,255)
		drawRct(ui.x+0.0715,ui.bottom_y-0.014,varSet2,0.009,66,140,180,255)

		if IsControlJustPressed(1,212) and GetEntityHealth(ped) > 100 then
			if distancia == 3.001 then
				voz = "Normal"
				distancia = 10.001
			elseif distancia == 10.001 then
				voz = "Longe"
				distancia = 25.001
			elseif distancia == 25.001 then
				voz = "Muito Longe"
				distancia = 50.001
			elseif distancia == 50.001 then
				voz = "Sussurro"
				distancia = 3.001
			end
			UpdateOverlay()
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x+width/2,y+height/2,width,height,r,g,b,a)
end

function drawTxt(x,y,scale,text,r,g,b,a)
	SetTextFont(4)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end