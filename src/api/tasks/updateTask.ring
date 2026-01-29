/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: updateTask
description: Update task information
*/
func updateTask
    try {
        # try to get the task ID from the URL
        cTaskID = ""
        try {
            cTaskID = oServer.match(1)
            ? logger("updateTask function", "Using URL match parameter: " + cTaskID, :info)
        catch
            ? logger("updateTask function", "Error getting URL match parameter", :error)
        }

        # check if the task ID is valid
        if cTaskID = NULL or len(cTaskID) = 0 {
            oServer.setContent('{"status":"error","message":"No task ID provided"}', "application/json")
            return
        }

        # search for the task by ID
        oTask = NULL

        for i = 1 to len(aTasks) {
            if aTasks[i].getId() = cTaskID {
                oTask = aTasks[i]
                exit
            }
        }

        if oTask != NULL {
            ? logger("updateTask function", "Updating task: " + oTask.getTitle(), :info)

            # update the task information
            oTask.setTitle(oServer.variable("title"))
            oTask.setDescription(oServer.variable("description"))
            oTask.setPriority(number(oServer.variable("priority")))

            # update the assigned agent
            cAgentId = oServer.variable("agent_id")
            ? logger("updateTask function", "Agent ID: " + cAgentId, :info)

            # search for the agent by ID
            for i = 1 to len(aAgents) {
                if aAgents[i].getID() = cAgentId {
                    oTask.assignTo(aAgents[i])
                    ? logger("updateTask function", "Task assigned to: " + aAgents[i].getName(), :info)
                    exit
                }
            }

            # save the changes to the database
            if saveTasks() {
                ? logger("updateTask function", "Task updated and saved successfully", :info)
                oServer.setContent('{"status":"success","message":"Task updated successfully"}',
                                  "application/json")
            else
                ? logger("updateTask function", "Task updated but not saved to database", :warning)
                oServer.setContent('{"status":"warning","message":"Task updated but not saved to database"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("updateTask function", "Error updating task: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
