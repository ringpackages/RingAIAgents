/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: saveAgents
Description: Save agents to database
*/
func saveAgents
    try {
        # Check if agents exist
        if len(aAgents) = 0 {
            return false
        }

        # Determine database path
        cDBPath = "G:\RingAIAgents\db\agents.db"

        # Create database if it doesn't exist
        if !fexists(cDBPath) {
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # Create agents table if it doesn't exist
            cSQL = "CREATE TABLE IF NOT EXISTS agents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT,
                    role TEXT,
                    goal TEXT,
                    skills TEXT,
                    personality TEXT,
                    language_model TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # Close database
            sqlite_close(oDatabase)
        }

        # Open database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # Delete all existing agents
        sqlite_execute(oDatabase, "DELETE FROM agents")

        # Save current agents
        for i = 1 to len(aAgents) {
            oAgent = aAgents[i]

            # Convert skills and personality traits to JSON
            cSkills = "[]"
            try {
                aSkills = oAgent.getSkills()

                # Check if aSkills is a list and not empty
                if islist(aSkills) and len(aSkills) > 0 {
                    # Print skills for debugging
                    ? logger("saveAgents function", "Skills for agent " + oAgent.getName() + ": " + list2str(aSkills), :info)

                    # Convert skills to JSON
                    try {
                        cSkills = listTojson(aSkills, 0)
                        ? logger("saveAgents function", "Skills JSON: " + cSkills, :info)
                    catch
                        ? logger("saveAgents function", "Error converting skills to JSON: " + cCatchError, :error)
                        cSkills = "[]"
                    }
                else
                    ? logger("saveAgents function", "No skills found or empty skills list for agent: " + oAgent.getName(), :info)
                }
            catch
                # Ignore errors
                ? logger("saveAgents function", "Error getting skills: " + cCatchError, :error)
            }

            cPersonality = []
            try {
                aPersonality = oAgent.getPersonalityTraits()
                if isList(aPersonality) {
                    cPersonality = listToJSON(aPersonality, 0)
                }
            catch
                # Ignore errors
            }

            # Get agent goal
            cGoal = ""
            try {
                cGoal = oAgent.getGoal()
            catch
                cGoal = "General purpose agent"
            }

            # Get language model
            cLanguageModel = ""
            try {
                cLanguageModel = oAgent.getLanguageModel()
            catch
                cLanguageModel = "gemini-1.5-flash"
            }

            # Add agent to database
            cSQL = "INSERT INTO agents (name, role, goal, skills, personality, language_model) VALUES (
                    '" + oAgent.getName() + "',
                    '" + oAgent.getRole() + "',
                    '" + cGoal + "',
                    '" + cSkills + "',
                    '" + cPersonality + "',
                    '" + cLanguageModel + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # Close database
        sqlite_close(oDatabase)

        return true
    catch
        ? logger("saveAgents function", "Error saving agents: " + cCatchError, :error)
        return false
    }
