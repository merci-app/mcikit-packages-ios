//
//  OTPAuthAlgorithm.swift
//

import Foundation
import CommonCrypto

internal enum OTPAuthAlgorithm {
    
    case sha1
    case sha256
    case sha512
    
    var hashInfo: (hashFunction: CCHmacAlgorithm, hashLength: Int) {
        switch self {
        case .sha1:
            return (CCHmacAlgorithm(kCCHmacAlgSHA1), Int(CC_SHA1_DIGEST_LENGTH))
        case .sha256:
            return (CCHmacAlgorithm(kCCHmacAlgSHA256), Int(CC_SHA256_DIGEST_LENGTH))
        case .sha512:
            return (CCHmacAlgorithm(kCCHmacAlgSHA512), Int(CC_SHA512_DIGEST_LENGTH))
        }
    }
    
}

extension OTPAuthAlgorithm {
    
    init(_ string: String) throws{
        switch string.uppercased() {
        case "SHA1": self = .sha1
        case "SHA256": self = .sha256
        case "SHA512": self = .sha512
        default: throw OTPAuthError.invalidAlgorithm(string)
        }
    }
    
}
