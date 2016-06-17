//
//  PhoneNumberValidator.swift
//  Cru
//
//  Created by Deniz Tumer on 5/31/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import SwiftValidator

class CruPhoneNoRule: RegexRule {
    static let regex = "^\\(\\d{3}\\)\\s\\d{3}-\\d{4}$"
    
    convenience init(message : String = "Must be a valid 10 digit phone number"){
        self.init(regex: CruPhoneNoRule.regex, message : message)
    }
}