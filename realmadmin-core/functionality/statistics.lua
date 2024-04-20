function statisticsPlayerCountReport(playercount)
    verifyIsAddedInterface();

    return invokeWrapper("StatisticsPlayerCountReport", {
        playerCountReport = {playerCountReport}
    });
end