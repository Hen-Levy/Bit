//
//  Location.swift
//  Bit
//
//  Created by Hen Levy on 19/03/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate {
    func didUpdateLocation(lastLocation: CLLocation)
    func didFail(with error: Error)
}

class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    var locationManagerDelegate: LocationManagerDelegate?
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        delegate = self
        desiredAccuracy = kCLLocationAccuracyBest
        requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            startUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            currentLocation = lastLocation
            locationManagerDelegate?.didUpdateLocation(lastLocation: lastLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManagerDelegate?.didFail(with: error)
    }
    
    func distanceFrom(location: CLLocation) -> CLLocationDistance? {
        return currentLocation?.distance(from: location)
    }
    
    deinit {
        stopUpdatingLocation()
    }
}
