//
//  OTPAuthFactor.swift
//

import Foundation

internal enum OTPAuthFactor {
    
    case counter(UInt64)
    case timer(period: TimeInterval)
    
    func counterValue(at time: Date) throws -> UInt64 {
        switch self {
        case .counter(let counter):
            return counter
            
        case .timer(let period):
            let timeSinceEpoch = time.timeIntervalSince1970
            return UInt64(timeSinceEpoch / period)
        }
    }
    
}
