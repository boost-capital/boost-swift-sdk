//
//  ResultRow.swift
//  BoostKYC_DemoApp
//
//  Created by Oleh Hrechyn on 26.11.2025.
//  Copyright © 2025 Boost Capital. All rights reserved.
//

import Foundation

enum ResultRow {
    case header(title: String)
    case keyValue(key: String, value: String?)
}

extension ResultRow {
    private static var indentSyntax: String { "  " }
    
    static func build(from json: [String: Any]) -> [ResultRow] {
        var rows: [ResultRow] = []
        
        let sortedKeys = json.keys.sorted()
        
        for key in sortedKeys {
            rows.append(.header(title: key))
            
            if let value = json[key] {
                let leafNodes = flatten(value)
                
                for (leafKey, leafValue) in leafNodes {
                    rows.append(.keyValue(key: leafKey, value: leafValue))
                }
            }
        }
        
        return rows
    }
    
    private static func flatten(_ value: Any, indent: String = "") -> [(String, String?)] {
        var results: [(String, String?)] = []
        
        if let dict = value as? [String: Any] {
            let sortedKeys = dict.keys.sorted()
            
            for key in sortedKeys {
                guard let val = dict[key] else { continue }
                
                let displayKey = indent + key
                
                if isContainer(val) {
                    results.append((displayKey, nil))
                    results.append(contentsOf: flatten(val, indent: indent + indentSyntax))
                } else {
                    results.append((displayKey, formatValue(val)))
                }
            }
        } else if let array = value as? [Any] {
            for (index, item) in array.enumerated() {
                let displayKey = indent + "[\(index)]"
                
                if isContainer(item) {
                    results.append((displayKey, nil))
                    results.append(contentsOf: flatten(item, indent: indent + indentSyntax ))
                } else {
                    results.append((displayKey, formatValue(item)))
                }
            }
        } else {
            results.append(("", formatValue(value)))
        }
        
        return results
    }
    
    private static func isContainer(_ value: Any) -> Bool {
        return (value is [String: Any]) || (value is [Any])
    }
    
    private static func formatValue(_ value: Any?) -> String {
        guard let value = value, !(value is NSNull) else { return "Null" }
        
        if let boolValue = value as? Bool {
            return boolValue ? "true" : "false"
        }
        
        return "\(value)"
    }
}
