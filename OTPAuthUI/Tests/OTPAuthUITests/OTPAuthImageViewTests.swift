//
//  OTPAuthImageViewTests.swift
//  
//
//  Created by Tiago Oliveira on 14/07/20.
//

import XCTest
import OTPAuth
@testable import OTPAuthUI

final class OTPAuthImageViewTests: XCTestCase {
        
    let cpf: String = "12345678909"
    let value: String = "12"
    var imageView: OTPAuthImageView?
    var otpAuth: OTPAuth?
    
    override func setUp() {
        super.setUp()
        imageView = OTPAuthImageView()
        otpAuth = try? OTPAuth(from: "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5")
    }
    
    func testImageViewNotNil() {
        guard let otpAuth = otpAuth else { return }
        XCTAssertNil(imageView?.image)
        
        imageView?.generateToken(vat: cpf, otpAuth: otpAuth)
        XCTAssertNotNil(imageView?.image)
    }
    
    func testImageViewWithValue() {
        guard let otpAuth = otpAuth else { return }
        XCTAssertNil(imageView?.image)
        
        imageView?.generateToken(vat: cpf, otpAuth: otpAuth, value: "12")
        XCTAssertNotNil(imageView?.image)
    }
    
    func testImageViewWithColor() {
        guard let otpAuth = otpAuth else { return }
        guard let imageView = imageView else { return }
        XCTAssertNil(imageView.image)
        
        imageView.generateToken(vat: cpf, otpAuth: otpAuth, value: "12", color: .blue)
        XCTAssertNotNil(imageView.image)
    }
    
    func testNormalizeString() {
        let valueNormalize = value.normalize()
        XCTAssertEqual("0000000012", valueNormalize)
    }
    
    static var allTests = [
        ("TestImageViewNotNil", testImageViewNotNil),
        ("TestImageViewWithValue", testImageViewWithValue),
        ("TestImageViewWithColor", testImageViewWithColor),
        ("TestNormalizeString", testNormalizeString)
    ]
}
