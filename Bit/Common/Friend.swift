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
    var lastBitSentDate: String?
    var lastBitText: String?
    
    var df: DateFormatter {
        let tempDf = DateFormatter()
        tempDf.dateFormat = dateFormat
        return tempDf
    }
    var lastBitDate: Date? {
        if let lastBitDateStr = lastBitSentDate {
            return df.date(from: lastBitDateStr)
        }
        return nil
    }
    
    init(uid: String, name: String, image: UIImage?, lastBitSentDate: String? = nil, lastBitText: String? = nil) {
        self.uid = uid
        self.name = name
        self.image = image ?? personPlaceholderImage
        self.lastBitSentDate = lastBitSentDate
        self.lastBitText = lastBitText
    }
}
