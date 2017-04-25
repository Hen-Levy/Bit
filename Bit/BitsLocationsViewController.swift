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
    var locations = [(bitText: String, coordinate: CLLocationCoordinate2D)]()
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.observeFriend(friendUid)
                }
            })
        } else {
            observeFriend(friend.uid)
        }
    }
    
    func observeFriend(_ friendUid: String) {
        let path = "users/" + User.shared.uid + "/friends/" + friendUid + "/bits"
        FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            guard let bitsDic = snapshot.value as? [String: AnyObject],
                let strongSelf = self else {
                    return
            }
            
            let bitsArray = Array(bitsDic.values)
            
            for bit in bitsArray {
                let bitText = (bit["text"] as? String) ?? ""
                
                if let coordinateDic = bit["location"] as? [String: Double] {
                    let coordinate = CLLocationCoordinate2D(latitude: coordinateDic["lat"]!, longitude: coordinateDic["long"]!)
                    strongSelf.locations.append((bitText, coordinate))
                }
            }
            
            guard !strongSelf.locations.isEmpty else {
                return
            }
            let camCoordinate = strongSelf.locations[0].coordinate
            
            let camera = GMSCameraPosition.camera(withLatitude: camCoordinate.latitude,
                                                  longitude: camCoordinate.longitude,
                                                  zoom: 14)
            strongSelf.mapView.camera = camera
            
            for location in strongSelf.locations {
                let marker = GMSMarker()
                marker.position = location.coordinate
                marker.snippet = location.bitText
                marker.appearAnimation = .pop
                marker.map = strongSelf.mapView
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if friend != nil {
            UIApplication.shared.isStatusBarHidden = true
        }
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
