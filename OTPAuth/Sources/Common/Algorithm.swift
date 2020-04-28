//
//  Algorithm.swift
//

import Foundation
import CommonCrypto

internal enum Algorithm {
    
    static func hmac(algorithm: OTPAuthAlgorithm, key: Data, data: Data) -> Data {
        
        let (hashFunction, hashLength) = algorithm.hashInfo
        
        let macOut = UnsafeMutablePointer<UInt8>.allocate(capacity: hashLength)
        defer {
            #if swift(>=4.1)
            macOut.deallocate()
            #else
            macOut.deallocate(capacity: hashLength)
            #endif
        }
        
        key.withUnsafeBytes { keyBuffer in
            guard let keyBytes = keyBuffer.baseAddress else { return }
            data.withUnsafeBytes { dataBuffer in
                guard let dataBytes = dataBuffer.baseAddress else { return }
                CCHmac(hashFunction, keyBytes, key.count, dataBytes, data.count, macOut)
            }
        }
        
        return Data(bytes: macOut, count: hashLength)
    }
    
    static func hash(_ time: Date,
                     _ factor: OTPAuthFactor,
                     _ algorithm: OTPAuthAlgorithm,
                     _ digits: Int,
                     _ secret: Data?) throws -> String {
        
        guard let secret = secret else {
            throw OTPAuthError.invalidSecret
        }
        
        let counter = try factor.counterValue(at: time)
        var bigCounter = counter.bigEndian
        
        let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)
        let hash = hmac(algorithm: algorithm, key: secret, data: counterData)
        
        var truncatedHash = hash.withUnsafeBytes { (buffer) -> UInt32 in
            guard let ptr = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            
            let offset = ptr[hash.count - 1] & 0x0f
            let truncatedHashPtr = ptr + Int(offset)
            return truncatedHashPtr.withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0.pointee
            }
        }
        
        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash &= 0x7fffffff
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))
        
        return String(truncatedHash).padded(with: "0", toLength: digits)
    }
    
}
