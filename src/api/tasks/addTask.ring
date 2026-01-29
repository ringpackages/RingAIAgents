/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: addTask
description: Create a new task
*/
func addTask
    try {
        oTask = new Task(oServer["description"]) {
            setTitle(oServer["title"])
            setStartTime(TimeList()[5])
            setPriority(number(oServer["priority"]))
            setContext(oServer["context"])

            # add subtasks
            if islist(oServer["subtasks"]) {
                for cSubtask in oServer["subtasks"] {
                    addSubtask(new Task(cSubtask))
                }
            }
        }

        # assign the task to an agent
        nAgentId = number(oServer["agent_id"])
        if nAgentId > 0 and nAgentId <= len(aAgents) {
            oTask.assignTo(aAgents[nAgentId])
        }

        add(aTasks, oTask)

        # save the task to the database
        if saveTasks() {
            ? logger("addTask function", "Task created and saved successfully", :info)
            oServer.setContent('{"status":"success","message":"Task created successfully","id":"' +
                              oTask.getId() + '"}', "application/json")
        else 
            ? logger("addTask function", "Task created but not saved to database", :warning)
            oServer.setContent('{"status":"warning","message":"Task created but not saved to database","id":"' +
                              oTask.getId() + '"}', "application/json")
        }
    catch
        ? logger("addTask function", "Error creating task: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
