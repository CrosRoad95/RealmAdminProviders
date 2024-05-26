local pendingRequests = {};
local timeout = 10000;
local resourceCache = nil;
local realmAdminResourceName = "realmadmin-core";

function getPendingRequests()
    local pending = {};
    for requestId in pairs(pendingRequests)do
        pending[#pending + 1] = requestId;
    end
    return pending;
end

local function completeRequest(requestId, isError, message)
    if(not pendingRequests[requestId])then
        return false;
    end
    if(isError)then
        local info = pendingRequests[requestId];
        outputDebugString ("[RealmAdmin Provider Error] "..info.debug.short_src..":"..info.debug.currentline.." "..message);           
    end
    pendingRequests[requestId] = nil;
end

local function realmAdminCall(funcName, ...)
    local target = resourceCache or getResourceFromName(realmAdminResourceName);
    resourceCache = target;

    local requestId, arg1, arg2, arg3 = call(target, funcName, ...);
    pendingRequests[requestId] = {
        sentAt = getTickCount(),
        funcName = funcName,
        debug = debug.getinfo(3, "Sl")
    };
    return requestId, arg1, arg2, arg3;
end

function isDevelopment(...) return exports[realmAdminResourceName]:isDevelopment() end
function addInterfaceResource(...) return realmAdminCall("addInterfaceResource", ...) end

function removeAllPlayers(...) return realmAdminCall("removeAllPlayers", ...) end
function removeAllVehicles(...) return realmAdminCall("removeAllVehicles", ...) end

function overviewAddTextWidget(...) return realmAdminCall("overviewAddTextWidget", ...) end
function overviewSetWidgetTitle(...) return realmAdminCall("overviewSetWidgetTitle", ...) end

function playersAddRowButtonAction(...) return realmAdminCall("playersAddRowButtonAction", ...) end
function playersAddCustomColumn(...) return realmAdminCall("playersAddCustomColumn", ...) end
function playersRemoveCustomColumn(...) return realmAdminCall("playersRemoveCustomColumn", ...) end
function playersAddPlayer(...) return realmAdminCall("playersAddPlayer", ...) end
function playersRemovePlayer(...) return realmAdminCall("playersRemovePlayer", ...) end
function playersSetData(...) return realmAdminCall("playersSetData", ...) end
function playersSetPlayerName(...) return realmAdminCall("playersSetPlayerName", ...) end

function vehiclesAddVehicle(...) return realmAdminCall("vehiclesAddVehicle", ...) end
function vehiclesAddAllVehicles(...) return realmAdminCall("vehiclesAddAllVehicles", ...) end
function vehiclesSetKinds(...) return realmAdminCall("vehiclesSetKinds", ...) end

function resourcesAddAllResources(...) return exports[realmAdminResourceName]:resourcesAddAllResources() end
function resourcesAddResource(...) return realmAdminCall("resourcesAddResource", ...) end
function resourcesRemoveResources(...) return realmAdminCall("resourcesRemoveResources", ...) end
function resourcesRemoveResource(...) return realmAdminCall("resourcesRemoveResource", ...) end
function resourcesSetResourceState(...) return realmAdminCall("resourcesSetResourceState", ...) end
function resourcesConfigureDefaultListener(...) return exports[realmAdminResourceName]:resourcesConfigureDefaultListener() end

function statisticsPlayerCountReport(...) return realmAdminCall("statisticsPlayerCountReport", ...) end

function isSystemCaller(...) return realmAdminCall("isSystemCaller", ...) end
function isRegisteredAsInterfaceResource(...) return realmAdminCall("isRegisteredAsInterfaceResource", ...) end

addEventHandler("onRealmAdminError", resourceRoot, function(source, requestId, message)
    completeRequest(requestId, true, message);
end)

addEventHandler("onRealmAdminSuccess", resourceRoot, function(source, requestId, message)
    completeRequest(requestId, false, message);
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(function()
        local now = getTickCount();
        for requestId, info in pairs(pendingRequests)do
            if(now - info.sentAt > timeout)then
                completeRequest(requestId, true, "Call timeout while calling '"..info.funcName.."'");
            end
        end
    end, 3000, 0)
end)