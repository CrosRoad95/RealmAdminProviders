function getElementLocation(element)
    local x,y,z = getElementPosition(element);
    local rx,ry,rz = getElementPosition(element);
    local i,d = getElementInterior(element), getElementDimension(element);

    return {
        x = x,
        y = y,
        z = z,
        rx = rx,
        ry = ry,
        rz = rz,
        interior = i,
        dimension = d
    };
end
