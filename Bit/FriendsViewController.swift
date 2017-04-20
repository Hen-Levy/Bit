//
//  FriendsViewController.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    var friendsSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarGradient()
    }
    
    func setupNavBarGradient() {
        guard let navController = navigationController else {
            return
        }
        let navBar = navController.navigationBar
        navBar.height = 88.0
        navBar.setupGradient()
   
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: navBar.height))
        customView.backgroundColor = .clear
        
        // title
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.text = "Friends"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        customView.addSubview(titleLabel)
        
        // search bar
        friendsSearchBar.frame = CGRect()
        friendsSearchBar.backgroundImage = UIImage()
        friendsSearchBar.placeholder = "Search for people"
        friendsSearchBar.delegate = self
        customView.addSubview(friendsSearchBar)
        navBar.addSubview(customView)
        
        // constraints
        friendsSearchBar.translatesAutoresizingMaskIntoConstraints = false
        friendsSearchBar.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchBar]-8-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: ["searchBar": friendsSearchBar]))
        friendsSearchBar.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-44-[searchBar]", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: ["searchBar": friendsSearchBar]))
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]-8-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: ["titleLabel": titleLabel]))
        titleLabel.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLabel(20)]", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: ["titleLabel": titleLabel]))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension FriendsViewController: UISearchBarDelegate {
    
}
