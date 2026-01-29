load "G:\RingAIAgents\src\security\Base64.ring"

/*
    Testing Base64 functions
*/
func main {
    ? "=== Testing Base64 functions ==="

    # Create Base64 object
    oBase64 = new Base64()

    # Testing text encryption and decryption
    testBase64(oBase64, "Hello, World!")

    # Testing text encryption and decryption
    testBase64(oBase64, "مرحباً بالعالم!")

    # Testing binary encryption and decryption
    testBase64Binary(oBase64)

    # Testing special cases
    testBase64SpecialCases(oBase64)

    ? "=== Testing completed successfully ==="
}

# Testing text encryption and decryption
func testBase64 oBase64, cText {
    ? "Testing text encryption and decryption: " + cText

    # Encrypt the text
    cEncoded = oBase64.encode(cText)
    ? "  Encoded text: " + cEncoded

    # Decrypt the text
    cDecoded = oBase64.decode(cEncoded)
    ? "  Decoded text: " + cDecoded

    # Validate the decoded text
    assert(cDecoded = cText, "Testing text encryption and decryption")
}

# Testing binary encryption and decryption
func testBase64Binary oBase64 {
    ? "Testing binary encryption and decryption"

    # Create binary data
    cBinary = ""
    for i = 0 to 255
        cBinary += char(i)
    next

    # Encrypt the binary data
    cEncoded = oBase64.encode(cBinary)
    ? "  Encoded binary data length: " + len(cEncoded)

    # Decrypt the binary data
    cDecoded = oBase64.decode(cEncoded)
    ? "  Decoded binary data length: " + len(cDecoded)

    # Validate the decoded binary data
    bEqual = true
    if len(cBinary) != len(cDecoded)
        bEqual = false
    else
        for i = 1 to len(cBinary)
            if substr(cBinary, i, 1) != substr(cDecoded, i, 1)
                bEqual = false
                exit
            ok
        next
    ok

    assert(bEqual, "Testing binary encryption and decryption")
}

# Testing special cases
func testBase64SpecialCases oBase64 {
    ? "Testing special cases"

    # Testing empty string
    cEncoded = oBase64.encode("")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "", "Testing empty string")

    # Testing string with length 1
    cEncoded = oBase64.encode("A")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "A", "Testing string with length 1")

    # Testing string with length 2
    cEncoded = oBase64.encode("AB")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "AB", "Testing string with length 2")

    # Testing string with length 3
    cEncoded = oBase64.encode("ABC")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "ABC", "Testing string with length 3")
}

# Helper function for assertion
func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    ok
}

