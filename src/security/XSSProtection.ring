//load "openssllib.ring"

/*
Class: XSSProtection
Description: The protection against cross-site scripting attacks
*/
class XSSProtection {
    
    func init {
        oConfig = new SecurityConfig
        
        # Load list of suspicious patterns from configuration
        aSuspiciousPatterns = oConfig.aSuspiciousPatterns
        
        # Add additional patterns
        aAdditionalPatterns = [
            "javascript:",
            "eval(",
            "document.cookie",
            "document.write",
            "document.location",
            "window.location",
            "onerror=",
            "onload=",
            "onclick=",
            "onmouseover=",
            "onfocus=",
            "onblur=",
            "onsubmit=",
            "onchange=",
            "onkeypress=",
            "onkeydown=",
            "onkeyup=",
            "ondblclick=",
            "oncontextmenu=",
            "onmousedown=",
            "onmouseup=",
            "onmousemove=",
            "onmouseout=",
            "onmouseover=",
            "ondrag=",
            "ondrop=",
            "onunload="
        ]
        
        # Merge the lists
        for pattern in aAdditionalPatterns {
            if not find(aSuspiciousPatterns, pattern) {
                add(aSuspiciousPatterns, pattern)
            }
        }
    }
    
    # Clean the text from XSS codes
    func sanitize cText {
        if cText = "" return "" ok
        
        # Replace dangerous tags
        cText = replaceHtmlTags(cText)
        
        # Replace dangerous JavaScript codes
        cText = replaceJavaScriptCode(cText)
        
        # Encrypt the text using SHA256 to verify it has not been modified
        cHash = sha256(cText)
        
        return cText
    }
    
    # Validate the text
    func validateText cText {
        if cText = "" return true ok
        
        # Check for suspicious patterns
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 {
                return false
            }
        }
        
        return true
    }
    
    # Add Content-Security-Policy header
    func addCSPHeader oServer {
        cCSP = "default-src 'self'; " +
               "script-src 'self' https://cdnjs.cloudflare.com https://code.jquery.com; " +
               "style-src 'self' https://cdnjs.cloudflare.com; " +
               "img-src 'self' data:; " +
               "font-src 'self' https://cdnjs.cloudflare.com; " +
               "connect-src 'self';"
        
        oServer.setHeader("Content-Security-Policy", cCSP)
    }
    
    # Add X-XSS-Protection header
    func addXSSProtectionHeader oServer {
        oServer.setHeader("X-XSS-Protection", "1; mode=block")
    }
    
    # Add X-Content-Type-Options header
    func addContentTypeOptionsHeader oServer {
        oServer.setHeader("X-Content-Type-Options", "nosniff")
    }
    
    # Add Strict-Transport-Security header
    func addHSTSHeader oServer {
        oServer.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
    }
    
    # Add X-Frame-Options header
    func addFrameOptionsHeader oServer {
        oServer.setHeader("X-Frame-Options", "SAMEORIGIN")
    }
    
    # Add Referrer-Policy header
    func addReferrerPolicyHeader oServer {
        oServer.setHeader("Referrer-Policy", "strict-origin-when-cross-origin")
    }
    
    # Add Permissions-Policy header
    func addPermissionsPolicyHeader oServer {
        oServer.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=(), payment=()")
    }
    
    # Add all security headers
    func addSecurityHeaders oServer {
        addCSPHeader(oServer)
        addXSSProtectionHeader(oServer)
        addContentTypeOptionsHeader(oServer)
        addHSTSHeader(oServer)
        addFrameOptionsHeader(oServer)
        addReferrerPolicyHeader(oServer)
        addPermissionsPolicyHeader(oServer)
    }
    
    # Generate CSRF token
    func generateCSRFToken {
        # Use Randbytes function to generate safe random bytes
        cRandom = randbytes(32)
        # Encrypt random bytes using SHA256
        return sha256(cRandom + date() + time())
    }
    
    # Encrypt sensitive data
    func encryptSensitiveData cData, cKey, cIV {
        try {
            return encrypt(cData, cKey, cIV, "aes256")
        catch
            return ""
        }
    }
    
    # Decrypt sensitive data
    func decryptSensitiveData cEncryptedData, cKey, cIV {
        try {
            return decrypt(cEncryptedData, cKey, cIV, "aes256")
        catch
            return ""
        }
    }
    
    private
    
    oConfig
    aSuspiciousPatterns = []
    
    # Replace HTML tags
    func replaceHtmlTags cText {
        cText = substr(cText, "<", "&lt;")
        cText = substr(cText, ">", "&gt;")
        cText = substr(cText, '"', "&quot;")
        cText = substr(cText, "'", "&#39;")
        cText = substr(cText, "&", "&amp;")
        return cText
    }
    
    # Replace JavaScript codes
    func replaceJavaScriptCode cText {
        # Replace suspicious patterns
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 {
                cText = substr(cText, pattern, "")
            }
        }
        
        return cText
    }
    
    # Validate encrypted data
    func validateEncryptedData cEncryptedData, cHash {
        # Check for hash match
        return sha256(cEncryptedData) = cHash
    }
}
