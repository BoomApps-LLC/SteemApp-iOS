//
//  String+Ext.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation


extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    static func cast<T>(_ some: T) -> String? {
        if some is Int {
            return "\(some)"
        } else if some is Int64 {
            return "\(some)"
        } else {
            return "\"\(some)\""
        }
    }
}

extension String {
    var forJs: String {
        return self.htmlEscapeQuotes
    }
    
    var permlink: String {
        let some = [ ("\\W+", "-") ].reduce(self) {
            try! $0.replacing(pattern: $1.0, with: $1.1)
            }.resolvedHTMLEntities.lowercased()
        return "re\(some)steemitapp-ios"
    }
    
    var letters: String {
        return [
            ("\\W+", "")
            ].reduce(self) {
                try! $0.replacing(pattern: $1.0, with: $1.1)
            }.resolvedHTMLEntities
    }
    
    var htmlToPlainText: String {
        return [
            ("(<[^>]*>)|(&\\w+;)", " "),
            ("[ ]+", " ")
            ].reduce(self) {
                try! $0.replacing(pattern: $1.0, with: $1.1)
            }.resolvedHTMLEntities
    }
    
    var htmlToFlatText: String {
        let htmlStringData = self.data(using: .utf8)!
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html]
        let attributedHTMLString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        
        return attributedHTMLString?.string ?? ""
    }
    
    var resolvedHTMLEntities: String {
        return self
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }
    
    func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
    }
    
    var htmlEscapeQuotes: String {
        return [
            ("\'", "\\\""),
            ("\"", "\\\""),
            ("“", "&quot;"),
            ("\r", "\\r"),
            ("\n", "\\n")
            ].reduce(self) {
                return $0.replacingOccurrences(of: $1.0, with: $1.1)
        }
    }
}
