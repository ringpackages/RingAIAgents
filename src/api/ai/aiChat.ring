/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
Function: aiChat
Description: Interaction with language model
*/
func aiChat
    try {
        # Extract data from request
        cPrompt = NULL
        cBody = NULL

        # Try to extract data from request parameters
        cPrompt = oServer["prompt"]
        ? logger("aiChat function", "Trying to get prompt from params: " + cPrompt, :info)

        # If data not found in parameters, try to extract it from request body
        if cPrompt = NULL {
            ? logger("aiChat function", "Trying to extract data from request body", :info)

            # Get request content
            try {
                cBody = oServer["request"]
                ? logger("aiChat function", "Request body length: " + len(cBody), :info)
                ? logger("aiChat function", "Request body: " + cBody, :info)

                if cBody != NULL and trim(cBody) != "" {
                    # Try to parse data as JSON
                    try {
                        # Clean text from any invisible characters
                        cBody = trim(cBody)

                        # Check if text starts with { or [
                        if left(cBody, 1) = "{" or left(cBody, 1) = "[" {
                            aBody = JSON2List(cBody)
                            ? logger("aiChat function", "Body parsed as JSON", :info)

                            if isList(aBody) {
                                if aBody[:prompt] != NULL {
                                    cPrompt = aBody[:prompt]
                                    ? logger("aiChat function", "Prompt from JSON body: " + cPrompt, :info)
                                else
                                    ? logger("aiChat function", "JSON body does not contain prompt field", :warning)
                                    ? logger("aiChat function", "JSON body keys: " + list2str(aBody), :info)
                                }
                            else
                                ? logger("aiChat function", "JSON parsed but result is not a list", :error)
                            }
                        else
                            ? logger("aiChat function", "Body does not start with { or [: " + left(cBody, 10), :error)
                        }
                    catch
                        ? logger("aiChat function", "Error parsing JSON body: " + cCatchError, :error)
                    }
                else
                    ? logger("aiChat function", "Request body is empty or NULL", :warning)
                }
            catch
                ? logger("aiChat function", "Error getting request content: " + cCatchError, :error)
            }
        }

        # If data not found, raise error
        if cPrompt = NULL {
            raise("Missing prompt data")
        }

        # Extract request parameters
        aParams = []

        # Check for agent ID
        nAgentId = 0
        cAgentId = ""

        # Try to extract agent ID from request parameters
        cAgentId = oServer["agent_id"]
        ? logger("aiChat function", "Agent ID from params: " + cAgentId, :info)

        # If agent ID not found in parameters, try to extract it from request body
        if cAgentId = NULL or cAgentId = "" {
            ? logger("aiChat function", "Trying to extract agent_id from request body", :info)

            # Use aBody that was parsed previously if available
            if isList(aBody) {
                if aBody[:agent_id] != NULL {
                    cAgentId = aBody[:agent_id]
                    ? logger("aiChat function", "Agent ID from JSON body: " + cAgentId, :info)
                else
                    ? logger("aiChat function", "JSON body does not contain agent_id field", :info)
                }
            else
                ? logger("aiChat function", "No valid JSON body available for agent_id extraction", :info)
            }
        }

        # If agent ID exists, try to convert it to number
        if cAgentId != NULL and cAgentId != "" {
            try {
                # Convert agent ID to number
                if isNumber(cAgentId) {
                    nAgentId = number(cAgentId)
                else
                    # If agent ID is text, search for agent by ID
                    for i = 1 to len(aAgents) {
                        if isObject(aAgents[i]) and methodExists(aAgents[i], "getid") {
                            if aAgents[i].getid() = cAgentId {
                                nAgentId = i
                                ? logger("aiChat function", "Found agent with ID " + cAgentId + " at index " + i, :info)
                                exit
                            }
                        }
                    }
                }
                ? logger("aiChat function", "Agent ID converted to number: " + nAgentId, :info)
            catch
                ? logger("aiChat function", "Error converting agent ID: " + cCatchError, :error)
            }
        }

        # If agent ID not found, use default agent
        if nAgentId = 0 {
            ? logger("aiChat function", "Using default agent", :info)
        }

        # Handle the selected agent
        cResponse = ""

        # Check for default agent ID
        if left(cAgentId, 13) = "agent_default" {
            ? logger("aiChat function", "Using default agent with ID: " + cAgentId, :info)

            # Use language model directly with default client context
            # API key is already set in initialize.ring

            if cAgentId = "agent_default_1" {
                cContext = "You are Default Assistant. A helpful AI assistant that can answer questions and provide information."
                oLLM.setSystemPrompt(cContext)

            elseif cAgentId = "agent_default_2"
                cContext = "You are Code Assistant. A specialized AI assistant for programming and software development."
                oLLM.setSystemPrompt(cContext)

            elseif cAgentId = "agent_default_3"
                cContext = "You are Education Assistant. An AI assistant specialized in teaching and explaining complex concepts."
                oLLM.setSystemPrompt(cContext)

            else
                cContext = "You are an AI assistant. Be helpful, concise, and accurate."
                oLLM.setSystemPrompt(cContext)
            }

            cResponse = oLLM.getResponse(cPrompt, aParams)

        elseif nAgentId > 0 and nAgentId <= len(aAgents)
            # Use the selected agent to respond to the message
            oAgent = aAgents[nAgentId]

            # Check if receiveMessage method exists in the agent
            if method_exists(oAgent, "receiveMessage") {
                aResult = oAgent.receiveMessage(cPrompt)

                if aResult[:success] {
                    if isList(aResult[:results]) and len(aResult[:results]) > 0 {
                        cResponse = aResult[:results][1]
                    else
                        cResponse = "Agent processed your message successfully."
                    }
                else
                    cResponse = "Error: " + aResult[:error]
                }
            else
                # Use language model directly with client context
                oLLM.setApiKey(sysget("GEMINI_API_KEY"))
                cContext = "You are " + oAgent.getname() + ". " + oAgent.getgoal()
                oLLM.setSystemPrompt(cContext)
                cResponse = oLLM.getResponse(cPrompt, aParams)
            }

        else
            # Use default language model
            oLLM.setApiKey(sysget("GEMINI_API_KEY"))
            oLLM.setSystemPrompt("You are an AI assistant. Be helpful, concise, and accurate.")
            cResponse = oLLM.getResponse(cPrompt, aParams)
        }

        # Store the conversation in memory
        aMetadata = [
            :prompt = cPrompt,
            :response = cResponse,
            :agent_id = nAgentId
        ]

        oMemory.store([
            :content = "Chat: " + cPrompt,
            :type = oMemory.SHORT_TERM,
            :priority = 5,
            :tags = ["chat", "interaction", "agent_" + nAgentId],
            :metadata = aMetadata
        ])

        # Create JSON object for response
        aResponseObj = [
            :status = "success",
            :response = cResponse
        ]

        # Convert object to JSON string
        cResponseJson = list2JSON(aResponseObj)

        ? logger("aiChat function", "Chat processed successfully", :info)
        oServer.setContent(cResponseJson, "application/json")
    catch
        ? logger("aiChat function", "Error processing chat: " + cCatchError, :error)

        # Create JSON object for error
        aErrorObj = [
            :status = "error",
            :message = cCatchError
        ]

        # Convert object to JSON string
        cErrorJson = list2JSON(aErrorObj)

        oServer.setContent(cErrorJson, "application/json")
    }







