//
//  MActionSheet.swift
//  Mosaic
//
//  Created by Stan Wu on 15/7/7.
//  Copyright (c) 2015年 Stan Wu. All rights reserved.
//

import UIKit

@objc protocol MActionSheetDelegate{
    @objc optional func actionSheetM(_ actionSheet: MActionSheet,
        didDismissWithButtonIndex buttonIndex: Int)
}

class MActionSheet: UIView {
    var vBG = UIView()
    weak var delegate: MActionSheetDelegate?
    
    init(title: String?, buttonTitles: [String]?, cancel: String?, delegate: MActionSheetDelegate?){
        super.init(frame: CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: SWDefinitions.ScreenHeight))
        self.delegate = delegate
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let count = buttonTitles?.count ?? 0
        let topMargin: CGFloat = title != nil ? 30 : 14
        let buttonHeight: CGFloat = 40
        let buttonMargin: CGFloat = 10
        let xMargin: CGFloat = 10
        
        let h = CGFloat(count+1)*buttonHeight+buttonMargin*CGFloat(count+1) + topMargin
        
        vBG.frame = CGRect(x: 0, y: SWDefinitions.ScreenHeight-h, width: SWDefinitions.ScreenWidth, height: h)
        vBG.transform = CGAffineTransform(translationX: 0, y: h)
        vBG.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.addSubview(vBG)
        
        if let t = title{
            let lbl = UILabel.create(CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: topMargin), font: UIFont.systemFont(ofSize: 12), textColor: UIColor(white: 0.5, alpha: 1))
            lbl.textAlignment = .center
            lbl.text = t
            vBG.addSubview(lbl)
        }
        
        for i in 0 ..< count+1{
            let title = i<count ? buttonTitles![i] : (cancel ?? NSLocalizedString("取消", comment: "取消"))
            
            let btn = UIButton(frame: CGRect(x: xMargin, y: topMargin + (buttonHeight + buttonMargin)*CGFloat(i), width: SWDefinitions.ScreenWidth-xMargin*2, height: buttonHeight))
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitle(title, for: UIControlState())
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 0.5
            btn.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
            if i != count{
                btn.tag = 100+i+1
                btn.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1,height: 1)), for: UIControlState())
                btn.setTitleColor(UIColor.white, for: UIControlState())
            }else{
                btn.tag = 100+0
                btn.setBackgroundImage(UIImage.colorImage(UIColor.white, size: CGSize(width: 1,height: 1)), for: UIControlState())
                btn.setTitleColor(ProjectDefinitions.ThemeColor, for: UIControlState())
            }
            btn.addTarget(self, action: #selector(MActionSheet.btnClicked(_:)), for: .touchUpInside)
            vBG.addSubview(btn)
        }
    }
    
    convenience init(titles: [String]?, cancel: String?, delegate: MActionSheetDelegate?){
        self.init(title: nil, buttonTitles: titles, cancel: cancel, delegate: delegate)
    }
    
    func show(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        self.alpha = 0
        appdelegate.window?.addSubview(self)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 1
        }, completion: { (finished: Bool) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.vBG.transform = CGAffineTransform.identity
            })
        })  
    }
    
    func dismiss(_ index: Int = -1){
        UIView.animate(withDuration: 0.2, animations: {
            self.vBG.transform = CGAffineTransform(translationX: 0, y: self.vBG.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
                
                if index >= 0{
                    self.delegate?.actionSheetM?(self, didDismissWithButtonIndex: index)
                }
            }) 
        })  
    }
    

    func btnClicked(_ btn: UIButton){
        self.dismiss(btn.tag % 100)
    }
    
    func buttonTitleAtIndex(_ buttonIndex: Int) -> String{
        let btn = vBG.viewWithTag(100+buttonIndex) as! UIButton
        
        return btn.title(for: UIControlState()) ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss()
    }

}
