/*
Class: Base64
Description: Provides encoding and decoding functions for Base64
*/
load "stdlibcore.ring"

if ismainsourcefile() {
    oBase64 = new Base64()
    cEncoded = oBase64.encode("مرحبا بك في الموقع الرئيسي للمؤسسة العامة للتعليم العام والتدريب")
    cDecoded = oBase64.decode(cEncoded)
    ? "cEncoded: " + cEncoded
    ? "cDecoded: " + cDecoded
}

class Base64 {
    func init {
        # Base64 encoding table
        cBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    }

    # Encode data using Base64
    func encode cData {
        if cData = "" return "" ok
        
        cResult = ""
        aBytes = []
        
        # Convert text to bytes
        for i = 1 to len(cData)
            aBytes + ascii(substr(cData, i, 1))
        next
        
        # Process every 3 bytes
        for i = 1 to len(aBytes) step 3
            # Group bytes
            n1 = aBytes[i]
            n2 = 0
            n3 = 0
            
            if i + 1 <= len(aBytes)
                n2 = aBytes[i + 1]
            ok
            
            if i + 2 <= len(aBytes)
                n3 = aBytes[i + 2]
            ok
            
            # Convert 3 bytes to 4 Base64 characters
            b1 = n1 >> 2
            b2 = ((n1 & 3) << 4) | (n2 >> 4)
            b3 = ((n2 & 15) << 2) | (n3 >> 6)
            b4 = n3 & 63
            
            # Add characters to result
            cResult += substr(cBase64Chars, b1 + 1, 1)
            cResult += substr(cBase64Chars, b2 + 1, 1)
            
            if i + 1 <= len(aBytes)
                cResult += substr(cBase64Chars, b3 + 1, 1)
            else
                cResult += "="
            ok
            
            if i + 2 <= len(aBytes)
                cResult += substr(cBase64Chars, b4 + 1, 1)
            else
                cResult += "="
            ok
        next
        
        return cResult
    }

    # Decode data from Base64
    func decode cData {
        if cData = "" return "" ok
        
        cResult = ""
        aValues = []
        
        # Convert characters to values
        for i = 1 to len(cData)
            if substr(cData, i, 1) = "=" break ok
            
            for j = 1 to len(cBase64Chars)
                if substr(cData, i, 1) = substr(cBase64Chars, j, 1)
                    aValues + (j - 1)
                    exit
                ok
            next
        next
        
        # Process every 4 values
        for i = 1 to len(aValues) step 4
            # Extract values
            n1 = aValues[i]
            n2 = 0
            n3 = 0
            n4 = 0
            
            if i + 1 <= len(aValues)
                n2 = aValues[i + 1]
            ok
            
            if i + 2 <= len(aValues)
                n3 = aValues[i + 2]
            ok
            
            if i + 3 <= len(aValues)
                n4 = aValues[i + 3]
            ok
            
            # Convert 4 values to 3 bytes
            b1 = (n1 << 2) | (n2 >> 4)
            b2 = ((n2 & 15) << 4) | (n3 >> 2)
            b3 = ((n3 & 3) << 6) | n4
            
            # Add bytes to result
            cResult += char(b1)
            
            if i + 2 <= len(aValues)
                cResult += char(b2)
            ok
            
            if i + 3 <= len(aValues)
                cResult += char(b3)
            ok
        next
        
        return cResult
    }

    # Encode file using Base64
    func encodeFile cFilePath {
        if not fexists(cFilePath)
            raise("File not found: " + cFilePath)
        ok
        
        return encode(read(cFilePath))
    }

    # Decode file from Base64
    func decodeToFile cBase64Data, cOutputPath {
        cData = decode(cBase64Data)
        write(cOutputPath, cData)
        return len(cData)
    }

    private
    cBase64Chars
}
