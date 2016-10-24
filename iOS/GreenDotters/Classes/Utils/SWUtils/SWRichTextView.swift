//
//  SWRichTextView.swift
//  Affair
//
//  Created by Stan Wu on 15/11/18.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import UIKit

class SWTextAttachment: NSTextAttachment{
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {        
        return CGRect(x: 0, y: 0, width: lineFrag.size.height, height: lineFrag.size.height)
    }
}

struct PMDefinitions{
    static let PMCellWidth = SWDefinitions.ScreenWidth - 155
}

class SWRichTextView: UILabel {
    static let dicEmoticonsMap = NSDictionary(contentsOfFile: "SWToolKit.bundle/Emoticons/EmoticonsMap.plist".bundlePath())
    static let regexEmoticons = try! NSRegularExpression(pattern: "\\[[^\\[\\]]+\\]", options: NSRegularExpression.Options(rawValue: 0))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.numberOfLines = 0
        
//        self.scrollEnabled = false
//        self.selectable = true
//        self.editable = false
//        
//        self.dataDetectorTypes = .Link
    }
    
    override var text: String?{
        didSet{
            if let content = text{
                super.text = nil
  
                self.attributedText = SWRichTextView.attributedString(content, font: self.font ?? UIFont.systemFont(ofSize: 15))
            }else{
                self.attributedText = nil
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //  MARK: - Basic Functions
    class func componets(_ content: String) -> [String]{
        let chunks = regexEmoticons.matches(in: content, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, content.length))
        
        var components = [String]()
        var ranges = [NSRange]()
        for i in 0..<chunks.count{
            let chunk = chunks[i]
            let total = chunk.numberOfRanges

            for j in 0..<total{
                ranges.append(chunk.rangeAt(j))
            }
        }
        
        var index = 0
        var i = 0
        
        while index < content.length{
            if i < ranges.count{
                let range = ranges[i]
                
                if index < range.location{
                    components.append((content as NSString).substring(with: NSMakeRange(index, range.location-index)) as String)
                }
                
                components.append((content as NSString).substring(with: range) as String)
                
                index = range.location + range.length
            }else{
                components.append((content as NSString).substring(with: NSMakeRange(index, content.length-index)) as String)
                
                index = content.length
            }
            
            i += 1
        }
        
        
        return components
    }
    
    class func imagePath(_ str: String) -> String?{
        if let name = (dicEmoticonsMap?.object(forKey: "name") as? NSDictionary)?.object(forKey: str) as? String{
            return "SWToolKit.bundle/Emoticons/images/\(name).png".bundlePath()
        }else{
            return nil
        }
    }
    
    class func attributedString(_ text: String,font: UIFont) -> NSAttributedString{
        let components = SWRichTextView.componets(text)
        
        var images = [[String:Any]]()
        var mutstr = ""
        
        for i in 0..<components.count{
            let str = components[i]
            
            if str.hasPrefix("[") && str.hasSuffix("]"){
                let path = SWRichTextView.imagePath(str) ?? ""
                if let _ = UIImage(contentsOfFile: path){
                    images.append(["path":path,"index":"\(mutstr.length)"])
                }else{
                    mutstr += str
                }
            }else{
                mutstr += str
            }
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        
        
        let attributes = [NSFontAttributeName:font]
        
        let attr = NSMutableAttributedString(string: mutstr, attributes: attributes)
        
        for i in stride(from: (images.count-1), through: 0, by: -1){
            let dic = images[i]
            let attachment = SWTextAttachment(data: nil, ofType: nil)
            attachment.image = UIImage(contentsOfFile: dic["path"] as! String)
            let textAttachmentString = NSAttributedString(attachment: attachment)
            attr.insert(textAttachmentString, at: Int(dic["index"] as! String)!)
        }
        
        return attr
    }
    
    class func size(_ content: String,font: UIFont) -> CGSize{
        let astr = self.attributedString(content, font: font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(astr as CFAttributedString)

        var r = CFRangeMake(0, 0)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: PMDefinitions.PMCellWidth, height: CGFloat.greatestFiniteMagnitude), &r)
        
        return suggestedSize
    }
    
}
