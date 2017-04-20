//
//  ViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: FormViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Actions
    
    @IBAction func login() {
        
        // validate email + password
        guard let email = emailTextField.text,
            let pass = passwordTextField.text,
            Validate.email(email: email),
            Validate.defaultText(text: pass) else {
                return
        }
        
        dismissKeyboard()
        
        // sign in
        FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: {(user,error)
            in
            if let strongError = error {
                debugPrint(strongError.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "SegueToFriends", sender: nil)
            }
        })
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
}

