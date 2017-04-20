//
//  GradientView.swift
//  Hen Levy
//
//  Created by Hen Levy on 03/02/2016.
//  Copyright © 2016 Hen Levy. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .white {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var endColor: UIColor = .black {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var roundness: CGFloat = 0.0 {
        didSet{
            setupView()
        }
    }
    
    
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
    }
    
    // Setup the view appearance
    private func setupView(){
        
        let colors:Array<AnyObject> = [startColor.cgColor, endColor.cgColor]
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = roundness
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        self.setNeedsDisplay()
        
    }
    
    // Helper to return the main layer as CAGradientLayer
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
}
