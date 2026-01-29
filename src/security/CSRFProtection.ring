/* load "openssllib.ring"
load "G:\RingAIAgents\src\security\Base64.ring"
load "G:\RingAIAgents\src\security\config\SecurityConfig.ring" */

/*
Class: CSRFProtection
Description: Provides protection against CSRF attacks
*/
class CSRFProtection {

    func init {
        oConfig = new SecurityConfig

        # Set token expiry duration (in seconds)
        nTokenExpiry = oConfig.nCSRFTokenExpiry

        # Initialize token store
        aTokens = []

        # Create Base64 object
        oBase64 = new Base64()
    }

    # Generate CSRF token
    func generateToken cSessionId {
        # Generate random token using randbytes
        cToken = oBase64.encode(randbytes(32))

        # Store the token with session ID
        aTokens + [cToken, cSessionId, date() + " " + time()]

        return cToken
    }

    # Validate CSRF token
    func validateToken cToken, cSessionId {
        if cToken = "" or cSessionId = "" { return false }

        # Search for the token
        for i = 1 to len(aTokens) {
            if aTokens[i][1] = cToken and aTokens[i][2] = cSessionId {
                # Check if the token has expired
                if not isTokenExpired(aTokens[i][3]) {
                    # Remove the token after usage
                    del(aTokens, i)
                    return true
                else
                    # Remove expired token
                    del(aTokens, i)
                    return false
                }
            }
        }

        return false
    }

    # Create hidden form field
    func createFormField cSessionId {
        cToken = generateToken(cSessionId)
        return "<input type='hidden' name='csrf_token' value='" + cToken + "'>"
    }

    # Generate CSRF token with HMAC signature
    func generateSignedToken cSessionId, cSecret {
        # Generate random token
        cRandom = oBase64.encode(randbytes(32))

        # Create data for signing
        cData = cSessionId + "|" + cRandom + "|" + date() + " " + time()

        # Calculate HMAC signature
        cSignature = hmac_sha256(cData, cSecret)

        # Store the token with session ID
        aTokens + [cRandom, cSessionId, date() + " " + time()]

        # Return the token and signature together
        return cRandom + "." + oBase64.encode(cSignature)
    }

    # Validate the signed token
    func validateSignedToken cToken, cSessionId, cSecret {
        if cToken = "" or cSessionId = "" { return false }

        # Split the token into parts
        aTokenParts = split(cToken, ".")
        if len(aTokenParts) != 2 { return false }

        cRandom = aTokenParts[1]
        cSignature = oBase64.decode(aTokenParts[2])

        # Search for the token
        for i = 1 to len(aTokens) {
            if aTokens[i][1] = cRandom and aTokens[i][2] = cSessionId {
                # Check if the token has expired
                if not isTokenExpired(aTokens[i][3]) {
                    # Create data for signature verification
                    cData = cSessionId + "|" + cRandom + "|" + aTokens[i][3]

                    # Calculate expected HMAC signature
                    cExpectedSignature = hmac_sha256(cData, cSecret)

                    # Check if the signatures match
                    if cSignature = cExpectedSignature {
                        # Remove the token after usage
                        del(aTokens, i)
                        return true
                    }
                else
                    # Remove expired token
                    del(aTokens, i)
                }

                return false
            }
        }

        return false
    }

    # Clean expired tokens
    func cleanExpiredTokens {
        for i = len(aTokens) to 1 step -1 {
            if isTokenExpired(aTokens[i][3]) {
                del(aTokens, i)
            }
        }
    }

    # Add CSRF header to the response
    func addCSRFHeader oServer, cSessionId {
        cToken = generateToken(cSessionId)
        oServer.setHeader("X-CSRF-Token", cToken)
    }

    # Encode data using Base64
    func base64encode cData {
        if cData = "" { return "" }

        # Base64 encoding table
        cBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

        # Convert data to bytes array
        aBytes = []
        for i = 1 to len(cData) {
            add(aBytes, ascii(substr(cData, i, 1)))
        }

        # Calculate the number of bytes remaining and the number of padding characters required
        nRemainder = len(aBytes) % 3
        nPadding = 0

        if nRemainder = 1 {
            nPadding = 2
        elseif nRemainder = 2
            nPadding = 1
        }

        # Add zero bytes for completion if the number of bytes is not a multiple of 3
        if nRemainder != 0 {
            for i = 1 to 3 - nRemainder {
                add(aBytes, 0)
            }
        }

        # Encode the data
        cResult = ""
        for i = 1 to len(aBytes) step 3 {
            # Group 3 bytes into a 24-bit value
            nValue = aBytes[i] * 65536 + aBytes[i+1] * 256 + aBytes[i+2]

            # Divide the value into 4 values of 6 bits
            nVal1 = floor(nValue / 262144) % 64
            nVal2 = floor(nValue / 4096) % 64
            nVal3 = floor(nValue / 64) % 64
            nVal4 = nValue % 64

            # Add the corresponding characters to the result
            cResult += substr(cBase64Chars, nVal1 + 1, 1)
            cResult += substr(cBase64Chars, nVal2 + 1, 1)
            cResult += substr(cBase64Chars, nVal3 + 1, 1)
            cResult += substr(cBase64Chars, nVal4 + 1, 1)
        }

        # Replace zero bytes with the = character
        if nPadding > 0 {
            cResult = left(cResult, len(cResult) - nPadding) + copy("=", nPadding)
        }

        return cResult
    }

    # Decode data from Base64
    func base64decode cData {
        if cData = "" { return "" }

        # Base64 encoding table
        cBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

        # Calculate the number of = characters at the end of the string
        nPadding = 0
        for i = len(cData) to 1 step -1 {
            if substr(cData, i, 1) = "=" {
                nPadding++
            else
                exit
            }
        }

        # Remove = characters from the end of the string
        cData = substr(cData, 1, len(cData) - nPadding)

        # Convert characters to values
        aValues = []
        for i = 1 to len(cData) {
            cChar = substr(cData, i, 1)
            nPos = 0

            # Find the position of the character in the encoding table
            for j = 1 to len(cBase64Chars) {
                if substr(cBase64Chars, j, 1) = cChar {
                    nPos = j - 1
                    exit
                }
            }

            add(aValues, nPos)
        }

        # Add zero values for completion
        for i = 1 to (4 - (len(aValues) % 4)) % 4 {
            add(aValues, 0)
        }

        # Decode the data
        cResult = ""
        nGroups = floor(len(aValues) / 4)

        for i = 1 to nGroups {
            # Get 4 values of 6 bits
            nIdx = (i - 1) * 4 + 1
            nVal1 = aValues[nIdx]
            nVal2 = aValues[nIdx + 1]
            nVal3 = aValues[nIdx + 2]
            nVal4 = aValues[nIdx + 3]

            # Combine the values into a 24-bit value
            nValue = nVal1 * 262144 + nVal2 * 4096 + nVal3 * 64 + nVal4

            # Extract 3 bytes from the value
            nByte1 = floor(nValue / 65536) % 256
            nByte2 = floor(nValue / 256) % 256
            nByte3 = nValue % 256

            # Add bytes to the result
            cResult += char(nByte1)

            # Add the second byte unless there are two = characters at the end of the string
            if nPadding < 2 {
                cResult += char(nByte2)
            }

            # Add the third byte unless there is at least one = character at the end of the string
            if nPadding < 1 {
                cResult += char(nByte3)
            }
        }

        return cResult
    }

    private

    oConfig
    nTokenExpiry
    aTokens
    oBase64

    # Check if the token has expired
    func isTokenExpired cCreatedAt {
        # Calculate the difference between the current time and the token creation time
        # The difference calculation should be done correctly
        return timeDiff(cCreatedAt, date() + " " + time()) > nTokenExpiry
    }

    # Calculate HMAC-SHA256
    func hmac_sha256 cData, cKey {
        # Prepare the key
        if len(cKey) > 64 {
            cKey = sha256(cKey)
        }

        if len(cKey) < 64 {
            cKey = cKey + copy(char(0), 64 - len(cKey))
        }

        # Calculate the inner and outer keys
        cInnerKey = ""
        cOuterKey = ""

        for i = 1 to 64 {
            cInnerKey += char(ascii(substr(cKey, i, 1)) ^ 0x36)
            cOuterKey += char(ascii(substr(cKey, i, 1)) ^ 0x5C)
        }

        # Calculate HMAC
        cInnerHash = SHA256(cInnerKey + cData)
        cOuterHash = SHA256(cOuterKey + cInnerHash)

        return cOuterHash
    }

    
}