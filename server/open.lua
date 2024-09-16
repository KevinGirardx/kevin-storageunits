Framework = nil

if GetResourceState('qbx_core') == 'started' then
    Framework = exports.qbx_core
    return Framework
elseif GetResourceState('qb-core') == 'started' then
    Framework = exports['qb-core']:GetCoreObject()
    return Framework
end