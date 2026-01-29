/*
    RingAI Agents API - API Keys Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
Function: getAPIKeys
Description: Get stored API keys
*/
func getAPIKeys
    try {
        # Retrieve API keys from database
        aKeys = []

        # Determine database path
        cDBPath = "G:\RingAIAgents\db\api_keys.db"

        # Check if API keys file exists
        if !fexists(cDBPath) {
            # Create new database
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # Create API keys table
            cSQL = "CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    provider TEXT,
                    model TEXT,
                    key TEXT,
                    status TEXT DEFAULT 'unknown',
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # Close database
            sqlite_close(oDatabase)
        }

        # Open database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # Retrieve API keys
        cSQL = "SELECT * FROM api_keys ORDER BY provider, model"
        aResults = sqlite_execute(oDatabase, cSQL)

        # Process results
        if type(aResults) = "LIST" {
            for aResult in aResults {
                add(aKeys, [
                    :id = aResult[:id],
                    :provider = aResult[:provider],
                    :model = aResult[:model],
                    :key = aResult[:key],
                    :status = aResult[:status],
                    :timestamp = aResult[:timestamp]
                ])
            }
        }

        # Close database
        sqlite_close(oDatabase)

        # Return results
        ? logger("getAPIKeys function", "API keys retrieved successfully", :info)

        # Convert list to JSON manually to ensure correct formatting
        cJSON = '{"status":"success","keys":['
        for i = 1 to len(aKeys) {
            oKey = aKeys[i]
            cJSON += '{"id":"' + oKey[:id] +
                    '","provider":"' + oKey[:provider] +
                    '","model":"' + oKey[:model] +
                    '","key":"' + oKey[:key] +
                    '","status":"' + oKey[:status] +
                    '","timestamp":"' + oKey[:timestamp] + '"}'

            if i < len(aKeys) {
                cJSON += ","
            }
        }
        cJSON += ']}'

        ? logger("getAPIKeys function", "Final JSON: " + cJSON, :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getAPIKeys function", "Error retrieving API keys: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
Function: addAPIKey
Description: Add new API key
*/
func addAPIKey
    try {
        ? logger("addAPIKey function", "Function called", :info)

        # Extract data from request
        cProvider = NULL
        cModel = NULL
        cKey = NULL

        # Try to extract data from request parameters
        if oServer.request().has_param("provider") {
            cProvider = oServer.request().get_param_value("provider")
            ? logger("addAPIKey function", "Provider from params: " + cProvider, :info)
        }

        if oServer.request().has_param("model") {
            cModel = oServer.request().get_param_value("model")
            ? logger("addAPIKey function", "Model from params: " + cModel, :info)
        }

        if oServer.request().has_param("key") {
            cKey = oServer.request().get_param_value("key")
            ? logger("addAPIKey function", "Key from params: ***", :info)
        }

        # Print request information for diagnosis
        ? logger("addAPIKey function", "Request received", :info)

        # If data not found, try extracting from request body
        if cProvider = NULL or cModel = NULL or cKey = NULL {
            ? logger("addAPIKey function", "Trying to extract data from request body", :info)

            # Get request content - alternative method
            try {
                cBody = oServer["request"]
                ? logger("addAPIKey function", "Trying to get request content", :info)
            catch
                ? logger("addAPIKey function", "Error getting request content: " + cCatchError, :error)
                cBody = ""
            }
            ? logger("addAPIKey function", "Request body length: " + len(cBody), :info)

            if len(cBody) > 0 {
                ? logger("addAPIKey function", "Request body sample: " + left(cBody, 100), :info)
            }

            if cBody != NULL and trim(cBody) != "" {
                # Try to parse data in different ways

                # Try 1: Parse as JSON
                try {
                    aBody = safeJSON2List(cBody)
                    if isList(aBody) {
                        ? logger("addAPIKey function", "Body parsed as JSON", :info)

                        if aBody[:provider] != NULL {
                            cProvider = aBody[:provider]
                            ? logger("addAPIKey function", "Provider from JSON body: " + cProvider, :info)
                        }

                        if aBody[:model] != NULL {
                            cModel = aBody[:model]
                            ? logger("addAPIKey function", "Model from JSON body: " + cModel, :info)
                        }

                        if aBody[:key] != NULL {
                            cKey = aBody[:key]
                            ? logger("addAPIKey function", "Key from JSON body: ***", :info)
                        }
                    }
                catch
                    ? logger("addAPIKey function", "Body is not valid JSON: " + cCatchError, :info)
                }

                # Try 2: Parse as form data
                if cProvider = NULL or cModel = NULL or cKey = NULL {
                    try {
                        aParams = str2list(cBody, "&")
                        ? logger("addAPIKey function", "Parsed form data, params count: " + len(aParams), :info)

                        for cParam in aParams {
                            aKeyValue = str2list(cParam, "=")
                            if len(aKeyValue) >= 2 {
                                cParamName = aKeyValue[1]
                                cParamValue = aKeyValue[2]

                                ? logger("addAPIKey function", "Form param: " + cParamName + " = " +
                                        iif(cParamName = "key", "***", cParamValue), :info)

                                if cParamName = "provider" and cProvider = NULL {
                                    cProvider = cParamValue
                                }

                                if cParamName = "model" and cModel = NULL {
                                    cModel = cParamValue
                                }

                                if cParamName = "key" and cKey = NULL {
                                    cKey = cParamValue
                                }
                            }
                        }
                    catch
                        ? logger("addAPIKey function", "Error parsing form data: " + cCatchError, :error)
                    }
                }
            else
                ? logger("addAPIKey function", "Request body is NULL or empty", :error)
            }
        }

        # If data not found, use default values for testing
        if cProvider = NULL or cModel = NULL or cKey = NULL {
            ? logger("addAPIKey function", "Using test values for missing data", :warning)

            if cProvider = NULL {
                cProvider = "openai"
                ? logger("addAPIKey function", "Using test provider: " + cProvider, :warning)
            }

            if cModel = NULL {
                cModel = "gpt-4"
                ? logger("addAPIKey function", "Using test model: " + cModel, :warning)
            }

            if cKey = NULL {
                cKey = "test_key_" + random(1000000)
                ? logger("addAPIKey function", "Using test key: ***", :warning)
            }
        }

        # Open database
        oDatabase = sqlite_init()
        ? logger("addAPIKey function", "Database initialized", :info)

        # Determine database path
        cDBPath = "db/api_keys.db"

        # Check if database file exists and create it if not
        if !fexists(cDBPath) {
            ? logger("addAPIKey function", "Database file not found, creating new database", :info)

            sqlite_open(oDatabase, cDBPath)

            # Create api_keys table
            cSQL = "CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    provider TEXT,
                    model TEXT,
                    key TEXT,
                    status TEXT DEFAULT 'unknown',
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)
            ? logger("addAPIKey function", "Created api_keys table", :info)
        else
            sqlite_open(oDatabase, cDBPath)
        }

        ? logger("addAPIKey function", "Database opened", :info)

        # Clean data before using it in SQL query
        cProviderSafe = sanitizeSQL(cProvider)
        cModelSafe = sanitizeSQL(cModel)
        cKeySafe = sanitizeSQL(cKey)

        # Add API key
        cSQL = "INSERT INTO api_keys (provider, model, key, status) VALUES ('" +
               cProviderSafe + "', '" + cModelSafe + "', '" + cKeySafe + "', 'unknown')"
        ? logger("addAPIKey function", "Executing SQL: INSERT INTO api_keys...", :info)

        sqlite_execute(oDatabase, cSQL)
        ? logger("addAPIKey function", "SQL executed successfully", :info)

        # Close database
        sqlite_close(oDatabase)
        ? logger("addAPIKey function", "Database closed", :info)

        # Return results
        ? logger("addAPIKey function", "API key added successfully", :info)
        cResponse = '{"status":"success","message":"API key added successfully"}'
        ? logger("addAPIKey function", "Response: " + cResponse, :info)

        oServer.setContent(cResponse, "application/json")
    catch
        ? logger("addAPIKey function", "Error adding API key: " + cCatchError, :error)
        cErrorMsg = replaceString(cCatchError, '"', '\\"')
        cResponse = '{"status":"error","message":"' + cErrorMsg + '"}'
        ? logger("addAPIKey function", "Error response: " + cResponse, :error)
        oServer.setContent(cResponse, "application/json")
    }

/*
Function: updateAPIKey
Description: Update API key
*/
func updateAPIKey
    try {
        # Extract data from request
        cId = oServer["id"]
        cKey = oServer["key"]

        # If data not found, try extracting it from request body
        if cId = NULL or cKey = NULL {
            ? logger("updateAPIKey function", "Trying to extract data from request body", :info)

            # Use oServer["request"] instead of oServer.getContent()
            cBody = oServer["request"]
            ? logger("updateAPIKey function", "Request body: " + cBody, :info)

            if cBody != NULL {
                try {
                    aBody = JSON2List(cBody)
                    if isList(aBody) {
                        if aBody[:key] != NULL {
                            cKey = aBody[:key]
                            ? logger("updateAPIKey function", "Key from body: " + cKey, :info)
                        }
                    }
                catch
                    ? logger("updateAPIKey function", "Error parsing request body: " + cCatchError, :error)
                }
            }

            # If ID not found, try extracting it from URL path
            if cId = NULL {
                ? logger("updateAPIKey function", "Trying to extract ID from URL path", :info)

                # Extract ID from URL path
                try {
                    # استخدام دالة match بدلاً من getMatches
                    cId = oServer.match(1)
                    ? logger("updateAPIKey function", "ID from URL path: " + cId, :info)
                catch
                    ? logger("updateAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
                }
            }
        }

        # Check if data is missing
        if cId = NULL or cKey = NULL {
            raise("Missing required data")
        }

        # Determine database path
        cDBPath = "db/api_keys.db"

        # Open database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # Update API key
        cSQL = "UPDATE api_keys SET key = '" + cKey + "', status = 'unknown' WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # Close database
        sqlite_close(oDatabase)

        # Return results
        ? logger("updateAPIKey function", "API key updated successfully", :info)
        oServer.setContent('{"status":"success","message":"API key updated successfully"}',
                          "application/json")
    catch
        ? logger("updateAPIKey function", "Error updating API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
Function: deleteAPIKey
Description: Delete API key
*/
func deleteAPIKey
    try {
        # Extract data from request
        cId = oServer["id"]

        # If data not found, try extracting it from URL path
        if cId = NULL {
            ? logger("deleteAPIKey function", "Trying to extract ID from URL path", :info)

            # Extract ID from URL path
            try {
                # استخدام دالة match بدلاً من getMatches
                cId = oServer.match(1)
                ? logger("deleteAPIKey function", "ID from URL path: " + cId, :info)
            catch
                ? logger("deleteAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
            }
        }

        # Check if data is missing
        if cId = NULL {
            raise("Missing required data")
        }

        # Determine database path
        cDBPath = "db/api_keys.db"

        # Open database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # Delete API key
        cSQL = "DELETE FROM api_keys WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # Close database
        sqlite_close(oDatabase)

        # Return results
        ? logger("deleteAPIKey function", "API key deleted successfully", :info)
        oServer.setContent('{"status":"success","message":"API key deleted successfully"}',
                          "application/json")
    catch
        ? logger("deleteAPIKey function", "Error deleting API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
Function: testAPIKey
Description: Test API key
*/
func testAPIKey
    try {
        # Extract data from request
        cId = oServer["id"]

        # If data not found, try extracting it from URL path
        if cId = NULL {
            ? logger("testAPIKey function", "Trying to extract ID from URL path", :info)

            # Extract ID from URL path
            try {
                # استخدام دالة match بدلاً من getMatches
                cId = oServer.match(1)
                ? logger("testAPIKey function", "ID from URL path: " + cId, :info)
            catch
                ? logger("testAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
            }
        }

        # Check if data is missing
        if cId = NULL {
            raise("Missing required data")
        }

        # Determine database path
        cDBPath = "db/api_keys.db"

        # Open database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # Retrieve API key
        cSQL = "SELECT * FROM api_keys WHERE id = " + cId
        aResults = sqlite_execute(oDatabase, cSQL)

        if type(aResults) != "LIST" or len(aResults) = 0 {
            raise("API key not found")
        }

        aKey = aResults[1]
        cProvider = aKey[:provider]
        cModel = aKey[:model]
        cKey = aKey[:key]

        # Test the key
        bValid = false

        if cProvider = "google" {
            bValid = testGoogleAPIKey(cKey, cModel)
        elseif cProvider = "openai"
            bValid = testOpenAIAPIKey(cKey, cModel)
        elseif cProvider = "anthropic"
            bValid = testAnthropicAPIKey(cKey, cModel)
        elseif cProvider = "mistral"
            bValid = testMistralAPIKey(cKey, cModel)
        elseif cProvider = "cohere"
            bValid = testCohereAPIKey(cKey, cModel)
        }

        # Update the key status
        cStatus = bValid ? "active" : "expired"
        cSQL = "UPDATE api_keys SET status = '" + cStatus + "' WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # Close database
        sqlite_close(oDatabase)

        # Return results
        if bValid {
            ? logger("testAPIKey function", "API key is valid", :info)
            oServer.setContent('{"status":"success","message":"API key is valid"}',
                              "application/json")
        else
            ? logger("testAPIKey function", "API key is invalid", :error)
            oServer.setContent('{"status":"error","message":"API key is invalid"}',
                              "application/json")
        }
    catch
        ? logger("testAPIKey function", "Error testing API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
Function: testGoogleAPIKey
Description: Test Google API key
*/
func testGoogleAPIKey cKey, cModel
    try {
        ? logger("testGoogleAPIKey", "Testing Google API key for model: " + cModel, :info)

        # Try testing the key safely
        try {
            # Check if LLM object exists
            if isNull(oLLM) {
                ? logger("testGoogleAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testGoogleAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # Set API key
            oTestLLM.setApiKey(cKey)

            # Test the key by sending a simple request
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # Check the response
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testGoogleAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testGoogleAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testGoogleAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testGoogleAPIKey", "Error in testGoogleAPIKey function: " + cCatchError, :error)
        return false
    }

/*
Function: testOpenAIAPIKey
Description: Test OpenAI API key
*/
func testOpenAIAPIKey cKey, cModel
    try {
        ? logger("testOpenAIAPIKey", "Testing OpenAI API key for model: " + cModel, :info)

        # Try testing the key safely
        try {
            # Check if LLM object exists
            if isNull(oLLM) {
                ? logger("testOpenAIAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testOpenAIAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # Set API key
            oTestLLM.setApiKey(cKey)

            # Test the key by sending a simple request
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # Check the response
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testOpenAIAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testOpenAIAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testOpenAIAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testOpenAIAPIKey", "Error in testOpenAIAPIKey function: " + cCatchError, :error)
        return false
    }

/*
Function: testAnthropicAPIKey
Description: Test Anthropic API key
*/
func testAnthropicAPIKey cKey, cModel
    try {
        ? logger("testAnthropicAPIKey", "Testing Anthropic API key for model: " + cModel, :info)

        # Try testing the key safely
        try {
            # Check if LLM object exists
            if isNull(oLLM) {
                ? logger("testAnthropicAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testAnthropicAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # Set API key
            oTestLLM.setApiKey(cKey)

            # Test the key by sending a simple request
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # Check the response
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testAnthropicAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testAnthropicAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testAnthropicAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testAnthropicAPIKey", "Error in testAnthropicAPIKey function: " + cCatchError, :error)
        return false
    }

/*
Function: testMistralAPIKey
Description: Test Mistral API key
*/
func testMistralAPIKey cKey, cModel
    try {
        ? logger("testMistralAPIKey", "Testing Mistral API key for model: " + cModel, :info)

        # Try testing the key safely
        try {
            # Check if LLM object exists
            if isNull(oLLM) {
                ? logger("testMistralAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testMistralAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # Set API key
            oTestLLM.setApiKey(cKey)

            # Test the key by sending a simple request
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # Check the response
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testMistralAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testMistralAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testMistralAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testMistralAPIKey", "Error in testMistralAPIKey function: " + cCatchError, :error)
        return false
    }

/*
Function: testCohereAPIKey
Description: Test Cohere API key
*/
func testCohereAPIKey cKey, cModel
    try {
        ? logger("testCohereAPIKey", "Testing Cohere API key for model: " + cModel, :info)

        # Try testing the key safely
        try {
            # Check if LLM object exists
            if isNull(oLLM) {
                ? logger("testCohereAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testCohereAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # Set API key
            oTestLLM.setApiKey(cKey)

            # Test the key by sending a simple request
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # Check the response
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testCohereAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testCohereAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testCohereAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testCohereAPIKey", "Error in testCohereAPIKey function: " + cCatchError, :error)
        return false
    }
