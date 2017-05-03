//
//  API.swift
//  Bit
//
//  Created by Hen Levy on 03/05/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Alamofire

class API {
    func requestSendBit(senderName: String, bitText: String, friendUID: String, spinner: UIActivityIndicatorView? = nil) {
        
        FIRDatabase.database().reference().child("users/\(friendUID)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let friendDic = snapshot.value as? [String: AnyObject],
                let token = friendDic["registrationToken"] as? String else {
                    spinner?.stopAnimating()
                    return
            }
            
            let params: Parameters = ["notification": ["title": senderName, "body": bitText],
                                      "to": token]
            
            Alamofire.request("https://fcm.googleapis.com/fcm/send",
                              method: HTTPMethod.post,
                              parameters: params, encoding: JSONEncoding.default,
                              headers: ["Authorization": "key=\(serverKey)"]).responseJSON(completionHandler: { (response) in
                                
                                if let json = response.result.value as? Dictionary<String, Any> {
                                    debugPrint(json)
                                }
                              })
        })
    }
}
