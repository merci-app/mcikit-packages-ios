//
//  OTPAuthError.swift
//


import Foundation

public enum OTPAuthError: Swift.Error {
    case genericError(String)
    case invalidURLScheme
    case invalidTimerPeriod(String)
    case invalidDigits(String)
    case invalidAlgorithm(String)
    case invalidSecret
    case invalidExpirationDate
}
