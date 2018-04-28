//
//  Latinizer.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/28/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

import Foundation

protocol Latinizer {
    static func latinize(_ input: String) -> String;
}

extension Latinizer {
    static func latinize(_ input: Contact) -> Contact {
        return Contact(firstName: Self.latinize(input.firstName),
                       lastName: Self.latinize(input.lastName),
                       companyName: Self.latinize(input.companyName))
    }
}

class NativeLatinizer: Latinizer {
    static func latinize(_ input: String) -> String {
        let output = NSMutableString(string: input) as CFMutableString
        CFStringTransform(output, nil, kCFStringTransformToLatin, false)
        return output as String
    }
}

/// For CustomLatinizer rules are taken from US Travel Docs website
/// which I consider the most neutral, not overloaded with diactritics
/// and overall sane.
/// I applied a couple of changes to suit my personal taste:
/// - use 'e' intead of 'ё' for 'ё'
/// - use 'iy' instead of 'yy' for 'ый'
/// You can find the original table here: http://www.ustraveldocs.com/ru/Transliteration.pdf
class CustomLatinizer: Latinizer {
    let table = {}
    static func latinize(_ input: String) -> String {
        var preprocessedInput: String
        preprocessedInput = input.replacingOccurrences(of: "ъе", with: "ye")
        preprocessedInput = input.replacingOccurrences(of: "ъё", with: "ye")
        preprocessedInput = input.replacingOccurrences(of: "ый", with: "iy")

        let latinizationPairs =
            ["а": "a",
             "б": "b",
             "в": "v",
             "г": "g",
             "д": "d",
             "e": "e",
             "ё": "e",
             "ж": "zh",
             "з": "z",
             "и": "i",
             "й": "y",
             "к": "k",
             "л": "l",
             "м": "m",
             "н": "n",
             "о": "o",
             "п": "p",
             "р": "r",
             "с": "s",
             "т": "t",
             "у": "u",
             "ф": "f",
             "х": "kh",
             "ц": "ts",
             "ч": "ch",
             "ш": "sh",
             "щ": "shch",
             "ъ": "",
             "ы": "y",
             "ь": "",
             "э": "e",
             "ю": "yu",
             "я": "ya"]

        var output = ""
        for inputChar in preprocessedInput {
            let lowercased = String(inputChar).lowercased()
            let firstCharIndex = lowercased.index(lowercased.startIndex, offsetBy: 0)
            let lowercasedChar = lowercased[firstCharIndex]
            let isLowercased = lowercasedChar == inputChar
            if let outputCharString = latinizationPairs[String(lowercasedChar)] {
                if isLowercased || outputCharString.count == 0 {
                    output.append(outputCharString)
                }
                else {
                    output.append(outputCharString.capitalized)
                }
            }
            else {
                output.append(inputChar)
            }
        }

        return output
    }
}
