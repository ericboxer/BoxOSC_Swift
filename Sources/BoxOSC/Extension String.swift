//
//  Extension String.swift
//
//
//  Created by Eric Boxer on 8/9/21.
//

import Foundation

extension String {
    var isNumber: Bool {
        
        // Is an empty string that includes numbers, no letters, and only at most 1 .
        return !isEmpty && (rangeOfCharacter(from: .decimalDigits) != nil ) && rangeOfCharacter(from: .letters) == nil && components(separatedBy: ".").count < 3
    }
}
