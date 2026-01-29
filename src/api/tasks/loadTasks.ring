/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: loadTasks
description: Load available tasks
*/
func loadTasks
    try {
        # clear the current tasks list
        aTasks = []

        # define the database path
        cDBPath = "G:\RingAIAgents\db\tasks.db"

        # check if the database exists
        if fexists(cDBPath) {
            ? logger("loadTasks function", "Loading tasks from database: " + cDBPath, :info)
            # open the database
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # retrieve the tasks
            cSQL = "SELECT * FROM tasks"
            aResults = sqlite_execute(oDatabase, cSQL)

            # log the SQL query and the number of tasks found
            ? logger("loadTasks function", "SQL query executed: " + cSQL, :info)
            ? logger("loadTasks function", "Number of tasks found: " + iif(type(aResults) = "LIST" , len(aResults) , 0), :info)

            # process the results
            if type(aResults) = "LIST" and len(aResults) > 0 {
                # log the details of each task
                for nTaskIndex = 1 to len(aResults) {
                    aResult = aResults[nTaskIndex]
                    ? logger("loadTasks function", "Processing task " + nTaskIndex + " of " + len(aResults) + ": " + aResult[:title], :info)

                    # create a new task
                    oTask = new Task(aResult[:description])

                    # set the task ID and title
                    oTask.setId(aResult[:id])
                    oTask.setTitle(aResult[:title])

                    # set the task status and priority
                    oTask.setStatus(aResult[:status])
                    oTask.setPriority(number(aResult[:priority]))

                    # set the task start and due times
                    oTask.setStartTime(aResult[:start_time])
                    oTask.setDueTime(aResult[:due_time])

                    # set the task context and progress
                    oTask.setContext(aResult[:context])
                    oTask.updateProgress(number(aResult[:progress]))

                    # set the task assigned to
                    cAssignedTo = aResult[:assigned_to]
                    if cAssignedTo != "" {
                        for i = 1 to len(aAgents) {
                            if isObject(aAgents[i]) and methodExists(aAgents[i], "getId") {
                                if aAgents[i].getId() = cAssignedTo {
                                    oTask.assignTo(aAgents[i])
                                    exit
                                }
                            }
                        }
                    }

                    # add the subtasks
                    try {
                        aSubtasks = JSON2List(aResult[:subtasks])
                        if isList(aSubtasks) {
                            for aSubtask in aSubtasks {
                                oSubtask = new Task(aSubtask[:description])
                                oSubtask.setId(aSubtask[:id])
                                oSubtask.setStatus(aSubtask[:status])
                                oTask.addSubtask(oSubtask)
                            }
                        }
                    catch
                        ? logger("loadTasks function", "Error parsing subtasks: " + cCatchError, :error)
                    }

                    # add the task to the list
                    add(aTasks, oTask)
                }
            }

            # close the database
            sqlite_close(oDatabase)
        }

        # create default tasks if no tasks are loaded
        if len(aTasks) = 0 and len(aAgents) > 0 {
            ? logger("loadTasks function", "No tasks loaded, creating default tasks", :info)

            # create a default task
            oDefaultTask = new Task("Implement basic functionality")
            oDefaultTask.setTitle("Basic Implementation")
            oDefaultTask.setPriority(5)
            oDefaultTask.setContext("Initial system setup")

            # add a subtask
            oSubtask = new Task("Create database schema")
            oDefaultTask.addSubtask(oSubtask)

            # assign the task to the first agent
            oDefaultTask.assignTo(aAgents[1])

            # add the task to the list
            add(aTasks, oDefaultTask)

            # save the default tasks
            saveTasks()
        }

        ? logger("loadTasks function", "Tasks loaded successfully: " + len(aTasks), :info)
        return true
    catch
        ? logger("loadTasks function", "Error loading tasks: " + cCatchError, :error)
        return false
    }
