hub = {};
local connected = false;
addEvent("onRealmAdminInvokeResourceStop");
addEvent("onRealmAdminInvokeResourceStart");
addEvent("onRealmAdminInvokeResourceRestart");
addEvent("onRealmAdminInvokeResourceRefresh");

function hubOn(method, callback)
    assert(not hub[method]);
    hub[method] = callback;
end

hubOn("Connected", function()
    connected = true;
    dprint("Autoryzacja przebiegła pomyślnie.");
    triggerEvent("onRealmAdminConnected", root);
end)

hubOn("Error", function(source, requestId, message)
    broadcastEvent("onRealmAdminError", source, requestId, message);
end)

hubOn("Rejected", function(message)
    outputDebugString(message, 1)
end)

hubOn("Print", function(message)
    dprint("Print:", message)
end)

hubOn("InvokePlayerAddRowAction", function(caller, playerIdRef, eventName, sourceResourceName)
    local resource = getResourceFromName(sourceResourceName);
    if(resource and getResourceState(resource) == "running")then
        triggerEvent(eventName, getResourceRootElement(resource), caller, derefCache(playerIdRef));
    end
end)

hubOn("InvokeResourceStop", function(caller, resourceName)
    triggerEvent("onRealmAdminInvokeResourceStop", root, caller, resourceName)
end)

hubOn("InvokeResourceStart", function(caller, resourceName)
    triggerEvent("onRealmAdminInvokeResourceStart", root, caller, resourceName)
end)

hubOn("InvokeResourceRefresh", function(caller, resourceName)
    triggerEvent("onRealmAdminInvokeResourceRefresh", root, caller, resourceName)
end)

hubOn("InvokeResourceRestart", function(caller, resourceName)
    triggerEvent("onRealmAdminInvokeResourceRestart", root, caller, resourceName)
end)