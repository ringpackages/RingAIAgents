/* load "openssllib.ring" */

/*
Class: PasswordPolicy
Description: Password policies
*/
class PasswordPolicy {
    
    func init {
        oConfig = new SecurityConfig
        
        # Load password settings from configuration
        nMinLength = oConfig.nMinPasswordLength
        bRequireSpecialChars = oConfig.bRequireSpecialChars
        bRequireNumbers = oConfig.bRequireNumbers
        bRequireUpperCase = oConfig.bRequireUpperCase
        
        # Set list of special characters
        cSpecialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?/"
    }
    
    # Validate password strength
    func validatePassword cPassword {
        if cPassword = "" return false
        
        # Check length
        if len(cPassword) < nMinLength {
            return [
                :valid = false,
                :message = "Password must be at least " + nMinLength + " characters long"
            ]
        }
        
        # Check for special characters
        if bRequireSpecialChars and not containsSpecialChars(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one special character"
            ]
        }
        
        # Check for numbers
        if bRequireNumbers and not containsNumbers(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one number"
            ]
        }
        
        # Check for uppercase letters
        if bRequireUpperCase and not containsUpperCase(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one uppercase letter"
            ]
        }
        
        return [
            :valid = true,
            :message = "Password meets all requirements"
        ]
    }
    
    # Calculate password strength (from 0 to 100)
    func calculateStrength cPassword {
        if cPassword = "" return 0
        
        nScore = 0
        
        # Length
        nScore += min(len(cPassword) * 4, 40)
        
        # Uppercase letters
        if containsUpperCase(cPassword) {
            nUpperCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isalpha(c) and c = upper(c) {
                    nUpperCount++
                }
            }
            nScore += min(nUpperCount * 2, 10)
        }
        
        # Lowercase letters
        if containsLowerCase(cPassword) {
            nLowerCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isalpha(c) and c = lower(c) {
                    nLowerCount++
                }
            }
            nScore += min(nLowerCount * 2, 10)
        }
        
        # Numbers
        if containsNumbers(cPassword) {
            nNumberCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isdigit(c) {
                    nNumberCount++
                }
            }
            nScore += min(nNumberCount * 4, 20)
        }
        
        # Special characters
        if containsSpecialChars(cPassword) {
            nSpecialCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if substr(cSpecialChars, c) > 0 {
                    nSpecialCount++
                }
            }
            nScore += min(nSpecialCount * 6, 30)
        }
        
        # Diversity
        nUnique = len(uniqueChars(cPassword))
        nScore += min(nUnique * 2, 10)
        
        # Reduce points for repetition
        nDeduction = calculateRepetitionDeduction(cPassword)
        nScore -= nDeduction
        
        # Reduce points for known patterns
        nDeduction = calculatePatternDeduction(cPassword)
        nScore -= nDeduction
        
        # Ensure result is between 0 and 100
        nScore = max(0, min(nScore, 100))
        
        return nScore
    }
    
    # Hash password using random salt
    func hashPassword cPassword {
        # Generate random salt
        cSalt = randbytes(16)
        cSaltHex = ""
        
        # Convert salt to hexadecimal string
        for i = 1 to len(cSalt) {
            byte = ascii(cSalt[i])
            cSaltHex += substr("0123456789abcdef", (byte / 16) + 1, 1)
            cSaltHex += substr("0123456789abcdef", (byte % 16) + 1, 1)
        }
        
        # Calculate hash
        cHash = sha256(cPassword + cSalt)
        
        # Return salt and hash
        return "$sha256$" + cSaltHex + "$" + cHash
    }
    
    # Verify password
    func verifyPassword cPassword, cStoredHash {
        # Split stored hash
        aParts = split(cStoredHash, "$")
        
        if len(aParts) != 4 {
            return false
        }
        
        cAlgorithm = aParts[2]
        cSaltHex = aParts[3]
        cHash = aParts[4]
        
        # Convert salt from hexadecimal string to bytes
        cSalt = ""
        for i = 1 to len(cSaltHex) step 2 {
            cHexPair = substr(cSaltHex, i, 2)
            nByte = 0
            
            for j = 1 to 2 {
                c = lower(substr(cHexPair, j, 1))
                if c >= "0" and c <= "9" {
                    nByte = nByte * 16 + (ascii(c) - 48)
                }
                else if c >= "a" and c <= "f" {
                    nByte = nByte * 16 + (ascii(c) - 87)
                }
            }
            
            cSalt += char(nByte)
        }
        
        # Calculate hash
        cComputedHash = ""
        
        if cAlgorithm = "sha256" {
            cComputedHash = sha256(cPassword + cSalt)
        }
        else if cAlgorithm = "sha512" {
            cComputedHash = sha512(cPassword + cSalt)
        }
        else {
            return false
        }
        
        # Verify hash
        return cComputedHash = cHash
    }
    
    private
    
    oConfig
    nMinLength
    bRequireSpecialChars
    bRequireNumbers
    bRequireUpperCase
    cSpecialChars
    
    # Check for special characters
    func containsSpecialChars cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if substr(cSpecialChars, c) > 0 {
                return true
            }
        }
        return false
    }
    
    # Check for numbers
    func containsNumbers cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isdigit(c) {
                return true
            }
        }
        return false
    }
    
    # Check for uppercase letters
    func containsUpperCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = upper(c) {
                return true
            }
        }
        return false
    }
    
    # Check for lowercase letters
    func containsLowerCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = lower(c) {
                return true
            }
        }
        return false
    }
    
    # Get unique characters
    func uniqueChars cText {
        aChars = []
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if not find(aChars, c) {
                add(aChars, c)
            }
        }
        return aChars
    }
    
    # Calculate repetition deduction
    func calculateRepetitionDeduction cPassword {
        nDeduction = 0
        
        # Search for repetitions
        for i = 1 to len(cPassword) - 1 {
            c = substr(cPassword, i, 1)
            cNext = substr(cPassword, i + 1, 1)
            
            if c = cNext {
                nDeduction += 2
            }
        }
        
        return nDeduction
    }
    
    # Calculate pattern deduction
    func calculatePatternDeduction cPassword {
        nDeduction = 0
        
        # Search for known patterns
        aPatterns = [
            "123", "234", "345", "456", "567", "678", "789", "890",
            "abc", "bcd", "cde", "def", "efg", "fgh", "ghi", "hij",
            "ijk", "jkl", "klm", "lmn", "mno", "nop", "opq", "pqr",
            "qrs", "rst", "stu", "tuv", "uvw", "vwx", "wxy", "xyz"
        ]
        
        for pattern in aPatterns {
            if substr(lower(cPassword), lower(pattern)) > 0 {
                nDeduction += 5
            }
        }
        
        return nDeduction
    }
}
