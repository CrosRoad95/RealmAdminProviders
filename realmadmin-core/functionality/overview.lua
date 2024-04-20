function overviewAddTextWidget(title, content)
    verifyIsAddedInterface();

    local id = generateId();
    local result = invokeWrapper("OverviewAddTextWidget", {
        id = id,
        title = title,
        content = content
    });
    return result, id;
end

function overviewSetWidgetTitle(id, title)
    verifyIsAddedInterface();

    return invokeWrapper("OverviewSetWidgetTitle", {
        id = id,
        title = title,
    });
end
