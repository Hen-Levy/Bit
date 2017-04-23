//
//  BitsViewController.swift
//  Bit
//
//  Created by Hen Levy on 23/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BitsViewController: UIViewController {
    @IBOutlet weak var friendNameLabel: UILabel!
    var friendUid: String!
    var dbRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = "users/" + friendUid
        dbRef.child(path).observe(.value, with: { [weak self] snapshot in
            if let friendDic = snapshot.value as? [String: AnyObject] {
                self?.friendNameLabel.text = friendDic["name"] as? String
            }
        })
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBit() {
        
    }
}
