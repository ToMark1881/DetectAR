//
//  String+Extensions.swift
//  GetMe
//
//  Created by Vladyslav Vdovycheko on 30.09.2020.
//

import Foundation
import Security
import UIKit


extension String {
    
    func getCleanedURL() -> URL? {
       guard self.isEmpty == false else {
           return nil
       }
       if let url = URL(string: self) {
           return url
       } else {
           if let urlEscapedString = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) , let escapedURL = URL(string: urlEscapedString){
               return escapedURL
           }
       }
       return nil
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        
        return from ..< to
    }

    subscript(r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(self[startIndex...endIndex])
        }
    }

    var toDouble: Double? {

        if let iosVersion = Double(self) {
            return iosVersion
        }

        let arr = components(separatedBy: ".")
        if arr.count >= 1 {
            var integerPart = 0
            var floatPart = 0

            if let _integerPart = Int(arr[0]), !arr[0].isEmpty {
                integerPart = _integerPart
            }

            if let _floatPart = Int(arr[1]), !arr[1].isEmpty {
                floatPart = _floatPart
            }

            return Double("\(integerPart).\(floatPart)")
        }
        return nil
    }

    func clear(start: String, end: String) -> String {
        var string = self as NSString

        while true {
            var result = ""
            //            var string = str
            let startRange = string.range(of: start)

            if startRange.location == NSNotFound {
                break
            }
            let rangeStart = NSRange(location: 0, length: startRange.location)
            result += string.substring(with: rangeStart)

            let endrange = string.range(of: end)
            if endrange.location == NSNotFound {
                break
            }

            let endIndex = endrange.location + end.count
            let rangeEnd = NSRange(location: endIndex, length: string.length - endIndex)

            result += string.substring(with: rangeEnd)

            string = result as NSString
        }

        return string as String
    }


    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    func insert(_ string: String, ind: Int) -> String {
        return String(self.prefix(ind)) + string + String(self.suffix(self.count - ind))
    }

    func normalizeString() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
        return range(of: string, options: options)?.lowerBound
    }

    func indexes(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
        var result: [String.Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }

    func ranges(of string: String, options: String.CompareOptions = .literal) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    func safelyLimitedTo(length: Int)->String {
        if (self.count <= length) {
            return self
        }
        return String(Array(self).prefix(upTo: length))
    }
    
}

