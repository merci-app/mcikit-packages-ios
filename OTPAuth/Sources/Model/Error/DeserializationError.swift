//
//  DeserializationError.swift
//

import Foundation

internal enum DeserializationError: Swift.Error {
    case duplicateQueryItem(String)
    case missingQueryItem(String)
}
