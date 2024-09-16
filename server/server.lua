local config = require 'shared.config'
local serverUnits = {}

local function checkSqlSet()
    local success = pcall(MySQL.scalar.await, 'SELECT 1 FROM storage_units')

    if not success then
        MySQL.query([[CREATE TABLE `storage_units` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
		    `owner` VARCHAR(255) NOT NULL,
            `owned` TINYINT(1) NOT NULL DEFAULT 0,
            `password` VARCHAR(255) DEFAULT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;]])
    end

    return true
end

local function setUpStorageUnits()
    local storageUnits = MySQL.query.await('SELECT * FROM storage_units')
    for id, unit in pairs(config.storageUnits) do
        serverUnits[id] = {
            id = id,
            owner = nil,
            owned = false,
            password = nil,
            inventory = unit.inventory,
            cost = unit.cost,
            coords = unit.coords,
        }
        
        for _, storageUnit in pairs(storageUnits) do
            if storageUnit.id == id then
                serverUnits[id].owner = storageUnit.owner
                serverUnits[id].owned = storageUnit.owned
                serverUnits[id].password = storageUnit.password
                break
            end
        end
        
        exports.ox_inventory:RegisterStash('storageUnit:'..id, unit.inventory.label, unit.inventory.slots, unit.inventory.maxWeight, nil, nil, vector3(unit.coords))
    end
end

local function hasUnitCost(source, unitId)
    if not config.storageUnits[unitId] then
        return false, 'Invalid Storage Unit', 'error'
    end
    
    local player = Framework:GetPlayer(source)
    if player.PlayerData.money.cash < config.storageUnits[unitId].cost then
        return false, 'Insufficient Funds', 'error'
    end

    return true
end

local function requestUnitPurchase(source, unitId, password)
    local unit = serverUnits[unitId]
    local player = Framework:GetPlayer(source)
    local citizenId = player.PlayerData.citizenid
    if not unit then
        return 'Invalid Storage Unit', 'error'
    end

    if unit.owned then
        return 'Storage Unit Already Owned', 'error'
    end

    local success, response = exports.ox_inventory:RemoveItem(source, 'money', config.storageUnits[unitId].cost)
    if not success then
        return 'Insufficient Funds', 'error'
    end

    MySQL.query('INSERT INTO storage_units (id, owner, owned, password) VALUES (@id, @owner, @owned, @password)', {
        ['@id'] = unitId,
        ['@owner'] = citizenId,
        ['@owned'] = true,
        ['@password'] = password,
    })
    serverUnits[unitId].owned = true
    serverUnits[unitId].owner = citizenId
    serverUnits[unitId].password = password
    TriggerClientEvent('kevin-storageunits:client:updateStorageUnit', -1, serverUnits[unitId])
    return 'Storage Unit Purchased', 'success'
end

local function validataUnitPassword(source, unitId, password)
    local unit = serverUnits[unitId]
    if not unit then return end

    if unit.password == password then
        return true
    end

    return false
end

lib.callback.register('kevin-storageunits:server:getStorageUnits', function (source)
    return serverUnits
end)

lib.callback.register('kevin-storageunits:server:hasUnitCost', function (source, unitId)
    return hasUnitCost(source, unitId)
end)

lib.callback.register('kevin-storageunits:server:purchaseStorageUnit', function (source, unitId, password)
    return requestUnitPurchase(source, unitId, password)
end)

lib.callback.register('kevin-storageunits:server:validateStorageUnitPassword', function (source, unitId, password)
    return validataUnitPassword(source, unitId, password)
end)

RegisterNetEvent('kevin-storageunits:server:updateStorageUnit', function (data)
    if not serverUnits[data.id] then return end
    local player = Framework:GetPlayer(source)
    local citizenId = player.PlayerData.citizenid
    if serverUnits[data.id].owner ~= citizenId then
        return
    end
    
    serverUnits[data.id] = data.unit

    serverUnits[data.id].password = data.password
    MySQL.query('UPDATE storage_units SET password = @password WHERE id = @id', {
        ['@id'] = data.id,
        ['@password'] = data.password,
    })
    TriggerClientEvent('kevin-storageunits:client:updateStorageUnit', -1, serverUnits[data.id])
end)

CreateThread(function ()
    local sqlValid = checkSqlSet()
    if sqlValid then
        setUpStorageUnits()
    end
end)