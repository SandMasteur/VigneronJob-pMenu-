ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('sandmaster:annoncevigneron')
AddEventHandler('sandmaster:annoncevigneron', function(result)
	local _source = source  
	local xPlayers = ESX.GetPlayers()
	local name = GetPlayerName(source)
	for i=1, #xPlayers, 1 do 
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		        TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Annonce Vigneron', '', result, 'CHAR_ASHLEY')
		end
end)

ESX.RegisterServerCallback('sandVigneron:getinventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	cb({
		items = items
	})
end)

RegisterServerEvent('sandVigneron:buy')
AddEventHandler('sandVigneron:buy', function(price, item, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() >= price then
	xPlayer.removeMoney(price)
    	xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('esx:showNotification', source, "Vous avez bien reçu votre ~b~Commande", "", 1)
	end
end)
RegisterServerEvent('sandVigneron:putStockItems')
AddEventHandler('sandVigneron:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('esx_addoninventory:getSharedInventory', "society_vigneron", function(inventory)
		local item = inventory.getItem(itemName)
		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ajouter [~b~x' .. count .. '~s~] ~b~' .. item.label)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, '~r~La quantité et invalid')
		end
	end)
end)

ESX.RegisterServerCallback('sandVigneron:getStockItems', function(source, cb)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_vigneron', function(inventory)
        cb(inventory.items) 
    end)     
end)       

RegisterServerEvent('sandVigneron:getStockItem')
AddEventHandler('sandVigneron:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('esx_addoninventory:getSharedInventory', "society_vigneron", function(inventory)
		local item = inventory.getItem(itemName)
		if item.count >= tonumber(count) then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, '~r~La quantité et invalid')
		end
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez retirer [~b~x' .. count .. '~s~] ~b~' .. item.label)
	end)
end)

-- Vin

RegisterNetEvent('Recoltevin')
AddEventHandler('Recoltevin', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = 0
	local xMoney = xPlayer.getMoney()
    local item = 'raisin'
    local items = 'raisin'
	if xMoney >= price then
		xPlayer.removeMoney(price)
		xPlayer.addInventoryItem('raisin', 5)
		TriggerClientEvent('esx:showNotification', source, "Tu viens de recolter ~g~des "..items..'')
	else
		TriggerClientEvent('esx:showNotification', source, "Vous n'avez assez ~r~d\'argent")
	end
end)


RegisterNetEvent('Traitementvin')
AddEventHandler('Traitementvin', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local raisin = xPlayer.getInventoryItem('raisin').count
    local vin = xPlayer.getInventoryItem('vin').count
    if vin > 50 then
        TriggerClientEvent('esx:showNotification', source, '~r~Il semble que tu ne puisses plus porter de vin...')
    elseif raisin < 10 then
        TriggerClientEvent('esx:showNotification', source, '~r~Pas assez de ~r~Préparation raisin pour traiter...')
    else
        xPlayer.removeInventoryItem('raisin', 10)
        xPlayer.addInventoryItem('vin', 2)
        TriggerClientEvent('esx:showNotification', source, 'Vous venez d\'emballer un ~r~sac de vin')
    end
end)

RegisterServerEvent('VenteVin')
AddEventHandler('VenteVin', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local vin = 0

	for i=1, #xPlayer.inventory, 1 do
		local item = xPlayer.inventory[i]

		if item.name == "vin" then
			vin = item.count
		end
	end
    
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_vigneron', function(account)
        societyAccount = account
    end)
    
    if vin > 0 then
        xPlayer.removeInventoryItem('vin', 1)
        xPlayer.addMoney(20)
        societyAccount.addMoney(25)
        TriggerClientEvent('esx:showNotification', xPlayer.source, "~y~Vous avez gagner ~y~20$~y~ pour chaque vente d'une bouteile de vin ")
        TriggerClientEvent('esx:showNotification', xPlayer.source, "~y~La société gagne ~y~25$~y~ pour chaque vente d'une bouteille de vin ")
    else 
        TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'avez plus rien à vendre")
    end
end)

--------------------------------- ACTION PATRON


RegisterServerEvent('sandmaster:recruter')
AddEventHandler('sandmaster:recruter', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' then
  	xTarget.setJob(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "Bienvenue chez les vigneron !")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron...")
end
  else
  	if xPlayer.job2.grade_name == 'boss' then
  	xTarget.setJob2(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "Bienvenue chez les vigneron !")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron...")
end
  end
end)



RegisterServerEvent('sandmaster:promouvoir')
AddEventHandler('sandmaster:promouvoir', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été promu ")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été promu !")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('sandmaster:descendre')
AddEventHandler('sandmaster:descendre', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été rétrogradé de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été rétrogradé de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('sandmaster:virer')
AddEventHandler('sandmaster:virer', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob("unemployed", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été viré de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être viré")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2("unemployed2", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été viré de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'êtes pas Patron ou alors le joueur ne peut pas être viré")
end
  end
end)


