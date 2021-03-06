//
//  User.swift
//  Bit
//
//  Created by Hen Levy on 25/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging
import FirebaseInstanceID

let personPlaceholderImage = UIImage(named: "contact_placeholder")

class User {
    static let shared = User()
    var uid: String {
        return FIRAuth.auth()?.currentUser?.uid ?? ""
    }
    var name: String {
        return FIRAuth.auth()?.currentUser?.displayName ?? ""
    }
    var email: String {
        return FIRAuth.auth()?.currentUser?.email ?? ""
    }
    var registrationToken: String? {
        return FIRInstanceID.instanceID().token()
    }
    private var downloadedImage: UIImage?
    
    func getProfilePic(userId: String, completion: @escaping (UIImage?) -> ()) {
        if userId == User.shared.uid && downloadedImage != nil {
            completion(downloadedImage)
            return
        }
        
        FIRDatabase.database().reference().child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("userPhoto"){
                let filePath = "\(userId)/\("userPhoto")"
                FIRStorage.storage().reference().child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    if let strongData = data {
                        let image = UIImage(data: strongData)
                        if userId == User.shared.uid {
                            User.shared.downloadedImage = image
                        }
                        completion(image)
                    } else {
                        completion(personPlaceholderImage)
                    }
                })
            } else {
                completion(personPlaceholderImage)
            }
        })
    }
    
    func setProfilePic(_ image: UIImage) {
        
        guard let scaledImage = image.scaleImage(toSize: CGSize(width:150,height:150)),
            let data = UIImagePNGRepresentation(scaledImage) else {
            return
        }
        
        // set upload path
        let filePath = "\(User.shared.uid)/\("userPhoto")"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        FIRStorage.storage().reference().child(filePath).put(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
                FIRDatabase.database().reference().child("users").child(User.shared.uid).updateChildValues(["userPhoto": downloadURL])
            }
            
        }
    }
    
    func clearUserCachedInfo() {
        downloadedImage = nil
    }
    
    func saveRegistrationToken() {
        if let token = registrationToken {
            let path = "users/" + uid + "/registrationToken"
            FIRDatabase.database().reference().child(path).setValue(token)
        }
    }
}
