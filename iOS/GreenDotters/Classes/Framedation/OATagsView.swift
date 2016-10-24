//
//  OATagsView.swift
//  Affair
//
//  Created by Stan Wu on 15/11/6.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import UIKit

enum OATagsViewStyle: Int{
    case `default`,profile,genderTags
}

class OATagsView: UIView {
    var style =  OATagsViewStyle.default
    
    var profile: NSDictionary?{
        didSet{
            for v in self.subviews{
                if let lbl = v as? UILabel{
                    lbl.removeFromSuperview()
                }
            }
            
            if let info = profile{
                if style == .profile{
                    var labels = [UIView]()
                    
                    let gender = info.int(forKey: "gender") ?? 0
                    let age = info.int(forKey: "age") ?? 0
                    let height = info.int(forKey: "height") ?? 0
                    let province = info.int(forKey: "province") ?? 0
                    let city = info.int(forKey: "city") ?? 0
                    let marriage_status = info.int(forKey: "marriage_status") ?? 0
                    
                    
                    let font = UIFont.systemFont(ofSize: 10)
                    
                    //  Gender Age
                    var lbl = UILabel.create(CGRect.zero, font: font, textColor:UIColor.white)
                    lbl.adoptAutoLayout()
                    addSubview(lbl)
                    let mutstr = NSMutableAttributedString()
                    let attach = NSTextAttachment()
                    attach.image = UIImage(named: 2 == gender ? "TagsFemaleIcon" : "TagsMaleIcon")
                    mutstr.append(NSAttributedString(attachment: attach))
                    mutstr.append(NSAttributedString(string: " \(age)"))
                    lbl.attributedText = mutstr
                    lbl.backgroundColor = 2 == gender ? UIColor(red: 0.98, green: 0.65, blue: 0.72, alpha: 1) : UIColor(red: 0.5, green: 0.75, blue: 0.86, alpha: 1)
                    labels.append(lbl)
                    
                    
                    
                    if height > 0{
                        lbl = UILabel.create(CGRect.zero, font: font, textColor: ProjectDefinitions.PurpleColor)
                        lbl.adoptAutoLayout()
                        addSubview(lbl)
                        lbl.text = "\(height)cm"
                        labels.append(lbl)
                    }
                    
                    if let area = SWUtils.area(province, city: city){
                        lbl = UILabel.create(CGRect.zero, font: font, textColor: ProjectDefinitions.PurpleColor)
                        lbl.adoptAutoLayout()
                        addSubview(lbl)
                        lbl.text = area
                        labels.append(lbl)
                    }
                    
                    if marriage_status > 0{
                        let marry_string = (MDataProvider.profilePlist().object(forKey: "marriage_status") as! NSArray).object(at: marriage_status) as? String
                        lbl = UILabel.create(CGRect.zero, font: font, textColor: ProjectDefinitions.PurpleColor)
                        lbl.adoptAutoLayout()
                        addSubview(lbl)
                        lbl.text = marry_string
                        labels.append(lbl)
                    }
                    
                    var vformat = "H:|"
                    
                    var views = [String:UIView]()
                    
                    for i in 0..<labels.count{
                        let l = labels[i] as! UILabel
                        l.textAlignment = .center
                        l.clipsToBounds = true
                        l.layer.cornerRadius = 2
                        
                        if i != 0{
                            l.backgroundColor = UIColor(red: 0.97, green: 0.91, blue: 0.98, alpha: 1)
                        }
                        
                        if i != 0{
                            vformat += "-6-"
                        }
                        
                        let w = (l.text! as NSString).size(attributes: [NSFontAttributeName:l.font]).width + 10.0
                        
                        vformat += "[v\(i)(==\(w))]"
                        
                        views["v\(i)"] = l
                        
                        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lbl]|", views: ["lbl":l]))
                    }
                    
                    self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vformat, views: views))
                }else{
                    
                    var labels = [UIView]()
                    
                    
                    let font = UIFont.systemFont(ofSize: 10)
                    
                    let gender = profile?.int(forKey: "gender") ?? 0
                    let age = profile?.int(forKey: "age") ?? 0
      
                    //  Gender Age
                    let lbl = UILabel.create(CGRect.zero, font: font, textColor:UIColor.white)
                    lbl.adoptAutoLayout()
                    addSubview(lbl)
                    let mutstr = NSMutableAttributedString()
                    let attach = NSTextAttachment()
                    attach.image = UIImage(named: 2 == gender ? "TagsFemaleIcon" : "TagsMaleIcon")
                    mutstr.append(NSAttributedString(attachment: attach))
                    mutstr.append(NSAttributedString(string: " \(age)"))
                    lbl.attributedText = mutstr
                    lbl.backgroundColor = 2 == gender ? UIColor(red: 0.98, green: 0.65, blue: 0.72, alpha: 1) : UIColor(red: 0.5, green: 0.75, blue: 0.86, alpha: 1)
                    labels.append(lbl)
                    
                    if let t = profile?.object(forKey: "tags") as? String{
                        let tags_list = t.components(separatedBy: ",")
                        for tag in tags_list{
                            let lbl = UILabel.create(CGRect.zero, font: font, textColor: ProjectDefinitions.PurpleColor)
                            lbl.adoptAutoLayout()
                            addSubview(lbl)
                            lbl.text = tag
                            labels.append(lbl)
                        }
                    }
                    
                    
                    
                    var vformat = "H:|"
                    
                    var views = [String:UIView]()
                    
                    for i in 0..<labels.count{
                        let l = labels[i] as! UILabel
                        l.textAlignment = .center
                        l.clipsToBounds = true
                        l.layer.cornerRadius = 2
                        if 0 != i{
                            l.backgroundColor = UIColor(red: 0.97, green: 0.91, blue: 0.98, alpha: 1)
                        }
                        
                        
                        if i != 0{
                            vformat += "-6-"
                        }
                        
                        let w = (l.text! as NSString).size(attributes: [NSFontAttributeName:l.font]).width + 10.0
                        
                        vformat += "[v\(i)(==\(w))]"
                        
                        views["v\(i)"] = l
                        
                        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lbl]|", views: ["lbl":l]))
                    }
                    
                    self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vformat, views: views))
                }
                
                
                
            }
        }
    }
    
    var tags: String?{
        didSet{
            for v in self.subviews{
                if let lbl = v as? UILabel{
                    lbl.removeFromSuperview()
                }
            }
            
            if let t = tags{
                var labels = [UIView]()
                
                let tags_list = t.components(separatedBy: ",")
                let font = UIFont.systemFont(ofSize: 10)
                
                for tag in tags_list{
                    let lbl = UILabel.create(CGRect.zero, font: font, textColor: ProjectDefinitions.PurpleColor)
                    lbl.adoptAutoLayout()
                    addSubview(lbl)
                    lbl.text = tag
                    labels.append(lbl)
                }
     
                var vformat = "H:|"
                
                var views = [String:UIView]()
                
                for i in 0..<labels.count{
                    let l = labels[i] as! UILabel
                    l.textAlignment = .center
                    l.clipsToBounds = true
                    l.layer.cornerRadius = 2
                    l.backgroundColor = UIColor(red: 0.97, green: 0.91, blue: 0.98, alpha: 1)
                    
                    if i != 0{
                        vformat += "-6-"
                    }
                    
                    let w = (l.text! as NSString).size(attributes: [NSFontAttributeName:l.font]).width + 10.0
                    
                    vformat += "[v\(i)(==\(w))]"
                    
                    views["v\(i)"] = l
                    
                    self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lbl]|", views: ["lbl":l]))
                }
                
                self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vformat, views: views))
                
            }
        }
    }
}
