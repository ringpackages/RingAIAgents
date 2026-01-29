/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: aiAnalyze
Description: Data analysis using artificial intelligence
*/
func aiAnalyze
    try {
        cData = oServer["data"]
        cType = oServer["type"]

        oResult = oLLM.analyze(cData, cType)

        oMemory.store(
            "Analysis: " + cType,
            Memory.SHORT_TERM,
            6,
            ["analysis", cType],
            [:data = cData, :result = oResult]
        )

        ? logger("aiAnalyze function", "Data analysis completed successfully", :info)
        oServer.setContent('{"status":"success","analysis":' + oResult + '}',
                          "application/json")
    catch
        ? logger("aiAnalyze function", "Error analyzing data: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
