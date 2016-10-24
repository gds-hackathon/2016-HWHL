//
//  ViewController.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let tfPhone = UITextField()
    let tfPassword = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBGColor()
        // Do any additional setup after loading the view, typically from a nib.
        let lblTitle = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black)
        lblTitle.text = "Green Dotters"
        lblTitle.adoptAutoLayout()
        lblTitle.textAlignment = .center
        self.view.addSubview(lblTitle)
        
        tfPhone.adoptAutoLayout()
        tfPhone.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(tfPhone)
        tfPhone.backgroundColor = UIColor.white
        tfPhone.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0)
        tfPhone.placeholder = "请输入你的手机号码"
        tfPhone.keyboardType = .phonePad
        
        tfPassword.adoptAutoLayout()
        tfPassword.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(tfPassword)
        tfPassword.backgroundColor = UIColor.white
        tfPassword.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0)
        tfPassword.placeholder = "请输入你的密码"
        tfPassword.isSecureTextEntry = true
        
        let btnLogin = UIButton.customButton()
        btnLogin.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnLogin.adoptAutoLayout()
        view.addSubview(btnLogin)
        btnLogin.setTitle("登录", for: .normal)
        btnLogin.setTitleColor(UIColor.white, for: .normal)
        btnLogin.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1, height: 1)), for: .normal)
        btnLogin.addTarget(self, action: #selector(self.loginClicked), for: .touchUpInside)
        
        let btnRegister = UIButton.customButton()
        btnRegister.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnRegister.adoptAutoLayout()
        view.addSubview(btnRegister)
        btnRegister.setTitle("注册", for: .normal)
        btnRegister.setTitleColor(UIColor.white, for: .normal)
        btnRegister.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.OrangeColor, size: CGSize(width: 1, height: 1)), for: .normal)
        btnRegister.addTarget(self, action: #selector(self.registerClicked ), for: .touchUpInside)
        
        
        let views = ["title":lblTitle, "phone":tfPhone, "password":tfPassword, "login": btnLogin, "register":btnRegister]
        
        view.filled(lblTitle, mode: .width)
        view.filled(tfPhone, mode: .width)
        view.filled(tfPassword, mode: .width)
        view.filled(btnLogin, mode: .width)
        view.filled(btnRegister, mode: .width)
        
        view.addConstraints("V:|-100-[title]-40-[phone(==44)]-10-[password(==44)]-30-[login(==44)]-10-[register(==44)]", views: views)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginClicked() {
        guard (tfPhone.text?.length ?? 0) > 0 else {
            OAAlertView.show(nil, message: "请输入手机号码", cancel: nil)
            return
        }
        
        guard (tfPassword.text?.length ?? 0) > 0 else {
            OAAlertView.show(nil, message: "请输入密码", cancel: nil)
            return
        }
        
        let phone = tfPhone.text!
        let password = tfPassword.text!
        
        let hashed_password = HMAC.sign(message: password, algorithm: HMAC.Algorithm.sha1, key: "mosaic")
        
        SVProgressHUD.show(withStatus: "正在登录")
        
        sw_dispatch_on_background_thread {
            let dict = MDataProvider.login(["phone":phone, "password":hashed_password!])
            let code = dict?.int(forKey: "code") ?? 0
            let msg = dict?.object(forKey: "message") as? String
            
            sw_dispatch_on_main_thread {
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LoginAccount"), object: nil)
                    SVProgressHUD.showSuccess(withStatus: "登录成功")
                } else {
                    SVProgressHUD.showError(withStatus: msg != nil ? msg : "登录失败，请稍候再重试")
                }
            }
            
        }
        
        
    }
    
    func registerClicked() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

