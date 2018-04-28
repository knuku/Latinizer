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
