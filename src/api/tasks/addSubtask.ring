/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: addSubtask
description: Add a subtask
*/
func addSubtask
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aTasks) {
            oTask = aTasks[nID]

            # create the subtask
            oSubtask = new Task {
                cTitle = oServer["title"]
                cDescription = oServer["description"]
                nPriority = number(oServer["priority"])
                dStartTime = TimeList()[5]
            }

            # add the subtask
            oTask.addSubtask(oSubtask)

            ? logger("addSubtask function", "Subtask added successfully", :info)
            oServer.setContent('{"status":"success","message":"Subtask added successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("addSubtask function", "Error adding subtask: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
