/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: getAgent
Description: Get agent details
*/
func getAgent
    try {
        # Check if agent ID exists in parameters
        cAgentID = ""

        # Print request method for debugging
        ? "Request method: " + oServer.getRequestMethod()

        # Try to get agent ID from URL parameters
        try {
            cAgentID = oServer.match(1)
            ? logger("getAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("getAgent function", "Error getting URL match parameter", :error)
        }

        # If ID is empty, try to get it from query parameters
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("getAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("getAgent function", "Error getting variable", :error)
            }
        }

        # No longer needed since we use oServer.variable

        # If ID is still empty, return error
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("getAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # Check if ID is valid
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        ? logger("getAgent function", "Getting agent with ID: " + cAgentID, :info)

        # Search for agent by ID
        oAgent = NULL
        ? logger("getAgent function", "Searching for agent with ID: " + cAgentID + " in " + len(aAgents) + " agents", :info)

        # Convert ID to string for comparison
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())
            ? logger("getAgent function", "Agent " + i + " ID: " + cCurrentID, :info)

            if cCurrentID = cAgentID {
                oAgent = aAgents[i]
                ? logger("getAgent function", "Found agent: " + oAgent.getName(), :info)
                exit
            }
        }

        if isObject(oAgent) {
            # Get skills
            cSkills = "[]"
            try {
                aSkills = oAgent.getSkills()
                if islist(aSkills) {
                    # Convert skills to list of objects containing name property
                    aFormattedSkills = []
                    for aSkill in aSkills {
                        if isList(aSkill) and aSkill[:name] != NULL {
                            add(aFormattedSkills, aSkill)
                        }
                    }
                    cSkills = list2JSON(aFormattedSkills)
                }
            catch
                # Ignore errors
                ? logger("getAgent function", "Error getting skills: " + cCatchError, :error)
            }

            # Get personality traits
            cPersonality = []
            try {
                aPersonality = oAgent.getPersonalityTraits()
                if isList(aPersonality) {
                    cPersonality = list2JSON(aPersonality)
                }
            catch
                # Ignore errors
            }

            # Get language model
            cLanguageModel = ""
            try {
                cLanguageModel = oAgent.getLanguageModel()
            catch
                cLanguageModel = "gemini-1.5-flash"
            }

            # Get energy level
            nEnergy = 0
            try {
                nEnergy = oAgent.getEnergyLevel()
            catch
                nEnergy = 100
            }

            # Get confidence level
            nConfidence = 0
            try {
                nConfidence = oAgent.getConfidenceLevel()
            catch
                nConfidence = 5
            }

            cJSON = '{"id":"' + oAgent.getID() +
                   '","name":"' + oAgent.getName() +
                   '","role":"' + oAgent.getRole() +
                   '","goal":"' + oAgent.getGoal() +
                   '","skills":' + cSkills +
                   ',"personality":' + cPersonality +
                   ',"status":"' + oAgent.getStatus() +
                   '","language_model":"' + cLanguageModel +
                   '","energy_level":' + nEnergy +
                   ',"confidence_level":' + nConfidence + '}'

            //? logger("getAgent function", "Agent found successfully", :info)
            oServer.setContent(cJSON, "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("getAgent function", "Error getting agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
