//
//  BitsLocationsViewController.swift
//  Bit
//
//  Created by Hen Levy on 25/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

class BitsLocationsViewController: UIViewController {
    var friend: Friend!
    var bitLocations = [LastBitItem]()
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLocations()
    }
    
    func loadLocations() {
        bitLocations.removeAll()
        
        if friend == nil {
            navigationController?.navigationBar.height = 44.0
            navigationController?.navigationBar.setupGradient()
            self.title = "Locations"
            
            let path = "users/" + User.shared.uid + "/friends"
            FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let friendsDic = snapshot.value as? [String: AnyObject]  else {
                    return
                }
                let friendsUIDs = Array(friendsDic.keys)
                for friendUid in friendsUIDs {
                    let friendName = (friendsDic[friendUid] as! [String: AnyObject])["name"] as! String
                    self.observeFriend(friendUid, friendName)
                }
            })
        } else {
            observeFriend(friend.uid, friend.name)
        }
    }
    
    func observeFriend(_ friendUid: String, _ friendName: String) {
        let path = "users/" + User.shared.uid + "/friends/" + friendUid + "/bits"
        FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            guard let bitsDic = snapshot.value as? [String: AnyObject],
                let strongSelf = self else {
                    return
            }
            
            let bitsArray = Array(bitsDic.values)
            
            for bit in bitsArray {
                let bitText = (bit["text"] as? String) ?? ""
                let bitUid = (bit["uid"] as? String) ?? ""
                
                if let coordinateDic = bit["location"] as? [String: Double] {
                    let coordinate = CLLocationCoordinate2D(latitude: coordinateDic["lat"]!, longitude: coordinateDic["long"]!)
                    
                    let bitLocation = LastBitItem(uid: bitUid, text: bitText, pin: 0, coordinate: coordinate)
                    
                    strongSelf.bitLocations.append(bitLocation)
                }
            }
            
            guard !strongSelf.bitLocations.isEmpty else {
                return
            }
            let camCoordinate = strongSelf.bitLocations[0].coordinate!
            
            let camera = GMSCameraPosition.camera(withLatitude: camCoordinate.latitude,
                                                  longitude: camCoordinate.longitude,
                                                  zoom: 14)
            strongSelf.mapView.camera = camera
            
            for location in strongSelf.bitLocations {
                let marker = GMSMarker()
                marker.position = location.coordinate!
                marker.snippet = friendName + ": " + location.text
                marker.appearAnimation = .pop
//                DispatchQueue.global(qos: .default).async {
//                    User.shared.getProfilePic(userId: friendUid, completion: { friendPhoto in
//                        DispatchQueue.main.async {
//                            let scaledImage = friendPhoto?.scaleImage(toSize: CGSize(width: 20, height: 20))
//                            let iconView = UIImageView(image: scaledImage)
//                            iconView.layer.masksToBounds = true
//                            iconView.layer.cornerRadius = iconView.frame.size.height/2
//                            marker.iconView = iconView
//                        }
//                    })
//                }
                marker.map = strongSelf.mapView
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if friend != nil {
            UIApplication.shared.isStatusBarHidden = true
        }
        loadLocations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if friend != nil {
            UIApplication.shared.isStatusBarHidden = false
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}
