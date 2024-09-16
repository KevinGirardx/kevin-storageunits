-- This file is used to handle the different UI systems for kevin Scripts
local config = require 'shared.config'

function showTextUi(text) -- feel free to implement your own text ui system here
    if config.textUi == 'ox' then
        lib.showTextUI(text, { position = 'left-center' })
    elseif config.textUi == 'jg' then
        exports['jg-textui']:DrawText(text)
    elseif config.textUi == 'qb' then
        exports['qb-core']:DrawText(text)
    end
end

function hideTextUi()
    if config.textUi == 'ox' then
        lib.hideTextUI()
    elseif config.textUi == 'jg' then
        exports['jg-textui']:HideText()
    elseif config.textUi == 'qb' then
        exports['qb-core']:HideText()
    end
end

function showNotify(text, type) -- feel free to implement your own notify system here
    if config.notify == 'ox' then
        lib.notify({ description = text, type = type })
    elseif config.notify == 'qb' then
        exports['qb-core']:GetCoreObject().Functions.Notify(text, type)
    end
end

local function addTargetOptions(options)
    local targetOptions = {}
    if config.target.resource == 'ox' then
        for i = 1, #options do
            targetOptions[i] = {
                label = options[i].label,
                onSelect = function (data)
                    options[i].onSelect(data)
                end,
                canInteract = options[i].canInteract,
                distance = config.target.distance,
            }
        end
    elseif config.target.resource == 'qb' then
        for i = 1, #options do
            targetOptions[i] = {
                icon = options[i].icon,
                label = options[i].label,
                action = function(entity)
                    options[i].onSelect(entity)
                end,
                canInteract = options[i].canInteract,
            }
        end
    elseif config.target.resource == 'interact' then
        for i = 1, #options do
            targetOptions[i] = {
                label = options[i].label,
                action = function(entity, coords, args)
                    options[i].onSelect()
                end,
                canInteract = options[i].canInteract,
            }
        end
    end
    return targetOptions
end

function addTargetToEntity(options) -- feel free to implement your own target system here
    -- options = options.entity, options.label, optins.distance, options.icon, options.onSelect, options.canInteract (if you want to add your own target/interaction)
    if config.target.resource == 'ox' then
        exports.ox_target:addLocalEntity(options.entity, addTargetOptions(options.options))
    elseif config.target.resource == 'qb' then
        exports['qb-target']:AddTargetEntity(options.entity, {
            options = addTargetOptions(options.options),
            distance = config.target.distance,
        })
    elseif config.target.resource == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = options.entity,
            interactDst = config.target.distance,
            offset = vec3(0.0, 0.0, 1.0),
            ignoreLos = true, -- optional ignores line of sight
            options = addTargetOptions(options.options),
        })
    end
end

function progressBar(data) -- feel free to implement your own progress bar system here
    if config.progressBar == 'ox_circle' then
        if lib.progressCircle({
            label = data.label, duration = data.duration, position = data.position, useWhileDead = false,
            canCancel = true,
            disable = { move = true,combat = true,sprint = true,car = true,},
            anim = { dict = data.anim.dict, clip = data.anim.clip, data.anim.scenario, data.flag},
        }) then
            data.onSuccess()
        else
            data.onCancel()
        end
    elseif config.progressBar == 'ox_bar' then
        if lib.progressBar({
            label = data.label, duration = data.duration, position = data.position, useWhileDead = false,
            canCancel = true,
            disable = { move = true,combat = true,sprint = true,car = true,},
            anim = { dict = data.anim.dict, clip = data.anim.clip, data.anim.scenario, data.flag},
        }) then
            data.onSuccess()
        else
            data.onCancel()
        end
    end
end

function showMinigame(data) -- feel free to implement your own minigame system here
    if config.minigame == 'ox' then
        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 1}, 'hard'}, {'1', '2', '3', '4'})
        if success then
            data.onSuccess()
        else
            data.onFail()
        end
    end
end