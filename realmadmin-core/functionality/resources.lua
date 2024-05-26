local isDefaultListenerConfigured = false;

local function getResourceDescription(resource, source)
    verifyIsAddedInterface();

    local exports = {}
    local meta = xmlLoadFile(":"..getResourceName(resource).."/meta.xml", true);
    for i,node in ipairs(xmlNodeGetChildren(meta))do
        local name = xmlNodeGetName(node)
        if(name == "export")then
            table.insert(exports, {
                name = xmlNodeGetAttribute(node, "function"),
                type = xmlNodeGetAttribute(node, "type")
            })
        end
    end
    xmlUnloadFile(meta)

    
    local resourceDescription = {
        name = getResourceName(resource),
        organizationalPath = getResourceOrganizationalPath(resource),
        state = getResourceState(resource),
        lastFailureReason = getResourceLoadFailureReason(resource),
        exports = exports,
        commands = getCommandHandlers(resource),
        infoType = getResourceInfo(resource, "type") or "unknown",
        source = getResourceName(source),
        requestId = 0,
    };
    
    return resourceDescription;
end

function resourcesAddAllResources()
    verifyIsAddedInterface();

    invokeWrapper("ResourcesRemoveAll", {}, sourceResource);
    local resources = {}
    for i,resource in ipairs(getResources())do
        local resourceDescription = getResourceDescription(resource, sourceResource);
        table.insert(resources, resourceDescription);
        if(#resources > 4)then
            invokeWrapper("ResourcesAddResources", {
                resources = resources
            });
            resources = {};
        end
    end

    if(#resources > 0)then
        invokeWrapper("ResourcesAddResources", {
            resources = resources
        }, sourceResource);
    end
    return true;
end

function resourcesAddResource(resource)
    verifyIsAddedInterface();

    return invokeWrapper("ResourcesAddResources", {
        resources = {resource}
    });
end

function resourcesRemoveResources(resources)
    verifyIsAddedInterface();

    local resourcesNames = {};
    for i,resource in ipairs(resourcesNames)do
        table.insert(resourcesNames, getResourceName(resource))
    end
    return invokeWrapper("ResourcesRemoveResources", {
        resources = resourcesNames
    });
end

function resourcesRemoveResource(resource)
    verifyIsAddedInterface();

    return invokeWrapper("ResourcesRemoveResources", {
        resources = {getResourceName(resource)}
    });
end

function resourcesSetResourceState(resource, newState, source)
    verifyIsAddedInterface();

    return invokeWrapper("ResourcesSetResourceState", {
        name = getResourceName(resource),
        state = newState
    }, source);
end

function resourcesConfigureDefaultListener()
    verifyIsAddedInterface();

    local sourceResource = sourceResource;
    if(isDefaultListenerConfigured)then
        return false;
    end
    isDefaultListenerConfigured = true;
    
    local function handleResourceStart(resource)
        resourcesSetResourceState(resource, "running", sourceResource)
    end

    local function handleResourceStop(resource)
        if(resource == sourceResource)then
            removeEventHandler("onResourceStart", root, handleResourceStart, true, "high");
            removeEventHandler("onResourceStop", root, handleResourceStop, true, "high");
            return;
        end
        resourcesSetResourceState(resource, "loaded", sourceResource)
    end

    addEventHandler("onResourceStart", root, handleResourceStart, true, "high");
    addEventHandler("onResourceStop", root, handleResourceStop, true, "high");

    return true;
end
