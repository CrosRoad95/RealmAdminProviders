local function getVehicleDescription(vehicle)
    return {
        vehicleIdRef = refCache(vehicle),
        model = getElementModel(vehicle),
        plateText = getVehiclePlateText(vehicle),
        location = getElementLocation(vehicle),
    }
end

function vehiclesAddVehicle(vehicle, data, kindElementDataOrKind)
    if(type(vehicle) ~= "userdata" and getElementType(vehicle) ~= "vehicle")then
        error("Vehicle is invalid.")
    end
    verifyIsAddedInterface();

    local vehicleDescription = getVehicleDescription(vehicle);
    vehicleDescription.data = data;
    if(type(kindElementDataOrKind) == "number")then
        vehicleDescription.kind = kindElementDataOrKind;
    elseif(type(kindElementDataOrKind) == "string")then
        vehicleDescription.kind = getElementData(vehicle, kindElementDataOrKind);
    end
    return invokeWrapper("VehiclesAddVehicle", vehicleDescription);
end

function vehiclesAddAllVehicles(data, kindElementDataOrKind)
    verifyIsAddedInterface();

    local vehicles = {}
    for i,vehicle in ipairs(getElementsByType("vehicle"))do
        local vehicleDescription = getVehicleDescription(vehicle);
        vehicleDescription.data = data;
        if(kindElementDataOrKind)then
            if(type(kindElementDataOrKind) == "number")then
                vehicleDescription.kind = kindElementDataOrKind;
            elseif(type(kindElementDataOrKind) == "string")then
                vehicleDescription.kind = getElementData(vehicle, kindElementDataOrKind);
            end
        end
        table.insert(vehicles, vehicleDescription)
    end
    return invokeWrapper("VehiclesAddVehicles", {
        vehicles = vehicles
    });
end

function vehiclesSetKinds(kinds)
    if(type(kinds) ~= "table")then
        error("Kinds is not table type.")
    end
    verifyIsAddedInterface();
    
    return invokeWrapper("VehiclesSetKinds", {
        kinds = kinds
    });
end