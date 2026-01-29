/* load "openssllib.ring"
load "internetlib.ring" */

/*
Class: MFAManager
Description: Manager for multi-factor authentication
*/
class MFAManager {
    
    

    func init {
        oConfig = new SecurityConfig
        oEmailService = new EmailService
        oSMSService = new SMSService
    }

    # Generate and send code
    func generateAndSendCode cUser, cMethod {
        cCode = generateCode()
        cExpiry = calculateExpiry()
        
        switch cMethod {
            case "email"
                sendEmailCode(cUser, cCode)
            case "sms"
                sendSMSCode(cUser, cCode)
            case "authenticator"
                return generateAuthenticatorCode(cUser)
        }
        
        aActiveCodes + [cUser, cCode, cExpiry]
        return true
    }

    # Verify code
    func verifyCode cUser, cCode {
        for aCode in aActiveCodes {
            if aCode[1] = cUser and aCode[2] = cCode {
                if not isCodeExpired(aCode[3]) {
                    removeCode(cUser)
                    return true
                }
            }
        }
        return false
    }

    private

    oConfig
    oEmailService
    oSMSService
    aActiveCodes = []

    # Generate random code
    func generateCode {
        cCode = ""
        for i = 1 to oConfig.nMFACodeLength {
            cCode += random(0, 9)
        }
        return cCode
    }

    # Calculate expiry time
    func calculateExpiry {
        return date() + " " + time() + oConfig.nMFACodeExpiry
    }

    # Send code via email
    func sendEmailCode cUser, cCode {
        cSubject = "MFACode"
        cBody = "MFACode: " + cCode
        oEmailService.send(cUser, cSubject, cBody)
    }

    # Send code via SMS
    func sendSMSCode cUser, cCode {
        cMessage = "MFACode: " + cCode
        oSMSService.send(cUser, cMessage)
    }

    # Generate code for authenticator app
    func generateAuthenticatorCode cUser {
        cSecret = generateTOTPSecret()
        return generateQRCode(cUser, cSecret)
    }

    # Check if code has expired
    func isCodeExpired cExpiry {
        return timeDiff(cExpiry, date() + " " + time()) <= 0
    }

    # Remove used code
    func removeCode cUser {
        for i = 1 to len(aActiveCodes) {
            if aActiveCodes[i][1] = cUser {
                del(aActiveCodes, i)
                exit
            }
        }
    }
}

/*
Class: EmailService
Description: Email service for sending emails
SendEmail(cSMTPServer,cEmail,cPassword,
            cSender,cReceiver,cCC,cTitle,cContent)
*/
class EmailService {
    func send cTo, cSubject, cBody {
        # Execute email sending
        SendEmail(oConfig.cSMTPServer, oConfig.cEmail, oConfig.cPassword,
            oConfig.cEmail, cTo, "", cSubject, cBody)
        return true
    }
}

/*
Class: SMSService
Description: SMS service for sending SMS messages
*/
class SMSService {
    func send cTo, cMessage {
        # Execute SMS sending
        return true
    }
}
