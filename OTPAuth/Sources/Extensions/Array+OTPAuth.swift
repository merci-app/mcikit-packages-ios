//
//  Array+OTPAuth.swift
//

import Foundation

internal extension Array where Element == URLQueryItem {
    
    func value(for name: String) throws -> String? {
        
        let matchingQueryItems = self.filter({
            $0.name == name
        })
        
        guard !matchingQueryItems.isEmpty else {
            throw DeserializationError.missingQueryItem(name)
        }
        
        guard matchingQueryItems.count == 1 else {
            throw DeserializationError.duplicateQueryItem(name)
        }
        
        return matchingQueryItems.first?.value
    }
    
}
