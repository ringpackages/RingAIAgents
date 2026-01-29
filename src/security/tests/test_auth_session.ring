load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"
load "consolecolors.ring"
load "G:/RingAIAgents/src/security/SessionManager.ring"
load "G:/RingAIAgents/src/security/TokenManager.ring"
load "G:/RingAIAgents/src/security/hmac.ring"

/*
    Testing authentication and sessions
*/
func main {
    ? "=== Testing authentication and sessions ==="
    
    # Testing sessions
    testSessions()
    
    # Testing tokens
    testTokens()
    
    ? "=== Testing completed successfully ==="
}

# Testing sessions
func testSessions {
    ? "Testing sessions..."
    
    oSession = new SessionManager()
    
    # Create session
    cUserId = "user123"
    cUserRole = "admin"
    cUserIP = "192.168.0.187"
    
    cSessionToken = oSession.createSession(cUserId, cUserRole, cUserIP)
    assert(len(cSessionToken) > 0, "Testing session creation")
    ? cSessionToken
    # Validate session
    aSessionData = oSession.validateSession(cSessionToken)
    ? "Session data: "
    ? aSessionData
    
    # Validate session
    assert(not aSessionData = false, "Testing session validation")
    
    # Validate session data
    if type(aSessionData) = "LIST" {
        assert(aSessionData["user_id"] = cUserId, "Testing session data")
    }
    
    # Destroy session
    cSessionId = split(cSessionToken, ".")[1]
    assert(oSession.destroySession(cSessionId), "Testing session destruction")
    
    ? "  Testing sessions completed successfully"
}

# Testing tokens
func testTokens {
    ? "Testing tokens..."
    
    oToken = new TokenManager()
    
    # Create token
    cUserId = "user123"
    cUserRole = "admin"
    aCustomClaims = [["app", "ringai"], ["device", "desktop"]]
    
    cToken = oToken.createToken(cUserId, cUserRole, aCustomClaims)
    assert(len(cToken) > 0, "Testing token creation")
    
    # Validate token
    aTokenData = oToken.validateToken(cToken)
    assert(type(aTokenData) = "LIST", "Testing token validation")
    assert(aTokenData[:sub] = cUserId, "Testing token data")
    
    # Revoke token
    assert(oToken.revokeToken(cToken), "Testing token revocation")
    assert(not oToken.validateToken(cToken), "Testing token revocation")
    
    ? "  Testing tokens completed successfully"
}

# Helper function for assertion
/*func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    ok
} */