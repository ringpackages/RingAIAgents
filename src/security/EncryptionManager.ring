load "openssllib.ring"
load "G:/RingAIAgents/src/security/Base64.ring"
load "G:/RingAIAgents/src/security/config/SecurityConfig.ring"

/*
Class: EncryptionManager
Description: Encryption Manager
*/
class EncryptionManager {

    func init {
        oConfig = new SecurityConfig

        # Load encryption settings from configuration
        this.cAlgorithm = oConfig.cEncryptionAlgorithm
        this.nKeyLength = oConfig.nKeyLength
        this.nIVLength = oConfig.nIVLength

        # Check for algorithm support
        aSupportedCiphers = supportedCiphers()
        if not find(aSupportedCiphers, this.cAlgorithm) {
            raise("Unsupported encryption algorithm: " + this.cAlgorithm)
        }
    }

    # Encrypt data
    func encrypte cData, cKey, cIV {
        try {
            return encrypt(cData, cKey, cIV, this.cAlgorithm)
        catch
            raise("Error encrypting data: " + cCatchError)
        }
    }

    # Encrypt data using a specific algorithm
    func encryptWithAlgorithm cData, cKey, cIV, cCipherAlgorithm {
        try {
            # Check for algorithm support
            aSupportedCiphers = supportedCiphers()
            if not find(aSupportedCiphers, cCipherAlgorithm) {
                raise("Unsupported encryption algorithm: " + cCipherAlgorithm)
            }
            # Encrypt data
            return encrypt(cData, cKey, cIV, cCipherAlgorithm)
        catch
            raise("Error encrypting data: " + cCatchError)
        }
    }

    # Decrypt data
    func decrypte cEncryptedData, cKey, cIV {
        try {
            # Decrypt data
            return decrypt(cEncryptedData, cKey, cIV, this.cAlgorithm)
        catch
            raise("Error decrypting data: " + cCatchError)
        }
    }

    # Decrypt data using a specific algorithm
    func decryptWithAlgorithm cEncryptedData, cKey, cIV, cCipherAlgorithm {
        try {
            # Check for algorithm support
            aSupportedCiphers = supportedCiphers()
            if not find(aSupportedCiphers, cCipherAlgorithm) {
                raise("Unsupported encryption algorithm: " + cCipherAlgorithm)
            }
            # Decrypt data
            return decrypt(cEncryptedData, cKey, cIV, cCipherAlgorithm)
        catch
            raise("Error decrypting data: " + cCatchError)
        }
    }

    # Generate random key
    func generateKey nLength {
        if nLength <= 0 {
            nLength = this.nKeyLength
        }

        return randbytes(nLength)
    }

    # Generate random initialization vector
    func generateIV nLength {
        if nLength <= 0 {
            nLength = this.nIVLength
        }

        return randbytes(nLength)
    }

    # Get list of supported algorithms
    func getSupportedAlgorithms {
        return supportedCiphers()
    }

    # Calculate MD5 hash of file
    func calculateMD5File cFilePath {
        try {
            # قراءة محتوى الملف
            cFileContent = Read(cFilePath)

            # التحقق من قراءة الملف
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }

            #  حساب التجزئة
            return md5(cFileContent)
        catch
            return ""
        }
    }

    # Calculate SHA1 hash of file
    func calculateSHA1File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha1(cFileContent)
        catch
            return ""
        }
    }

    # Calculate SHA256 hash of file
    func calculateSHA256File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha256(cFileContent)
        catch
            return ""
        }
    }

    # Calculate SHA512 hash of file
    func calculateSHA512File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha512(cFileContent)
        catch
            return ""
        }
    }

    # Generate RSA key pair
    func generateRSAKeyPair nBits {
        try {
            # Generate RSA key pair
            rsaKey = rsa_generate(nBits)

            # Extract key parameters
            rsaKeyParams = rsa_export_params(rsaKey)

            # Create public key
            rsaPublicKeyParam = [:n = rsaKeyParams[:n], :e = rsaKeyParams[:e]]
            rsaPublicKey = rsa_import_params(rsaPublicKeyParam)

            # Export keys in PEM format
            cPrivateKeyPEM = rsa_export_pem(rsaKey)
            cPublicKeyPEM = rsa_export_pem(rsaPublicKey)

            return [
                :private_key = cPrivateKeyPEM,
                :public_key = cPublicKeyPEM
            ]
        catch
            raise("Error generating RSA key pair: " + cCatchError)
        }
    }

    # Encrypt data using RSA
    func encryptRSA cData, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Encrypt data
            return rsa_encrypt_pkcs(rsaPublicKey, cData)
        catch
            raise("Error encrypting data using RSA: " + cCatchError)
        }
    }

    # Decrypt data using RSA
    func decryptRSA cEncryptedData, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

            # Decrypt data
            return rsa_decrypt_pkcs(rsaKey, cEncryptedData)
        catch
            raise("Error decrypting data using RSA: " + cCatchError)
        }
    }

    # Sign data using RSA
    func signRSA cData, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

            # Calculate hash of data
            cHash = SHA256(cData)

            # Sign the hash
            return rsa_signhash_pkcs(rsaKey, cHash)
        catch
            raise("Error signing data using RSA: " + cCatchError)
        }
    }

    # Verify signature using RSA
    func verifyRSA cData, cSignature, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Calculate hash of data
            cHash = SHA256(cData)

            # Verify the signature
            return rsa_verifyhash_pkcs(rsaPublicKey, cHash, cSignature)
        catch
            raise("Error verifying signature using RSA: " + cCatchError)
        }
    }

    # Encrypt file using AES then encrypt AES key using RSA
    func encryptFile cFilePath, cOutputPath, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Read file content
            cData = read(cFilePath)

            # Generate random AES-256 key
            cKey = randbytes(32)
            cIV = randbytes(16)

            # Encrypt data using AES-256
            cEncryptedData = encrypt(cData, cKey, cIV, "aes256")

            # Encrypt AES key using RSA
            cEncryptedKey = rsa_encrypt_pkcs(rsaPublicKey, cKey)

            # Calculate length of encrypted key
            nKeyLength = len(cEncryptedKey)

            # Store IV, encrypted key length, encrypted key, and encrypted data in file
            write(cOutputPath, cIV + char(nKeyLength) + cEncryptedKey + cEncryptedData)

            return true
        catch
            raise("Error encrypting file: " + cCatchError)
        }
    }

    # Decrypt file using AES and RSA
    func decryptFile cEncryptedFilePath, cOutputPath, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)
            
            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

            # Read encrypted file content
            cEncryptedContent = read(cEncryptedFilePath)

            # Extract IV (first 16 bytes)
            cIV = substr(cEncryptedContent, 1, 16)

            # Extract encrypted key length (next byte)
            rsaKeyParams = rsa_export_params(rsaKey)
            nKeyLength = rsaKeyParams[:bits]/ 8
            # Extract encrypted key
            cEncryptedKey = substr(cEncryptedContent, 18, nKeyLength)

            # Extract encrypted data
            cEncryptedData = substr(cEncryptedContent, 18 + nKeyLength)

            # Decrypt AES key using RSA
            cKey = rsa_decrypt_pkcs(rsaKey, cEncryptedKey)

            # Decrypt data using AES
            cPlainData = decrypt(cEncryptedData, cKey, cIV, "aes256")

            # Write decrypted data to file
            write(cOutputPath, cPlainData)

            return true
        catch
            raise("Error decrypting file: " + cCatchError)
        }
    }

    # Encrypt large file using AES then encrypt AES key using RSA
    func encryptLargeFile cFilePath, cOutputPath, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Generate random AES-256 key
            cKey = randbytes(32)
            cIV = randbytes(16)

            # Encrypt AES key using RSA
            cEncryptedKey = rsa_encrypt_pkcs(rsaPublicKey, cKey)

            # Calculate length of encrypted key
            nKeyLength = len(cEncryptedKey)

            # Open source file for reading
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open source file: " + cFilePath)
            }

            # Open destination file for writing
            fpDest = fopen(cOutputPath, "wb")
            if fpDest = 0 {
                fclose(fpSource)
                raise("Failed to open destination file: " + cOutputPath)
            }

            # Write IV, encrypted key length, and encrypted key to destination file
            fwrite(fpDest, cIV + char(nKeyLength) + cEncryptedKey)

            # Read source file in chunks and encrypt
            nChunkSize = 8192  # 8 Kilobytes
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                # Encrypt the chunk
                cEncryptedChunk = encrypt(cChunk, cKey, cIV, "aes256")

                # Write encrypted chunk length and encrypted chunk to destination file
                nChunkLength = len(cEncryptedChunk)
                fwrite(fpDest, char(nChunkLength / 256) + char(nChunkLength % 256) + cEncryptedChunk)
            }

            # Close files
            fclose(fpSource)
            fclose(fpDest)

            return true
        catch
            # Close files in case of error
            if fpSource != NULL {
                fclose(fpSource)
            }
            if fpDest != NULL {
                fclose(fpDest)
            }

            raise("Error encrypting large file: " + cCatchError)
        }
    }

    # Decrypt large file encrypted using AES and RSA
    func decryptLargeFile cEncryptedFilePath, cOutputPath, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

            # Open encrypted file for reading
            fpSource = fopen(cEncryptedFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open encrypted file: " + cEncryptedFilePath)
            }

            # Read IV (first 16 bytes)
            cIV = fread(fpSource, 16)

            # Read encrypted key length (next byte)
            nKeyLength = ascii(fread(fpSource, 1))

            # Read encrypted key
            cEncryptedKey = fread(fpSource, nKeyLength)

            # Decrypt AES key using RSA
            cKey = rsa_decrypt_pkcs(rsaKey, cEncryptedKey)

            # Open destination file for writing
            fpDest = fopen(cOutputPath, "wb")
            if fpDest = 0 {
                fclose(fpSource)
                raise("Failed to open destination file: " + cOutputPath)
            }

            # Read and decrypt chunks
            while true {
                # Read encrypted chunk length (2 bytes)
                cChunkLengthBytes = fread(fpSource, 2)
                if len(cChunkLengthBytes) < 2 {
                    exit  # End of file
                }

                nChunkLength = ascii(cChunkLengthBytes[1]) * 256 + ascii(cChunkLengthBytes[2])

                # Read encrypted chunk
                cEncryptedChunk = fread(fpSource, nChunkLength)
                if len(cEncryptedChunk) < nChunkLength {
                    raise("Unexpected end of file")
                }

                # Decrypt the chunk
                cPlainChunk = decrypt(cEncryptedChunk, cKey, cIV, "aes256")

                # Write decrypted chunk to destination file
                fwrite(fpDest, cPlainChunk)
            }

            # Close files
            fclose(fpSource)
            fclose(fpDest)

            return true
        catch
            # Close files in case of error
            if fpSource != NULL {
                fclose(fpSource)
            }
            if fpDest != NULL {
                fclose(fpDest)
            }

            raise("Error decrypting large file: " + cCatchError)
        }
    }

    # Sign file using RSA
    func signFile cFilePath, cSignatureFilePath, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

           # Calculate SHA256 hash of the file
            cDigest = calculateSHA256File(cFilePath)

            # Sign the hash using RSA-PKCS
            cSignature = rsa_signhash_pkcs(rsaKey, cDigest)

            # Write the signature to file
            write(cSignatureFilePath, cSignature)

            return true
        catch
            raise("Error signing file: " + cCatchError)
        }
    }

    # Verify file signature using RSA
    func verifyFileSignature cFilePath, cSignatureFilePath, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Calculate SHA256 hash of the file
            cDigest = calculateSHA256File(cFilePath)

            # Read the signature from the file
            cSignature = read(cSignatureFilePath)

            # Verify the signature using RSA-PKCS
            return rsa_verifyhash_pkcs(rsaPublicKey, cDigest, cSignature)
        catch
            raise("Error verifying file signature: " + cCatchError)
        }
    }

    # Sign large file using RSA
    func signLargeFile cFilePath, cSignatureFilePath, cPrivateKeyPEM {
        try {
            # Import private key
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # Check if the key is a private key
            if not rsa_is_privatekey(rsaKey) {
                raise("The provided key is not a private key")
            }

            # Open the file for reading
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open file: " + cFilePath)
            }

            # Initialize SHA256 context
            ctx = sha256init()

            # Read the file in chunks and update the hash context
            nChunkSize = 8192  # 8 Kilobytes
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                sha256update(ctx, cChunk)
            }

            # Close the file
            fclose(fpSource)

            # Finalize the hash calculation
            cDigest = sha256final(ctx)

            # Sign the hash using RSA-PKCS
            cSignature = rsa_signhash_pkcs(rsaKey, cDigest)

            # Write the signature to file
            write(cSignatureFilePath, cSignature)

            return true
        catch
            # Close the file in case of error
            if fpSource != NULL {
                fclose(fpSource)
            }

            raise("Error signing large file: " + cCatchError)
        }
    }

    # Verify large file signature using RSA
    func verifyLargeFileSignature cFilePath, cSignatureFilePath, cPublicKeyPEM {
        try {
            # Import public key
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # Open the file for reading
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open file: " + cFilePath)
            }

            # Initialize SHA256 context
            ctx = sha256init()

            # Read the file in chunks and update the hash context
            nChunkSize = 8192  # 8 Kilobytes
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                sha256update(ctx, cChunk)
            }

            # Close the file
            fclose(fpSource)

            # Finalize the hash calculation
            cDigest = sha256final(ctx)

            # Read the signature from the file
            cSignature = read(cSignatureFilePath)

            # Verify the signature using RSA-PKCS
            return rsa_verifyhash_pkcs(rsaPublicKey, cDigest, cSignature)
        catch
            # Close the file in case of error
            if fpSource != NULL {
                fclose(fpSource)
            }

            raise("Error verifying large file signature: " + cCatchError)
        }
    }

    # Helper function for generating random strings
    func random_string nLength
        cResult = ""
        for i = 1 to nLength {
            cResult += char(random(26) + 97)
        }
        return cResult
    
    private

    oConfig
    cAlgorithm
    nKeyLength
    nIVLength
}
