local zones = {}
local clientUnits = {}

local function requestUnitPurchase(unit)
    local hasUnitCost, response, type = lib.callback.await('kevin-storageunits:server:hasUnitCost', false, unit.id)
    if not hasUnitCost then
        showNotify(response, type)
        return
    end

    local input = lib.inputDialog('Storage Unit: '..unit.id, {
        {type = 'input', label = 'Password', description = 'Storage Unit Password', password = true, required = true, min = 4, max = 16},
    })
    if not input then return end
    
    local password = input[1]

    response, type = lib.callback.await('kevin-storageunits:server:purchaseStorageUnit',false, unit.id, password)
    showNotify(response, type)
end

local function openUnit(unit)
    if unit.password == nil then
        exports.ox_inventory:openInventory('stash', 'storageUnit:'..unit.id)
        return
    end

    local input = lib.inputDialog('Storage Unit: '..unit.id, {
        {type = 'input', label = 'Password', description = 'Storage Unit Password', password = true, required = true, min = 4, max = 16},
    })
    if not input then return end
    
    local password = input[1]

    local success = lib.callback.await('kevin-storageunits:server:validateStorageUnitPassword', false, unit.id, password)
    if not success then
        showNotify('Invalid Password', 'error')
        return
    end

    exports.ox_inventory:openInventory('stash', 'storageUnit:'..unit.id)
end

local function cutUnitKeyPadPower(unit)
    if not unit.owned then
        showNotify('Storage Unit Not Owned', 'error')
        return
    end

    showMinigame({
        onSuccess = function ()
            showNotify('Storage Unit Unlocked', 'success')
            unit.password = nil

            local data = { id = unit.id, unit = unit, password = nil,}
            TriggerServerEvent('kevin-storageunits:server:updateStorageUnit', data)
            Wait(1000)
            exports.ox_inventory:openInventory('stash', 'storageUnit:'..unit.id)
        end,
        onFail = function ()
            showNotify('Failed To Unlock Storage Unit', 'error')
        end
    })
end

local function resetUnitPassword(unit)
    local input = lib.inputDialog('Storage Unit: '..unit.id, {
        {type = 'input', label = 'Password', description = 'Storage Unit Password', password = true, required = true, min = 4, max = 16},
    })

    if not input then return end

    local password = input[1]
    local data = { id = unit.id, unit = unit, password = password,}
    TriggerServerEvent('kevin-storageunits:server:updateStorageUnit', data)
end

local function createUnitKeyPad(unit)
    local model = `h4_prop_h4_ld_keypad_01b`
    lib.requestModel(model)
    local keypad = CreateObject(model, clientUnits[unit.id].coords.x, clientUnits[unit.id].coords.y, clientUnits[unit.id].coords.z, false, false, false)
    SetEntityHeading(keypad, clientUnits[unit.id].coords.w)
    SetEntityAsMissionEntity(keypad, true, true)
    FreezeEntityPosition(keypad, true)
    SetModelAsNoLongerNeeded(model)
    clientUnits[unit.id].keypad = keypad
    addTargetToEntity({
        entity = clientUnits[unit.id].keypad,
        options = {
            {
                label = 'Open Storage Unit',
                onSelect = function ()
                    openUnit(unit)
                end,
                canInteract = function ()
                    return clientUnits[unit.id].owned
                end
            },
            {
                label = 'Buy Storage Unit',
                onSelect = function ()
                    requestUnitPurchase(unit)
                end,
                canInteract = function ()
                    return not clientUnits[unit.id].owned
                end
            },
            {
                label = 'Cut Lock',
                onSelect = function ()
                    cutUnitKeyPadPower(unit)
                end,
                canInteract = function ()
                    return clientUnits[unit.id].owned and unit.password and not clientUnits[unit.id].owner == QBX.PlayerData.citizenid
                end
            },
            {
                label = 'Reset Lock',
                onSelect = function ()
                    resetUnitPassword(unit)
                end,
                canInteract = function ()
                    return clientUnits[unit.id].password == nil and clientUnits[unit.id].owned and clientUnits[unit.id].owner == QBX.PlayerData.citizenid
                end
            }
        }
    })
end

local function setupStorageUnit(id, unit)
    zones[id]= lib.zones.sphere({
        coords = unit.coords,
        radius = 25.0,
        debug = false,
        onEnter = function ()
            createUnitKeyPad(unit)
        end,
        onExit = function ()
            if clientUnits[id].keypad then
                DeleteEntity(clientUnits[id].keypad)
            end
        end,
    })
end

local function getServerStorageUnits()
    local units = lib.callback.await('kevin-storageunits:server:getStorageUnits', false)
    clientUnits = units
    
    for id, unit in pairs(clientUnits) do
        setupStorageUnit(id, unit)
    end
end

RegisterNetEvent('kevin-storageunits:client:updateStorageUnit', function (unit)
    clientUnits[unit.id] = unit
    setupStorageUnit(unit.id, unit)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(500)
    getServerStorageUnits()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(500)
        getServerStorageUnits()
    end
end)

AddEventHandler('onResourceStop', function (resource)
    if resource == GetCurrentResourceName() then
        for _, unit in pairs(clientUnits) do
            if unit.keypad then
                DeleteEntity(unit.keypad)
            end
        end
    end
end)
