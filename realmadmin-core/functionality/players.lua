local _getPlayerName = getPlayerName;
local _getPlayerSerial = getPlayerSerial;
local _getPlayerIP = getPlayerIP;
local _getPlayerVersion = getPlayerVersion;

local function getPlayerName(player)
    if(getElementType(player) == "player")then
        return _getPlayerName(player);
    end
    return "<unknown>";
end

local function getPlayerSerial(player)
    if(getElementType(player) == "player")then
        return _getPlayerSerial(player);
    end
    return "<unknown>";
end

local function getPlayerIP(player)
    if(getElementType(player) == "player")then
        return _getPlayerIP(player);
    end
    return "<unknown>";
end

local function getPlayerVersion(player)
    if(getElementType(player) == "player")then
        return _getPlayerVersion(player);
    end
    return "<unknown>";
end

function playersAddRowButtonAction(actionName, callbackEventName)
    verifyIsAddedInterface();

    return invokeWrapper("PlayersAddRowButtonAction", {
        name = actionName,
        callbackEventName = callbackEventName,
        sourceResourceName = getResourceName(sourceResource)
    });
end

function playersSetCustomColumns(columns)
    verifyIsAddedInterface();

    return invokeWrapper("PlayersSetCustomColumns", {
        columns = columns
    });
end

function playersAddPlayer(player, data)
    if(type(player) ~= "userdata" and getElementType(player) ~= "player")then
        error("Player is invalid.")
    end
    verifyIsAddedInterface();

    return invokeWrapper("PlayersAddPlayer", {
        playerIdRef = refCache(player),
        playerName = getPlayerName(player),
        serial = getPlayerSerial(player),
        ip = getPlayerIP(player),
        version = getPlayerVersion(player),
        data = data
    });
end

function playersRemovePlayer(player)
    if(type(player) ~= "userdata" and getElementType(player) ~= "player")then
        error("Player is invalid.")
    end

    verifyIsAddedInterface();

    return invokeWrapper("PlayersSetPlayerData", {
        playerIdRef = refCache(player)
    });
end

function playersSetData(player, data)
    if(type(player) ~= "userdata" and getElementType(player) ~= "player")then
        error("Player is invalid.")
    end

    verifyIsAddedInterface();

    return invokeWrapper("PlayersSetData", {
        playerIdRef = refCache(player),
        data = data
    });
end

function playersSetPlayerName(player, data)
    if(type(player) ~= "userdata" and getElementType(player) ~= "player")then
        error("Player is invalid.")
    end

    verifyIsAddedInterface();

    return invokeWrapper("PlayersSetPlayerName", {
        playerIdRef = refCache(player),
        playerName = getPlayerName(player),
    });
end
