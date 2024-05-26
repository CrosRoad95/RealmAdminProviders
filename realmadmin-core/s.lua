local id = 0;
local requestId = 0;
local refId = 0;
local refByUserData = {}
local userDataByRef = {}
local providers = {}

function isRegisteredAsInterfaceResource(resource)
    return providers[resource] and true or false;
end

local function getSourceName(resource)
    if(providers[resource])then
        return providers[resource].name;
    end
    return false;
end

function addInterfaceResource(name, description)
    local resource = sourceResource or getThisResource();
    -- if(providers[resource])then
    --     return false;
    -- end

    if(type(name) ~= "string")then
        error("Nazwa zasobu musi być string'iem");
    end
    if(type(description) ~= "string")then
        error("Opis zasobu musi być string'iem");
    end

    providers[resource] = {
        name = name,
        description = description
    };

    raprint("Zarejestrowano zasób '"..getResourceName(resource).."' jako dostawcę funkcjonalności.");
    
    local name = name;

    addEventHandler("onResourceStop", getResourceRootElement(resource), function(_)
        if(providers[resource])then
            invokeWrapper("RemoveProvider", {
                name = name
            }, resource)
            raprint("Odrejestrowano zasób '"..getResourceName(resource).."' z dostawców funkcjonalności.");
            providers[resource] = nil;
        end
    end, true, "low");
    
    return invokeWrapper("AddProvider", {
        resource = getResourceName(resource),
        name = name,
        description = description,
        addedAt = getRealTime().timestamp
    }, resource);
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

function raprint(...)
    print("[RealmAdmin] "..table.concat({...}, " "));
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
    raprint("Łączenie...");
    connect();
end)

function isSystemCaller(id)
    return id == -1;
end

function invokeWrapper(target, model, source)
    if(target == "Authenticate")then
        model.source = "";
    else
        local sourceResource = source or sourceResource or getThisResource();
        local source = getSourceName(source or sourceResource or getThisResource());
        if(not source)then
            error("Failed to call '"..tostring(target).."' because "..getResourceName(sourceResource).." is not registered as realmadmin provider.");
        end
        model.source = source;
    end
    model.requestId = generateRequestId();
    invoke(target, model);
    return model.requestId;
end

function isDevelopment()
    return configuration.isDevelopment and true or false;
end

function handleResourceStarted()
    if(isConnected())then
        triggerEvent("onRealmAdminConnected", source)
    end
end

addEventHandler("onResourceStart", root, handleResourceStarted);