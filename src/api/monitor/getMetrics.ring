/*
    RingAI Agents API - Monitor Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: getMetrics
description: Get metrics
*/
func getMetrics
    try {
        aMetrics = oMonitor.getAllMetrics()
        cJSON = list2json(aMetrics)
        ? logger("getMetrics function", "Metrics retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getMetrics function", "Error retrieving metrics: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
