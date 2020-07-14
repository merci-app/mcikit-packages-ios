//
//  File.swift
//  
//
//  Created by Tiago Oliveira on 14/07/20.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OTPAuthUITests.allTests),
    ]
}
#endif
