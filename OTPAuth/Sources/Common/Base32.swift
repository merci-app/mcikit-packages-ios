//
//  Base32.swift
//

import Foundation

internal enum Base32 {
    
    static let __: UInt8 = 255
    static let alphabetDecodeTable: [UInt8] = [
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x20 - 0x2F
        __,__,26,27, 28,29,30,31, __,__,__,__, __,__,__,__,  // 0x30 - 0x3F
        __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x40 - 0x4F
        15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x50 - 0x5F
        __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x60 - 0x6F
        15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x70 - 0x7F
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
        __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
    ]
    
    
    static func base32DecodeToData(_ string: String) -> Data? {
        return base32decode(string, Base32.alphabetDecodeTable).flatMap { decoded in
            return decoded.withUnsafeBufferPointer {
                guard let baseAddress = $0.baseAddress else { return nil }
                return Data(bytes: baseAddress, count: decoded.count)
            }
        }
    }
    
    static func base32decode(_ string: String, _ table: [UInt8]) -> [UInt8]? {
        
        let length = string.unicodeScalars.count
        if length == 0 {
            return []
        }
        
        // validate string
        let leastPaddingLength = getLeastPaddingLength(string)
        if let index = string.unicodeScalars.firstIndex(where: {$0.value > 0xff || table[Int($0.value)] > 31}) {
            // index points padding "=" or invalid character that table does not contain.
            let pos = string.unicodeScalars.distance(from: string.unicodeScalars.startIndex, to: index)
            // if pos points padding "=", it's valid.
            if pos != length - leastPaddingLength {
                print("string contains some invalid characters.")
                return nil
            }
        }
        
        var remainEncodedLength = length - leastPaddingLength
        var additionalBytes = 0
        
        switch remainEncodedLength % 8 {
        // valid
        case 0: break
        case 2: additionalBytes = 1
        case 4: additionalBytes = 2
        case 5: additionalBytes = 3
        case 7: additionalBytes = 4
        default:
            print("string length is invalid.")
            return nil
        }
        
        // validated
        let dataSize = remainEncodedLength / 8 * 5 + additionalBytes
        
        // Use UnsafePointer<UInt8>
        return string.utf8CString.withUnsafeBufferPointer {
            (data: UnsafeBufferPointer<CChar>) -> [UInt8]? in
            guard var encoded = data.baseAddress else { return nil }
            var result = Array<UInt8>(repeating: 0, count: dataSize)
            
            guard
                var decoded = result.withUnsafeMutableBytes({ $0.baseAddress?.assumingMemoryBound(to: UInt8.self) })
                else { return nil }
            
            // decode regular blocks
            var value0, value1, value2, value3, value4, value5, value6, value7: UInt8
            (value0, value1, value2, value3, value4, value5, value6, value7) = (0, 0, 0, 0, 0, 0, 0, 0)
            
            while remainEncodedLength >= 8 {
                value0 = table[Int(encoded[0])]
                value1 = table[Int(encoded[1])]
                value2 = table[Int(encoded[2])]
                value3 = table[Int(encoded[3])]
                value4 = table[Int(encoded[4])]
                value5 = table[Int(encoded[5])]
                value6 = table[Int(encoded[6])]
                value7 = table[Int(encoded[7])]
                
                decoded[0] = value0 << 3 | value1 >> 2
                decoded[1] = value1 << 6 | value2 << 1 | value3 >> 4
                decoded[2] = value3 << 4 | value4 >> 1
                decoded[3] = value4 << 7 | value5 << 2 | value6 >> 3
                decoded[4] = value6 << 5 | value7
                
                remainEncodedLength -= 8
                decoded = decoded.advanced(by: 5)
                encoded = encoded.advanced(by: 8)
            }
            
            // decode last block
            (value0, value1, value2, value3, value4, value5, value6, value7) = (0, 0, 0, 0, 0, 0, 0, 0)
            
            switch remainEncodedLength {
            case 7:
                value6 = table[Int(encoded[6])]
                value5 = table[Int(encoded[5])]
                fallthrough
            case 5:
                value4 = table[Int(encoded[4])]
                fallthrough
            case 4:
                value3 = table[Int(encoded[3])]
                value2 = table[Int(encoded[2])]
                fallthrough
            case 2:
                value1 = table[Int(encoded[1])]
                value0 = table[Int(encoded[0])]
            default: break
            }
            
            switch remainEncodedLength {
            case 7:
                decoded[3] = value4 << 7 | value5 << 2 | value6 >> 3
                fallthrough
            case 5:
                decoded[2] = value3 << 4 | value4 >> 1
                fallthrough
            case 4:
                decoded[1] = value1 << 6 | value2 << 1 | value3 >> 4
                fallthrough
            case 2:
                decoded[0] = value0 << 3 | value1 >> 2
            default: break
            }
            
            return result
        }
    }
    
    /// Calc padding length
    
    private static func getLeastPaddingLength(_ string: String) -> Int {
        if string.hasSuffix("======") { return 6 }
        if string.hasSuffix("====") { return 4 }
        if string.hasSuffix("===") { return 3 }
        if string.hasSuffix("=") { return 1 }
        return 0
    }
    
}
