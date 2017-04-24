//
//  BitItem.swift
//  Bit
//
//  Created by Hen Levy on 24/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import Foundation

class BitItem {
    var uid = ""
    var text = ""
    var pin = 0
    
    init(uid: String, text: String, pin: Int) {
        self.uid = uid
        self.text = text
        self.pin = pin
    }
}
