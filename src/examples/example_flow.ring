Load "G:\RingAIAgents\src\libAgentAi.ring"



# Example usage
func main {
    # Text processing flow
    oTextFlow = new TextGenerationFlow()

    # Task flow
    oTaskFlow = new TaskFlow()

    # Parallel flow
    oParallelFlow = new ParallelFlow()

    ? "=== Starting flow execution ==="

    ? "--- Text flow ---"
    oTextFlow.execute()
    ? "Result: " + oTextFlow.oState.getText("result")

    ? "--- Task flow ---"
    oTaskFlow.execute()
    ? "Task status: "
    see oTaskFlow.oState.getList("task")

    ? "--- Parallel flow ---"
    oParallelFlow.execute()
    ? "Final total: " + oParallelFlow.oState.getNumber("total")

    ? "--- Data processing flow ---"
    oDataFlow = new DataProcessingFlow()
    oDataFlow.execute()
    ? "Processing result: " + oDataFlow.oState.getNumber("result")
    if len(oDataFlow.oState.getList("errors")) > 0 {
        ? "سجل الأخطاء:"
        ? oDataFlow.oState.getText("error_log")
    }

    ? "--- Workflow flow ---"
    aWorkflowFlow = new WorkflowFlow()
    aWorkflowFlow.execute()
    ? "Final workflow status:"
    see aWorkflowFlow.oState.getList("workflow")
}



/*
Class: TextGenerationFlow
Description: Example flow that generates and analyzes text
*/
class TextGenerationFlow from Flow {

    func init {
        super.init()
        # Registering methods
        registerMethod("generatetext")
        //registerMethod("analyzetext")
        //registerMethod("formatresults")

        # Starting the flow
        start("generatetext")
    }

    func generatetext {
        oState.setText("text", "Welcome to the Ring Flows System!")
        ctext = oState.getText("text")
        emit("text_generated", ctext)

        # Creating thread for analysis
        oThreads.createThread(1, super +".analyzetext(ctext)")
        oThreads.setThreadName(1, "TextAnalysis")
    }

    func analyzetext xText {
        nWords = len(split(xText))
        oState.setNumber("word_count", nWords)
        emit("analysis_complete", nWords)

        # Creating thread for formatting
        oThreads.createThread(2, super +".formatresults(" + nWords + ")")
        oThreads.setThreadName(2, "ResultFormat")
    }

    func formatresults nCount {
        cResult = "Text analysis result: Number of words = " + nCount
        oState.setText("result", cResult)
        emit("formatting_complete", cResult)
    }
}

/*
Class: TaskFlow
Description: Example flow that manages tasks with multiple conditions
*/
class TaskFlow from Flow {

    func init {
        super.init()
        registerMethod("createTask")
        start("createTask")
    }

    func createTask {
        oTask = [
            :title = "New Task",
            :priority = "High",
            :status = "New"
        ]
        oState.setList("task", oTask)
        emit("task_created", oTask)

        # Executing tasks in parallel
        oThreads.createThread(1, super +".assignTask(oTask)")
        oThreads.createThread(2, super +".validateTask(oTask)")
        oThreads.setThreadName(1, "TaskAssignment")
        oThreads.setThreadName(2, "TaskValidation")
    }

    func assignTask oTask {
        oTask[:assignee] = "John Doe"
        oState.setList("task", oTask)
        emit("task_assigned", oTask)
    }

    func validateTask oTask {
        bValid = true
        if oTask[:title] = "" { bValid = false }
        if oTask[:priority] = "" { bValid = false }
        emit("validation_complete", bValid)
    }
}

/*
Class: ParallelFlow
Description: Example flow that executes operations in parallel
*/
class ParallelFlow from Flow {

    func init {
        super.init()
        registerMethod("startParallel")
        start("startParallel")
    }

    func startParallel {
        # Executing operations in parallel
        oThreads.createThread(1, super +".process1()")
        oThreads.createThread(2, super +".process2()")
        oThreads.setThreadName(1, "Process1")
        oThreads.setThreadName(2, "Process2")

        # Waiting for completion of operations
        oThreads.joinAllThreads()

        # Combining results
        combineResults()
    }

    func process1 {
        # Simulating processing
        oState.setNumber("result1", 10)
        emit("process1_complete", 10)
    }

    func process2 {
        # Simulating processing
        oState.setNumber("result2", 20)
        emit("process2_complete", 20)
    }

    func combineResults {
        nTotal = oState.getNumber("result1") + oState.getNumber("result2")
        oState.setNumber("total", nTotal)
        emit("all_complete", nTotal)
    }
}

/*
Class: DataProcessingFlow
Description: Example flow that processes data and handles errors
*/
class DataProcessingFlow from Flow {

    func init {
        super.init()
        registerMethod("loadData")
        start("loadData")
    }

    func loadData {
        try {
            aData = [1, 2, "three", 4, 5]
            oState.setList("raw_data", aData)

            # Creating thread for data validation
            oThreads.createThread(1, super +".validateData(aData)")
            oThreads.setThreadName(1, "DataValidation")
        catch
            emit("data_error", "Error loading data: " + cCatchError)
        }
    }

    func validateData aData {
        aValidData = []
        aErrors = []

        #   Locking the mutex
        oThreads.lockMutex(nMutexId)

        for item in aData {
            if type(item) = "NUMBER" {
                add(aValidData, item)
            else
                add(aErrors, "Invalid value: " + item)
            }
        }

        oState.setList("valid_data", aValidData)
        oState.setList("errors", aErrors)

        # Unlocking the mutex
        oThreads.unlockMutex(nMutexId)

        if len(aErrors) > 0 {
            # Handling errors in a separate thread
            oThreads.createThread(2, super +".handleErrors(aErrors)")
            oThreads.setThreadName(2, "ErrorHandler")
        else
            # Processing valid data in a separate thread
            oThreads.createThread(3, super +".processData(aValidData)")
            oThreads.setThreadName(3, "DataProcessor")
        }
    }

    func processData aData {
        nSum = 0
        for num in aData {
            nSum += num
        }
        oState.setNumber("result", nSum)
        emit("processing_complete", nSum)
    }

    func handleErrors aErrors {
        cErrorLog = "Detected " + len(aErrors) + " errors:"
        for error in aErrors {
            cErrorLog += nl + "- " + error
        }
        oState.setText("error_log", cErrorLog)
        emit("error_handling_complete", cErrorLog)
    }
}

/*
    Class: WorkflowFlow
    Description: Example flow that manages workflows with different states
*/
class WorkflowFlow from Flow {

    func init {
        super.init()
        registerMethod("initializeWorkflow")
        start("initializeWorkflow")
    }

    func initializeWorkflow {
        aWorkflow = [
            :status = "new",
            :steps = ["review", "approve", "implement"],
            :currentStep = 1,
            :assignee = "John Doe"
        ]
        oState.setList("workflow", aWorkflow)
        emit("workflow_initialized", aWorkflow)
    }

    func review aWorkflow {
        listen("workflow_initialized", "review")
        if aWorkflow[:currentStep] = 1 {
            aWorkflow[:status] = "in_review"
            aWorkflow[:reviewDate] = date()
            oState.setList("workflow", aWorkflow)
            emit("review_complete", aWorkflow)
        }
    }

    func approve aWorkflow {
        listen(or_(["review_complete", "review_rejected"]), "approve")

        # Simulating approval decision
        if random(2) = 1 {
            aWorkflow[:status] = "approved"
            aWorkflow[:currentStep] = 2
            emit("approval_complete", aWorkflow)
        else
            aWorkflow[:status] = "rejected"
            emit("review_rejected", aWorkflow)
        }

        oState.setList("workflow", aWorkflow)
    }

    func implement aWorkflow {
        listen("approval_complete", "implement")
        aWorkflow[:status] = "implementing"
        aWorkflow[:currentStep] = 3
        aWorkflow[:implementationDate] = date()
        oState.setList("workflow", aWorkflow)
        emit("implementation_complete", aWorkflow)
    }

    func finalizeWorkflow aWorkflow {
        listen("implementation_complete", "finalizeWorkflow")
        aWorkflow[:status] = "completed"
        aWorkflow[:completionDate] = date()
        oState.setList("workflow", aWorkflow)
        emit("workflow_complete", aWorkflow)
    }
}
