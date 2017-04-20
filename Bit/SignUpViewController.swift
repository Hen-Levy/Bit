//
//  SignUpViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: FormViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    @IBAction func signUp() {
        
        dismissKeyboard()
        
        // validate email + password
        guard let email = emailTextField.text,
            let pass = passwordTextField.text,
            let rePass = rePasswordTextField.text,
            Validate.email(email: email),
            Validate.defaultText(text: pass),
            pass == rePass else {
                return
        }
        
        // sign up
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { [weak self] (user, error) in
            if let strongError = error {
                debugPrint(strongError.localizedDescription)
            } else if let strongSelf = self {
                
                // update user display name
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                changeRequest?.displayName = strongSelf.firstNameTextField.text
                changeRequest?.commitChanges() { (error) in
                    if let strongError = error {
                        debugPrint(strongError.localizedDescription)
                    } else {
                        strongSelf.performSegue(withIdentifier: "SignUpSegueToFriends", sender: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func back() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            rePasswordTextField.becomeFirstResponder()
        } else {
            signUp()
        }
        return true
    }
}
