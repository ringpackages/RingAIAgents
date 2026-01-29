/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: listTasks
description: Get a list of tasks
*/
func listTasks
    try {
        # collect the tasks
        aTasksList = []
        
        for oTask in aTasks {
            # collect the subtasks
            aSubtasks = []
            for oSubtask in oTask.aSubtasks {
                add(aSubtasks, [
                    :id = oSubtask.getID(),
                    :title = oSubtask.getTitle(),
                    :progress = oSubtask.getProgress()
                ])
            }
            
            # add task information
            add(aTasksList, [
                :id = oTask.getId(),
                :title = oTask.getTitle(),
                :description = oTask.getDescription(),
                :start_time = oTask.getStartTime(),
                :priority = oTask.getPriority(),
                :progress = oTask.getProgress(),
                :status = oTask.getStatus(),
                :assigned_to = iif(oTask.getAssignedTo() != NULL, oTask.getAssignedTo().getID(), ""),
                :subtasks = aSubtasks
            ])
        }
        
        # prepare the JSON response
        aResponse = [
            :status = "success",
            :tasks = aTasksList
        ]
        
        # convert the object to JSON
        cJSON = list2json(aResponse)
        
        # log the JSON response for debugging
        ? logger("listTasks function", "JSON response: " + cJSON, :info)
        
        # send the response
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listTasks function", "Error retrieving tasks: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
