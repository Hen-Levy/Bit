//
//  ProfileViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import TOCropViewController

class ProfileViewController: UIViewController {
    @IBOutlet weak var changeProfilePicButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    let storageRef = FIRStorage.storage().reference()
    let dbRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.height = 44.0
        navigationController?.navigationBar.setupGradient()
        self.title = "Profile"
        
        nameLabel.text = User.shared.name
        emailLabel.text = User.shared.email
        User.shared.getProfilePic {[weak self] userPhoto in
            self?.changeProfilePicButton.setImage(userPhoto, for: .normal)
        }
    }
    
    @IBAction func logout() {
        do {
            try FIRAuth.auth()?.signOut()
            User.shared.clearUserCachedInfo()
            tabBarController?.dismiss(animated: true, completion: nil)
        }
        catch {
            debugPrint("Something went wrong when tried to sign out")
        }
    }
    
    @IBAction func changeProfilePicture() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { alertAction in
                self.presentImagePicker(sourceType: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { alertAction in
                self.presentImagePicker(sourceType: .savedPhotosAlbum)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}


extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image  = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        picker.pushViewController(cropViewController, animated: true)
    }
}

extension ProfileViewController: TOCropViewControllerDelegate {
    
    @objc(cropViewController:didCropToImage:withRect:angle:) func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        changeProfilePicButton.setImage(image, for: .normal)
        dismiss(animated: true, completion: nil)
        
        User.shared.setProfilePic(image)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true, completion: nil)
    }
}

