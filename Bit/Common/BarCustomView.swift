//
//  BarCustomView.swift
//  Bit
//
//  Created by Hen Levy on 23/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit

class BarCustomView: UIView {
    var friendsSearchBar = UISearchBar()
    var addFriendButton = UIButton(type: .custom)
    var backButton = UIButton(type: .custom)
    var titleLabel = UILabel()
    var navController: UINavigationController?
    
    init(target: UIViewController) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 88.0))
        backgroundColor = .clear
        
        guard let navigationController = target.navigationController else {
            return
        }
        let navBar = navigationController.navigationBar
        navBar.height = frame.height
        navBar.setupGradient()
        
        // add friend button
        addFriendButton.addTarget(target, action: #selector(FriendsViewController.addFriend), for: .touchUpInside)
        addFriendButton.setImage(UIImage(named:"add"), for: .normal)
        addFriendButton.sizeToFit()
        
        // back button
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.sizeToFit()
        backButton.isHidden = true
        
        // title
        titleLabel.textColor = .white
        titleLabel.text = "Friends"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        addSubview(titleLabel)
        
        // search bar
        friendsSearchBar.frame = CGRect()
        friendsSearchBar.backgroundImage = UIImage()
        friendsSearchBar.placeholder = "Search for people"
        friendsSearchBar.tintColor = .white
        addSubview(friendsSearchBar)
        addSubview(addFriendButton)
        addSubview(backButton)
        
        // constraints
        friendsSearchBar.translatesAutoresizingMaskIntoConstraints = false
        friendsSearchBar.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchBar]-8-|", options: .alignAllLeft, metrics: nil, views: ["searchBar": friendsSearchBar]))
        friendsSearchBar.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-44-[searchBar]", options: .alignAllLeft, metrics: nil, views: ["searchBar": friendsSearchBar]))
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]-8-|", options: .alignAllLeft, metrics: nil, views: ["titleLabel": titleLabel]))
        titleLabel.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLabel(20)]", options: .alignAllLeft, metrics: nil, views: ["titleLabel": titleLabel]))
        
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        addFriendButton.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[addButton]-8-|", options: .alignAllLeft, metrics: nil, views: ["addButton":addFriendButton]))
        addFriendButton.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[addButton]", options: .alignAllLeft, metrics: nil, views: ["addButton":addFriendButton]))
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[backButton(32)]", options: .alignAllLeft, metrics: nil, views: ["backButton":backButton]))
        backButton.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[backButton(32)]", options: .alignAllLeft, metrics: nil, views: ["backButton":backButton]))
        
        self.navController = navigationController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func back() {
        let _ = navController?.popViewController(animated: true)
    }
}
