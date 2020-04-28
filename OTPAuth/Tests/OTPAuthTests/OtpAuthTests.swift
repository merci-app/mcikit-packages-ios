import XCTest
@testable import OTPAuth

final class OTPAuthTests: XCTestCase {
    
    func testToken() {
        let string = "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5"
        let token = try? OTPAuth(from: string)
        
        print("Current token: \(token?.currentToken ?? "")")
        print("Remaining seconds: \(token?.remainingSeconds ?? "")")
        
        XCTAssertNotNil(token?.currentToken)
        XCTAssertTrue(token?.currentToken?.count == 6)
    }
    
    func testMissingIssuer() {
        let string = "otpauth://totp/XPTO:FOO?algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5"
        let token = try? OTPAuth(from: string)
        
        print("Current token: \(token?.currentToken ?? "")")
        print("Remaining seconds: \(token?.remainingSeconds ?? "")")
        
        XCTAssertNotNil(token?.currentToken)
        XCTAssertTrue(token?.currentToken?.count == 6)
    }
    
    func testMissingAlgorithm() {
        let string = "otpauth://totp/XPTO:FOO?issuer=XPTO&digits=6&period=30&secret=N4SYQORWRZ2TIML5"

        XCTAssertThrowsError(try OTPAuth(from: string)) { (error) in
            if case OTPAuthError.genericError = error {
            } else {
                XCTFail()
            }
        }
    }
    
    func testMissingDigits() {
        let string = "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&period=30&secret=N4SYQORWRZ2TIML5"

        XCTAssertThrowsError(try OTPAuth(from: string)) { (error) in
            if case OTPAuthError.genericError = error {
            } else {
                XCTFail()
            }
        }
    }
    
    func testMissingPeriod() {
        let string = "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&secret=N4SYQORWRZ2TIML5"
        
        XCTAssertThrowsError(try OTPAuth(from: string)) { (error) in
            if case OTPAuthError.genericError = error {
            } else {
                XCTFail()
            }
        }
    }
    
    func testMissingSecret() {
        let string = "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30"
        
        XCTAssertThrowsError(try OTPAuth(from: string)) { (error) in
            if case OTPAuthError.genericError = error {
            } else {
                XCTFail()
            }
        }
    }
    
    static var allTests = [
        ("TestToken", testToken),
        ("TestMissingIssuer", testMissingIssuer),
        ("TestMissingAlgorithm", testMissingAlgorithm),
        ("TestMissingDigits", testMissingDigits),
        ("TestMissingPeriod", testMissingPeriod),
        ("TestMissingSecret", testMissingSecret),
    ]
    
}
