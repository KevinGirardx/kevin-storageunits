Framework = nil

if GetResourceState('qbx_core') == 'started' then
    Framework = exports.qbx_core
elseif GetResourceState('qb-core') == 'started' then
    Framework = exports['qb-core']:GetCoreObject()
end

function getPlayerCitizenId(source)
    if GetResourceState('qbx_core') == 'started' then
        return Framework:GetPlayer(source).PlayerData.citizenid
    elseif GetResourceState('qb-core') == 'started' then
        return Framework.Functions.GetPlayer(source).PlayerData.citizenid
    end
end

function getPlayerCash(source)
    if GetResourceState('qbx_core') == 'started' then
        return Framework:GetPlayer(source).PlayerData.money.cash
    elseif GetResourceState('qb-core') == 'started' then
        return Framework.Functions.GetPlayer(source).PlayerData.money.cash
    end
end