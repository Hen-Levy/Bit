//
//  Friend.swift
//  Bit
//
//  Created by Hen Levy on 24/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit

class Friend {
    var uid = ""
    var name = ""
    var image: UIImage?
    
    init(uid: String, name: String, image: UIImage?) {
        self.uid = uid
        self.name = name
        self.image = image ?? UIImage(named: "contact_placeholder")
    }
}
