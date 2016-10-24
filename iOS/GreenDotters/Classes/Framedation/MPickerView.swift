//
//  MPickerView.swift
//  Mosaic
//
//  Created by Stan Wu on 15/7/12.
//  Copyright (c) 2015年 Stan Wu. All rights reserved.
//

import UIKit

class MPickerView: UIView,ABPickerViewDelegate {
    var vPicker: ABPickerView!
    weak var delegate: ABPickerViewDelegate?
    
    init(editType: ABEditType,delegate: ABPickerViewDelegate?){
        super.init(frame:UIScreen.main.bounds)
        
        self.delegate = delegate
        
        vPicker = ABPickerView(frame: CGRect(x: 0, y: SWDefinitions.ScreenHeight-260, width: SWDefinitions.ScreenWidth, height: 260))
        vPicker.editType = editType
        vPicker.delegate = self
        vPicker.transform = CGAffineTransform(translationX: 0, y: vPicker.frame.size.height)
        self.addSubview(vPicker)
    }
    
    class func show(_ editType: ABEditType,delegate: ABPickerViewDelegate?) -> ABPickerView{
        let picker = MPickerView(editType: editType, delegate: delegate)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.addSubview(picker)
        
        picker.show()
        
        return picker.vPicker
    }
    
    func show(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.vPicker.transform = CGAffineTransform.identity
        })
    }

    func dismiss(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.vPicker.transform = CGAffineTransform(translationX: 0, y: self.vPicker.frame.size.height)
            }, completion: { (finished: Bool) -> Void in
            self.removeFromSuperview()
        }) 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss()
    }
    
    //  MARK: - ABPickerView Delegate
    func pickerDidCancelSelection(_ picker: ABPickerView!) {
        self.dismiss()
    }
    
    func pickerDidChangedSelection(_ picker: ABPickerView!) {
        self.delegate?.pickerDidChangedSelection(picker)
    }
    
    func pickerDidFinishSelection(_ picker: ABPickerView!) {
        self.delegate?.pickerDidFinishSelection(picker)
        self.dismiss()
    }
}
