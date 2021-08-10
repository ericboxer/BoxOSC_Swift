//
//  Extension String.swift
//  
//
//  Created by Eric Boxer on 8/9/21.
//

import Foundation

extension String {
    var isInt: Bool {
        return !isEmpty && (rangeOfCharacter(from: .decimalDigits.inverted) == nil)
    }
}
