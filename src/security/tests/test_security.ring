load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"

load "G:\RingAIAgents\src\security\config\SecurityConfig.ring"
load "G:\RingAIAgents\src\security\Base64.ring"
load "G:\RingAIAgents\src\security\EncryptionManager.ring"
load "G:\RingAIAgents\src\security\SecurityManager.ring"
load "G:\RingAIAgents\src\security\SessionManager.ring"
load "G:\RingAIAgents\src\security\TokenManager.ring"
load "G:\RingAIAgents\src\security\InputValidator.ring"
load "G:\RingAIAgents\src\security\CSRFProtection.ring"
load "G:\RingAIAgents\src\security\XSSProtection.ring"
load "G:\RingAIAgents\src\security\MFAManager.ring"
load "G:\RingAIAgents\src\security\RBACManager.ring"


/*  
    Testing security system
*/
func main {
    ? "=== Testing security system ==="
    
    # Testing security manager
    testSecurityManager()
    
    # Testing encryption
    testEncryption()
    
    # Testing authentication
    testAuthentication()
    
    # Testing sessions
    testSessions()
    
    # Testing tokens
    testTokens()
    
    # Testing input validation
    testInputValidation()
    
    # Testing CSRF protection
    testCSRFProtection()
    
    # Testing XSS protection
    testXSSProtection()
    
    # Testing intrusion prevention
    testIntrusionPrevention()
    
    ? "=== Testing security system completed successfully ==="
}

# Testing security manager
func testSecurityManager {
    ? "Testing security manager..."
    
    oSecurity = new SecurityManager
    
    # Testing encryption and decryption
    cData = "Confidential data for testing"
    cEncrypted = oSecurity.encryptData(cData)
    cDecrypted = oSecurity.decryptData(cEncrypted)
    
    assert(cDecrypted = cData, "Testing encryption and decryption")
    
    ? "  Testing security manager completed successfully"
}

# Testing encryption
func testEncryption {
    ? "Testing encryption..."
    
    oEncryption = new EncryptionManager
    
    # Testing key and IV generation
    cKey = oEncryption.generateKey(32)
    cIV = oEncryption.generateIV(16)
    
    assert(len(cKey) = 32, "Testing key generation")
    assert(len(cIV) = 16, "Testing IV generation")
    
    # Testing encryption and decryption
    cData = "Confidential data for testing"
    cEncrypted = oEncryption.encrypt(cData, cKey, cIV)
    cDecrypted = oEncryption.decrypt(cEncrypted, cKey, cIV)
    
    assert(cDecrypted = cData, "Testing encryption and decryption")
    
    ? "  Testing encryption completed successfully"
}

# Testing authentication
func testAuthentication {
    ? "Testing authentication..."
    
    oAuth = new AuthenticationManager
    
    # Testing password hashing
    cPassword = "P@ssw0rd123"
    cHashed = oAuth.hashPassword(cPassword)
    
    assert(len(cHashed) > 0, "Testing password hashing")
    
    ? "  Testing authentication completed successfully"
}

# Testing sessions
func testSessions {
    ? "Testing sessions..."
    
    oSession = new SessionManager
    
    #   Testing session creation
    cUserId = "user123"
    cUserRole = "admin"
    cUserIP = "192.168.1.1"
    
    cSessionToken = oSession.createSession(cUserId, cUserRole, cUserIP)
    assert(len(cSessionToken) > 0, "Testing session creation")
    
    # Testing session validation
    aSessionData = oSession.validateSession(cSessionToken)
    assert(type(aSessionData) = "LIST", "Testing session validation")
    assert(aSessionData[:user_id] = cUserId, "Testing session data")
    
    # Testing session destruction
    cSessionId = split(cSessionToken, ".")[1]
    assert(oSession.destroySession(cSessionId), "Testing session destruction")
    
    ? "  Testing sessions completed successfully"
}

# Testing tokens
func testTokens {
    ? "Testing tokens..."
    
    oToken = new TokenManager
    
    # Testing token creation
    cUserId = "user123"
    cUserRole = "admin"
    aCustomClaims = [["app", "ringai"], ["device", "desktop"]]
    
    cToken = oToken.createToken(cUserId, cUserRole, aCustomClaims)
    assert(len(cToken) > 0, "Testing token creation")
    
    # Testing token validation
    aTokenData = oToken.validateToken(cToken)
    assert(type(aTokenData) = "LIST", "Testing token validation")
    assert(aTokenData[:sub] = cUserId, "Testing token data")
    
    # Testing token revocation
    assert(oToken.revokeToken(cToken), "Testing token revocation")
    assert(not oToken.validateToken(cToken), "Testing token revocation")
    
    ? "  Testing tokens completed successfully"
}

# Testing input validation
func testInputValidation {
    ? "Testing input validation..."
    
    oValidator = new InputValidator
    
    # Testing email validation
    assert(oValidator.validateEmail("user@example.com"), "Testing valid email")
    assert(not oValidator.validateEmail("invalid-email"), "Testing invalid email")
    
    # Testing password validation
    assert(oValidator.validatePassword("P@ssw0rd123"), "Testing valid password")
    assert(not oValidator.validatePassword("weak"), "Testing weak password")
    
    # Testing text validation
    assert(oValidator.validateText("Normal text"), "Testing valid text")
    assert(not oValidator.validateText("<script>alert('XSS')</script>"), "Testing text with XSS")
    
    # Testing text sanitization
    cDirtyText = "<script>alert('XSS')</script>"
    cCleanText = oValidator.sanitizeText(cDirtyText)
    assert(substr(cCleanText, "<script>") = 0, "Testing text sanitization")
    
    ? "  Testing input validation completed successfully"
}

# Testing CSRF protection
func testCSRFProtection {
    ? "Testing CSRF protection..."
    
    oCSRF = new CSRFProtection
    
    # Testing token generation
    cSessionId = "session123"
    cToken = oCSRF.generateToken(cSessionId)
    assert(len(cToken) > 0, "Testing token generation")
    
    # Testing token validation
    assert(oCSRF.validateToken(cToken, cSessionId), "Testing token validation")
    
    # Testing form field creation
    cFormField = oCSRF.createFormField(cSessionId)
    assert(substr(cFormField, "csrf_token") > 0, "Testing form field creation")
    
    ? "  Testing CSRF protection completed successfully"
}

# Testing XSS protection
func testXSSProtection {
    ? "Testing XSS protection..."
    
    oXSS = new XSSProtection
    
    # Testing text sanitization
    cDirtyText = "<script>alert('XSS')</script>"
    cCleanText = oXSS.sanitize(cDirtyText)
    assert(substr(cCleanText, "<script>") = 0, "Testing text sanitization")
    
    ? "  Testing XSS protection completed successfully"
}

# Testing intrusion prevention
func testIntrusionPrevention {
    ? "Testing intrusion prevention..."
    
    oIntrusion = new IntrusionPreventionManager
    
    # Testing suspicious patterns detection
    assert(oIntrusion.containsSuspiciousPatterns("<script>alert('XSS')</script>"), "Testing suspicious patterns detection")
    assert(not oIntrusion.containsSuspiciousPatterns("Normal text"), "Testing normal text")
    
    # Testing IP blocking
    cIP = "192.168.1.100"
    oIntrusion.blockIP(cIP)
    assert(oIntrusion.isIPBlocked(cIP), "Testing IP blocking")
    
    ? "  Testing intrusion prevention completed successfully"
}

# Testing helper function
func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("Failed test: " + message)
    ok
}