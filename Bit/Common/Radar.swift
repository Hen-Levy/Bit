//
//  Radar.swift
//  Bit
//
//  Created by Hen Levy on 03/05/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase

class Radar: LocationManagerDelegate {
    static let shared = Radar()
    
    private let dbRef = FIRDatabase.database().reference()
    private let locationManager: LocationManager!
    private var myCurrentLocation: CLLocation?
    private let searchEverySeconds = 5.0
    private let areaKm = 0.3 // 300 meters
    private let api = API()
    
    init() {
        self.locationManager = LocationManager()
        self.locationManager.locationManagerDelegate = self
    }
    
    func didUpdateLocation(lastLocation: CLLocation) {
        self.myCurrentLocation = lastLocation
    }
    
    func didFail(with error: Error) {
        debugPrint(error)
    }
    
    func start() {

        // search for bits locations in area
        // run it in separate queue
        
        DispatchQueue.global(qos: .background).async {
            self.searchBitsLocations()
        }
    }
    
    private func searchBitsLocations() {
        guard myCurrentLocation != nil else {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + searchEverySeconds) {
                self.searchBitsLocations()
            }
            return
        }
        
        let path = "users/" + User.shared.uid + "/friends"
        FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let friendsDic = snapshot.value as? [String: AnyObject]  else {
                return
            }

                let friendsUIDs = Array(friendsDic.keys)
                for friendUid in friendsUIDs {
//                    
//                    let friendName = (friendsDic[friendUid] as! [String: AnyObject])["name"] as! String
                    guard let friend = friendsDic[friendUid] as? [String: AnyObject],
                        let bitsDic = friend["bits"] as? [String: AnyObject],
                        let friendName = friend["name"] as? String else {
                            return
                    }
                    self.observeFriendBits(bitsDic: bitsDic, friendUid: friendUid, friendName: friendName)
                }
        })
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + searchEverySeconds) {
            self.searchBitsLocations()
        }
    }
    
    private func observeFriendBits(bitsDic: [String: AnyObject], friendUid: String, friendName: String) {
//        let path = "users/" + User.shared.uid + "/friends/" + friendUid + "/bits"
//        FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value, with: { (snapshot) in
        
            guard let myCurrentCoordinate = myCurrentLocation?.coordinate else {
                return
            }
        
            let bitsArray = Array(bitsDic.values)
            
            for bit in bitsArray {
                if let coordinateDic = bit["location"] as? [String: Double] {
                    let coordinate = CLLocationCoordinate2D(latitude: coordinateDic["lat"]!, longitude: coordinateDic["long"]!)
                    
                    let distanceFromMyCurrentLocation = distance(lat1: coordinate.latitude, lon1: coordinate.longitude, lat2: myCurrentCoordinate.latitude, lon2: myCurrentCoordinate.longitude, unit: "K")
                    
                    // if bit's distance is under X km
                    // and bit didn't sent - send it
                    
                    if distanceFromMyCurrentLocation <= self.areaKm,
                    let bitDic = bit as? [String: Any],
                        bitDic["sent"] == nil || (bitDic["sent"] as? Bool) == false {
                        
                        sendBit(senderName: friendName,
                                     bitDic: bitDic,
                                     bitFriendUID: friendUid)
                        
                        debugPrint("found bit's location in a distance of \(distanceFromMyCurrentLocation) km")
                        break
                    }
                }
            }
    }
    
    private func sendBit(senderName: String, bitDic: [String: Any], bitFriendUID: String) {
        api.requestSendBit(senderName: senderName, bitText: bitDic["text"] as! String, friendUID: bitFriendUID)
        
        let df = DateFormatter()
        df.dateFormat = dateFormat
        let dateSentStr = df.string(from: Date())
        
        // update database that the bit was sent
        var path = "users/" + bitFriendUID + "/friends/" + User.shared.uid + "/lastBitSent"
        dbRef.child(path).setValue(["date": dateSentStr,
                                    "text": bitDic["text"]!])
        
        // update specific bit with date
        var bitDic = ["uid": bitDic["uid"]!,
                      "text": bitDic["text"]!,
                      "pin": bitDic["pin"]!,
                      "location": bitDic["location"]!,
                      "sent": true,
                      "dateSent": dateSentStr] as [String : Any]
        
        path = "users/" + User.shared.uid + "/friends/" + bitFriendUID + "/bits/" + (bitDic["uid"] as! String)
        dbRef.child(path).setValue(bitDic)
    }
    
    private func deg2rad(_ deg:Double) -> Double {
        return deg * M_PI / 180.0
    }

    private func rad2deg(_ rad:Double) -> Double {
        return rad * 180.0 / M_PI
    }
    
    private func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
        dist = acos(dist)
        dist = rad2deg(dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        } else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
}
