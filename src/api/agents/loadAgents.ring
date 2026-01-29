/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: loadAgents
Description: Load available agents
*/
func loadAgents
    try {
        # Clear current list of agents
        aAgents = []

        # Determine database path
        cDBPath = "G:\RingAIAgents\db\agents.db"

        # Check if agents database exists
        if fexists(cDBPath) {
            # Open database
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # Retrieve agents
            cSQL = "SELECT * FROM agents ORDER BY id"
            aResults = sqlite_execute(oDatabase, cSQL)

            # Process results
            if type(aResults) = "LIST" and len(aResults) > 0 {
                for aResult in aResults {
                    # Create new agent
                    ? logger("loadAgents function", "Creating agent: " + aResult[:name], :info)

                    try {
                        oAgent = new Agent(aResult[:name], aResult[:goal])
                        ? logger("loadAgents function", "Agent created successfully", :info)

                      /*  # Check if methods exist
                        if methodExists(oAgent, "getName") {
                            ? logger("loadAgents function", "getName method exists", :info)
                        else
                            ? logger("loadAgents function", "getName method does NOT exist", :error)
                        }

                        if methodExists(oAgent, "getRole") {
                            ? logger("loadAgents function", "getRole method exists", :info)
                        else
                            ? logger("loadAgents function", "getRole method does NOT exist", :error)
                        }

                        if methodExists(oAgent, "getId") {
                            ? logger("loadAgents function", "getId method exists", :info)
                        else
                            ? logger("loadAgents function", "getId method does NOT exist", :error)
                        }*/

                        # Set properties
                        oAgent.setRole(aResult[:role])
                        oAgent.setLanguageModel(aResult[:language_model])
                    catch
                        ? logger("loadAgents function", "Error creating agent: " + cCatchError, :error)
                    }

                    # Set skills
                    try {
                        ? logger("loadAgents function", "Loading skills for agent: " + aResult[:name], :info)

                        # Check if skills exist
                        if aResult[:skills] != NULL and len(aResult[:skills]) > 2 {  # More than "{}"
                            ? logger("loadAgents function", "Skills JSON: " + aResult[:skills], :info)

                            # Try to convert JSON to list
                            try {
                                aSkills = JSON2List(aResult[:skills])
                                ? logger("loadAgents function", "Skills after JSON2List: " + toCode(aSkills), :info)

                                # Check if aSkills is a list
                                if islist(aSkills) {
                                    # Add all skills
                                    for i = 1 to len(aSkills) {
                                        aSkill = aSkills[i]
                                        if isList(aSkill) and aSkill[:name] != NULL {
                                            nLevel = 50  # Default level
                                            if aSkill[:proficiency] != NULL {
                                                nLevel = number(aSkill[:proficiency])
                                            elseif aSkill[:level] != NULL
                                                nLevel = number(aSkill[:level])
                                            }
                                            ? logger("loadAgents function", "Adding skill: " + aSkill[:name] + " with level: " + nLevel, :info)
                                            oAgent.addSkill(aSkill[:name], nLevel)
                                        }
                                    }
                                }
                            catch
                                ? logger("loadAgents function", "Error parsing skills JSON: " + cCatchError, :error)
                            }
                        else
                            ? logger("loadAgents function", "No skills found or empty skills JSON", :info)
                            # Add default skills
                            oAgent.addSkill("General Knowledge", 50)
                        }
                    catch
                        ? logger("loadAgents function", "Error loading skills: " + cCatchError, :error)
                    }

                    # Set personality traits
                    try {
                        aPersonality = JSON2List(aResult[:personality])
                        if isList(aPersonality) {
                            oAgent.setPersonalityTraits(aPersonality)
                        }
                    catch
                        # Ignore errors
                    }

                    # Add agent to list
                    add(aAgents, oAgent)
                }
            }

            # Close database
            sqlite_close(oDatabase)
        }

        # If no agents, create default agents
        if len(aAgents) = 0 {
            # Create default agent
            ? logger("loadAgents function", "Creating default agent", :info)

            try {
                oDefaultAgent = new Agent("Default Assistant", "A helpful AI assistant that can answer questions and provide information.")
                ? logger("loadAgents function", "Default agent created successfully", :info)

               /* # Check if methods exist
                if methodExists(oDefaultAgent, "getName") {
                    ? logger("loadAgents function", "getName method exists in default agent", :info)
                else
                    ? logger("loadAgents function", "getName method does NOT exist in default agent", :error)
                }

                if methodExists(oDefaultAgent, "getRole") {
                    ? logger("loadAgents function", "getRole method exists in default agent", :info)
                else
                    ? logger("loadAgents function", "getRole method does NOT exist in default agent", :error)
                }

                if methodExists(oDefaultAgent, "getId") {
                    ? logger("loadAgents function", "getId method exists in default agent", :info)
                else
                    ? logger("loadAgents function", "getId method does NOT exist in default agent", :error)
                }*/
 
                oDefaultAgent {
                    setRole("Assistant")
                    addSkill("General Knowledge", 90)
                    addSkill("Problem Solving", 85)
                    setLanguageModel("gemini-1.5-flash")
                    setPersonalityTraits([
                        :openness = 8,
                        :conscientiousness = 9,
                        :extraversion = 7,
                        :agreeableness = 9,
                        :neuroticism = 2
                    ])
                }
            catch
                ? logger("loadAgents function", "Error creating default agent: " + cCatchError, :error)
            }

            # Add default agent to list
            add(aAgents, oDefaultAgent)

            # Create coding agent
            oCodingAgent = new Agent("Code Assistant", "A specialized AI assistant for programming and software development.")
            oCodingAgent {
                setRole("Developer")
                addSkill("Programming", 95)
                addSkill("Debugging", 90)
                addSkill("Code Review", 85)
                setLanguageModel("gemini-1.5-flash")
                setPersonalityTraits([
                    :openness = 7,
                    :conscientiousness = 10,
                    :extraversion = 5,
                    :agreeableness = 8,
                    :neuroticism = 3
                ])
            }

            # Add coding agent to list
            add(aAgents, oCodingAgent)

            # Create education agent
            oEducationAgent = new Agent("Education Assistant", "An AI assistant specialized in teaching and explaining complex concepts.")
            oEducationAgent {
                setRole("Teacher")
                addSkill("Teaching", 95)
                addSkill("Explanation", 90)
                addSkill("Knowledge", 85)
                setLanguageModel("gemini-1.5-flash")
                setPersonalityTraits([
                    :openness = 9,
                    :conscientiousness = 8,
                    :extraversion = 8,
                    :agreeableness = 10,
                    :neuroticism = 2
                ])
            }

            # Add education agent to list
            add(aAgents, oEducationAgent)

            # Save default agents to database
            saveAgents()
        }

        # Register agents with monitor
        try {
            if isObject(oMonitor) {
                for i = 1 to len(aAgents) {
                    if isObject(aAgents[i]) {
                        oMonitor.registerAgent(aAgents[i])
                    }
                }
            }
        catch
            ? logger("loadAgents function", "Error registering agents with monitor: " + cCatchError, :error)
        }

        return aAgents
    catch
        ? logger("loadAgents function", "Error loading agents: " + cCatchError, :error)
        return []
    }
