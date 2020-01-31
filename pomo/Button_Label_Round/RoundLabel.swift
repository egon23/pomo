//
//  RoundTextField.swift
//  Quizme
//
//  Created by David Hartl on 20.06.19.
//  Copyright © 2019 David Hartl. All rights reserved.
//

import UIKit

@IBDesignable class RoundLabel: UILabel{
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
        self.layer.masksToBounds = true
    }
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
    
}
