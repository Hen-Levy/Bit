//
//  FriendsManager.swift
//  Bit
//
//  Created by Hen Levy on 25/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class FriendsManager {
    static let shared = FriendsManager()
    var friendsImagesCache = NSCache<NSString, UIImage>()
    
    init() {
        self.friendsImagesCache.countLimit = 20
    }
    
    func downloadFriendImage(friendUid: String, completion: @escaping (UIImage?) -> ()) {
        FIRDatabase.database().reference().child("users").child(friendUid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("userPhoto") {
                let filePath = "\(friendUid)/\("userPhoto")"
                FIRStorage.storage().reference().child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    if let strongData = data,
                        let friendImage = UIImage(data: strongData) {
                        self.friendsImagesCache.setObject(friendImage, forKey: NSString(string: friendUid))
                        completion(friendImage)
                    } else {
                        completion(personPlaceholderImage)
                    }
                })
            } else {
                completion(personPlaceholderImage)
            }
        })
    }
}
