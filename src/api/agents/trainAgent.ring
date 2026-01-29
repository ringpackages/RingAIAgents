/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: trainAgent
Description: Train an agent on a new skill
*/
func trainAgent
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aAgents) {
            oAgent = aAgents[nID]

            cSkill = oServer["skill"]
            nLevel = number(oServer["level"])

            # Start training
            oAgent.startTraining(cSkill, nLevel)

            # Store training in memory
            oMemory.store(
                "Agent Training: " + oAgent.getName() + " - " + cSkill,
                Memory.LONG_TERM,
                7,
                ["training", "skill"],
                [:agent = oAgent.getName(), :skill = cSkill, :level = nLevel]
            )

            ? logger("trainAgent function", "Training started successfully", :info)
            oServer.setContent('{"status":"success","message":"Training started successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("trainAgent function", "Error starting training: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
