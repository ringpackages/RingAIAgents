/*
the class: State
the description: manages the flow state and provides an interface for storing and retrieving data
*/
class State {
    
    func init {
        aData = []
        oThreads = new ThreadManager(1)
        nMutexId = oThreads.createRecursiveMutex()
    }

    /*
    the function: setText
    the description: sets a text value
    the input: cKey - the key
             xValue - the value
    */
    func setText cKey, xValue {
        return setValue(cKey, string(xValue))
    }

    /*
    the function: getText
    the description: gets a text value
    the input: cKey - the key
    */
    func getText cKey {
        return string(getValue(cKey))
    }

    /*
    the function: setNumber
    the description: sets a number value
    the input: cKey - the key
             xValue - the value
    */
    func setNumber cKey, xValue {
        return setValue(cKey, number(xValue))
    }

    /*
    the function: getNumber
    the description: gets a number value
    the input: cKey - the key
    */
    func getNumber cKey {
        return number(getValue(cKey))
    }

    /*
    the function: setList
    the description: sets a list value
    the input: cKey - the key
             aValue - the value
    */
    func setList cKey, aValue {
        if type(aValue) != "LIST" {
            raise("يجب تمرير قائمة")
        }
        return setValue(cKey, aValue)
    }

    /*
    the function: getList
    the description: gets a list value
    the input: cKey - the key
    */
    func getList cKey {
        xValue = getValue(cKey)
        if type(xValue) != "LIST" {
            return []
        }
        return xValue
    }

    /*
    the function: setValue
    the description: sets a value
    the input: cKey - the key
             xValue - the value
    */
    func setValue cKey, xValue {
        oThreads.lockMutex(nMutexId)
        aData[cKey] = xValue
        oThreads.unlockMutex(nMutexId)
        return self
    }

    /*
    the function: getValue
    the description: gets a value
    the input: cKey - the key
    */
    func getValue cKey {
        oThreads.lockMutex(nMutexId)
        if exists(aData, cKey) {
            xValue = aData[cKey]
        else
            xValue = null
        }
        oThreads.unlockMutex(nMutexId)
        return xValue
    }

    /*
    the function: exists
    the description: checks if a key exists
    the input: aList - the list
             xKey - the key
    */
    func exists aList, xKey {
        for item in aList {
            if item[1] = xKey {
                return true
            }
        }
        return false
    }

    /*
    the function: clear
    the description: clears the state
    */
    func clear {
        oThreads.lockMutex(nMutexId)
        aData = []
        oThreads.unlockMutex(nMutexId)
        return self
    }

    /*
    the function: getAll
    the description: gets all values
    */
    func getAll {
        oThreads.lockMutex(nMutexId)
        aCopy = aData
        oThreads.unlockMutex(nMutexId)
        return aCopy
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
    the function: destructor
    the description: cleans up the resources used
    */
    func destructor {
        cleanup()
    }
    # private
        aData = []      # array to store data
        nMutexId = 0    # mutex id for synchronization
        oThreads = null # thread manager object

}