//
//  Extensions.swift
//  RainKit
//
//  Created by rainedAllNight on 2020/9/30.
//

import Foundation

public extension String {
    func camelCase(with separator: Character = "_") -> String {
        let strings = self.split(separator: separator)
        if strings.count <= 1 {
            return self.filter({$0 != separator})
        } else {
            return strings.reduce("") { (result, sub) -> String in
                if result.isEmpty {
                    return String(sub)
                } else {
                    return result + sub.capitalized
                }
            }
        }
    }
    
    var headUppercased: String {
        guard !isEmpty else {return ""}
        let range = ...startIndex
        return replacingCharacters(in: range, with: self.first!.uppercased())
    }
}
