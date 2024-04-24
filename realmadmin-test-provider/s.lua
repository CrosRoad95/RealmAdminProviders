local fakePlayer1 = createElement("fake-player");
local fakePlayer2 = createElement("fake-player");
local fakePlayer3 = createElement("fake-player");
setElementData(fakePlayer1, "name", "fakePlayer1");
setElementData(fakePlayer2, "name", "fakePlayer2");
setElementData(fakePlayer3, "name", "fakePlayer2");

addEventHandler("onRealmAdminError", resourceRoot, function(source, requestId, message)
    iprint("onRealmAdminError:",source, requestId, message)
end)

addEventHandler("onRealmAdminConnected", root, function()
    iprint("Starting test provider at", getTickCount())
    local admin = exports["realmadmin-core"]

    admin:addInterfaceResource("test-provider", "dodaje testowe funkconalności");

    local requestId, widgetId = admin:overviewAddTextWidget("tytuł", "zawartość asd");
    local i = 0;
    setTimer(function()
        i = i + 1;
        admin:overviewSetWidgetTitle(widgetId, "tytuł "..i);
        --admin:overviewAddTextWidget("tytuł", "zawartość asd");
    end, 100, 3);

    admin:playersAddRowButtonAction("kick", "realmAdminHandleKick")
    admin:playersAddRowButtonAction("zabierz prawko", "realmAdminHandleTakeLicense")

    admin:playersAddPlayer(fakePlayer1, {
        ["prawko"] = "tak",
    })
    admin:playersAddPlayer(fakePlayer2, {
        ["prawko"] = "nie",
    })
    admin:playersAddPlayer(fakePlayer3, {
        ["prawko"] = "zawieszone",
    })

    -- local i = 0
    -- setTimer(function()
    --     i = i + 1
    --     admin:playersSetData(fakePlayer2, {
    --         ["prawko"] = "nie "..i,
    --     })
    -- end, 1000, 0)

    admin:resourcesAddAllResources();

    admin:resourcesConfigureDefaultListener();
    admin:vehiclesSetKinds({
        [0] = "domyślny"
    });
    admin:vehiclesAddAllVehicles(nil, 0);

    local count = 0;
    setTimer(function()
        count = count + 1;
        admin:statisticsPlayerCountReport(count);
    end, 1000, 10)
end)

addCommandHandler("add", function()
    local admin = exports["realmadmin-core"];
    admin:playersAddCustomColumn(
    {
        ["key"] = "prawko",
        ["name"] = "Prawo jazdy",
    })
end)

addCommandHandler("remove", function()
    local admin = exports["realmadmin-core"];
    admin:playersRemoveCustomColumn("prawko")
end)

addEvent("realmAdminHandleKick")
addEventHandler("realmAdminHandleKick", resourceRoot, function(caller, player)
    iprint("kick", caller, player)
end)

addEvent("realmAdminHandleTakeLicense")
addEventHandler("realmAdminHandleTakeLicense", resourceRoot, function(caller, player)
    iprint("zabierz prawko", caller, player)
end)
