hub = {};
local connected = false;
addEvent("onRealmAdminInvokeResourceStop");
addEvent("onRealmAdminInvokeResourceStart");
addEvent("onRealmAdminInvokeResourceRestart");
addEvent("onRealmAdminInvokeResourceRefresh");
addEvent("onRealAdminUserOpened");
addEvent("onRealAdminUserClosed");

function isConnected()
    return connected;
end

function hubOn(method, callback)
    assert(not hub[method]);
    hub[method] = callback;
end

hubOn("Connected", function()
    connected = true;
    raprint("Autoryzacja przebiegła pomyślnie.");
    addInterfaceResource("core", "Główny zasób obsługując połączenie do panelu.");
    triggerEvent("onRealmAdminConnected", root);
end)

hubOn("Error", function(source, requestId, message)
    broadcastEvent("onRealmAdminError", source, requestId, message);
end)

hubOn("Rejected", function(message)
    raprint(message)
end)

hubOn("Print", function(message)
    raprint("Print:", message)
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

hubOn("UserOpened", function(userId)
    triggerEvent("onRealAdminUserOpened", root, userId);
end)

hubOn("UserClosed", function(userId)
    triggerEvent("onRealAdminUserClosed", root, userId);
end)

hubOn("VersionMismatch", function(currentVersion, expectedVersion)
    raprint("Uwaga: Posiadasz złą wersje zasobu realmadmin-core, twoja wersja to: v"..currentVersion..", podczas gdy oczekiwana wersja to: v"..expectedVersion)
    raprint("Pobierz odpowiednią wersje ( v"..expectedVersion.." ) ze strony: https://github.com/CrosRoad95/RealmAdminProviders/tags");
end)