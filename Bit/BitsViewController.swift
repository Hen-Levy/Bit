//
//  BitsViewController.swift
//  Bit
//
//  Created by Hen Levy on 23/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class BitsViewController: UIViewController {
    @IBOutlet weak var bitsTableView: UITableView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var addNewBitView: UIView!
    @IBOutlet weak var bitTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var dbRef = FIRDatabase.database().reference()
    var friend: Friend!
    var bits = [BitItem]()
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bitsTableView.tableFooterView = UIView(frame: CGRect.zero)
        friendNameLabel.text = friend.name
        friendImageView.image = friend.image
        
        observeFriendBits()
    }
    
    func observeFriendBits() {
        
        let path = "users/" + FIRAuth.auth()!.currentUser!.uid + "/friends/" + friend.uid + "/bits"
        dbRef.child(path).observe(.value, with: { [weak self] snapshot in
            if let bitsDic = snapshot.value as? [String: AnyObject] {
                
                guard let strongSelf = self else {
                    return
                }
                let bitsArray = Array(bitsDic.values)
                
                for bit in bitsArray {
                    let uid = (bit["uid"] as? String) ?? ""
                    let text = (bit["text"] as? String) ?? ""
                    let pin = (bit["pin"] as? Int) ?? 0
                    let bitItem = BitItem(uid: uid, text: text, pin: pin)
                    if !strongSelf.bits.contains { $0.text == text} {
                        strongSelf.bits.append(bitItem)
                    }
                }
                
                strongSelf.sortBits()
            }
        })
    }
    
    func sortBits() {
        bits = bits.sorted {$0.pin > $1.pin}
        bitsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBit() {
        overlayView.isHidden = false
        view.addSubview(addNewBitView)
        addNewBitView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[newBitView]-20-|", options: .alignAllLeft, metrics: nil, views: ["newBitView": addNewBitView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-180-[newBitView]", options: .alignAllLeft, metrics: nil, views: ["newBitView": addNewBitView]))
        
        bitTextField.becomeFirstResponder()
    }
    
    func pinBit(sender: UIButton) {
        
        if let cell = sender.superview?.superview as? BitCell,
            let indexPath = bitsTableView.indexPath(for: cell) {
            
            let bit = bits[indexPath.row]
            bit.pin = 1
            let bitDic = ["uid": bit.uid,
                          "text": bit.text,
                          "pin": bit.pin] as [String : Any]
            let path = "users/" + FIRAuth.auth()!.currentUser!.uid + "/friends/" + friend.uid + "/bits/" + bit.uid
            FIRDatabase.database().reference().child(path).setValue(bitDic)
            sortBits()
        }
    }
}

extension BitsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BitCellIdentifier", for: indexPath) as! BitCell
        
        let bit = bits[indexPath.row]
        cell.bitTextLabel.text = bit.text
        
        let pinImageNamed = bit.pin == 0 ? "favorite_border" : "favorite"
        cell.pinButton.setImage(UIImage(named: pinImageNamed), for: .normal)
        
        if !cell.pinButton.allTargets.isEmpty {
            cell.pinButton.removeTarget(self, action: #selector(pinBit(sender:)), for: .touchUpInside)
        }
        cell.pinButton.addTarget(self, action: #selector(pinBit(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let bit = bits[indexPath.row]
        let path = "users/" + FIRAuth.auth()!.currentUser!.uid + "/friends/" + friend.uid + "/bits/" + bit.uid
        dbRef.child(path).removeValue()
        bits.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension BitsViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            bitTextField.resignFirstResponder()
            spinner.startAnimating()
            DispatchQueue.main.async { [weak self] in
                self?.saveNewBit()
            }
            return true
        }
        
        @IBAction func saveNewBit() {
            guard let bitText = bitTextField.text else {
                spinner.stopAnimating()
                return
            }
            
            var path = "users/" + FIRAuth.auth()!.currentUser!.uid + "/friends/" + friend.uid + "/bits"
            let uid = dbRef.child(path).childByAutoId().key
            
            let bitDic = ["uid": uid,
                          "text": bitText,
                          "pin": 0] as [String : Any]
            path = path + "/" + uid
            dbRef.child(path).setValue(bitDic)
            
            spinner.stopAnimating()
            cancel()
        }
        
        @IBAction func cancel() {
            bitTextField.resignFirstResponder()
            overlayView.isHidden = true
            addNewBitView.removeFromSuperview()
        }
}
