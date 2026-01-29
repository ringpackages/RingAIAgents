/*
    RingAI Agents Library - Helper Functions
*/
/*
load "stdlib.ring"
load "consolecolors.ring"

if isMainSourceFile() {
    # Example usage
    ? generateUniqueId("agent_")

    aSkills = ["JavaScript", "Python", "React"]
    ? join(aSkills, ", ")
    ? ToCode(aSkills)
}
*/

/*
function validateString
Description: Check if the variable is a string
Parameters: cStr - The variable to check
Return: true if the variable is a string, false if not
*/
func validateString cStr
    if type(cStr) != "STRING"{
        return false
    }
    return true

/*
function validateNumber
Description: Check if the variable is a number
Parameters: nNum - The variable to check
Return: true if the variable is a number, false if not
*/
func validateNumber nNum
    if type(nNum) != "NUMBER"{
        return false
    }
    return true

/*
function validateList
Description: Check if the variable is a list
Parameters: aList - The variable to check
Return: true if the variable is a list, false if not
*/
func validateList aList
    if type(aList) != "LIST"{
        return false
    }
    return true

/*
function isList
Description: Check if the variable is a list
Parameters: aList - The variable to check
Return: true if the variable is a list, false if not
*/
func isList aList
    return type(aList) = "LIST"

/*
function validateObject
Description: Check if the variable is an object
Parameters: oObj - The variable to check
Return: true if the variable is an object, false if not
*/
func validateObject oObj
    if type(oObj) != "OBJECT"{
        return false
    }
    return true

/*
function validateBoolean
Description: Check if the variable is a boolean
Parameters: bValue - The variable to check
Return: true if the variable is a boolean, false if not
*/
func validateBoolean bValue
    if type(bValue) != "NUMBER" or (bValue != 0 and bValue != 1){
        return false
    }
    return true

/*
function sanitizeSQL
Description: Sanitize text before using it in SQL queries
Parameters: cText - The text to sanitize
Return: The sanitized text
*/
func sanitizeSQL cText
    if cText = NULL {
        return ""
    }

    # Replace special characters
    cText = replaceString(cText, "'", "''")
    cText = replaceString(cText, "\\", "\\\\")

    return cText

/*
function replaceString
Description: Replace all occurrences of a string in a string
Parameters: cStr - The string to replace in, cOld - The string to replace, cNew - The string to replace with
Return: The string with all occurrences of the old string replaced with the new string
*/
func replaceString cStr, cOld, cNew
    cResult = ""
    nOldLen = len(cOld)
    nPos = substr(cStr, cOld)

    while nPos > 0
        cResult += substr(cStr, 1, nPos-1) + cNew
        cStr = substr(cStr, nPos + nOldLen)
        nPos = substr(cStr, cOld)
    end

    return cResult + cStr

/*
function join
Description: Join list elements with a specified separator
Parameters: aList - The list to join elements from, cSeparator - The separator between elements
Return: A string containing the list elements separated by the specified separator
*/
func join aList, cSeparator
    cResult = ""
    for i = 1 to len(aList) {
        cResult += aList[i]
        if i < len(aList) {
            cResult += cSeparator
        }
    }
    return cResult

/*
function iif
Description: Short-circuit conditional function (if-else)
Parameters:
    - condition: The condition to test
    - value1: The value to return if the condition is true
    - value2: The value to return if the condition is false
Return: value1 if the condition is true, value2 if the condition is false
*/
func iif condition, value1, value2
    if condition return value1 else return value2 ok
    

/*
function timeDiff
Description: Calculate the time difference in seconds between two timestamps
Parameters:
    - cTime1: The first timestamp in "MM/DD/YYYY HH:MM:SS" format
    - cTime2: The second timestamp in "MM/DD/YYYY HH:MM:SS" format
Return: The time difference in seconds between the two timestamps
*/
func timeDiff cTime1, cTime2
    # Split timestamps into date and time parts
    aTime1 = split(cTime1, " ")
    aTime2 = split(cTime2, " ")

    if len(aTime1) != 2 or len(aTime2) != 2 {
        return 0
    }

    # Convert dates to Julian days
    nJulian1 = gregorian2julian(aTime1[1])
    nJulian2 = gregorian2julian(aTime2[1])

    # Convert times to seconds
    aHMS1 = split(aTime1[2], ":")
    aHMS2 = split(aTime2[2], ":")

    if len(aHMS1) != 3 or len(aHMS2) != 3 {
        return 0
    }

    nSeconds1 = number(aHMS1[1]) * 3600 + number(aHMS1[2]) * 60 + number(aHMS1[3])
    nSeconds2 = number(aHMS2[1]) * 3600 + number(aHMS2[2]) * 60 + number(aHMS2[3])

    # Calculate total difference in seconds
    return (nJulian2 - nJulian1) * 86400 + (nSeconds2 - nSeconds1)

/*
function gregorian2julian
Description: Convert a Gregorian date to a Julian day number
Parameters:
    - cDate: The Gregorian date in "MM/DD/YYYY" format
Return: The Julian day number corresponding to the Gregorian date
*/
func gregorian2julian cDate
    aDate = split(cDate, "/")
    if len(aDate) != 3 {
        return 0
    }

    nYear = number(aDate[3])
    nMonth = number(aDate[1])
    nDay = number(aDate[2])

    if nMonth <= 2 {
        nYear--
        nMonth += 12
    }

    nA = floor(nYear / 100)
    nB = 2 - nA + floor(nA / 4)

    return floor(365.25 * (nYear + 4716)) +
           floor(30.6001 * (nMonth + 1)) +
           nDay + nB - 1524.5

/*
function julian2gregorian
Description: Convert a Julian day number to a Gregorian date
Parameters:
    - nJulian: The Julian day number
Return: The Gregorian date in "MM/DD/YYYY" format
*/
func julian2gregorian nJulian {
    nJulian = floor(nJulian + 0.5)
    
    nA = floor((nJulian - 1867216.25) / 36524.25)
    nB = nJulian + 1 + nA - floor(nA / 4)
    nC = nB + 1524
    nD = floor((nC - 122.1) / 365.25)
    nE = floor(365.25 * nD)
    nF = floor((nC - nE) / 30.6001)
    
    nDay = nC - nE - floor(30.6001 * nF)
    nMonth = nF - 1
    if nMonth > 12 {
        nMonth = nMonth - 12
    }
    nYear = nD - 4715
    if nMonth > 2 {
        nYear--
    }
    
    # Format the date as MM/DD/YYYY
    return padLeft(string(nMonth), "0", 2) + "/" + 
           padLeft(string(nDay), "0", 2) + "/" + 
           string(nYear)
}

/*
function URLEncode
Description: Encode a string for use in URLs
Parameters:
    - cStr: The string to encode
Return: The encoded string in URL format
*/
func URLEncode cStr
    cResult = ""
    for i = 1 to len(cStr) {
        c = substr(cStr, i, 1)
        if isalnum(c) or c = "-" or c = "_" or c = "." or c = "~"
            cResult += c
        else
            cResult += "%" + hex(ascii(c))
        ok
    }
    return cResult

/*
function assert
Description: Check the truth of a condition and display a colored message
Parameters:
    - bCondition: The condition to test
    - cMessage: The message to display
Return: Nothing, displays a colored message in the console
*/
func assert(bCondition, cMessage)
    if not bCondition
        ? seeColored(CC_FG_RED, CC_BG_NONE,"✗ Test failed: ") + seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage)
    else
        ? seeColored(CC_FG_GREEN, CC_BG_NONE,"✓ Test passed: ") + seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage)
    ok

/*
function seeColored
Description: Display a colored text in the console
Parameters:
    - CfgColor: The foreground color of the text
    - bgColorolor: The background color of the text
    - text: The text to display
Return: The colored text
*/
func seeColored CfgColor, bgColorolor, text
    cc_print(CfgColor | bgColorolor, text)

/*
function generateUniqueId
Description: Generate a unique identifier
Parameters:
    - cName: The prefix of the identifier (e.g. "agent_" or "team_")
Return: A unique identifier in UUID format
*/
func generateUniqueId cName
        cUUID =	"xxx_xxxx_4xxx_yxxx_xxxx"
        for cChar = 1 to len( cUUID)
                cRand16 = hex(random(15))
                cRand3 = hex(random(3))
                if cUUID[cChar] ="x"
                    cUUID[cChar]=cRand16
                elseif cUUID[cChar] ="y"
                    cUUID[cChar]= cRand3
                ok
        next
        return cName + "_" + cUUID

/*
function methodExists
Description: Check if a method exists in an object
Parameters:
    - oObject: The object to check
    - cMethodName: The name of the method to check
Return: true if the method exists, false otherwise
*/
func methodExists oObject, cMethodName
    if type(oObject) != "OBJECT" or type(cMethodName) != "STRING" {
        return false
    }
    if find(methods(oObject), cMethodName) > 0 {
        return true
    }   
    return false

/*
function logger
Description: Log messages in the console with different colors based on message type
Parameters:
    - cComponent: The name of the component that performs the logging
    - cMessage: The message to log
    - cStatus: The type of the message (:error, :warning, :success, :info, :save)
Return: Nothing, displays a colored message in the console or saves it to a file
*/
func logger cComponent, cMessage, cStatus
    if ServerDebug = false {
        return
    }

        for Item in aDebag {

            if Item = :error and cStatus = :error{
                ? seeColored(CC_FG_DARK_RED, CC_BG_NONE,TimeList()[5]+ ' -->') +
                seeColored(CC_FG_RED, CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_RED, CC_BG_NONE,cMessage ) + nl

            }

            if Item  = :warning and cStatus = :warning {
                ? seeColored(CC_FG_DARK_YELLOW, CC_BG_NONE,TimeList()[5] + ' -->') +
                seeColored(CC_FG_YELLOW , CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage ) + nl
            }

            if Item  = :success and cStatus = :success {
                ? seeColored(CC_FG_DARK_GREEN, CC_BG_NONE,TimeList()[5]+ ' -->')  +
                seeColored(CC_FG_GREEN, CC_BG_NONE, ' [' + cComponent+ '] : ')  +
                seeColored(CC_FG_GREEN, CC_BG_NONE,cMessage ) + nl
            }

            if Item = :info and cStatus = :info {
                ? seeColored(CC_FG_DARK_CYAN, CC_BG_NONE,TimeList()[5] + ' -->')  +
                seeColored(CC_FG_CYAN, CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_CYAN, CC_BG_NONE,cMessage ) + nl
            }
            if Item = :save {
                # save to file
                fp = fopen("log.txt", "a")
                cStr = TimeList()[5] + ' --> [' +cComponent+ '] ' + cMessage + nl
                fwrite(fp, cStr)
                fclose(fp)
            }
        }


/*
function ToCode
Description: Convert a list, object, or any data structure to a formatted string with colors
Parameters:
    - aInput: The data structure to convert
Return: A formatted string with colors representing the data structure
*/
func ToCode(aInput)
    cCode = cc_print(CC_FG_CYAN|CC_BG_BLACK,"[")
    lStart = True
    for item in aInput {
        if !lStart {
            cCode += cc_print(CC_FG_WHITE|CC_BG_BLACK,","+Char(32))
            else
                lStart = False
        }
        if isString(item) {
            item2 = item
            item2 = substr(item2,'"','"'+char(34)+'"')
            cCode += Char(32)+cc_print(CC_FG_GREEN|CC_BG_BLACK,'"'+item2+'"')
            elseif isnumber(item)
                cCode += Char(32)+cc_print(CC_FG_YELLOW|CC_BG_BLACK,""+item)
            elseif islist(item)
                cCode += Windowsnl()
                cCode += ToCode(item)
            elseif isobject(item)
                aAttribut = attributes(item)
                cCode += cc_print(CC_FG_MAGENTA|CC_BG_BLACK,"[")
                lStart = True
                for attribut in aAttribut {
                    if !lStart {
                        cCode += cc_print(CC_FG_WHITE|CC_BG_BLACK,",")
                        else
                            lStart = False
                    }
                    value = getattribute(item,attribut)
                    cCode += cc_print(CC_FG_BLUE|CC_BG_BLACK,":"+attribut+"=")
                    if isString(value) {
                        cCode += cc_print(CC_FG_GREEN|CC_BG_BLACK,'"'+value+'"')
                        elseif isNumber(value)
                            cCode += cc_print(CC_FG_YELLOW|CC_BG_BLACK,""+value)
                        elseif isList(value)
                            cCode += ToCode(value)
                        elseif isobject(value)
                            cCode += ToCode(value)
                    }
                }
                cCode += cc_print(CC_FG_MAGENTA|CC_BG_BLACK," ]")+Windowsnl()
        }
    }
    cCode += Char(32)+cc_print(CC_FG_CYAN|CC_BG_BLACK,"]")
    return cCode


/*
function safeJSON2List
Description: Safely parse JSON with error handling
Parameters:
    - cJSON: The JSON string to parse
Return: The parsed list or NULL on error
*/
func safeJSON2List cJSON
    try {
        ? logger("safeJSON2List", "Parsing JSON: " + cJSON, :info)

        if cJSON = NULL or cJSON = "" {
            ? logger("safeJSON2List", "JSON is NULL or empty", :error)
            return NULL
        }

        # Clean the text from any invisible characters
        cJSON = trim(cJSON)

        # Check if the text starts with { or [
        if not (left(cJSON, 1) = "{" or left(cJSON, 1) = "[") {
            ? logger("safeJSON2List", "JSON does not start with { or [: " + left(cJSON, 10), :error)
            return NULL
        }

        # Try to parse JSON
        aResult = JSON2List(cJSON)

        if isList(aResult) {
            ? logger("safeJSON2List", "JSON parsed successfully", :info)
            return aResult
        else
            ? logger("safeJSON2List", "JSON parsed but result is not a list", :error)
            return NULL
        }
    catch
        ? logger("safeJSON2List", "Error parsing JSON: " + cCatchError, :error)
        return NULL
    }



/*
function sortByTimestamp
Description: Sort a list by timestamp
Parameters:
    - aList: The list to sort
Return: The sorted list
*/
func sortByTimestamp aList
    # Using quicksort algorithm
    if len(aList) <= 1 {
        return aList
    }

    aPivot = aList[1]
    aLess = []
    aEqual = []
    aGreater = []

    for i = 1 to len(aList) {
        if aList[i][:timestamp] < aPivot[:timestamp] {
            add(aLess, aList[i])
        elseif aList[i][:timestamp] = aPivot[:timestamp]
            add(aEqual, aList[i])
        else
            add(aGreater, aList[i])
        }
    }

    # Sort in descending order (newest first)
    aResult = sortByTimestamp(aGreater)
    for item in aEqual { add(aResult, item) }
    aTemp = sortByTimestamp(aLess)
    for item in aTemp { add(aResult, item) }

    return aResult

