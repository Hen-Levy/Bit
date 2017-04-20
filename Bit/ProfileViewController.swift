//
//  ProfileViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.height = 44.0
        navigationController?.navigationBar.setupGradient()
        self.title = "Profile"
    }
    
    @IBAction func logout() {
        do {
            try FIRAuth.auth()?.signOut()
            tabBarController?.dismiss(animated: true, completion: nil)
        }
        catch {
            debugPrint("Something went wrong when tried to sign out")
        }
    }
}
