# The summonses were transferred to libAgentAi.ring

/*
the class: Flow
the description: represents the workflow in the system and manages the sequence of tasks and states
*/
class Flow {
    # the public variables
    cId
    oState
    aListeners
    bPersist
    oThreads
    nMutexId
    aRegisteredMethods

    func init {
        cId = generateUniqueId("flow_")
        oState = new State()
        aListeners = []
        # create thread manager with 4 threads
        oThreads = new ThreadManager(4)
        # create mutex for synchronization
        this.nMutexId = oThreads.createRecursiveMutex()
       // oThreads.dumpThreadInfo()

        # register available methods
        aRegisteredMethods = []
    }

    /*
    the function: start
    the description: sets the starting point of the workflow
    the input: cMethodName - the name of the function to start the workflow
    */
    func start cMethodName {
        return addListener(:start, cMethodName)
    }

    /*
    the function: listen
    the description: adds a listener for a specific event
    the input: cEvent - the event to listen to
             cMethodName - the name of the function to execute when the event occurs
    */
    func listen cEvent, cMethodName {
        return addListener(cEvent, cMethodName)
    }

    /*
    the function: or_
    the description: merges listeners so that the function is executed when any of them occurs
    the input: aEvents - list of events
    */
    func or_ aEvents {
        if type(aEvents) != "LIST" {
            raise("A list of events must be passed around.")
        }
        return "or:" + list2str(aEvents)
    }

    /*
    the function: and_
    the description: merges listeners so that the function is executed when all of them occur
    the input: aEvents - list of events
    */
    func and_ aEvents {
        if type(aEvents) != "LIST" {
            raise("A list of events must be passed around.")
        }
        return "and:" + list2str(aEvents)
    }

    /*
    the function: parallel
    the description: executes a list of tasks in parallel
    the input: aTasks - list of tasks to execute
    */
    func parallel aTasks {
        if type(aTasks) != "LIST" {
            raise("A list of tasks must be passed around.")
        }

        # execute tasks in parallel threads
        for i = 1 to len(aTasks) {
            oThreads.createThread(i, aTasks[i])
            oThreads.setThreadName(i, "Task_" + i)
        }
    }

    /*
    the function: waitAll
    the description: waits for all parallel tasks to complete
    */
    func waitAll {
        oThreads.joinAllThreads()
    }

    /*
    the function: execute
    the description: executes the flow
    */
    func execute {
        emit(:start, null)
        waitAll()
    }

    //private

    /*
    the function: addListener
    the description: adds an internal listener
    the input: cEvent - the event
             cMethod - the listener function
    */
    func addListener cEvent, cMethod {
        oThreads.lockMutex(this.nMutexId)
        aListener = [
            :event = cEvent,
            :method = cMethod
        ]
        add(aListeners, aListener)
        oThreads.unlockMutex(this.nMutexId)

    }

    /*
    the function: emit
    the description: emits an event
    the input: cEvent - the event to emit
             xData - the data associated with the event
    */
    func emit cEvent, xData {
        if this.nMutexId != 0 {
            oThreads.lockMutex(this.nMutexId)
            aCurrentListeners = aListeners
            oThreads.unlockMutex(this.nMutexId)
        else 
            aCurrentListeners = aListeners
        }

        nThreadId = 1
        for listener in aCurrentListeners {
            if isMatchingEvent(listener[:event], cEvent) {
                listenerMethod = listener[:method]

                # try to call the method using callMethod
                if callMethod(listenerMethod, xData)
                    # method called successfully
                else
                    # using the traditional method
                    wrapperFunc = listenerMethod + "(" + xData + ")"
                    oThreads.createThread(nThreadId, wrapperFunc)
                    oThreads.setThreadName(nThreadId, "Event_" + cEvent + "_" + nThreadId)
                    nThreadId++
                ok
            }
        }
    }

    /*
    the function: isMatchingEvent
    the description: checks if the event matches the pattern
    the input: cPattern - the event pattern
             cEvent - the actual event
    the output: true if there is a match
    */
    func isMatchingEvent cPattern, cEvent {
        if left(cPattern, 3) = "or:" {
            aEvents = str2list(substr(cPattern, 4))
            for event in aEvents {
                if event = cEvent return true ok
            }
            return false
        elseif left(cPattern, 4) = "and:"
            aEvents = str2list(substr(cPattern, 5))
            for event in aEvents {
                if event != cEvent return false ok
            }
            return true
        }
        return cPattern = cEvent
    }

    /*
    the function: cleanup
    the description: cleans up the resources used
    */
    func cleanup {
        if oThreads != null {
            oThreads.destroy()
            oThreads = null
        }
    }

    /*
    the function: registerMethod
    the description: registers a method to be called from the parent class
    the input: cMethodName - the name of the method to register
    */
    func registerMethod cMethodName {
        add(aRegisteredMethods, cMethodName)
    }

    /*
    the function: callMethod
    the description: calls a registered method
    the input: cMethodName - the name of the method to call
               xData - the data to pass to the method
    */
    func callMethod cMethodName, xData {
        if find(aRegisteredMethods, cMethodName) > 0 {
            if xData = NULL
                call cMethodName()
            else
                call cMethodName(xData)
            ok
            return true
        }
        return false
    }

    /*
    the function: destructor
    the description: cleans up the resources when the object is deleted
    */
    func destructor {
        cleanup()
    }
}

