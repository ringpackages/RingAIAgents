/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: updateAgent
Description: Update agent information
*/
func updateAgent
    try {
        # Check if agent ID exists in parameters
        cAgentID = ""

        # Print request method for debugging
        ? "Request method: " + oServer.getRequestMethod()

        # Try to get agent ID from URL parameters
        try {
            cAgentID = oServer.match(1)
            ? logger("updateAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("updateAgent function", "Error getting URL match parameter", :error)
        }

        # If agent ID is empty, try to get it from query parameters
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("updateAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("updateAgent function", "Error getting variable", :error)
            }
        }

        # If agent ID is still empty, return error
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("updateAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # Check if agent ID is valid
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        # Log update agent information
        ? logger("updateAgent function", "Updating agent with ID: " + cAgentID, :info)

        # Search for agent by ID
        oAgent = NULL

        # Convert ID to string for comparison
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())

            if cCurrentID = cAgentID {
                oAgent = aAgents[i]
                ? logger("updateAgent function", "Found agent for update: " + oAgent.getName(), :info)
                exit
            }
        }

        if isObject(oAgent) {

            # Update basic information
            oAgent.setName(oServer["name"])
            oAgent.setRole(oServer["role"])
            oAgent.setGoal(oServer["goal"])

            # Update skills
            if oServer["skills"] != NULL {
                try {
                    # Clear existing skills
                    ? logger("updateAgent function", "Clearing existing skills", :info)
                    oAgent.setSkills([])

                    # Split skills separated by commas
                    Skills = split(oServer["skills"], ",")
                    ? logger("updateAgent function", "Skills to add: " + list2str(Skills), :info)

                    # Add new skills
                    for i = 1 to len(Skills) {
                        if i <= len(Skills) {  # Check if index is within range
                            cSkill = trim(Skills[i])
                            if len(cSkill) > 0 {
                                ? logger("updateAgent function", "Adding skill: " + cSkill, :info)
                                try {
                                    oAgent.addSkill(cSkill, 50)  # Default level 50
                                catch
                                    ? logger("updateAgent function", "Error adding skill: " + cCatchError, :error)
                                }
                            }
                        }
                    }

                    # Print updated skills
                    try {
                        ? logger("updateAgent function", "Updated skills: " + list2str(oAgent.getSkills()), :info)
                    catch
                        ? logger("updateAgent function", "Error getting updated skills: " + cCatchError, :error)
                    }
                catch
                    ? logger("updateAgent function", "Error updating skills: " + cCatchError, :error)
                }
            else
                ? logger("updateAgent function", "No skills specified in update", :info)
            }

            # Update language model
            if oServer["language_model"] != NULL {
                oAgent.setLanguageModel(oServer["language_model"])
            }

            # Update personality traits
            try {
                aPersonality = [
                    :openness = number(oServer["openness"]),
                    :conscientiousness = number(oServer["conscientiousness"]),
                    :extraversion = number(oServer["extraversion"]),
                    :agreeableness = number(oServer["agreeableness"]),
                    :neuroticism = number(oServer["neuroticism"])
                ]
                oAgent.setPersonalityTraits(aPersonality)
            catch
                # Ignore errors
            }

            # Save agents to database
            saveAgents()

            ? logger("updateAgent function", "Agent updated successfully", :info)
            oServer.setContent('{"status":"success","message":"Agent updated successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("updateAgent function", "Error updating agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
