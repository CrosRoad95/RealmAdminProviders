local fakePlayer1 = createElement("fake-player");
local fakePlayer2 = createElement("fake-player");
local fakePlayer3 = createElement("fake-player");
setElementData(fakePlayer1, "name", "fakePlayer1");
setElementData(fakePlayer2, "name", "fakePlayer2");
setElementData(fakePlayer3, "name", "fakePlayer2");

createVehicle(404, 0, 0, 3)

addEventHandler("onRealmAdminConnected", root, function()
    iprint("Starting test provider at", getTickCount())

    addInterfaceResource("test-provider", "dodaje testowe funkconalności");

    removeAllPlayers();
    removeAllVehicles();
    
    local requestId, widgetId = overviewAddTextWidget("tytuł", "przykładowa treść");
    local i = 0;
    setTimer(function()
        i = i + 1;
        overviewSetWidgetTitle(widgetId, "tytuł "..i);
        --admin:overviewAddTextWidget("tytuł", "zawartość asd");
    end, 100, 3);

    playersAddRowButtonAction("kick", "realmAdminHandleKick")
    playersAddRowButtonAction("zabierz prawko", "realmAdminHandleTakeLicense")

    playersAddPlayer(fakePlayer1, {
        ["prawko"] = "tak",
    })
    playersAddPlayer(fakePlayer2, {
        ["prawko"] = "nie",
    })
    playersAddPlayer(fakePlayer3, {
        ["prawko"] = "zawieszone",
    })

    -- local i = 0
    -- setTimer(function()
    --     i = i + 1
    --     admin:playersSetData(fakePlayer2, {
    --         ["prawko"] = "nie "..i,
    --     })
    -- end, 1000, 0)

    resourcesAddAllResources();

    resourcesConfigureDefaultListener();
    
    vehiclesSetKinds({
        [0] = "domyślny"
    });
    vehiclesAddAllVehicles(nil, 0);
end)

addCommandHandler("add", function()
    playersAddCustomColumn({
        ["key"] = "prawko",
        ["name"] = "Prawo jazdy",
    })
end)

addCommandHandler("remove", function()
    playersRemoveCustomColumn("prawko")
end)

addEvent("realmAdminHandleKick")
addEventHandler("realmAdminHandleKick", resourceRoot, function(caller, player)
    iprint("kick", caller, player)
end)

addEvent("realmAdminHandleTakeLicense")
addEventHandler("realmAdminHandleTakeLicense", resourceRoot, function(caller, player)
    iprint("zabierz prawko", caller, player)
end)
