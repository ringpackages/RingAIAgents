/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: addAgent
Description: Add a new agent
*/
func addAgent
    try {
        ? logger("addAgent function", "Adding agent: " + oServer["name"], :info)
        oAgent = new Agent(oServer["name"], oServer["goal"]) {
            setRole(oServer["role"])

            # Initialize skills
            if oServer["skills"] != NULL {
                # Split skills separated by commas
                Skills = split(oServer["skills"], ",")
                ? logger("addAgent function", "Skills to add: " + ToCode(Skills), :info)

                # Add each skill
                for i = 1 to len(Skills) {
                    cSkill = trim(Skills[i])
                    if len(cSkill) > 0 {
                        ? logger("addAgent function", "Adding skill: " + cSkill, :info)
                        try {
                            addSkill(cSkill, 50)  # Default level 50
                        catch
                            ? logger("addAgent function", "Error adding skill: " + cCatchError, :error)
                        }
                    }
                }

                # Print skills after initialization
                try {
                    ? logger("addAgent function", "Initial skills: " + ToCode(getSkills()), :info)
                catch
                    ? logger("addAgent function", "Error getting skills: " + cCatchError, :error)
                }
            else
                # Add default skill if no skills specified
                ? logger("addAgent function", "No skills specified, adding default skill", :info)
                addSkill("General Knowledge", 50)
            }

            # Initialize properties
            setProperties(oServer["properties"])

            # Initialize personality traits
            setPersonalityTraits([
                :openness = number(oServer["openness"]),
                :conscientiousness = number(oServer["conscientiousness"]),
                :extraversion = number(oServer["extraversion"]),
                :agreeableness = number(oServer["agreeableness"]),
                :neuroticism = number(oServer["neuroticism"])
            ])

            # Initialize language model
            setLanguageModel(oServer["language_model"])
        }

        # Add agent and register it in the monitor
        add(aAgents, oAgent)
        oMonitor.registerAgent(oAgent)

        # Store agent information in memory content, type, priority, tags, metadata
        oMemory.store([
            :content = "Agent created: " + oAgent.getName(),
            :type =  oMemory.LONG_TERM ,
            :priority = 8,
            :tags = ["agent", "creation"],
            :metadata = [:timestamp = TimeList()[5]]
        ])

        # Save agents to database
        saveAgents()

        oServer.setContent('{"status":"success","message":"Agent added successfully","id":' +
                          len(aAgents) + '}', "application/json")
    catch
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
