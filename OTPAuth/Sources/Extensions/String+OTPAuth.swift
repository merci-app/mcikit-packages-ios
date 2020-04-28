//
//  String+OTPAuth.swift
//

import Foundation

extension String {

    func padded(with character: Character, toLength length: Int) -> String {
        let paddingCount = length - count
        guard paddingCount > 0 else { return self }

        let padding = String(repeating: String(character), count: paddingCount)
        return padding + self
    }

}
