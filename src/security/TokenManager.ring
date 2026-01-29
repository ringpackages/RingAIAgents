/* load "openssllib.ring"
load "jsonlib.ring" */

/*
Class: TokenManager
Description: Manager JWT tokens
*/
class TokenManager {
    
    func init {
        oConfig = new SecurityConfig
        oBase64 = new Base64()
        oHmac = new Hmac()

        # Set the signing key
        cSigningKey = oConfig.cJWTSigningKey
        if cSigningKey = "" {
            cSigningKey = randbytes(32)
        }
        
        # Set token expiry duration (in seconds)
        nTokenExpiry = oConfig.nJWTExpiry
        
        # Initialize list of revoked tokens
        aRevokedTokens = []
    }
    
    # Create JWT token
    func createToken cUserId, cUserRole, aCustomClaims {
        # Create header
        aHeader = [
            :alg = "HS256",
            :typ = "JWT"
        ]
        
        # Create payload
        aPayload = [
            :sub = cUserId,
            :role = cUserRole,
            :iat = timestamp(),
            :exp = timestamp() + nTokenExpiry
        ]
        
        # Add custom claims
        if type(aCustomClaims) = "LIST" {
            for claim in aCustomClaims {
                aPayload[claim[1]] = claim[2]
            }
        }
        
        # Encode header and payload
        cEncodedHeader = this.oBase64.encode(list2json(aHeader))
        cEncodedPayload = this.oBase64.encode(list2json(aPayload))
        cEncodedSignature = this.oBase64.encode(this.oHmac.hmac_sha256(cEncodedHeader + "." + cEncodedPayload, cSigningKey))
        # Create signature
        cSignature = createSignature(cEncodedHeader + "." + cEncodedPayload)
        
        # Create token
        cToken = cEncodedHeader + "." + cEncodedPayload + "." + cEncodedSignature
        
        return cToken
    }
    
    # Validate JWT token
    func validateToken cToken {
        if cToken = "" return false ok
        
        # Split token into parts
        aTokenParts = split(cToken, ".")
        if len(aTokenParts) != 3 return false ok
        
        cEncodedHeader = aTokenParts[1]
        cEncodedPayload = aTokenParts[2]
        cSignature = aTokenParts[3]
        
        # Verify signature
        cExpectedSignature = createSignature(cEncodedHeader + "." + cEncodedPayload)
        if cSignature != cExpectedSignature return false ok
        
        # Decrypt data
        cDecodedPayload = this.oBase64.decode(cEncodedPayload)
        aPayload = json2list(cDecodedPayload)
        
        # Check if token has expired
        if ComperTimeTemp(aPayload[:exp], "<", timestamp()) return false ok
        
        # Check if token has been revoked
        if isTokenRevoked(cToken) return false ok
        
        return aPayload
    }
    
    # Revoke token
    func revokeToken cToken {
        if not isTokenRevoked(cToken) {
            aRevokedTokens + cToken
            return true
        }
        return false
    }
    
    # Check if token has been revoked
    func isTokenRevoked cToken {
        return find(aRevokedTokens, cToken) > 0
    }
    
    # Clean expired tokens
    func cleanExpiredTokens {
        for i = len(aRevokedTokens) to 1 step -1 {
            cToken = aRevokedTokens[i]
            
            # Split token into parts
            aTokenParts = split(cToken, ".")
            if len(aTokenParts) != 3 {
                del(aRevokedTokens, i)
                loop
            }
            
            # Decrypt data
            cDecodedPayload = this.oBase64.decode(aTokenParts[2])
            aPayload = json2list(cDecodedPayload)
            
            # Check if token has expired
            if aPayload[:exp] < timestamp() {
                del(aRevokedTokens, i)
            }
        }
    }
    
    private
    
    oConfig
    cSigningKey
    nTokenExpiry
    aRevokedTokens
    oBase64
    oHmac
    # Create signature
    func createSignature cData {
        return this.oBase64.encode(this.oHmac.hmac_sha256(cData, cSigningKey))
    }
    
    # Get current timestamp
    func timestamp {
        aTimeList = timelist()
        cDate = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19]  # MM/DD/YYYY
        cTime = padLeft(string(aTimeList[7]), "0", 2) + ":" +  # HH
                padLeft(string(aTimeList[11]), "0", 2) + ":" +  # MM
                padLeft(string(aTimeList[13]), "0", 2)  # SS
        return cDate + " " + cTime
    }

    # Compare times
    func ComperTimeTemp cTime1, operation, cTime2 {
        nSeconds1 = Time2Seconds(cTime1)
        nSeconds2 = Time2Seconds(cTime2)
        
        switch operation {
            on ">" return nSeconds1 > nSeconds2
            on "<" return nSeconds1 < nSeconds2
            on "=" return nSeconds1 = nSeconds2
            on ">=" return nSeconds1 >= nSeconds2
            on "<=" return nSeconds1 <= nSeconds2
            other return false
        }
    }

    # Convert time to seconds
    func Time2Seconds cTime {
        try {
            if cTime = NULL return 0 ok
            
            # Split date and time
            aDateTime = split(cTime, " ")
            if len(aDateTime) != 2 return 0 ok
            
            # Convert date to Julian day
            nJulianDate = gregorian2julian(aDateTime[1])
            
            # Convert time to seconds
            aTime = split(aDateTime[2], ":")
            if len(aTime) != 3 return 0 ok
            
            nSeconds = number(aTime[1]) * 3600 +  # hours
                      number(aTime[2]) * 60 +     # minutes
                      number(aTime[3])            # seconds
            
            return (nJulianDate * 86400) + nSeconds
        catch
            return 0
        }
    }

    # Helper function to add leading zeros to the text
    func padLeft cStr, cPadChar, nWidth {
        while len(cStr) < nWidth {
            cStr = cPadChar + cStr
        }
        return cStr
    }
}
