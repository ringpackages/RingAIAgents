/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
Function: getChatHistory
Description: Get chat history from memory
*/
func getChatHistory
    try {
        # Extract data from request
        nAgentId = 0
        cConversationId = NULL

        # Try extracting data from request parameters
        cAgentId = oServer["agent_id"]
        if cAgentId != NULL and cAgentId != "" {
            nAgentId = number(cAgentId)
        }
        ? logger("getChatHistory function", "Agent ID from params: " + nAgentId, :info)

        cConversationId = oServer["conversation_id"]
        ? logger("getChatHistory function", "Conversation ID from params: " + cConversationId, :info)

        # If data not found in parameters, try extracting from request body
        try {
            cBody = oServer["request"]
            ? logger("getChatHistory function", "Trying to get request content", :info)

            if cBody != NULL and trim(cBody) != "" {
                ? logger("getChatHistory function", "Request body length: " + len(cBody), :info)
                ? logger("getChatHistory function", "Request body: " + cBody, :info)

                # Try parsing data as JSON
                try {
                    # Clean text from any invisible characters
                    cBody = trim(cBody)

                    # Check if text starts with { or [
                    if left(cBody, 1) = "{" or left(cBody, 1) = "[" {
                        aBody = JSON2List(cBody)
                        ? logger("getChatHistory function", "Body parsed as JSON", :info)

                        if isList(aBody) {
                            ? logger("getChatHistory function", "JSON body keys: " + list2str(aBody), :info)

                            if aBody[:agent_id] != NULL {
                                cAgentId = aBody[:agent_id]
                                if cAgentId != NULL and cAgentId != "" {
                                    nAgentId = number(cAgentId)
                                }
                                ? logger("getChatHistory function", "Agent ID from JSON body: " + nAgentId, :info)
                            }

                            if aBody[:conversation_id] != NULL {
                                cConversationId = aBody[:conversation_id]
                                ? logger("getChatHistory function", "Conversation ID from JSON body: " + cConversationId, :info)
                            }
                        else
                            ? logger("getChatHistory function", "JSON parsed but result is not a list", :error)
                        }
                    else
                        ? logger("getChatHistory function", "Body does not start with { or [: " + left(cBody, 10), :error)
                    }
                catch
                    ? logger("getChatHistory function", "Error parsing JSON body: " + cCatchError, :error)
                }
            else
                ? logger("getChatHistory function", "Request body is empty or NULL", :warning)
            }
        catch
            ? logger("getChatHistory function", "Error getting request content: " + cCatchError, :error)
        }

        # Get conversations from memory
        aConversations = []

        # Get conversation by ID
        if cConversationId != NULL {
            # Use retrieveById function to get the conversation
            aResult = oMemory.retrieveById(cConversationId)

            if aResult != NULL {
                aMetadata = aResult[:metadata]
                add(aConversations, [
                    :id = aResult[:id],
                    :timestamp = aResult[:timestamp],
                    :agent_id = aMetadata[:agent_id],
                    :prompt = aMetadata[:prompt],
                    :response = aMetadata[:response]
                ])
            }
        # Get conversations for a specific customer or all conversations
        else
            # Use retrieve function to get conversations
            # We use retrieve instead of retrieveByTag because the latter requires two parameters
            aResults = oMemory.retrieve("chat", "", 50)
            ? logger("getChatHistory function", "Retrieved " + len(aResults) + " chat entries", :info)

            # Process the results
            for aResult in aResults {
                aMetadata = aResult[:metadata]

                # Check if customer ID is specified
                if nAgentId > 0 {
                    if aMetadata[:agent_id] = nAgentId {
                        add(aConversations, [
                            :id = aResult[:id],
                            :timestamp = aResult[:timestamp],
                            :agent_id = aMetadata[:agent_id],
                            :prompt = aMetadata[:prompt],
                            :response = aMetadata[:response]
                        ])
                    }
                else
                    add(aConversations, [
                        :id = aResult[:id],
                        :timestamp = aResult[:timestamp],
                        :agent_id = aMetadata[:agent_id],
                        :prompt = aMetadata[:prompt],
                        :response = aMetadata[:response]
                    ])
                }
            }
        }

        # Sort conversations by date (newest first)
        aConversations = sortByTimestamp(aConversations)

        # Create JSON object for response
        aResponseObj = [
            :status = "success",
            :conversations = aConversations
        ]

        # Convert object to JSON string
        cResponseJson = list2JSON(aResponseObj)

        # Return results
        ? logger("getChatHistory function", "Chat history retrieved successfully", :info)
        oServer.setContent(cResponseJson, "application/json")
    catch
        ? logger("getChatHistory function", "Error retrieving chat history: " + cCatchError, :error)

        # Create JSON object for error
        aErrorObj = [
            :status = "error",
            :message = cCatchError
        ]

        # Convert object to JSON string
        cErrorJson = list2JSON(aErrorObj)

        oServer.setContent(cErrorJson, "application/json")
    }
