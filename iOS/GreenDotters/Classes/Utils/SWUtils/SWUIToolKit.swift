//
//  SWUIToolKit.swift
//  ReservationClient
//
//  Created by Stan Wu on 15/3/28.
//  Copyright (c) 2015 Stan Wu. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import CoreGraphics

@objc enum NaviButtonPosition:Int{
    case left,right
}

enum ConstraintFillMode: Int{
    case both,width,height
}

class SWLineSpacingLabel: UILabel{
    var lineSpacing:CGFloat = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    override var text: String?{
        didSet{
//            super.attributedText = nil
            
            if let str = text{
                if 0 == lineSpacing{
                    super.attributedText = nil
                    super.text = str
                    return
                }else{
//                    newValue = nil
                    super.text = nil
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = lineSpacing;
                    paragraphStyle.alignment = .Left;
                    var attributes: [String:AnyObject] = [NSParagraphStyleAttributeName: paragraphStyle]
                    if let color = self.textColor{
                        attributes[NSForegroundColorAttributeName] = color
                    }
                    let attributedText = NSAttributedString(string: str, attributes: attributes)
                    self.attributedText = attributedText;
                }
            }
        }



    }
*/
}

extension UIAlertView{
    class func show(_ title:String?,message:String?,cancelButton:String?){
        var cancel = cancelButton;
        if  cancel==nil {
            cancel = NSLocalizedString("确定", comment: "确定")
        }
        UIAlertView.show(title, message: message, cancelButton: cancel, delegate: nil)
    }
    
    class func show(_ title:String?,message:String?,cancelButton:String?,delegate:UIAlertViewDelegate?){
        let alert:UIAlertView = UIAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButton)
        alert.show()
        
    }
}

extension UIBarButtonItem{
    class func navBackItem(_ target: UIViewController) -> [UIBarButtonItem]{
        let items = UIBarButtonItem.navButtonItem(nil, image: UIImage(named: "MNavBack"), action: #selector(UIViewController.navBack), target: target)
        
        for item in items{
            item.tintColor = UIColor.gray
        }
        
        return items
    }
    
    class func navBackItemPurple(_ target: UIViewController) -> [UIBarButtonItem]{
        let items = UIBarButtonItem.navButtonItem(nil, image: UIImage(named: "NavBackPurple"), action: #selector(UIViewController.navBack), target: target)
        
        for item in items{
            item.tintColor = UIColor.gray
        }
        
        return items
    }
    
    @objc class func navButtonItem(_ title: String?,action: Selector,target: Any?) -> UIBarButtonItem{
        let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: target, action: action)
        item.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 17),NSForegroundColorAttributeName:UIColor.white], for: UIControlState())
        return item
    }
    
    @objc class func navButtonItem(_ title: String?,color: UIColor?,action: Selector,target: Any?) -> UIBarButtonItem{
        let btn = UIButton.customButton()
        btn.frame = CGRect(x: 0, y: 0, width: 56, height: 22)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 2
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        
        let bgColor = color ?? UIColor(red: 0.32, green: 0.31, blue: 0.39, alpha: 1)
        
        btn.setBackgroundImage(UIImage.colorImage(bgColor, size: CGSize(width: 1, height: 1)), for: UIControlState())
        
        btn.setTitle(title, for: UIControlState())
        
        btn.addTarget(target, action: action, for: .touchUpInside)
        
        
        return UIBarButtonItem(customView: btn)
    }
    
    class func navButtonItem(_ title: String?,image: UIImage?,action: Selector,target: Any?) -> [UIBarButtonItem]{
        return UIBarButtonItem.navButtonItem(title, image: image, action: action, position: NaviButtonPosition.left,target: target)
    }
    
    class func navButtonItem(_ title: String?,image: UIImage?,action: Selector,position: NaviButtonPosition,target: Any?) -> [UIBarButtonItem]{
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        btn.setTitle(title, for: UIControlState())
        btn.setImage(image, for: UIControlState())
        let font = image==nil ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.font = font
        
        let size = (title ?? "").size(attributes: [NSFontAttributeName:font])
        
        if image != nil && title != nil{
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, -image!.size.width-8, 0, 0);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, image!.size.width*2+size.width, 0, 0);
        }else if image != nil{
            btn.imageEdgeInsets = position == .left ? UIEdgeInsetsMake(0, -image!.size.width, 0, 0) : UIEdgeInsetsMake(0, 0, 0, -image!.size.width);
        }
        
        
        btn.addTarget(target, action: action, for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: btn)
        let fixspace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixspace.width = -20
        
        if .left==position{
            return [item]
        }else{
            return [fixspace,item]
        }
    }
}

extension UIViewController{
    
    
    @objc func addNavButton(_ title: String,action: Selector,target: Any?,position:NaviButtonPosition){
        let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: target, action: action)
        item.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 17),NSForegroundColorAttributeName:UIColor.white], for: UIControlState())
        switch position{
        case .left:
            self.navigationItem.leftBarButtonItem = item
        case .right:
            self.navigationItem.rightBarButtonItem = item
        }
    }
    
    @objc func addNavButton(_ title: String,color: UIColor?,action: Selector,position:NaviButtonPosition){
        let btn = UIButton.customButton()
        btn.frame = CGRect(x: 0, y: 0, width: 56, height: 22)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 2
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        
        let bgColor = color ?? UIColor(red: 0.32, green: 0.31, blue: 0.39, alpha: 1)
        
        btn.setBackgroundImage(UIImage.colorImage(bgColor, size: CGSize(width: 1, height: 1)), for: UIControlState())
        
        btn.setTitle(title, for: UIControlState())
        
        btn.addTarget(self, action: action, for: .touchUpInside)
        
        
        let item = UIBarButtonItem(customView: btn)
        
        if .left==position{
            self.navigationItem.leftBarButtonItem = item
        }else{
            self.navigationItem.rightBarButtonItem = item
        }
    }
    
    @objc func addNavButton(_ title: String?,image: UIImage?,position: NaviButtonPosition,action: Selector){
        if title != nil{
            let font = UIFont.systemFont(ofSize: 10)
            
            let btn = UIButton(type: .custom)
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 2
            btn.setBackgroundImage(UIImage.colorImage(UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControlState())
            btn.setTitleColor(ProjectDefinitions.PurpleColor, for: UIControlState())
            btn.titleLabel?.font = font
            
            btn.setImage(image, for: UIControlState())
            btn.setTitle(title, for: UIControlState())
            
            var w: CGFloat!
            
            if title != nil && image != nil{
                w = title!.size(attributes: [NSFontAttributeName:font]).width + image!.size.width + 6*2 + 3
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 1.5)
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 1.5, 0, 0)
            }else if title != nil{
                w = title!.size(attributes: [NSFontAttributeName:font]).width + 6*2
            }else{
                w = 45
            }
            
            if w < 45{
                w = 45
            }
            
            btn.frame = CGRect(x: 0, y: 0, width: w, height: 20)
            
            
            btn.addTarget(self, action: action, for: .touchUpInside)
            
            let item = UIBarButtonItem(customView: btn)
            let fixspace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixspace.width = -20
            
            if .left==position{
                self.navigationItem.leftBarButtonItems = [item]
            }else{
                self.navigationItem.rightBarButtonItems = [item]
            }
            return
        }
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        btn.setTitle(title, for: UIControlState())
        btn.setImage(image, for: UIControlState())
        let font = image==nil ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.font = font
        
        let size = (title ?? "").size(attributes: [NSFontAttributeName:font])
        
        if image != nil && title != nil{
            btn.titleEdgeInsets = UIEdgeInsetsMake(image!.size.height, -image!.size.width, 0, 0);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, image!.size.height, -size.width);
        }else if image != nil{
            btn.imageEdgeInsets = position == .left ? UIEdgeInsetsMake(0, -image!.size.width, 0, 0) : UIEdgeInsetsMake(0, 0, 0, -image!.size.width);
        }
        
        
        btn.addTarget(self, action: action, for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: btn)
        let fixspace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixspace.width = -20
        
        if .left==position{
            self.navigationItem.leftBarButtonItems = [item]
        }else{
            self.navigationItem.rightBarButtonItems = [fixspace,item]
        }
    }
    
    @objc func addBGColor(){
        self.view.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
    @objc func addBGColor(_ color: UIColor?){
        if let c = color{
            self.view.backgroundColor = c
        }else{
            self.addBGColor()
        }
    }
    
    @objc func setNavTitle(_ title:String?){
        self.setNavTitle(title, image: nil)
    }
    
    @objc func setNavTitle(_ title:String?,gender: Int){
        let img = 2==gender ? UIImage(named: "SmallFemaleAvatar") : (1==gender ? UIImage(named: "SmallMaleAvatar") : nil)
        
        self.setNavTitle(title, image: img)
    }
    
    @objc func setNavTitle(_ title: String?,image: UIImage?){
        var lbl = self.navigationItem.titleView as? UILabel
        
        if nil == lbl{
            lbl = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 14), textColor: UIColor.white)
            self.navigationItem.titleView = lbl
        }
        
        if let img = image{
            
            
            
            let str = NSMutableAttributedString()
            str.append(NSAttributedString(string: title ?? ""))
            
            str.append(NSAttributedString(string: " "))
            
            let attachment = NSTextAttachment()
            attachment.image = img
            str.append(NSAttributedString(attachment: attachment))
            
            lbl?.attributedText = str
            lbl?.sizeToFit()
            

            
            
            
            
        }else{
            lbl?.attributedText = nil
            lbl?.text = title
            lbl?.sizeToFit()
        }
    }
    
    @objc func setNavTitle(_ title: String?,images: [UIImage]?){
        var lbl = self.navigationItem.titleView as? UILabel
        
        if nil == lbl{
            lbl = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 14), textColor: UIColor.white)
            self.navigationItem.titleView = lbl
        }
        
        if let imgs = images{
            let str = NSMutableAttributedString()
            
            str.append(NSAttributedString(string: title ?? ""))
            
            for img in imgs{
                
                
                
                str.append(NSAttributedString(string: " "))
                
                let attachment = NSTextAttachment()
                attachment.image = img
                str.append(NSAttributedString(attachment: attachment))
            }
            lbl?.attributedText = str
            lbl?.sizeToFit()
        }else{
            lbl?.attributedText = nil
            lbl?.text = title
            lbl?.sizeToFit()
        }
    }
    
    
    
    @objc func addNavBack(){
        self.addNavButton(nil, image: UIImage(named: "MNavBack"), position: .left, action: #selector(UIViewController.navBack))
    }
    
    @objc func navBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func footerViewForLoadMore() -> UIView{
        let v = UIView(frame: CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 50))
        v.backgroundColor = UIColor.clear
        
        let btn = UIButton.customButton()
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(UIColor(white: 0.62, alpha: 1), for: UIControlState())
        btn.frame = v.bounds
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle(NSLocalizedString("点击加载更多", comment: "点击加载更多"), for: UIControlState())
        v.addSubview(btn)
        btn.addTarget(self, action: #selector(UIViewController.moreClicked(_:)), for: .touchUpInside)
        btn.tag = 100
        
        let lbl = UILabel.create(v.bounds, font: UIFont.systemFont(ofSize: 15), textColor: btn.titleColor(for: UIControlState())!)
        lbl.textAlignment = .center
        v.insertSubview(lbl, belowSubview: btn)
        lbl.text = NSLocalizedString("正在载入", comment: "正在载入")
        lbl.tag = 102
        lbl.isHidden = true
        
        let size = lbl.text!.size(attributes: [NSFontAttributeName:lbl.font])
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.center = CGPoint(x: SWDefinitions.ScreenWidth/2+size.width/2+10.0, y: lbl.center.y)
        v.insertSubview(indicator, belowSubview: btn)
        indicator.tag = 101

        return v
    }
    
    @objc func moreClicked(_ btn:UIButton){
        btn.isHidden = true
        
        let lbl = btn.superview?.viewWithTag(102) as? UILabel
        lbl?.isHidden = false
        
        let indicator = btn.superview?.viewWithTag(101) as? UIActivityIndicatorView
        indicator?.startAnimating()
        
        Thread.detachNewThreadSelector(Selector("loadMoreData"), toTarget: self, with: nil)
    }
}

extension UILabel{
    class func create(_ frame:CGRect,font:UIFont,textColor:UIColor) -> UILabel{
        let lbl = self.init(frame: frame)
        lbl.font = font
        lbl.textColor = textColor
        lbl.backgroundColor = UIColor.clear
        lbl.isUserInteractionEnabled = false
        
        return lbl
    }
    
    func updateText(_ lineSpacing: CGFloat,text: String?){
        if (lineSpacing > 0){
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing;
            paragraphStyle.alignment = .left;
            var attributes: [String:Any] = [NSParagraphStyleAttributeName: paragraphStyle]
            if let color = self.textColor{
                attributes[NSForegroundColorAttributeName] = color
            }
            let attributedText = NSAttributedString(string: (text ?? ""), attributes: attributes)
            self.attributedText = attributedText;
        }else{
            self.text = text
        }
    }
}

extension UIImage{
    class func colorImage(_ color:UIColor,size:CGSize) -> UIImage{
        var cicolor = CIColor(cgColor: color.cgColor)

        cicolor = CIColor(red: cicolor.red, green: cicolor.green, blue: cicolor.blue, alpha: cicolor.alpha)
        

        typealias MYImage = CoreImage.CIImage
        let ciimg:MYImage = MYImage(color:cicolor)
        
        let ctx = CIContext(options: nil)
        let imgref = ctx.createCGImage(ciimg, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIImage(cgImage: imgref!)

    
        return img;
    }
    
    func resizedImage(_ size: CGSize) -> UIImage{
        let img = self.fixOrientation()
        
        var newSize = size
        
        if (img.size.width-img.size.height)*(newSize.width-newSize.height)<0{
            newSize = CGSize(width: newSize.height, height: newSize.width)
        }
        
        
        let mysize = img.size
        
        var w = newSize.width
        var h = newSize.height
        let W = mysize.width
        let H = mysize.height
        
        let fw = w/W
        let fh = h/H
        
        if (w>=W && h>=H){
            return self;
        }else{
            if (fw>fh){
                w = h/H*W;
            }else{
                h = w/W*H;
            }
        }
        
        w = CGFloat(Int(w))
        h = CGFloat(Int(h))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h),true,0.0);
        let ctx = UIGraphicsGetCurrentContext();
        ctx?.translateBy(x: 0, y: h);
        ctx?.scaleBy(x: 1.0, y: -1.0);
        ctx?.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: w, height: h));
        let imgC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        return imgC!;
    }
    
    func coloredImage(_ color: UIColor) -> UIImage{
        
        // lets tint the icon - assumes your icons are black
        UIGraphicsBeginImageContext(self.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: 0, y: self.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        
        // draw alpha-mask
        context.setBlendMode(CGBlendMode.normal)
        context.draw(self.cgImage!, in: rect);
        
        // draw tint color, preserving alpha values of original image
        context.setBlendMode(.sourceIn);
        color.setFill()
        context.fill(rect);
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return coloredImage!;
    }
    
    func fixOrientation() -> UIImage{
        if self.imageOrientation == UIImageOrientation.up{
            return self
        }
        
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (self.imageOrientation) {
        case UIImageOrientation.down,UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height);
            transform = transform.rotated(by: CGFloat(M_PI))
            break;
            
        case UIImageOrientation.left,UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
            break;
            
        case UIImageOrientation.right,UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
            break;
        default:
            break;
        }
        
        switch (self.imageOrientation) {
        case UIImageOrientation.upMirrored,UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case UIImageOrientation.leftMirrored,UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
            bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0,
            space: (self.cgImage?.colorSpace!)!,
            bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!);
        ctx?.concatenate(transform);

        switch (self.imageOrientation) {
        case .left,.leftMirrored,.right,.rightMirrored:
            // Grr...
            ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width));
            break;
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx?.makeImage();
        let img = UIImage(cgImage: cgimg!)
        
        return img;
    }
}

@objc protocol SWImageViewDelegate{
    func swImageViewLoadFinished(_ imgv:SWImageView)
}

class SWImageView: UIImageView{
    weak var delegate:SWImageViewDelegate?
    lazy var indicator:UIActivityIndicatorView = {
        var indi = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indi.hidesWhenStopped = true
        indi.adoptAutoLayout()
        self.addSubview(indi)
        
        self.addConstraint(NSLayoutConstraint.equalConstraint(indi, attribute1: .centerX, view2: self, attribute2: .centerX))
        self.addConstraint(NSLayoutConstraint.equalConstraint(indi, attribute1: .centerY, view2: self, attribute2: .centerY))
        
        
        
        return indi
    }()
    
    func loadURL(_ str: String?){
        if let url = str{
            var ary = url.components(separatedBy: "/")
            let fileName = NSMutableString()
            
        

            for i in 0 ..< ary.count{
                fileName.append(ary[i])
            }
            
            let path = (fileName as String).imageCachePath

            if FileManager.default.fileExists(atPath: path){
                indicator.stopAnimating()
                self.image = UIImage(contentsOfFile: path)
                
                self.delegate?.swImageViewLoadFinished(self)
            }else{
                indicator.startAnimating()
                indicator.isHidden = false
                
                self.image = nil
                Thread.detachNewThreadSelector(#selector(SWImageView.loadImage(_:)), toTarget: self, with: str)
            }
        }else{
            self.image = nil
            indicator.stopAnimating()
        }
    }
    
    func loadImage(_ str: String){
        autoreleasepool { () -> () in
            let url = URL(string: str)
            let data = try? Data(contentsOf: url!)
            
            if let d = data{
                let img = UIImage(data: d)
                
                
                if let image = img{
                    SWUtils.RunOnMainThread({ () -> Void in
                        self.image = image
                        
                        var ary = str.components(separatedBy: "/")
                        let fileName = NSMutableString()
                        
                        
                        
                        for i in 0 ..< ary.count{
                            fileName.append(ary[i])
                        }
                        
                        let path = (fileName as String).imageCachePath
                        
                        try? data?.write(to: URL(fileURLWithPath: path), options: [])
                        
                        self.delegate?.swImageViewLoadFinished(self)
                        
                        self.indicator.stopAnimating()
                    })
                }else{
                    self.indicator.stopAnimating()
                }
            }
            
        }
    }
    
    func loadURL(_ str: String?,defaultImg img:UIImage?){
        self.image = img
        if let url = str{
            self.loadImage(url)
        }
    }
}

class SWButton: UIButton{
//    weak var delegate:SWImageViewDelegate?
    lazy var indicator:UIActivityIndicatorView = {
        var indi = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indi.hidesWhenStopped = true
        indi.adoptAutoLayout()
        self.addSubview(indi)
        
        self.addConstraint(NSLayoutConstraint.equalConstraint(indi, attribute1: .centerX, view2: self, attribute2: .centerX))
        self.addConstraint(NSLayoutConstraint.equalConstraint(indi, attribute1: .centerY, view2: self, attribute2: .centerY))
        
        
        
        return indi
    }()
    
    func loadURL(_ str: String?){
        if let url = str{
            var ary = url.components(separatedBy: "/")
            let fileName = NSMutableString()
            
            
            
            for i in 0 ..< ary.count{
                fileName.append(ary[i])
            }
            
            let path = (fileName as String).imageCachePath
            
            if FileManager.default.fileExists(atPath: path){
                self.setImage(UIImage(contentsOfFile: path), for: UIControlState())
                
//                self.delegate?.swImageViewLoadFinished(self)
            }else{
                self.setImage(nil, for: UIControlState())
                
                indicator.startAnimating()
                indicator.isHidden = false

                Thread.detachNewThreadSelector(#selector(SWImageView.loadImage(_:)), toTarget: self, with: str)
            }
        }
    }
    
    func loadImage(_ str: String){
        autoreleasepool { () -> () in
            let url = URL(string: str)
            let data = try? Data(contentsOf: url!)
            
            if let d = data{
                let img = UIImage(data: d)
                
                
                if let image = img{
                    SWUtils.RunOnMainThread({ () -> Void in
                        self.setImage(image, for: UIControlState())
                        
                        var ary = str.components(separatedBy: "/")
                        let fileName = NSMutableString()
                        
                        
                        
                        for i in 0 ..< ary.count{
                            fileName.append(ary[i])
                        }
                        
                        let path = (fileName as String).imageCachePath
                        
                        try? data?.write(to: URL(fileURLWithPath: path), options: [])
                        
//                        self.delegate?.swImageViewLoadFinished(self)
                    })
                }else{
                    self.indicator.stopAnimating()
                }
            }
            
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        
        self.indicator.stopAnimating()
    }
}

extension UIView{
    func adoptAutoLayout(){
        if self.responds(to: #selector(setter: UIView.translatesAutoresizingMaskIntoConstraints)){
            self.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func filled(_ v: UIView,mode: ConstraintFillMode){
        switch mode{
        case .both:
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", views: ["v":v]))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", views: ["v":v]))
        case .width:
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", views: ["v":v]))
        case .height:
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", views: ["v":v]))
        }
    }
    
    func addConstraints(_ format: String,views: [String:Any]){
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, views: views))
    }
}

extension UIButton{
    class func customButton() -> UIButton{
        return self.init(type: .custom)
    }
}

extension NSLayoutConstraint{
    class func constraintsWithVisualFormat(_ format: String, views: [String : Any]) -> [NSLayoutConstraint]{
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: views)
    }
    
    class func squareConstraint(_ view: UIView) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
    }
    
    class func centerConstraints(_ view1: UIView,view2: UIView) -> [NSLayoutConstraint]{
        return [NSLayoutConstraint(item: view1, attribute: .centerX, relatedBy: .equal, toItem: view2, attribute: .centerX, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: view1, attribute: .centerY, relatedBy: .equal, toItem: view2, attribute: .centerY, multiplier: 1.0, constant: 0)]
    }
    
    class func heightConstraint(_ view: UIView,height: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: height)
    }
    
    class func widthConstraint(_ view: UIView,width: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: width)
    }
    
    class func sizeConstraints(_ view: UIView,width: CGFloat, height: CGFloat) -> [NSLayoutConstraint]{
        return [NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: width),NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: height)]
    }
    
    class func equalConstraint(_ view1: UIView,attribute1: NSLayoutAttribute,view2: UIView?,attribute2: NSLayoutAttribute) -> NSLayoutConstraint{
        return NSLayoutConstraint.equalConstraint(view1, attribute1: attribute1, view2: view2, attribute2: attribute2, constant: 0)
    }
    
    class func equalConstraint(_ view1: UIView,attribute1: NSLayoutAttribute,view2: UIView?,attribute2: NSLayoutAttribute,constant: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint.equalConstraint(view1,attribute1: attribute1,view2: view2,attribute2: attribute2,multiplier: 1.0,constant: constant)
    }
    
    class func equalConstraint(_ view1: UIView,attribute1: NSLayoutAttribute,view2: UIView?,attribute2: NSLayoutAttribute,multiplier: CGFloat,constant: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: view1, attribute: attribute1, relatedBy: .equal, toItem: view2, attribute: attribute2, multiplier: multiplier, constant: constant)
    }
    
    class func ratioConstraint(_ view: UIView,ratio: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: ratio, constant: 0)
    }
    
    class func sameConstraints(_ view1: UIView,view2: UIView) -> [NSLayoutConstraint]{
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint.equalConstraint(view1, attribute1: .width, view2: view2, attribute2: .width))
        constraints.append(NSLayoutConstraint.equalConstraint(view1, attribute1: .height, view2: view2, attribute2: .height))
        constraints.append(NSLayoutConstraint.equalConstraint(view1, attribute1: .left, view2: view2, attribute2: .left))
        constraints.append(NSLayoutConstraint.equalConstraint(view1, attribute1: .top, view2: view2, attribute2: .top))
        
        return constraints
    }
    
}
    //  MARK: - Classes
class SWTextView: UITextView{
    fileprivate var shouldDrawPlackholder = false
    var _placeholderColor = UIColor(white: 0.7, alpha: 1)
    
    var placeholderColor: UIColor?{
        get{
            return _placeholderColor
        }
        
        set{
            if newValue == nil{
                _placeholderColor = UIColor.clear
            }else{
                _placeholderColor = newValue!
            }
        }
    }
    
    var placeholder: String?{
        didSet{
            _updateShouldDrawPlaceholder()
        }
    }
    
    override var text: String?{
        didSet{
            _updateShouldDrawPlaceholder()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        _initialize()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if shouldDrawPlackholder{
            placeholderColor?.set()
            placeholder?.draw(in: self.bounds.insetBy(dx: 4, dy: 4), withAttributes: (self.font == nil ? nil : [NSFontAttributeName:self.font!,NSForegroundColorAttributeName:placeholderColor!]))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Private Functions
    fileprivate func _initialize(){
        NotificationCenter.default.addObserver(self, selector: #selector(SWTextView._textChanged(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        
        
        shouldDrawPlackholder = false
    }
    
    fileprivate func _updateShouldDrawPlaceholder(){
        let prev = shouldDrawPlackholder
        shouldDrawPlackholder = self.placeholderColor != nil && self.placeholderColor != nil && (self.text?.length ?? 0) == 0
        if prev != shouldDrawPlackholder{
            self.setNeedsDisplay()
        }
    }
    
    func _textChanged(_ notice: Notification){
        self._updateShouldDrawPlaceholder()
    }
}
