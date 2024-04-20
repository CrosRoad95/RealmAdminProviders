local isDefaultListenerConfigured = false;

local function getResourceDescription(resource)
    verifyIsAddedInterface();

    local resourceDescription = {
        name = getResourceName(resource),
        organizationalPath = getResourceOrganizationalPath(resource),
        state = getResourceState(resource),
        lastFailureReason = getResourceLoadFailureReason(resource),
        exports = getResourceExportedFunctions(resource),
        commands = getCommandHandlers(resource),
        infoType = getResourceInfo(resource, "type") or "-"
    };
    
    return resourceDescription;
end

function resourcesAddAllResources()
    verifyIsAddedInterface();

    local resources = {}
    for i,resource in ipairs(getResources())do
        local resourceDescription = getResourceDescription(resource);
        table.insert(resources, resourceDescription);
        if(#resources > 4)then
            invokeWrapper("ResourcesAddResources", {
                resources = resources
            });
            resources = {};
        end
    end
    invokeWrapper("ResourcesAddResources", {
        resources = resources
    });
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

function resourcesSetResourceState(resource, newState)
    verifyIsAddedInterface();

    return invokeWrapper("ResourcesSetResourceState", {
        name = getResourceName(resource),
        state = newState
    });
end

function resourcesConfigureDefaultListener()
    verifyIsAddedInterface();

    if(isDefaultListenerConfigured)then
        return false;
    end
    isDefaultListenerConfigured = true;
    addEventHandler("onResourceStart", root, function(resource)
        resourcesSetResourceState(resource, "running")
    end);

    addEventHandler("onResourceStop", root, function(resource)
        resourcesSetResourceState(resource, "loaded")
    end);

    return true;
end