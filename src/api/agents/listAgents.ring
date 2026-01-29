/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: listAgents
Description: Get list of agents
*/
func listAgents
    try {
        ? logger("listAgents function", "listAgents function called", :info)
        ? logger("listAgents function", "Number of agents: " + len(aAgents), :info)

        aAgentsList = []

        # Collect agent information from the global variable aAgents
        for i = 1 to len(aAgents) {
            oAgent = aAgents[i]

            # Collect basic information
            aAgentInfo = [
                :id = oAgent.getID(),
                :name = oAgent.getName(),
                :role = oAgent.getRole()
            ]

            ? logger("listAgents function", "Agent " + i + ": " + oAgent.getName() + " (" + oAgent.getRole() + ")", :info)
            add(aAgentsList, aAgentInfo)
        }

        # If no agents are found, create default agents
        if len(aAgentsList) = 0 {
            ? logger("listAgents function", "No agents found, creating default agents", :info)

            # Create default agent
            oDefaultAgent = new Agent("Default Assistant", "A helpful AI assistant that can answer questions and provide information.")
            oDefaultAgent {
                setRole("Assistant")
                addSkill("General Knowledge", 90)
                setLanguageModel("gemini-1.5-flash")
            }

            # Add default agent to the global variable
            add(aAgents, oDefaultAgent)

            # Add default agent to the response list
            add(aAgentsList, [
                :id = oDefaultAgent.getID(),
                :name = oDefaultAgent.getName(),
                :role = oDefaultAgent.getRole()
            ])

            # Create coding agent
            oCodingAgent = new Agent("Code Assistant", "A specialized AI assistant for programming and software development.")
            oCodingAgent {
                setRole("Developer")
                addSkill("Programming", 95)
                setLanguageModel("gemini-1.5-flash")
            }

            # Add coding agent to the global variable
            add(aAgents, oCodingAgent)

            # Add coding agent to the response list
            add(aAgentsList, [
                :id = oCodingAgent.getID(),
                :name = oCodingAgent.getName(),
                :role = oCodingAgent.getRole()
            ])

            # Save default agents to database
            saveAgents()
        }

        # Convert list to JSON manually to ensure correct formatting
        ? logger("listAgents function", "Creating JSON manually", :info)

        cJSON = '{"agents":['
        for i = 1 to len(aAgentsList) {
            oAgent = aAgentsList[i]

            # Ensure ID is a string
            cId = string(oAgent[:id])

            cJSON += '{"id":"' + cId +
                    '","name":"' + oAgent[:name] +
                    '","role":"' + oAgent[:role] + '"}'

            if i < len(aAgentsList) {
                cJSON += ","
            }
        }
        cJSON += ']}'

        # Log final JSON for debugging
        ? logger("listAgents function", "Final JSON: " + cJSON, :info)

        ? logger("listAgents function", "Agents listed successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listAgents function", "Error listing agents: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
