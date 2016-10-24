//
//  PortalViewController.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit
import AVFoundation
class PortalViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    let lblTips = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 20), textColor: UIColor.black)
    var initialized = false
    let btnProfile = UIButton.customButton()
    let vPreview = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavTitle("Green Dotters")
        addBGColor()
        
        vPreview.adoptAutoLayout()
        view.addSubview(vPreview)
        
        lblTips.text = "请允许使用摄像头"
        lblTips.adoptAutoLayout()
        lblTips.textAlignment = .center
        vPreview.addSubview(lblTips)
        vPreview.addConstraints(NSLayoutConstraint.centerConstraints(lblTips, view2: vPreview))
        vPreview.filled(lblTips, mode: .both)
        lblTips.isHidden = true
        
        btnProfile.adoptAutoLayout()
        view.addSubview(btnProfile)
        btnProfile.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1, height: 1)), for: .normal)
        btnProfile.setTitleColor(UIColor.white, for: .normal)
        btnProfile.setTitle("我的资料", for: .normal)
        btnProfile.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnProfile.addTarget(self, action: #selector(profileClicked), for: .touchUpInside)
        
        
        
        let views = ["btn":btnProfile, "preview": vPreview]
        
        
        view.filled(vPreview, mode: .width)
        view.filled(btnProfile, mode: .width)
        view.addConstraints("V:|[preview][btn(==54)]|", views: views)
        
        initialCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialCapture()
        
        if lblTips.text != nil && lblTips.isHidden {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func profileClicked() {
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func initialCapture() {
        if initialized {
            return
        }

        // Do any additional setup after loading the view, typically from a nib.
        //获取摄像设备
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            lblTips.isHidden = false
            return
        }
        //创建输入流
        let input = try? AVCaptureDeviceInput(device: device)
        //创建输出流
        let output = AVCaptureMetadataOutput()
        //设置代理 在主线程里刷新
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //初始化链接对象
        
        //高质量采集率
        session.sessionPreset = AVCaptureSessionPresetHigh
        session.addInput(input)
        session.addOutput(output)
        
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        let layer = AVCaptureVideoPreviewLayer.init(session: session)!
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = self.view.layer.bounds
        vPreview.layer.insertSublayer(layer, at:0)
        
        //开始捕获
        session.startRunning()
        initialized = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //  MARK: - AVFoundation Delegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            //[session stopRunning];
            session.stopRunning()
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            //输出扫描字符串
            
            
            if let str = metadataObject.stringValue {
                if let json = (try? JSONSerialization.jsonObject(with: str.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)) as? NSDictionary {
                    guard let shop_id = json.object(forKey: "shop_id") as? String else {
                        OAAlertView.show(nil, message: "无效的二维码", cancel: nil, callback: { (buttonTitle) in
                            self.session.startRunning()
                        })
                        return
                    }
                    
                    MDataProvider.getShopInfo(["shop_id":shop_id], completionBlock: { (code, data, message) in
                        if SWDefinitions.RETURN_SUCCESS_CODE == code {
                            let vc = ShopViewController()
                            vc.shopInfo = data as! [String : Any]
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            OAAlertView.show(nil, message: message != nil ? message : "获取商家信息失败，请稍候再试", cancel: nil, callback: { (buttonTitle) in
                                self.session.startRunning()
                            })
                        }
                    })
                    
                    
                }
            }else {
                OAAlertView.show(nil, message: "无效的二维码", cancel: nil, callback: { (buttonTitle) in
                    self.session.startRunning()
                })
            }
        }
    }

}
