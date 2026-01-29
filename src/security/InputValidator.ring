load "G:/RingAIAgents/src/security/config/SecurityConfig.ring"

/*
Class: InputValidator
Description: Validates input data
*/
class InputValidator {
    
    # Class variables
    oConfig
    nMinPasswordLength
    bRequireSpecialChars
    bRequireNumbers
    bRequireUpperCase
    aSuspiciousPatterns
    
    func init {
        oConfig = new SecurityConfig
        
        # Copy settings from oConfig with correct value conversion
        try {
            nMinPasswordLength = number(oConfig.nMinPasswordLength)
        catch
            nMinPasswordLength = 8  # Default value
        }
        
        # Convert boolean values
        bRequireSpecialChars = isTrue(oConfig.bRequireSpecialChars)
        bRequireNumbers = isTrue(oConfig.bRequireNumbers)
        bRequireUpperCase = isTrue(oConfig.bRequireUpperCase)
        aSuspiciousPatterns = oConfig.aSuspiciousPatterns
    }
    
    # Helper function to convert to boolean
    func isTrue value {
        if type(value) = "NUMBER" {
            return value = 1
        }
        return false
    }
    
    # Validate email
    func validateEmail cEmail {
        if cEmail = "" return false ok
        
        # Check for @ and .
        if substr(cEmail, "@") = 0 return false ok
        if substr(cEmail, ".") = 0 return false ok
        
        # Check for spaces
        if substr(cEmail, " ") > 0 return false ok
        
        # Check length
        if len(cEmail) < 5 return false ok
        
        # Validate format using regular expression
        # Should implement validation using regular expression correctly
        
        return true
    }
    
    # Validate password
    func validatePassword cPassword {
        try {
            if cPassword = "" return false ok
            
            # Check length
            if len(cPassword) < nMinPasswordLength return false ok
            
            # Check for special characters
            if bRequireSpecialChars {
                if not containsSpecialChars(cPassword) return false ok
            }
            
            # Check for numbers
            if bRequireNumbers {
                if not containsNumbers(cPassword) return false ok
            }
            
            # Check for uppercase letters
            if bRequireUpperCase {
                if not containsUpperCase(cPassword) return false ok
            }
            
            return true
        catch
            ? "Error validating password: " + cCatchError
            return false
        }
    }
    
    # Validate username
    func validateUsername cUsername {
        if cUsername = "" return false ok
        
        # Check length
        if len(cUsername) < 3 return false ok
        
        # Check for spaces
        if substr(cUsername, " ") > 0 return false ok
        
        # Check format (letters, numbers, and underscores only)
        for i = 1 to len(cUsername) {
            c = substr(cUsername, i, 1)
            if not (isalpha(c) or isdigit(c) or c = "_") return false ok
        }
        
        return true
    }
    
    # Validate text (prevent SQL injection and XSS)
    func validateText cText {
        if cText = "" return true ok
        
        # Check for suspicious patterns
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 return false ok
        }
        
        return true
    }
    
    # Validate number
    func validateNumber cNumber {
        if cNumber = "" return false ok
        
        # Check if input is a number
        for i = 1 to len(cNumber) {
            c = substr(cNumber, i, 1)
            if not (isdigit(c) or c = "." or c = "-") return false ok
        }
        
        return true
    }
    
    # Validate date
    func validateDate cDate {
        if cDate = "" return false ok
        
        # Check date format
        # Should implement date validation correctly
        
        return true
    }
    
    # Sanitize text (remove malicious code)
    func sanitizeText cText {
        if cText = "" return "" ok      
        
        # Replace malicious code
        cText = replaceHtmlTags(cText)
        cText = replaceSqlInjection(cText)
        
        return cText
    }
    
    private
    
    # Check for special characters
    func containsSpecialChars cText {
        cSpecialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?/"
        for i = 1 to len(cSpecialChars) {
            c = substr(cSpecialChars, i, 1)
            if substr(cText, c) > 0 return true ok
        }
        return false 
    }
    
    # Check for numbers
    func containsNumbers cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isdigit(c) return true ok
        }
        return false 
    }
    
    # Check for uppercase letters
    func containsUpperCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = upper(c) return true ok
        }
        return false 
    }
    
    # Replace HTML tags
    func replaceHtmlTags cText {
        cText = substr(cText, "<", "&lt;")
        cText = substr(cText, ">", "&gt;")
        cText = substr(cText, '\"', "&quot;")
        cText = substr(cText, "'", "&#39;")
        return cText
    }
    
    # Replace SQL injection patterns
    func replaceSqlInjection cText {
        cText = substr(cText, "SELECT", "")
        cText = substr(cText, "INSERT", "")
        cText = substr(cText, "UPDATE", "")
        cText = substr(cText, "DELETE", "")
        cText = substr(cText, "DROP", "")
        cText = substr(cText, "UNION", "")
        cText = substr(cText, ";", "")
        cText = substr(cText, "--", "")
        return cText
    }
}
