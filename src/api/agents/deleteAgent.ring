/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: deleteAgent
Description: Delete an agent
*/
func deleteAgent
    try {
        # Check if agent ID exists in parameters
        cAgentID = ""

        # Print request method for debugging
        ? "Request method: " + oServer.getRequestMethod()

        # Try to get agent ID from URL parameters
        try {
            cAgentID = oServer.match(1)
            ? logger("deleteAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("deleteAgent function", "Error getting URL match parameter", :error)
        }

        # If ID is empty, try to get it from query parameters
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("deleteAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("deleteAgent function", "Error getting variable", :error)
            }
        }

        # If ID is still empty, return error
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("deleteAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # Check if ID is valid
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        ? logger("deleteAgent function", "Deleting agent with ID: " + cAgentID, :info)

        # Search for agent by ID
        nIndex = 0
        oAgentToDelete = NULL

        # Convert ID to string for comparison
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())

            if cCurrentID = cAgentID {
                nIndex = i
                oAgentToDelete = aAgents[i]
                ? logger("deleteAgent function", "Found agent for deletion: " + oAgentToDelete.getName(), :info)
                exit
            }
        }

        if isObject(oAgentToDelete) {
            # Remove agent from monitor
            try {
                if isObject(oMonitor) {
                    oMonitor.unregisterAgent(oAgentToDelete)
                }
            catch
                # Ignore errors
            }

            # Remove agent
            del(aAgents, nIndex)

            # Save agents to database
            saveAgents()

            ? logger("deleteAgent function", "Agent deleted successfully", :info)
            oServer.setContent('{"status":"success","message":"Agent deleted successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found with ID: ' + cAgentID + '"}',
                              "application/json")
        }
    catch
        ? logger("deleteAgent function", "Error deleting agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
