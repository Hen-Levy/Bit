//
//  FriendsViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit

class FriendsViewController: PeopleViewController {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barCustomView = BarCustomView(target: self)
        barCustomView!.friendsSearchBar.delegate = self
        navigationController?.navigationBar.addSubview(barCustomView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barCustomView?.addFriendButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barCustomView?.addFriendButton.isHidden = false
        barCustomView?.titleLabel.text = "Friends"
    }
    
    // MARK: Actions
    
    func addFriend() {
        performSegue(withIdentifier: "SegueToContacts", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contactsViewController = segue.destination as! ContactsViewController
        contactsViewController.barCustomView = barCustomView
    }
}

extension FriendsViewController: UISearchBarDelegate {
    
}
