//
//  ShopViewController.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var shopInfo: [String:Any]! = ["shop_id":"1","name":"遵义羊肉粉"]
    
    let tfPrice = UITextField()
    let lblPrice = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 24), textColor: UIColor.black)

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBack()
        addBGColor()
        setNavTitle(shopInfo?["name"] as? String)
        // Do any additional setup after loading the view.
        
        let imgvAvatar = UIImageView()
        imgvAvatar.clipsToBounds = true
        imgvAvatar.layer.borderWidth = 1
        imgvAvatar.layer.borderColor = UIColor.lightGray.cgColor
        imgvAvatar.adoptAutoLayout()
        imgvAvatar.layer.cornerRadius = 50
        view.addSubview(imgvAvatar)
        
        
        tfPrice.delegate = self
        tfPrice.backgroundColor = UIColor.white
        tfPrice.clipsToBounds = true
        tfPrice.layer.cornerRadius = 5
        tfPrice.keyboardType = .numberPad
        tfPrice.textAlignment = .center
        tfPrice.placeholder = "请输入要支付的金额"
        tfPrice.adoptAutoLayout()
        view.addSubview(tfPrice)
        
        let lbl = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 12), textColor: UIColor.lightGray)
        lbl.text = "优惠后"
        lbl.adoptAutoLayout()
        view.addSubview(lbl)
        
        
        lblPrice.textAlignment = .center
        lblPrice.adoptAutoLayout()
        view.addSubview(lblPrice)
        lblPrice.text = "0.00"
        
        let tvPayments = UITableView()
        tvPayments.backgroundColor = UIColor.clear
        tvPayments.delegate = self
        tvPayments.dataSource = self
        tvPayments.adoptAutoLayout()
        tvPayments.separatorStyle = .none
        view.addSubview(tvPayments)
        
        let views = ["avatar":imgvAvatar, "price":tfPrice, "lbl": lbl, "discounted":lblPrice, "payments": tvPayments]
        
        
        
        view.addConstraints("V:|-18-[avatar(==100)]-12-[price(==46)]-8-[lbl]-12-[discounted]-30-[payments]|", views: views)
        
        view.addConstraint(NSLayoutConstraint.squareConstraint(imgvAvatar))
        view.addConstraint(NSLayoutConstraint.equalConstraint(imgvAvatar, attribute1: .centerX, view2: view, attribute2: .centerX))
        
        view.addConstraints("H:|-28-[price]-28-|", views: views)
        view.filled(tvPayments, mode: .width)
        
        view.addConstraint(NSLayoutConstraint.equalConstraint(lbl, attribute1: .centerX, view2: view, attribute2: .centerX))
        view.addConstraint(NSLayoutConstraint.equalConstraint(lblPrice, attribute1: .centerX, view2: view, attribute2: .centerX))
    }
    
    func updateDiscountedPrice(_ str: String) {
        var params = shopInfo
        params?["price"] = str
        
        MDataProvider.getDiscountedPrice(params as NSDictionary?, completionBlock: { (code: Int, data:Any?, message: String?) in
            if SWDefinitions.RETURN_SUCCESS_CODE == code {
                if let price = (data as? NSDictionary)?.double(forKey: "price") {
                    self.lblPrice.text = String(format: "%.2f", price)
                } else {
                    self.lblPrice.text = str
                }
            } else {
                self.lblPrice.text = str
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - UITableView Delegate & Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "PaymentsCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.selectionStyle = .none
            
            let lbl = UILabel.create(CGRect.zero, font: UIFont.systemFont(ofSize: 14), textColor: ProjectDefinitions.ThemeColor)
            lbl.backgroundColor = UIColor.white
            lbl.tag = 100
            lbl.textAlignment = .center
            lbl.adoptAutoLayout()
            cell.contentView.addSubview(lbl)
            
            cell.contentView.filled(lbl, mode: .both)
        }
        
        let lbl = cell.contentView.viewWithTag(100) as! UILabel
        
        var payments = ["余额支付", "支付宝支付", "微信支付"]
        
        lbl.text = payments[indexPath.section]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let price = tfPrice.text else {
            SVProgressHUD.showError(withStatus: "请输入金额")
            return
        }
        
        guard (price as NSString).floatValue > 0 else {
            SVProgressHUD.showError(withStatus: "请输入正常金额")
            return
        }
        
        if 2 == indexPath.section {
            OAAlertView.show(nil, message: "即将开通", cancel: nil)
            return
        }
        
        SVProgressHUD.show(withStatus: "正在支付")
        switch indexPath.section {
        case 0:
            
            var orderInfo = shopInfo
            orderInfo?["price"] = price
            MDataProvider.makePurchase(orderInfo as NSDictionary?, completionBlock: { (code: Int, data: Any?, message: String?) in
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    SVProgressHUD.showSuccess(withStatus: "支付成功")
                    
                    //  return to home
                } else {
                    SVProgressHUD.showError(withStatus: message != nil ? message : "支付失败，请稍候再重试")
                }
            })
        case 1:
            var orderInfo = shopInfo
            orderInfo?["price"] = tfPrice.text
            orderInfo?["pay_type"] = "alipay"
            SVProgressHUD.show(withStatus: "")
            MDataProvider.getOrder(orderInfo as NSDictionary?, completionBlock: { (code: Int, data: Any?, message: String?) in
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    self.rechargeViaAlipay(data as! NSDictionary)
                    SVProgressHUD.dismiss()
                    //  return to home
                } else {
                    SVProgressHUD.showError(withStatus: message != nil ? message : "支付失败，请稍候再重试")
                }
            })
        case 2:
            var orderInfo = shopInfo
            orderInfo?["price"] = tfPrice.text
            orderInfo?["pay_type"] = "wxpay"
            MDataProvider.makePurchase(orderInfo as NSDictionary?, completionBlock: { (code: Int, data: Any?, message: String?) in
                if SWDefinitions.RETURN_SUCCESS_CODE == code {
                    self.rechargeViaWxpay(data as! NSDictionary)
                    SVProgressHUD.dismiss()
                    //  return to home
                } else {
                    SVProgressHUD.showError(withStatus: message != nil ? message : "支付失败，请稍候再重试")
                }
            })
        default:
            ()
        }
    }
    
    //  MARK: - UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = textField.text ?? ""
        
        str = (str as NSString).replacingCharacters(in: range, with: string)
        
        lblPrice.text = nil
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(updateDiscountedPrice(_:)), with: str, afterDelay: 0.5)

        return true
    }
    
    //  MARK: - Payments
    func rechargeViaAlipay(_ orderInfo: NSDictionary){
        if let order_string = orderInfo.object(forKey: "order_string") as? String{
            AlipaySDK.defaultService().payOrder(order_string, fromScheme: "greendot.alipay", callback: { (resultDic: [AnyHashable: Any]?) -> Void in
                if resultDic != nil{
                    let resultStatus = Int((resultDic?["resultStatus"] as? String) ?? "" ) ?? 0
                    
                    if 9000 == resultStatus{
                        OAAlertView.show(nil, message: "支付成功", cancel: nil)
                    }else{
                        var msg = "支付失败"
                        
                        switch resultStatus{
                        case 4000:
                            msg = NSLocalizedString("支付失败", comment: "支付失败")
                        case 6001:
                            msg = NSLocalizedString("支付已取消", comment: "支付已取消")
                        case 6002:
                            msg = NSLocalizedString("网络连接出错", comment: "网络连接出错")
                        default:()
                        }
                        
                        if let memo = resultDic?["memo"] as? String{
                            OAAlertView.show(nil, message: memo.length > 0 ? memo : msg, cancel: nil)
                        }else{
                            OAAlertView.show(nil, message: msg, cancel: nil)
                        }
                    }
                }else{
                    OAAlertView.show(nil, message: NSLocalizedString("充值失败", comment: "充值失败"), cancel: nil)
                }
            })
        }
    }
    
    func rechargeViaWxpay(_ orderInfo: NSDictionary){
        let request = PayReq()
        
        request.partnerId = orderInfo.object(forKey: "partnerid") as? String
        request.prepayId = orderInfo.object(forKey: "prepayid") as? String
        request.package = "Sign=WXPay";
        request.nonceStr = orderInfo.object(forKey: "noncestr") as? String
        request.timeStamp = UInt32(orderInfo.int(forKey: "timestamp") ?? 0)
        request.sign = orderInfo.object(forKey: "sign") as? String
        
        SVProgressHUD.dismiss()
        
        WXApi.send(request)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }

}
