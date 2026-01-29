load "G:\RingAIAgents\src\security\EncryptionManager.ring"


/*
    Testing encryption and signature functions
*/
func main {
    ? "=== Testing encryption and signature functions ==="
    
    # Testing AES encryption and decryption
    testAESEncryption()
    
    # Testing RSA key generation
    testRSAKeyGeneration()
    
    # Testing RSA encryption and decryption
    testRSAEncryption()
    
    # Testing RSA signature and verification
    testRSASignature()
    
    # Testing file encryption and decryption
    testFileEncryption()
    
    # Testing file signature and verification
    testFileSignature()
    
    ? "=== Testing completed successfully ==="
}

# Testing AES encryption and decryption
func testAESEncryption {
    ? "Testing AES encryption and decryption..."
    
    oEncryption = new EncryptionManager()
    
    # Generate AES key and initialization vector
    cKey = oEncryption.generateKey(32)
    cIV = oEncryption.generateIV(16)
    
    assert(len(cKey) = 32, "Testing AES key generation")
    assert(len(cIV) = 16, "Testing AES initialization vector generation")
    
    # Testing encryption and decryption
    cData = "Secret data for testing"
    cEncrypted = oEncryption.encrypte(cData, cKey, cIV)
    cDecrypted = oEncryption.decrypte(cEncrypted, cKey, cIV)
    
    assert(cDecrypted = cData, "Testing AES encryption and decryption")
    
    ? "  Testing AES encryption and decryption completed successfully"
}

# Testing RSA key generation
func testRSAKeyGeneration {
    ? "Testing RSA key generation..."
    
    oEncryption = new EncryptionManager
    
    # Generate RSA key pair
    aKeyPair = oEncryption.generateRSAKeyPair(2048)
    
    assert(len(aKeyPair[:private_key]) > 0, "Testing RSA private key generation")
    assert(len(aKeyPair[:public_key]) > 0, "Testing RSA public key generation")
    
    # Save the keys in temporary files for later tests
    write("temp_private_key.pem", aKeyPair[:private_key])
    write("temp_public_key.pem", aKeyPair[:public_key])
    
    ? "  Testing RSA key generation completed successfully"
}

# Testing RSA encryption and decryption
func testRSAEncryption {
    ? "Testing RSA encryption and decryption..."
    
    oEncryption = new EncryptionManager
    
    # Read the keys from temporary files
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # Testing encryption and decryption
    cData = "Secret data for testing using RSA"
    cEncrypted = oEncryption.encryptRSA(cData, cPublicKeyPEM)
    cDecrypted = oEncryption.decryptRSA(cEncrypted, cPrivateKeyPEM)
    
    assert(cDecrypted = cData, "Testing RSA encryption and decryption")
    
    ? "  Testing RSA encryption and decryption completed successfully"
}

# Testing RSA signature and verification
func testRSASignature {
    ? "Testing RSA signature and verification..."
    
    oEncryption = new EncryptionManager
    
    # Read the keys from temporary files
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # Testing signature and verification
    cData = "Data for testing using RSA"
    cSignature = oEncryption.signRSA(cData, cPrivateKeyPEM)
    bVerified = oEncryption.verifyRSA(cData, cSignature, cPublicKeyPEM)
    
    assert(bVerified, "Testing RSA signature and verification")
    
    # Testing signature verification with modified data
    cModifiedData = cData + " (modified data)"
    bVerified = oEncryption.verifyRSA(cModifiedData, cSignature, cPublicKeyPEM)
    
    assert(not bVerified, "Testing signature verification with modified data")
    
    ? "  Testing RSA signature and verification completed successfully"
}

# Testing file encryption and decryption
func testFileEncryption {
    ? "Testing file encryption and decryption..."
    
    oEncryption = new EncryptionManager
    
    # Read the keys from temporary files
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # Create test file
    cTestData = "This is a test file to encrypt and decrypt using AES and RSA."
    write("test_file.txt", cTestData)
    
    # Encrypt the file
    oEncryption.encryptFile("test_file.txt", "test_file.enc", cPublicKeyPEM)
    
    # Decrypt the file
    oEncryption.decryptFile("test_file.enc", "test_file_decrypted.txt", cPrivateKeyPEM)
    
    # Validate the decrypted file
    cDecryptedData = read("test_file_decrypted.txt")
    assert(cDecryptedData = cTestData, "Testing file encryption and decryption")
    
    ? "  Testing file encryption and decryption completed successfully"
}

# Testing file signature and verification
func testFileSignature {
    ? "Testing file signature and verification..."
    
    oEncryption = new EncryptionManager
    
    # Read the keys from temporary files
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # Sign the test file
    oEncryption.signFile("test_file.txt", "test_file.sig", cPrivateKeyPEM)
    
    # Verify the file signature
    bVerified = oEncryption.verifyFileSignature("test_file.txt", "test_file.sig", cPublicKeyPEM)
    assert(bVerified, "Testing file signature and verification")
    
    # Modify the file
    cModifiedData = read("test_file.txt") + " (تم تعديله)"
    write("test_file_modified.txt", cModifiedData)
    
    # Verify the modified file signature
    bVerified = oEncryption.verifyFileSignature("test_file_modified.txt", "test_file.sig", cPublicKeyPEM)
    assert(not bVerified, "Testing file signature and verification with modified file")
    
    ? "  Testing file signature and verification completed successfully"
    
    # Clean up temporary files
    remove("temp_private_key.pem")
    remove("temp_public_key.pem")
    remove("test_file.txt")
    remove("test_file.enc")
    remove("test_file_decrypted.txt")
    remove("test_file.sig")
    remove("test_file_modified.txt")
}

# Helper function for assertion
func assert condition, message {
    if condition {
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("Testing failed: " + message)
    }
}

