//
//  SWAlbumView.swift
//  Affair
//
//  Created by Stan Wu on 15/12/2.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import UIKit

class SWAlbumView: UIView,ABScrollPageViewDeleage,SWPhotoViewDelegate {
    var photoList: [NSDictionary]
    var scvPhotos: ABScrollPageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    init(frame: CGRect ,photos: [NSDictionary]) {
        photoList = photos
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
                
        scvPhotos = ABScrollPageView(frame: self.bounds)
        scvPhotos.frame = self.bounds
        scvPhotos.setDelegate(self)
        scvPhotos.pageCount = UInt(photoList.count)
        scvPhotos.reloadData()
        scvPhotos.pageControl.isHidden = true
        self.addSubview(scvPhotos)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(SWAlbumView.singleTapped(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(SWAlbumView.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(doubleTap)
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
        }) 
    }
    
    func show(){
        self.alpha = 0
        let window = UIApplication.shared.windows.last
        
        window?.addSubview(self)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1
        }) 
    }
    
    class func show(_ photos: [NSDictionary]){
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        let v = SWAlbumView(frame: (window?.bounds)!, photos: photos)
        v.show()
    }
    
    class func show(_ photos: [NSDictionary],_ pageIndex: Int){
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        let v = SWAlbumView(frame: (window?.bounds)!, photos: photos)
        v.scvPhotos.turn(toPage: pageIndex < photos.count ? pageIndex : (photos.count - 1))
        v.show()
    }
    
    func singleTapped(_ tap: UITapGestureRecognizer){
        dismiss()
    }
    
    func doubleTapped(_ tap: UITapGestureRecognizer){
        
    }
    
    //  MARK: - ABScrollPageView Delegate
    func scrollPageView(_ scrollPageView: Any!, viewForPageAt index: UInt) -> UIView! {
        var v = (scrollPageView as! ABScrollPageView).dequeueReusablePage(index) as? SWPhotoView
        
        if v == nil && Int(index) < photoList.count{
            v = SWPhotoView(frame: self.bounds)
            v?.delegate = self
            v?.dicInfo = photoList[Int(index)] as! [AnyHashable: Any]
        }
        
        return v
    }
    
    func didScrollToPage(at index: UInt) {
        if let imgv = scrollPageView(scvPhotos, viewForPageAt: index) as? SWPhotoView{
            imgv.loadBigPhoto()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - SWPhotoView Delegate
    func photoDownloadFailed() {
        SVProgressHUD.showError(withStatus: NSLocalizedString("图片下载失败，请稍候再试", comment: "图片下载失败，请稍候再试"))
        dismiss()
    }

}
