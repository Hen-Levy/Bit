//
//  UINavigationBar+Gradient.swift
//  Bit
//
//  Created by Hen Levy on 20/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        var updatedFrame = bounds
        updatedFrame.size.height = height + 20
        updatedFrame.size.width = UIScreen.main.bounds.width
        gradientLayer.frame = updatedFrame
        gradientLayer.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: UIBarMetrics.default)
    }
}
