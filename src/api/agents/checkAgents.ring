/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: checkAgents
Description: Check agents status
*/
func checkAgents
    try {
        ? logger("checkAgents function", "Checking agents status...", :info)
        ? logger("checkAgents function", "Number of agents: " + len(aAgents), :info)
        
        for i = 1 to len(aAgents) {
            oAgent = aAgents[i]
            ? logger("checkAgents function", "Agent " + i + ":", :info)
            ? logger("checkAgents function", "  ID: " + oAgent.getID(), :info)
            ? logger("checkAgents function", "  Name: " + oAgent.getName(), :info)
            ? logger("checkAgents function", "  Role: " + oAgent.getRole(), :info)
            
            # Check skills
            aSkills = oAgent.getSkills()
            ? logger("checkAgents function", "  Skills count: " + len(aSkills), :info)
            for j = 1 to len(aSkills) {
                ? logger("checkAgents function", "    Skill " + j + ": " + aSkills[j][:name] + " (" + aSkills[j][:proficiency] + ")", :info)
            }
        }
        
        ? logger("checkAgents function", "Agents checked successfully", :info)
        oServer.setContent('{"status":"success","message":"Agents checked successfully","count":' + len(aAgents) + '}', "application/json")
    catch
        ? logger("checkAgents function", "Error checking agents: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}', "application/json")
    }
