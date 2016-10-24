//
//  SWBottomButtonView.swift
//  FamousMe
//
//  Created by Stan Wu on 16/3/1.
//  Copyright © 2016年 Stan Wu. All rights reserved.
//

import UIKit

class SWBottomButtonView: UIView {
    let btnBottom = UIButton.customButton()
    
    init(title: String,target: Any?, action: Selector) {
        super.init(frame:CGRect.zero)

        self.backgroundColor = UIColor(red: 1, green: 1, blue: 0.99, alpha: 1)
        
        let line = UIView()
        line.adoptAutoLayout()
        line.backgroundColor = UIColor(white: 0.78, alpha: 1)
        self.addSubview(line)
        self.filled(line, mode: .width)
        
        btnBottom.adoptAutoLayout()
        btnBottom.clipsToBounds = true
        btnBottom.layer.cornerRadius = 5
        btnBottom.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1, height: 1)), for: UIControlState())
        btnBottom.setTitle(title, for: UIControlState())
        btnBottom.setTitleColor(UIColor.white, for: UIControlState())
        btnBottom.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btnBottom.addTarget(target, action: action, for: .touchUpInside)
        self.addSubview(btnBottom)
        
        let views = ["line":line,"btn":btnBottom]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[btn]-8-|", views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-7-[btn]-7-|", views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[line(==0.5)]", views: views))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
