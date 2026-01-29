load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"
load "consolecolors.ring"

load "G:\RingAIAgents\src\security\CSRFProtection.ring"
load "G:\RingAIAgents\src\security\XSSProtection.ring"
load "G:\RingAIAgents\src\security\InputValidator.ring"
load "G:\RingAIAgents\src\security\Base64.ring"
load "G:\RingAIAgents\src\utils\helpers.ring"


/*
    Testing protection
*/
func main {
    ? "=== Testing protection ==="
    
    # Testing input validation
    testInputValidation()
    
    # Testing CSRF protection
    testCSRFProtection()
    
    # Testing XSS protection
    testXSSProtection()
    
    ? "=== Testing protection completed successfully ==="
}

# Testing input validation
func testInputValidation {
    ? "Testing input validation..."
    
    oValidator = new InputValidator()
    
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
    
    oCSRF = new CSRFProtection()
    
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

# Testing helper function
/*func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
       // raise("فشل الاختبار: " + message)
    ok
} 