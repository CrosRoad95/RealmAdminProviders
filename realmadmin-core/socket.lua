-- https://github.com/dotnet/aspnetcore/blob/main/src/SignalR/docs/specs/HubProtocol.md

local version = 4;
local state = "closed"; -- Default state
local connectionEstablished = false;
local isDuringHandshake = false;
local socket = nil -- Socket used to communicate with panel
local openingSocket = nil -- Socket used to communicate with panel
local lastPing = 0;
local reconnectTimer = nil;
local timeoutTimer = nil;
local attemptCount = 0;
local maxAttempts = 10;
local reconnectInterval = 5000; -- In miliseconds
local reconnectTimeout = 1500; -- In miliseconds
local recordSeparatorCode = 30;
local recordSeparator = string.char(recordSeparatorCode);
local streamInvocations = {};
local invocations = {};
local nextInvocationId = 0;
local subscribedEvents = {};
local buffer = "";
local bufferSplitMatch = "([^"..recordSeparator.."]+)";
local server, serverPort;
if(configuration.isDevelopment)then
    server = "localhost";
    serverPort = 5555;
    maxAttempts = 50000;
else
    server = "83.168.69.118";
    serverPort = 5555;
end

local messageType = {
    invocation = 1,
    streamItem = 2,
    completion = 3,
    streamInvocation = 4,
    cancelInvocation = 5,
    ping = 6,
    close = 7,
    ack = 8,
    sequence = 9
}

addEvent("onSocketError");
addEvent("onSocketData");
addEvent("onSocketStateChanged");
addEvent("onConnectioneEstablished");
addEvent("onRealmAdminConnected");
addEvent("onRealmAdminDisconnected");
addEvent("onRealmAdminError");
addEvent("onRealmAdminSuccess");

addEventHandler("onSocketStateChanged", resourceRoot, function(state)
    raprint("Zmieniono stan połączenia na:", state)
    if (reconnectTimer and isTimer(reconnectTimer))then
        killTimer(reconnectTimer)
        reconnectTimer = nil
    end
    if (state == "open") then
        lastPing = getTickCount();
        isDuringHandshake = true;
        sendPacket({
                ["protocol"] = "json",
                ["version"] = 1,
            }
        );
    elseif(state == "closed")then
        connectionEstablished = false;
        socket = nil;
        attemptCount = 0;
        raprint("Połączenie zostało zamknięte, nastąpi próba ponownego połączenia");
        triggerEvent("onRealmAdminDisconnected", root);
        reconnectTimer = setTimer(function()
            connect(true)
        end, reconnectTimeout, 1)
    end
end)

function createId()
    nextInvocationId = nextInvocationId + 1
    return "id"..nextInvocationId
end

addEventHandler("onSocketError", resourceRoot, function(err)
    raprint("Socket error:", err)
end)

function createArguments(...)
    local result = {...}
    for i,v in ipairs(result)do
        if(type(v) == "userdata")then
            result[i] = ref(v)
        end
    end
    return result
end

function invoke(target, ...)
    sendPacket({
        ["type"] = messageType.invocation,
        ["target"] = target,
        ["arguments"] = createArguments(...),
    });
end

function fetch(callback, target, ...)
    local id = createId();
    sendPacket({
        ["type"] = messageType.invocation,
        ["target"] = target,
        ["invocationId"] = id,
        ["arguments"] = createArguments(...),
    });
    invocations[id] = {callback, getTickCount()}
end

function cancelInvocation(invocationId)
    sendPacket({
        ["type"] = messageType.cancelInvocation,
        ["invocationId"] = invocationId,
    });
end

function streamInvoke(callback, target, ...)
    local id = createId();
    sendPacket({
        ["type"] = messageType.streamInvocation,
        ["invocationId"] = id,
        ["target"] = target,
        ["arguments"] = createArguments(...),
    });
    streamInvocations[id] = { callback, getTickCount()}

    return function()
        cancelInvocation(id)
    end
end

function setSocketState(newState)
    if(state ~= newState)then
        state = newState;
        triggerEvent("onSocketStateChanged", resourceRoot, state);
    end
end

function serialize(data)
    local json = toJSON(data, true)
    json = string.sub(json, 2, string.len(json) -1)
    return json..recordSeparator
end

function sendPacket(packet)
    local rawPacket = serialize(packet);
    if(configuration.debugPrint)then
        raprint("sendPacket:", #rawPacket, rawPacket)
    end
    sockWrite(socket, rawPacket)
end

function connect(reconnecting)
    if(openingSocket)then
        sockClose(openingSocket);
        openingSocket = false;
    end
    if(reconnecting)then
        attemptCount = attemptCount + 1;
    else
        attemptCount = 0;
    end

    if(attemptCount > maxAttempts)then
        raprint("Zbyt dużo prób połączenia ("..maxAttempts.."), przerwano połączenie. Zresetuj zasób aby spróbować ponownie.");
        return;
    end
    openingSocket = sockOpen(server, serverPort);
    timeoutTimer = setTimer(function()
        if(not reconnecting)then
            attemptCount = attemptCount + 1;
        end
        raprint("Błąd podczas połączenia (próba: "..attemptCount..")! Trwa próba ponownego połączenia...");
        connect(true);
    end, reconnectInterval, 1);
end

addEventHandler('onSockOpened', root, function(newSocket)
    if(socket)then
        return;
    end
    socket = newSocket
    killTimer(timeoutTimer);
    setSocketState("open")
end)

addEventHandler('onSockClosed', root, function()
    setSocketState("closed")
end)

function handlePacket(rawData)
    local data = fromJSON(rawData)
    if(type(data) ~= "table")then
        return;
    end

    if (isDuringHandshake) then
        if (data["error"]) then
            triggerEvent("onSocketError", resourceRoot, data["error"])
        else
            connectionEstablished = true
            triggerEvent("onConnectioneEstablished", resourceRoot)
        end
        isDuringHandshake = false;
    end

    if(rawData == "{}")then
        return; -- Empty packet
    end

    if (data["error"]) then
        triggerEvent("onSocketError", resourceRoot, data["error"])
        return;
    end

    local t = data["type"]
    if (type(t) ~= "number")then
        raprint("Wystąpił błąd podczas odczytu pakietu, pole 'type' jest typem '"..type(t).."' a powinien być typem 'number'", inspect(data))
        return;
    end

    if (t == messageType.invocation) then
        local target = hub[data.target];
        if (target) then
            local succeed, err = pcall(target, unpack(data.arguments))
            if(not succeed)then
                raprint("Wystąpił problem podczas wykonywania metody: '"..tostring(data.target).."', "..err);
            end
        else
            raprint("Wystąpił problem podczas wykonywania metody: '"..tostring(data.target).."', metoda nie istnieje");
        end
        return;
    elseif(t == messageType.streamItem)then
        local callback = streamInvocations[data.invocationId];
        assert(callback)
        callback[1](function()
            cancelInvocation(data.invocationId)
        end, data.item)
        return;
    elseif(t == messageType.completion)then
        if(data.result)then
            invocations[data.invocationId][1](data.result)
        end
        invocations[data.invocationId] = nil
        streamInvocations[data.invocationId] = nil
        return;
    elseif(t == messageType.ping)then
        local interval = getTickCount() -lastPing;
        if (interval > 20000) then -- Usually takes 15000ms
            raprint("Ping trwał zbyt długo!", interval);
        end
        lastPing = getTickCount()
        return;
    elseif(t == messageType.close)then
        sockClose(socket)
        setSocketState("closed")
    else
        raprint("Otrzymano niezaimplementowany typ pakietu: ", t);
    end
end

addEventHandler('onSockData', root, function(_, bytes)
    if(configuration.debugPrint)then
        raprint("onSockData:", bytes);
    end
    buffer = buffer..bytes;
    local readBytes = 0;
    for rawPacket in string.gmatch(buffer, bufferSplitMatch) do
        if(rawPacket ~= "")then
            readBytes = readBytes + string.len(rawPacket) + 1 ;
            handlePacket(rawPacket);
        end
    end
    buffer = string.sub(buffer, readBytes + 1);
end);

addEventHandler("onConnectioneEstablished", resourceRoot, function(state)
    raprint("Połączono pomyślnie. Rozpoczęto autoryzację...");

    -- Test logic:
    invokeWrapper("Authenticate", {
        serverId = configuration.serverId,
        apiKey = configuration.apiKey,
        version = version
    });
end)

addEventHandler("onResourceStart", resourceRoot, function()
    if(configuration.isDevelopment)then
        raprint("Włączono tryb developerski")
    end
end)