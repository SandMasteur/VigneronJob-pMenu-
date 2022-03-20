ESX = nil
local PlayerData = {}
local interval = 200


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0) 
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end 
	PlayerData = ESX.GetPlayerData() 
end) 
 
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job
end)

RecolteVin = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Recolte Raisin", world = true },
    Data = { currentMenu = "Recolte vin"}, 
    Events = {
        onSelected = function(self, _, sandamaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            if sandamaster.name == "Recolter vin" then
                Recoltevin()
            end
        end
    },
    Menu = {
        ["Recolte vin"] = {
            b = {
                {name = "Recolter vin", ask = "", askX = true}
            }
        }
    }
}
function Recoltevin()
    local playerPed = PlayerPedId()
    createProgressBar("Récolte en cours", 0, 255, 185, 120, 6000)
    ExecuteCommand("e pickup")
    Citizen.Wait(6000)
    TriggerServerEvent('Recoltevin')
    ClearPedTasksImmediately(playerPed)
end
function Traitementvin()
    local playerPed = PlayerPedId()
    createProgressBar("Traitement en cours", 0, 255, 185, 120, 10000)
    ExecuteCommand("e mechanic")
    Citizen.Wait(10000)
    TriggerServerEvent('Traitementvin')
    ClearPedTasksImmediately(playerPed)
end
function VenteCo()
    createProgressBar("Vente en cours", 0, 255, 185, 120, 12000)
    ExecuteCommand("e atm")
    Citizen.Wait(12000)
    TriggerServerEvent('VenteVin')
    ClearPedTasksImmediately(playerPed)
end


TraitementVin = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Traitement vin", world = true },
    Data = { currentMenu = "Traitement vin"}, 
    Events = {
        onSelected = function(self, _, sandamaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            if sandamaster.name == "Traitement vin" then
                Traitementvin()
            end
        end
    },
    Menu = {
        ["Traitement vin"] = {
            b = {
                {name = "Traitement vin", ask = "~g~20g > 40g", askX = true},
            }
        }
    }
}

VenteVin = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Vente Vin", world = true },
    Data = { currentMenu = "Vente vin"}, 
    Events = {
        onSelected = function(self, _, sandamaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            if sandamaster.name == "Vente vin" then
                VenteCo()
            end
        end
    },
    Menu = {
        ["Vente vin"] = {
            b = {
                {name = "Vente vin", ask = "~g~20g > 40g", askX = true},
            }
        }
    }
}


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()  
    while true do
        time = 200
            if PlayerData.job.name == "vigneron" then 
                time = 350
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local recolte = Vdist(plyCoords, -1795.87, 2225.63, 89.41-0.93)
            local traitement = Vdist(plyCoords, 1224.5, 1870.82, 78.88-0.93)
            local vente = Vdist(plyCoords, 1929.58, 4635.93, 40.44-0.93)
            if traitement < 8 or recolte < 8 or vente < 8  then
                    time = 0
                    DrawMarker(25, -1795.87, 2225.63, 89.41-0.93, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.8, 0.8, 0.2, 52, 152, 219, 120, false, false, false, false) 
                    DrawMarker(25, 1224.5, 1870.82, 78.88-0.93, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.8, 0.8, 0.2, 52, 152, 219, 120, false, false, false, false)  
                    DrawMarker(25, 1929.58, 4635.93, 40.44-0.93, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.8, 0.8, 0.2, 52, 152, 219, 120, false, false, false, false)  
                end
                if recolte <= 1 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder à la ~b~récolte")
                    if IsControlJustPressed(1,51) then
                        CreateMenu(RecolteVin)
                    end
                elseif vente <= 2 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder à la ~b~vente")
                    if IsControlJustPressed(1,51) then
                        CreateMenu(VenteVin)
                    end
                elseif traitement <= 1.5 then 
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder au ~b~Traitement Vin")
                        if IsControlJustPressed(1,51) then
                            CreateMenu(TraitementVin)
                        end
                    end
        end
        Citizen.Wait(time)
    end
end)


-----     -931.95, -1177.47, -5.03