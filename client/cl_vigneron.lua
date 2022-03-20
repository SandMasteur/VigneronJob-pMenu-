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

local Notification = nil

function NotificationClear(msg)
if Notification then
RemoveNotification(Notification)
end
SetNotificationTextEntry("STRING")
AddTextComponentSubstringPlayerName(msg)
Notification = DrawNotification(0, 1)
end
 
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job
end)


f6vigneron = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "vigneron", world = true},
    Data = { currentMenu = "Action", GetPlayerName() },
    Events = {
        onSelected = function(self, _, sandmaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            if sandmaster.name == "Effectuer une annonce" then 
                local result = KeyboardInput('', '', 255)
                if result ~= nil then 
                    TriggerServerEvent('sandmaster:annoncevigneron', result)
                end
                
            elseif sandmaster.name == "Effectuer une facture" then 
                ExecuteCommand("e notepad")
                Citizen.Wait(1500)
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Personne autour')
                else
                    local amount = KeyboardInput('Veuillez saisir le montant de la facture', '', 4)
                    TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_vigneron', 'vigneron', amount)
                end  
            end
    end
    },
    Menu = {
        ["Action"] = {
            b = {
                {name = "Effectuer une annonce", ask = ">", askX = true},
                {name = "Effectuer une facture", ask = ">", askX = true},
            }
        }
    }
}

RegisterKeyMapping('vigneron', 'Menu vigneron', 'keyboard', 'F6')

RegisterCommand('vigneron', function()
    if ESX.GetPlayerData().job.name == "vigneron" then 
        CreateMenu(f6vigneron)
    end    
end)

stockvigneron = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Vestiare vigneron", world = true },
    Data = { currentMenu = "Action", GetPlayerName() },
    Events = {
        onSelected = function(self, _, sandmaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
                if self.Data.currentMenu == "Déposer un objet" then 
                    local result = KeyboardInput('Nombre', '', 10)
                    if result ~= nil then
                        TriggerServerEvent('sandVigneron:putStockItems', sandmaster.value, result)
                        OpenMenu("Action")
                    end 
                elseif self.Data.currentMenu == "Retirer un objet" then 
                    local result = KeyboardInput('Nombre :', '', 10)
                    if result ~= nil then 
                        TriggerServerEvent('sandVigneron:getStockItem', sandmaster.value, result)
                        OpenMenu("Action")
                    end  
                end

                if sandmaster.name == "Déposer un objet" then 
                    stockvigneron.Menu["Déposer un objet"].b = {}
                    ESX.TriggerServerCallback('sandVigneron:getinventory', function(sandmaster)
                        for i=1, #sandmaster.items, 1 do
                            local item = sandmaster.items[i]
                            if item.count > 0 then
                                table.insert(stockvigneron.Menu["Déposer un objet"].b,  {name = item.label .. ' x' .. item.count, askX = true, value = item.name})
                            end
                        end
                        OpenMenu("Déposer un objet")
                    end)
                elseif sandmaster.name == "Reprendre vos affaires" then
                        NotificationClear('~r~Vous êtes plus en tenue')
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                        end)
                        SetPedArmour(playerPed, 0)	   
                elseif sandmaster.name == "Vestiaires" then
                    OpenMenu("Vestiaires")
                elseif sandmaster.name == "Tenue Serveur" then
                    NotificationClear('~b~Vous êtes en tenue')
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        if skin.sex == 0 then
                            TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.vigneron_tenue.male)
                        elseif skin.sex == 1 then
                            TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.vigneron_tenue.female)
                        end
                    end)
                elseif sandmaster.name == "Retirer un objet" then 
                    stockvigneron.Menu["Retirer un objet"].b = {}
                    ESX.TriggerServerCallback('sandVigneron:getStockItems', function(items)  
                        for i=1, #items, 1 do 
                            if items[i].count > 0 then
                                table.insert(stockvigneron.Menu["Retirer un objet"].b, {name = 'x' .. items[i].count .. ' ' .. items[i].label, askX = true, value = items[i].name})
                            end
                        end
                    OpenMenu('Retirer un objet')
                    end)
                end

       
        end,
    },
    Menu = {
        ["Action"] = {
            b = {
                {name = "Déposer un objet", ask = ">", askX = true, id = 33},
                {name = "Retirer un objet", ask = ">", askX = true, id = 33},
                {name = "Vestiaires", ask = ">", askX = true, id = 33}
            }
        },
        ["Vestiaires"] = {
            b = {
                {name = "Tenue Serveur", ask = ">", askX = true},
                {name = "Reprendre vos affaires", ask = ">", askX = true}
            }
        },
        ["Déposer un objet"] = { b = {} },
        ["Retirer un objet"] = { b = {} },
    }
}

Citizen.CreateThread(function()
    RequestModel(GetHashKey("mp_m_waremech_01"))
    while not HasModelLoaded(GetHashKey("mp_m_waremech_01")) do 
        Wait(1) 
    end
    ped = CreatePed(4, "mp_m_waremech_01", Config.Pedgaragevigneron.x, Config.Pedgaragevigneron.y, Config.Pedgaragevigneron.z, false, true)
    FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
    SetEntityHeading(ped, Config.Pedgaragevigneron.a) 
    SetBlockingOfNonTemporaryEvents(ped, true)
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
            local diststockvigneron = Vdist(plyCoords, -1882.32, 2070.61, 141.01-0.93)
            local distgaragevigneron = Vdist(plyCoords, -1924.23, 2051.18, 140.82-0.93)
                if  diststockvigneron < 8 or distgaragevigneron < 8 then
                    time = 0
                    DrawMarker(25, -1882.32, 2070.61, 141.01-0.93, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.8, 0.8, 0.2, 52, 152, 219, 120, false, false, false, false) 
                end
                if diststockvigneron <= 1 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder au ~b~stock")
                    if IsControlJustPressed(1,51) then
                        CreateMenu(stockvigneron)
                    end
                elseif distgaragevigneron <= 1.5 then 
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder au ~b~garage")
                    if IsControlJustPressed(1,51) then
                        
                        opengaragevigneron()
                    end
                end
        end
        Citizen.Wait(time)
    end
end)


garagevigneron = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Garage", world = true },
    Data = { currentMenu = "Action", GetPlayerName() },
    Events = {
        onSelected = function(self, _, sandmaster, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            if self.Data.currentMenu == "Action" and sandmaster.name ~= "Ranger le vehicule" then 
                TriggerEvent('esx:deleteVehicle')  
                ESX.Game.SpawnVehicle(sandmaster.value, {x = Config.Spawngaragevigneron.x,y = Config.Spawngaragevigneron.y, z =  Config.Spawngaragevigneron.z + 1}, Config.Spawngaragevigneron.a, function(vehicle)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)    
                    local plate = GetVehicleNumberPlateText(vehicle)
                    TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)        
				end)  
            end 
            if sandmaster.name == "Ranger le vehicule" then 
                TriggerEvent('esx:deleteVehicle')  
            end 
        end,
    },
    Menu = {
        ["Action"] = {
            b = {
                {name = "Ranger le vehicule", ask = ">", askX = true, id = 33},
            }
        },
        ["Ranger le vehicule"] = { b = {} },
    }
}

function opengaragevigneron()
    garagevigneron.Menu["Action"].b = {}
    for k, v in pairs(Config.carsvigneron) do
        table.insert(garagevigneron.Menu["Action"].b, {name = v.label, value = v.name})
    end
    table.insert(garagevigneron.Menu["Action"].b, {name = "Ranger le vehicule"})
    CreateMenu(garagevigneron)
end 


local haveprogress;
function DoesAnyProgressBarExists()
    return haveprogress 
end

function DrawNiceText(Text,Text3,Taille,Text2,Font,Justi,havetext)
    SetTextFont(Font)
    SetTextScale(Taille,Taille)
    SetTextColour(255,255,255,255)
    SetTextJustification(Justi or 1)
    SetTextEntry("STRING")
        if havetext then 
            SetTextWrap(Text,Text+.1)
        end;
        AddTextComponentString(Text2)
    DrawText(Text,Text3)
end

local petitpoint = {".","..","...",""}
function getObjInSight()
	local ped = GetPlayerPed(-1)
	local pos = GetEntityCoords(ped) + vector3(.0, .0, -.4)
	local entityWorld = GetOffsetFromEntityInWorldCoords(ped, 0.0, 20.0, 0.0) + vector3(.0, .0, -.4)
	local rayHandle = StartShapeTestRay(pos, entityWorld, 16, ped, 0)
	local _, _, _, _, ent = GetRaycastResult(rayHandle)

	if not IsEntityAnObject(ent) then
		return
	end
	return ent
end

function createProgressBar(Text,r,g,b,a,Timing,NoTiming)
    if not Timing then 
        return 
    end
    killProgressBar()
    haveprogress = true
    Citizen.CreateThread(function()
        local Timing1, Timing2 = .0, GetGameTimer() + Timing
        local E, Timing3 = ""
        while haveprogress and (not NoTiming and Timing1 < 1) do
            Citizen.Wait(0)
            if not NoTiming or Timing1 < 1 then 
                Timing1 = 1-((Timing2 - GetGameTimer())/Timing)
            end
            if not Timing3 or GetGameTimer() >= Timing3 then
                Timing3 = GetGameTimer()+500;
                E = petitpoint[string.len(E)+1] or ""
            end;
            DrawRect(.5,.875,.15,.03,0,0,0,100)
            local y, endroit=.15-.0025,.03-.005;
            local chance = math.max(0,math.min(y,y*Timing1))
            DrawRect((.5-y/2)+chance/2,.875,chance,endroit,r,g,b,a) -- 0,155,255,125
            DrawNiceText(.5,.875-.0125,.3,(Text or"Action en cours")..E,0,0,false)
        end;
        killProgressBar()
    end)
end

function killProgressBar()
    haveprogress = nil 
end


--------------------- ACTION PATRON

local bossvigneron = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {245 ,207 ,14}, Title = "Action Patron", world = true },
    Data = { currentMenu = "Action", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
                if btn.name == "Retirer de l'Argent" then
                          local amount = KeyboardInput("Montant", "", 10)
                          amount = tonumber(amount)
                          if amount == nil then
                            ESX.ShowNotification('Montant invalide')
                          else
                              TriggerServerEvent('esx_society:withdrawMoney', 'vigneron', amount)
                              RefreshvigneronMoney('vigneron')	
                          end
                elseif btn.name == "Déposer de l'Argent" then
                          local amount = KeyboardInput("Montant", "", 10)
                          amount = tonumber(amount)
                          if amount == nil then
                            ESX.ShowNotification('Montant invalide')
                          else
                              TriggerServerEvent('esx_society:depositMoney', 'vigneron', amount)
                              RefreshvigneronMoney('vigneron')
                          end
                elseif btn.name == "Recruter" then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('sandmaster:recruter', "vigneron", false, GetPlayerServerId(closestPlayer))
                         else
                            ESX.ShowNotification('Aucun joueur à proximité')
                        end 
                elseif btn.name == "Promouvoir" then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('sandmaster:promouvoir', "vigneron", false, GetPlayerServerId(closestPlayer))
                         else
                            ESX.ShowNotification('Aucun joueur à proximité')
                        end 
                elseif btn.name == "Rétrograder" then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('sandmaster:descendre', "vigneron", false, GetPlayerServerId(closestPlayer))
                         else
                            ESX.ShowNotification('Aucun joueur à proximité')
                         end
                elseif btn.name == "Virer" then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('sandmaster:virer', "vigneron", false, GetPlayerServerId(closestPlayer))
                         else
                            ESX.ShowNotification('Aucun joueur à proximité')
                        end 			
                    end 
                end,
            },   

Menu = {
["Action"] = {
    b = {
        {name = "Argent société :", ask = '$0' , askX = true,},
        {name = "Retirer de l'Argent", ask = '>>', askX = true},
        {name = "Déposer de l'Argent", ask = '>>', askX = true},
        {name = "Virer", ask = '>>', askX = true},
        {name = "Recruter", ask = '>>', askX = true},
        {name = "Promouvoir", ask = '>>', askX = true},
        {name = "Rétrograder", ask = '>>', askX = true},
    }
}
}
}

Citizen.CreateThread(function()
while true do
    Citizen.Wait(0)
    for k,v in pairs(Config.bossvigneron) do                           
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v.x,v.y,v.z ) <= 1.5 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'vigneron' and ESX.PlayerData.job and ESX.PlayerData.job.name == 'vigneron' and ESX.PlayerData.job.grade_name == 'boss' then
            DrawMarker(25, -1899.07, 2068.77, 141.02-0.93, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.8, 0.8, 0.2, 52, 152, 219, 120, false, false, false, false) 
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour accéder à ~b~l'action patron")
            if IsControlJustPressed(1,38) then
                RefreshvigneronMoney('vigneron')
                ExecuteCommand('e type')         
                CreateMenu(bossvigneron)      
                Citizen.Wait(3000)
                ClearPedTasksImmediately(PlayerPedId())                
            end
        end
    end
end
end)

----------------------- REFRESHMONEY 

function RefreshvigneronMoney(p)
    
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then  
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdatesocietyvigneronMoney(money , p)
        end, ESX.PlayerData.job.name)
    end
   
end
    
function UpdatesocietyvigneronMoney(money, p)
    societyvigneronmoney = money 
    if p ~= nil then  
        bossvigneron.Menu.Action.b[1].ask =  "$".. societyvigneronmoney 
    end
end
