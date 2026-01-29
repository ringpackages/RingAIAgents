/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: saveTasks
description: Save tasks to the database
*/
func saveTasks
    try {
        # check if there are any tasks
        if len(aTasks) = 0 {
            return false
        }

        # define the database path
        cDBPath = "G:\RingAIAgents\db\tasks.db"

        # create the database if it doesn't exist
        if !fexists(cDBPath) {
            ? logger("saveTasks function", "Creating new database at: " + cDBPath, :info)
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # create the tasks table if it doesn't exist
            cSQL = "CREATE TABLE IF NOT EXISTS tasks (
                    id TEXT PRIMARY KEY,
                    title TEXT,
                    description TEXT,
                    status TEXT,
                    priority INTEGER,
                    assigned_to TEXT,
                    start_time TEXT,
                    due_time TEXT,
                    context TEXT,
                    progress INTEGER,
                    subtasks TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # close the database
            sqlite_close(oDatabase)
        }

        # open the database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # save the tasks to the database
        ? logger("saveTasks function", "Saving " + len(aTasks) + " tasks to database", :info)
        for i = 1 to len(aTasks) {
            oTask = aTasks[i]

            # collect the subtasks
            aSubtasks = []
            for oSubtask in oTask.getSubtasks() {
                add(aSubtasks, [
                    :id = oSubtask.getId(),
                    :description = oSubtask.getDescription(),
                    :status = oSubtask.getStatus()
                ])
            }

            # convert the subtasks to JSON
            cSubtasks = list2json(aSubtasks)

            # clean the texts from double quotes
            cTitle = substr(oTask.getTitle(), '"', '""')
            cDescription = substr(oTask.getDescription(), '"', '""')
            cContext = substr(oTask.getContext(), '"', '""')

            # get the assigned agent ID
            cAssignedTo = ""
            if oTask.getAssignedTo() != NULL {
                cAssignedTo = oTask.getAssignedTo().getID()
            }

            # log the task data for debugging
            ? logger("saveTasks function", "Saving task: " + oTask.getId(), :info)
            ? logger("saveTasks function", "Title: " + cTitle, :info)
            ? logger("saveTasks function", "Status: " + oTask.getStatus(), :info)

            # add the task to the database or update it if it exists
            cSQL = "REPLACE INTO tasks (id, title, description, status, priority, assigned_to, start_time, due_time, context, progress, subtasks) VALUES (
                    '" + oTask.getId() + "',
                    '" + cTitle + "',
                    '" + cDescription + "',
                    '" + oTask.getStatus() + "',
                    " + oTask.getPriority() + ",
                    '" + cAssignedTo + "',
                    '" + oTask.getStartTime() + "',
                    '" + oTask.getDueTime() + "',
                    '" + cContext + "',
                    " + oTask.getProgress() + ",
                    '" + cSubtasks + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # close the database
        sqlite_close(oDatabase)

        ? logger("saveTasks function", "Tasks saved successfully", :info)
        return true
    catch
        ? logger("saveTasks function", "Error saving tasks: " + cCatchError, :error)
        return false
    }
