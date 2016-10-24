//
//  SWEmoticonsKeyboard.swift
//  Affair
//
//  Created by Stan Wu on 15/11/20.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import UIKit

class SWKeyboardCollectionLayout: UICollectionViewFlowLayout{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let mut = NSMutableArray()
        
        if let ary = super.layoutAttributesForElements(in: rect){
            mut.addObjects(from: ary)
        }
        
        let sectionCount = self.collectionView?.numberOfSections ?? 0
        for i in 0..<sectionCount{
            if let las = self.layoutAttributesForDecorationView(ofKind: "DelSendButton", at: IndexPath(item: 0, section: i)){
                mut.add(las)
            }
        }
        
        return (mut as NSArray) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath as NSIndexPath).row == 0{
            let decorationAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
            let r = self.rectForButton((indexPath as NSIndexPath).section)
  
            decorationAttributes.frame = r
            decorationAttributes.zIndex = 0
            
            
            return decorationAttributes
        }
        else{
            return nil
        }
    }
    
    func rectForButton(_ section: Int) -> CGRect{
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        
        let x: CGFloat = SWDefinitions.ScreenWidth * CGFloat(section) + 40 * CGFloat(cols-3) + self.sectionInset.left
        let y: CGFloat = CGFloat(rows-1) * 40 + self.sectionInset.top

        return CGRect(x: x, y: y, width: 120, height: 40)
    }
    
}

class SWDelSendButton: UICollectionReusableView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        
        let btnDel = UIButton.customButton()
        btnDel.adoptAutoLayout()
        self.addSubview(btnDel)
        btnDel.setImage(UIImage(named: "KeyboardButtonDelete"), for: UIControlState())
        btnDel.addTarget(self, action: #selector(SWDelSendButton.delClicked), for: .touchUpInside)
        
        let btnSend = UIButton.customButton()
        btnSend.adoptAutoLayout()
        self.addSubview(btnSend)
        btnSend.clipsToBounds = true
        btnSend.layer.cornerRadius = 3
        btnSend.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.PurpleColor, size: CGSize(width: 1, height: 1)), for: UIControlState())
        btnSend.setTitle(NSLocalizedString("发送", comment: "发送"), for: UIControlState())
        btnSend.setTitleColor(UIColor.white, for: UIControlState())
        btnSend.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnSend.addTarget(self, action: #selector(SWDelSendButton.sendClicked), for: .touchUpInside)
        
        let views = ["del":btnDel,"send":btnSend]
        
        self.addConstraints("H:|[del(==40)]-8-[send]|", views: views)
        self.addConstraint(NSLayoutConstraint.equalConstraint(btnDel, attribute1: .centerY, view2: self, attribute2: .centerY))
        self.addConstraint(NSLayoutConstraint.equalConstraint(btnSend, attribute1: .centerY, view2: btnDel, attribute2: .centerY))
        self.addConstraint(NSLayoutConstraint.equalConstraint(btnSend, attribute1: .height, view2: btnDel, attribute2: .height))
    }
    
    func delClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SWEmoticonKeyboardDeleteClicked"), object: nil)
    }
    
    func sendClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SWEmoticonKeyboardSendClicked"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SWEmoticonKeyboard: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    weak var inputTextView: UITextView?
    let cvEmoticons: UICollectionView
    let dicEmoticonsMap = NSDictionary(contentsOfFile: "SWToolKit.bundle/Emoticons/EmoticonsMap.plist".bundlePath())!
    
    override init(frame: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        
        let xpadding: CGFloat = (rect.size.width - CGFloat(cols)*40) / 2
        let ypadding: CGFloat = (rect.size.height - CGFloat(rows)*40) / 2
        
        let layout = SWKeyboardCollectionLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(ypadding, xpadding, ypadding, xpadding)
        layout.scrollDirection = .horizontal
        layout.register(SWDelSendButton.self, forDecorationViewOfKind: "DelSendButton")
        cvEmoticons = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(frame: rect)
        
        cvEmoticons.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmoticonCell")
        cvEmoticons.backgroundColor = UIColor.clear
        cvEmoticons.adoptAutoLayout()
        cvEmoticons.delegate = self
        cvEmoticons.dataSource = self
        cvEmoticons.isPagingEnabled = true
        self.addSubview(cvEmoticons)
        self.filled(cvEmoticons, mode: .both)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SWDelSendButton.delClicked), name: NSNotification.Name(rawValue: "SWEmoticonKeyboardDeleteClicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SWDelSendButton.sendClicked), name: NSNotification.Name(rawValue: "SWEmoticonKeyboardSendClicked"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func delClicked(){
        if let txt = self.inputTextView?.text{
            let len = txt.length
            if len > 0{
                if txt.hasSuffix("]"){
                    var rightFinded = false,leftFinded = false
                    
                    
                    
                    for i in stride(from: (len-2), through: 0, by: -1){
                        let sub = (txt as NSString).substring(with: NSMakeRange(i, 1)) as String
                        if sub == "["{
                            leftFinded = true
                        }else if sub == "]"{
                            rightFinded = true
                        }
                        
                        if leftFinded && !rightFinded{
                            let newstr = (txt as NSString).replacingCharacters(in: NSMakeRange(i, len-i), with: "") as String
                            self.inputTextView?.text = newstr
                            break
                        }else if rightFinded && !leftFinded{
                            let newstr = (txt as NSString).replacingCharacters(in: NSMakeRange(len-1, 1), with: "")
                            self.inputTextView?.text = newstr
                            break
                        }
                    }
                }else{
                    let newstr = (txt as NSString).replacingCharacters(in: NSMakeRange(len-1, 1), with: "")
                    self.inputTextView?.text = newstr
                }
            }
        }
    }
    
    func sendClicked(){
        self.inputTextView?.delegate?.textView?(inputTextView!, shouldChangeTextIn: NSMakeRange(inputTextView?.text.length ?? 0 , 0), replacementText: "\n")
    }
    
    //  MARK: - UICollectionView Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmoticonCell", for: indexPath)
        
        var imgv:UIImageView! = cell.contentView.viewWithTag(100) as? UIImageView
        if imgv == nil{
            cell.contentView.backgroundColor = UIColor.clear
            
            imgv = UIImageView()
            imgv.adoptAutoLayout()
            imgv.tag = 100
            cell.contentView.addSubview(imgv)
            cell.contentView.addConstraint(NSLayoutConstraint.equalConstraint(imgv, attribute1: .centerX, view2: cell.contentView, attribute2: .centerX))
            cell.contentView.addConstraint(NSLayoutConstraint.equalConstraint(imgv, attribute1: .centerY, view2: cell.contentView, attribute2: .centerY))
            cell.contentView.addConstraint(NSLayoutConstraint.squareConstraint(imgv))
            cell.contentView.addConstraint(NSLayoutConstraint.widthConstraint(imgv, width: 32))
        }
        
//        let images = dicEmoticonsMap.objectForKey("image")?.allKeys as! NSArray
        let emoticons = dicEmoticonsMap.object(forKey: "order") as! NSArray
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        

        let col = (indexPath as NSIndexPath).row / rows
        let row = (indexPath as NSIndexPath).row % rows
        
        let i = (indexPath as NSIndexPath).section*(cols*rows-3) + row*cols + col

        if row == rows - 1 && col >= cols - 3{
            imgv.image = nil
        }else{
            if i < emoticons.count{
                let name = (emoticons.object(at: i) as? NSDictionary)?.allValues.last as! String
                
                imgv.image = UIImage(named: "SWToolKit.bundle/Emoticons/images/\(name).png")
            }else{
                imgv.image = nil
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        
        return cols*rows
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        
        let total = (dicEmoticonsMap.object(forKey: "image") as? NSDictionary)?.allKeys.count ?? 0
        
        return total / (cols * rows - 3) + (total % (cols * rows - 3) == 0 ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rect = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 216)
        let cols = Int(rect.size.width) / 40
        let rows = Int(rect.size.height) / 40
        
        
        let col = (indexPath as NSIndexPath).row / rows
        let row = (indexPath as NSIndexPath).row % rows
        
        let i = (indexPath as NSIndexPath).section*(cols*rows-3) + row*cols+col
        
        if row == rows - 1 && col >= cols - 3{
//            if col == cols - 3{
//                //  del
//                delClicked()
//            }else{
//                //  send
//                sendClicked()
//            }
        }else{
            if let orders = dicEmoticonsMap.object(forKey: "order") as? NSArray{
                if i < orders.count{
                    if let str = (orders.object(at: i) as? NSDictionary)?.allKeys.last as? String{
                        if inputTextView?.text == nil{
                            inputTextView?.text = str
                        }else{
                            inputTextView?.text = (inputTextView?.text ?? "") + str
                        }
                        
                        inputTextView?.delegate?.textViewDidChange?(inputTextView!)
                    }
                }
                
            }
        }
    }
    
}
