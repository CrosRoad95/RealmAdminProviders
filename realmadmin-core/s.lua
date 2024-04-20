local id = 0;
local requestId = 0;
local refId = 0;
local refByUserData = {}
local userDataByRef = {}
local providers = {}

function addInterfaceResource(name, description)
    local resource = sourceResource or getThisResource();
    if(providers[resource])then
        error("Zasób: '"..getResourceName(resource).."' jest już zarejestrowany jako dostawca funkcjonalności.");
    end

    if(type(name) ~= "string")then
        error("Nazwa zasobu musi być string'iem");
    end
    if(type(description) ~= "string")then
        error("Opis zasobu musi być string'iem");
    end
    if(providers[resource])then
        error("Zasób już został zarejestrowany jako dostawca funkcjonalności.");
    end

    providers[resource] = {name = name, description = description}

    addEventHandler("onResourceStop", getResourceRootElement(resource), function(resource)
        providers[resource] = nil;
    end);
end

function broadcastEvent(eventName, ...)
    for resource in pairs(providers)do
        triggerEvent(eventName, getResourceRootElement(resource), ...)
    end
end

local function getCallingFunctionName()
    return debug.getinfo(3, "n").name;
end

function verifyIsAddedInterface()
    local resource = sourceResource or getThisResource();
    if(not providers[resource])then
        error("Błąd podczas wykonywania funkcji '"..getCallingFunctionName().."'. Zasób '"..getResourceName(resource).."' nie jest zarejestrowany jako dostawca funkcjonalności.");
    end
end

function generateId()
    id = id + 1;
    return id;
end

function generateRequestId()
    requestId = requestId + 1;
    return requestId;
end

function dprint(...)
    print("[RealmAdmin]", ...);
end

function refCache(userdata)
    if(not userdata)then
        error("UserData is invalid. Got type:"..type(userdata));
    end
    if(not refByUserData[userdata])then
        refByUserData[userdata] = refId;
        userDataByRef[refId] = userdata;
        refId = refId + 1;
    end
    return refByUserData[userdata];
end

function derefCache(userData)
    return refByUserData[userData];
end

addEventHandler("onResourceStart", resourceRoot, function()
    dprint("Łączenie...");
    addInterfaceResource("core", "bla bla bla");
    connect();
end)

function isSystemCaller(id)
    return id == -1;
end

function invokeWrapper(target, model)
    model.source = getResourceName(sourceResource or getThisResource());
    model.requestId = generateRequestId();
    invoke(target, model);
    return model.requestId;
end

function handleResourceStarted()
    triggerEvent("onRealmAdminConnected", source)
end

addEventHandler("onRealmAdminConnected", resourceRoot, function()
    addEventHandler("onResourceStart", root, handleResourceStarted);
end)

addEventHandler("onRealmAdminDisconnected", resourceRoot, function()
    removeEventHandler("onResourceStart", root, handleResourceStarted);
end)