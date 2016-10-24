//
//  OAAlertView.swift
//  Mosaic
//
//  Created by Stan Wu on 15/7/9.
//  Copyright (c) 2015年 Stan Wu. All rights reserved.
//

import UIKit

@objc protocol OAAlertViewDelegate: NSObjectProtocol{
    func alertView(_ alertView: OAAlertView, didClickedOnButton buttonTitle: String?)
}

class OAAlertView: UIView {
    var vContent = UIView()
    var vButtonArea = UIView()
    var lblTitle,lblMessage: UILabel!
    var buttons = [UIButton]()
    var buttonTitles = [NSLocalizedString("取消", comment: "取消")]
    var callback: ((_ title: String?) -> Void)?
    
    weak var delegate: OAAlertViewDelegate?
    
    @objc init(title: String?,message: String?,delegate: OAAlertViewDelegate?,cancel: String!,special: String?, other: [String]?){
        super.init(frame: UIScreen.main.bounds)
        
        self.delegate = delegate
        
        var cancelTitle = cancel
        if cancelTitle == nil{
            cancelTitle = NSLocalizedString("确定", comment: "确定")
        }
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        vContent.adoptAutoLayout()
        vContent.backgroundColor = UIColor(white: 0.97, alpha: 1)
        vContent.clipsToBounds = true
        vContent.layer.cornerRadius = 4
        self.addSubview(vContent)
        
        vButtonArea.adoptAutoLayout()
        vContent.addSubview(vButtonArea)
        
        lblTitle = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 15), textColor: UIColor(white: 0.29, alpha: 1))
        lblTitle.adoptAutoLayout()
        lblTitle.textAlignment = .center
        vContent.addSubview(lblTitle)
        lblTitle.text = title
        
        lblMessage = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 14), textColor: UIColor(white: 0.47, alpha: 1))
        lblMessage.adoptAutoLayout()
        lblMessage.numberOfLines = 0
        lblMessage.text = message
        vContent.addSubview(lblMessage)
        

        
        var btn = UIButton.customButton()
        btn.adoptAutoLayout()
        btn.addTarget(self, action: #selector(OAAlertView.btnClicked(_:)), for: .touchUpInside)
        btn.setTitle(cancelTitle, for: UIControlState())
        btn.tag = 0
        btn.setBackgroundImage(UIImage.colorImage(UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControlState())
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        btn.layer.borderWidth = 0.5
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(ProjectDefinitions.PurpleColor, for: UIControlState())
        vButtonArea.addSubview(btn)
        buttons.append(btn)
        
        if let otherButtonTitles = other{
            for i in 0 ..< otherButtonTitles.count{
                let title = otherButtonTitles[i]
                
                btn = UIButton.customButton()
                btn.adoptAutoLayout()
                btn.setBackgroundImage(UIImage.colorImage(UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControlState())
                btn.setTitle(title, for: UIControlState())
                btn.clipsToBounds = true
                btn.layer.cornerRadius = 5
                btn.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
                btn.layer.borderWidth = 0.5
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                btn.setTitleColor(ProjectDefinitions.PurpleColor, for: UIControlState())
                btn.addTarget(self, action: #selector(OAAlertView.btnClicked(_:)), for: .touchUpInside)
                btn.tag = buttons.count
                
                vButtonArea.addSubview(btn)
                buttons.append(btn)
            }
        }
        
        if let specialButtonTitle = special{
            btn = UIButton.customButton()
            btn.adoptAutoLayout()
            btn.addTarget(self, action: #selector(OAAlertView.btnClicked(_:)), for: .touchUpInside)
            btn.setTitle(specialButtonTitle, for: UIControlState())
            btn.tag = buttons.count
            btn.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.PurpleColor, size: CGSize(width: 1, height: 1)), for: UIControlState())
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 5
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(UIColor.white, for: UIControlState())
            vButtonArea.addSubview(btn)
            buttons.append(btn)
        }
        
        //  Constraints  26 18 20
        var views: [String:UIView] = ["content":vContent,"title":lblTitle,"message":lblMessage,"area":vButtonArea]
        
        self.addConstraints("H:|-25-[content]-25-|", views: views)
        vContent.addConstraints("H:|-15-[area]-15-|", views: views)
        vContent.addConstraints("H:|-15-[title]-15-|", views: views)
        vContent.addConstraints("H:|-15-[message]-15-|", views: views)
        self.addConstraint(NSLayoutConstraint.equalConstraint(vContent, attribute1: .centerY, view2: self, attribute2: .centerY))
        
        if title != nil && message != nil{
            vContent.addConstraints("V:|-26-[title]-18-[message]-20-[area]-15-|", views: views)
        }else if title != nil{
            vContent.addConstraints("V:|-26-[title]-20-[area]-15-|", views: views)
        }else{
            vContent.addConstraints("V:|-26-[message]-20-[area]-15-|", views: views)
        }
        
        
        
        
        for b in buttons{
            views["btn\(b.tag)"] = b
        }
        
        let buttonHeight: CGFloat = 40
        
        if buttons.count <= 3{
            var buttonsConstraintString = "H:|"
            for b in buttons{
                if b.tag == 0{
                    buttonsConstraintString += "[btn\(b.tag)]"
                }else{
                    buttonsConstraintString += "-10-[btn\(b.tag)(==btn0)]"
                    vButtonArea.addConstraint(NSLayoutConstraint.equalConstraint(b, attribute1: .centerY, view2: views["btn0"]!, attribute2: .centerY))
                }
                vButtonArea.addConstraints("V:|[btn\(b.tag)(==\(buttonHeight))]|", views: views)
            }
            buttonsConstraintString += "|"
            vButtonArea.addConstraints(buttonsConstraintString, views: views)
        }else{
            var buttonsConstraintString = "V:|"
            for b in buttons{
                if b.tag == 0{
                    buttonsConstraintString += "[btn\(b.tag)(==\(buttonHeight))]"
                }else{
                    buttonsConstraintString += "-5-[btn\(b.tag)(==\(buttonHeight))]"
                    vButtonArea.addConstraint(NSLayoutConstraint.equalConstraint(b, attribute1: .centerX, view2: views["btn0"]!, attribute2: .centerX))
                }
                vButtonArea.addConstraints("H:|[btn\(b.tag)]|", views: views)
            }
            buttonsConstraintString += "|"
            vButtonArea.addConstraints(buttonsConstraintString, views: views)
        }
        
    }
    
    class func show(_ title: String?,message: String?,cancel: String?){
        let alert = OAAlertView(title: title, message: message, delegate: nil, cancel: cancel, special: nil, other: nil)
        alert.show()
    }
    
    class func show(_ title: String?,message: String?,cancel: String?, callback: ((_ title: String?) -> Void)?){
        let alert = OAAlertView(title: title, message: message, delegate: nil, cancel: cancel, special: nil, other: nil)
        alert.callback = callback
        alert.show()
    }
    
    class func show(_ title: String?,message: String?,cancel: String?, special: String?, callback: ((_ title: String?) -> Void)?){
        let alert = OAAlertView(title: title, message: message, delegate: nil, cancel: cancel, special: special, other: nil)
        alert.callback = callback
        alert.show()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(){
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        
        self.alpha = 0
        window?.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1
        }) 
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
        }) 
    }
    
    func btnClicked(_ btn: UIButton){
        let buttonTitle = btn.title(for: UIControlState())
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
                self.delegate?.alertView(self, didClickedOnButton: buttonTitle)
                self.callback?(buttonTitle)
        }) 
        
        
    }
    /*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let touch = (touches as NSSet).anyObject() as! UITouch
        
        let pt = touch.locationInView(vContent)
        if !CGRectContainsPoint(vContent.bounds, pt){
            self.dismiss()
        }
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let msg = lblMessage.text{
            let size = (msg as NSString).size(attributes: [NSForegroundColorAttributeName:lblMessage.font])
            let h1 = ("A" as NSString).size(attributes: [NSForegroundColorAttributeName:lblMessage.font]).height
            if size.height > h1 || (size.width > (SWDefinitions.ScreenWidth - 80)){
                lblMessage.textAlignment = .left
            }else{
                lblMessage.textAlignment = .center
            }
        }
    }

}
