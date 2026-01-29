load "openssllib.ring"
load "jsonlib.ring"
load "G:/RingAIAgents/src/security/EncryptionManager.ring"
//load "G:/RingAIAgents/src/utils/helpers.ring"
/*
Class: SessionManager
Description: Session manager
*/
class SessionManager {
     oConfig
    oEncryption
    cSessionKey
    cSessionIV
    aActiveSessions
    nSessionExpiry
    oBase64
    func init {
        oConfig = new SecurityConfig
        oEncryption = new EncryptionManager()
        oBase64 = new Base64()
        # Generate encryption key and initialization vector
        cSessionKey = this.oEncryption.generateKey(32)
        cSessionIV = this.oEncryption.generateIV(16)
        
        # Initialize session store
        aActiveSessions = []
        
        # Set session expiry duration (in seconds)
        nSessionExpiry = oConfig.nSessionExpiry
        
    }
    
    # Create new session
    func createSession(cUserId, cUserRole, cUserIP) {
        try {
            # Generate unique session ID
            cSessionId = generateSessionId()
            
            # Get current time in correct format
            aTimeList = timelist()
            cCurrentDateTime = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19] + " " +
                             padLeft(string(aTimeList[7]), "0", 2) + ":" +
                             padLeft(string(aTimeList[11]), "0", 2) + ":" +
                             padLeft(string(aTimeList[13]), "0", 2)
            
            # Create session data as an associative array
            aSessionData = [
                :user_id = cUserId,
                :role = cUserRole,
                :ip = cUserIP,
                :created_at = cCurrentDateTime,
                :expires_at = calculateExpiry(),
                :last_activity = cCurrentDateTime
            ]
            
            # Convert data to JSON
            cJsonData = list2json(aSessionData)
            
            # Encrypt data
            cEncryptedData = this.oEncryption.encrypte(cJsonData, cSessionKey, cSessionIV)
            
            # Store session
            add(aActiveSessions, [cSessionId, cEncryptedData])
            
            # Create session token
            cSessionToken = cSessionId + "." + oBase64.encode(cEncryptedData)
            
            return cSessionToken
        catch
            ? "Error creating session: " + cCatchError
            return ""
        }
    }
    
    # Validate session
    func validateSession cSessionToken {
        try {
            if cSessionToken = "" return false ok
            
            # Split token into ID and data
            aTokenParts = split(cSessionToken, ".")
            if len(aTokenParts) != 2 return false ok
            
            cSessionId = aTokenParts[1]
            cEncryptedData = oBase64.decode(aTokenParts[2])
            
            # Search for session
            for session in aActiveSessions {
                if session[1] = cSessionId {
                    # Decrypt session data
                    cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
                    
                    # Convert data from JSON to list
                    aSessionData = json2list(cDecryptedData)
                    
                    # Check if session has expired
                    if isSessionExpired(aSessionData[:expires_at]) {
                        destroySession(cSessionId)
                        return false
                    }
                    
                    # Update last activity time
                    updateSessionActivity(cSessionId)
                    
                    return aSessionData
                }
            }
            
            return false
        catch
            ? "Error validating session: " + cCatchError
            return false
        }
    }
    
    # Destroy session
    func destroySession cSessionId {
        for i = 1 to len(aActiveSessions) {
            if aActiveSessions[i][1] = cSessionId {
                del(aActiveSessions, i)
                return true
            }
        }
        return false
    }
    
    # Clean expired sessions
    func cleanExpiredSessions {
        for i = len(aActiveSessions) to 1 step -1 {
            cSessionId = aActiveSessions[i][1]
            cEncryptedData = aActiveSessions[i][2]
            
            # Decrypt session data
            cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
            aSessionData = json2list(cDecryptedData)
            
            # Check if session has expired
            if isSessionExpired(aSessionData[:expires_at]) {
                del(aActiveSessions, i)
            }
        }
    }
    
    # Calculate session expiry time
    func calculateExpiry {
        # Get current date and time
        aTimeList = timelist()
        
        # Convert date to full format (MM/DD/YYYY)
        cYear = aTimeList[19]  # Full year (YYYY)
        cMonth = aTimeList[6]  # Month (MM)
        cDay = aTimeList[8]    # Day (DD)
        cCurrentDate = cMonth + "/" + cDay + "/" + cYear
        
        # Get current time
        nCurrentHours = number(aTimeList[7])      # Hours
        nCurrentMinutes = number(aTimeList[11])   # Minutes
        nCurrentSeconds = number(aTimeList[13])   # Seconds
        
        # Calculate total seconds
        nTotalSeconds = nCurrentHours * 3600 + nCurrentMinutes * 60 + nCurrentSeconds + nSessionExpiry
        
        # Convert seconds to hours, minutes, and seconds
        nHours = floor(nTotalSeconds / 3600)
        nMinutes = floor((nTotalSeconds % 3600) / 60)
        nSeconds = nTotalSeconds % 60
        
        # Handle day change if hours exceed 24
        nDaysToAdd = floor(nHours / 24)
        nHours = nHours % 24
        
        # Format time
        cExpiryTime = padLeft(string(nHours), "0", 2) + ":" + 
                  padLeft(string(nMinutes), "0", 2) + ":" + 
                  padLeft(string(nSeconds), "0", 2)
        
        # Add days to date if necessary
        if nDaysToAdd > 0 {
            # Convert current date to Julian day
            nJulianDate = gregorian2julian(cCurrentDate)
            # Add days
            nNewJulianDate = nJulianDate + nDaysToAdd
            # Convert new Julian date to Gregorian date
            cNewDate = julian2gregorian(nNewJulianDate)
            return cNewDate + " " + cExpiryTime
        }
        
        return cCurrentDate + " " + cExpiryTime
    }
    
    # Check if session has expired
    func isSessionExpired cExpiry {
        cCurrentDateTime = date() + " " + time()
        nDiff = timeDiff(cExpiry, cCurrentDateTime)
        return nDiff <= 0
    }
    
    private
    
    # Generate unique session ID
    func generateSessionId {
        cRandom = randbytes (32)
        cTimestamp = timelist()[5]
        return sha256(cRandom + cTimestamp)
    }
    
    # Update last activity time for session
    func updateSessionActivity cSessionId {
        try {
            for i = 1 to len(aActiveSessions) {
                if aActiveSessions[i][1] = cSessionId {
                    # Decrypt session data
                    cEncryptedData = aActiveSessions[i][2]
                    cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
                    aSessionData = json2list(cDecryptedData)
                    
                    # Update last activity time
                    aTimeList = timelist()
                    cCurrentDateTime = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19] + " " +
                                    padLeft(string(aTimeList[7]), "0", 2) + ":" +
                                    padLeft(string(aTimeList[11]), "0", 2) + ":" +
                                    padLeft(string(aTimeList[13]), "0", 2)
                    
                    aSessionData[:last_activity] = cCurrentDateTime
                    
                    # Re-encrypt data
                    cEncryptedData = this.oEncryption.encrypte(list2json(aSessionData), cSessionKey, cSessionIV)
                    aActiveSessions[i][2] = cEncryptedData
                    
                    return true
                }
            }
            return false
        catch
            ? "Error updating session activity: " + cCatchError
            return false
        }
    }
    
    # Helper function to add leading zeros to a string
    func padLeft cStr, cPadChar, nWidth {
        while len(cStr) < nWidth {
            cStr = cPadChar + cStr
        }
        return cStr
    }
    
    # Convert Julian day to Gregorian date
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
        
        # Format date as MM/DD/YYYY
        return padLeft(string(nMonth), "0", 2) + "/" + 
               padLeft(string(nDay), "0", 2) + "/" + 
               string(nYear)
    }
}
