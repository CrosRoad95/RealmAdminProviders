local logsFile = nil;
local flushTimer = nil;

local function now(includeDate)
    local time = getRealTime();
    local hours = time.hour;
    local minutes = time.minute;
    local seconds = time.second;

    if(includeDate)then
        local day = time.monthday;
        local month = time.month;
        local year = time.year + 1900;
        return string.format("%02d-%02d-%04d %02d-%02d-%02d", day, month, year, hours, minutes, seconds);
    else
        return string.format("%02d-%02d-%02d", hours, minutes, seconds);
    end
end

local function log(message)
    fileWrite(logsFile, message);
    if(not flushTimer)then
        flushTimer = setTimer(function()
            fileFlush(logsFile)
            flushTimer = nil;
        end, 5000, 1)
    end
end

addEventHandler("onRealmAdminConnected", root, function()
    exports["realmadmin-core"]:addInterfaceResource("logger", "Logger wiadomości.");
    log(string.format("[Info] [%s] %s\n", now(), "Nastąpiło połączenie z RealmAdmin."));
end);

addEventHandler("onRealmAdminError", resourceRoot, function(source, requestId, message)
    iprint("error", getTickCount())
    log(string.format("[Error] [%s] %s\n", now(), message));
end);

addEventHandler("onRealmAdminSuccess", resourceRoot, function(source, requestId, message)
    iprint("success", getTickCount())
    log(string.format("[Success] [%s] %s\n", now(), message));
end);

addEventHandler("onResourceStart", resourceRoot, function()
    local fileName = "logs/"..now(true)..".txt";
    logsFile = fileCreate(fileName);
end);

addEventHandler( "onResourceStop", resourceRoot,function()
    if(flushTimer)then
        killTimer(flushTimer)
        flushTimer = nil;
    end
    log(string.format("[Info] [%s] %s\n", now(), "Logger został zatrzymany."));
    fileClose(logsFile)
end);