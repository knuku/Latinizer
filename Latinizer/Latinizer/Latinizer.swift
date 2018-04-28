//
//  Latinizer.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/28/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

import Foundation

class Latinizer {
    class func latinize(_ input: Contact) -> Contact {
        return Contact(firstName: Latinizer.latinize(input.firstName),
                       lastName: Latinizer.latinize(input.lastName),
                       companyName: Latinizer.latinize(input.companyName))
    }

    class func latinize(_ input: String) -> String {
        let output = NSMutableString(string: input) as CFMutableString
        CFStringTransform(output, nil, kCFStringTransformToLatin, false)
        return output as String
    }
}
