//
//  RegisterViewController.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var btnSend: UIButton!
    var tfPhone, tfPassword, tfPassword1, tfAuthCode: UITextField?
    
    var timer: Timer!
    var leftSeconds = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBGColor()
        addNavBack()
        setNavTitle("注册")
        
        let tvForm = UITableView()
        tvForm.adoptAutoLayout()
        view.addSubview(tvForm)
        tvForm.delegate = self
        tvForm.dataSource = self
        tvForm.separatorStyle = .none
        tvForm.backgroundColor = UIColor.clear
        
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 30)
        tvForm.tableHeaderView = v
        
        let btn = UIButton.customButton()
        btn.frame = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 44)
        btn.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1, height: 1)), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitle("注册", for: .normal)
        btn.addTarget(self, action: #selector(registerClicked), for: .touchUpInside)
        
        tvForm.tableFooterView = btn
        
        view.filled(tvForm, mode: .both)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSeconds), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer.invalidate()
    }
    
    func updateSeconds(){
        if btnSend.isEnabled{
            return
        }
        
        leftSeconds -= 1
        
        if leftSeconds < 0{
            leftSeconds = 0
        }
        
        if leftSeconds==0{
            leftSeconds = 60
            btnSend.isEnabled = true
            btnSend.setTitle(NSLocalizedString("重新发送", comment: "重新发送"), for: .normal)
        }else{
            btnSend.isEnabled = false
            btnSend.setTitle(String(format: NSLocalizedString("重新发送(%d秒)", comment: "重新发送(%d秒)"), leftSeconds), for: .normal)
        }
    }
    
    func sendCodeClicked() {
        guard let phone = tfPhone?.text else {
            SVProgressHUD.showError(withStatus: "请填写手机号")
            return
        }
        
        guard phone.isValidPhone() else {
            SVProgressHUD.showError(withStatus: "请填写正确手机号码")
            return
        }
        
        SVProgressHUD.show(withStatus: "正在发送验证码")
        
        tfPhone?.isUserInteractionEnabled = false
        btnSend.isEnabled = false
        leftSeconds = 60
        
        sw_dispatch_on_background_thread { 
            let dict = MDataProvider.sendAuthCode(["phone":phone])
            let code = dict?.int(forKey: "code") ?? 0
            
            sw_dispatch_on_main_thread {
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    SVProgressHUD.showSuccess(withStatus: "发送成功")
                } else {
                    let msg = dict?.object(forKey: "message") as? String
                    
                    SVProgressHUD.showError(withStatus: msg != nil ? msg : "发送失败，请稍候再试")
                }
            }
        }
    }
    
    func registerClicked() {
        guard let phone = tfPhone?.text else {
            SVProgressHUD.showError(withStatus: "请填写手机号")
            return
        }
        
        guard let auth_code = tfAuthCode?.text else {
            SVProgressHUD.showError(withStatus: "请填写验证码")
            return
        }
        
        guard let password = tfPassword?.text else {
            SVProgressHUD.showError(withStatus: "请填写密码")
            return
        }
        
        guard let password1 = tfPassword?.text else {
            SVProgressHUD.showError(withStatus: "请填写确认密码")
            return
        }
        
        guard password == password1 else {
            SVProgressHUD.showError(withStatus: "两次密码不一致")
            return
        }
        
        SVProgressHUD.show(withStatus: "正在注册账号")
        
        sw_dispatch_on_background_thread {
//            String hashed_password = HMAC.sign(message: password, algorithm: HMAC.Algorithm.sha1, key: "mosaic")
            let dict = MDataProvider.reg(["phone":phone,"auth_code":auth_code,"password":password])
            
            let code = dict?.int(forKey: "code") ?? 0
            
            sw_dispatch_on_main_thread {
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    SVProgressHUD.showSuccess(withStatus: "注册成功")
                    
                    let profile = dict?.object(forKey: "data") as! NSDictionary
                    let access_token = profile.object(forKey: "access_token") as! String
                    UserDefaults.standard.setValue(access_token, forKey: "access_token")
                    UserDefaults.standard.setValue(profile, forKey: "UserInfo")
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init("LoginAccount"), object: nil)
                } else {
                    let msg = dict?.object(forKey: "message") as? String
                    SVProgressHUD.showError(withStatus: msg != nil ? msg : "注册失败，请稍候再试")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UITableView Delegate & Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FieldsCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.selectionStyle = .none
            
            let tf = UITextField()
            tf.backgroundColor = UIColor.white
            tf.font = UIFont.systemFont(ofSize: 14)
            tf.tag = 100
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(12, 0, 0)
            
            tf.adoptAutoLayout()
            cell.contentView.addSubview(tf)
            
            cell.contentView.filled(tf, mode: .both)
            
            let btn = UIButton.customButton()
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 3
            btn.setBackgroundImage(UIImage.colorImage(ProjectDefinitions.ThemeColor, size: CGSize(width: 1, height: 1)), for: .normal)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitle("发送验证码", for: .normal)
            btn.adoptAutoLayout()
            btn.tag = 101
            
            cell.contentView.addSubview(btn)
            
            cell.contentView.addConstraints("H:[btn(==86)]-12-|", views: ["btn":btn])
            cell.contentView.addConstraint(NSLayoutConstraint.heightConstraint(btn, height: 30))
            cell.contentView.addConstraint(NSLayoutConstraint.equalConstraint(btn, attribute1: .centerY, view2: cell.contentView, attribute2: .centerY))
            
            if btnSend == nil {
                btnSend = btn
                btnSend.addTarget(self, action: #selector(sendCodeClicked), for: .touchUpInside)
            }
            
        }
        
        let tf = cell.contentView.viewWithTag(100) as! UITextField
        let btn = cell.contentView.viewWithTag(101) as! UIButton
        
        btn.isHidden = 0 != indexPath.section
        
        var placeholders = ["请输入你的手机号", "验证码", "密码", "确认密码"]
        
        tf.placeholder = placeholders[indexPath.section]
        
        tf.isSecureTextEntry = false
        tf.keyboardType = .default
        
        switch indexPath.section {
        case 0:
            tfPhone = tf
            tf.keyboardType = .phonePad
        case 1:
            tfAuthCode = tf
            tf.keyboardType = .numberPad
        case 2:
            tfPassword = tf
            tf.isSecureTextEntry = true
        case 3:
            tfPassword1 = tf
            tf.isSecureTextEntry = true
            
        default:
            ()
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}
