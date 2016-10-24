//
//  ProfileViewController.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBack()
        setNavTitle("个人资料")
        addBGColor()

        let tvProfile = UITableView()
        tvProfile.adoptAutoLayout()
        view.addSubview(tvProfile)
        tvProfile.delegate = self
        tvProfile.dataSource = self
        tvProfile.separatorStyle = .none
        tvProfile.backgroundColor = UIColor.clear
        
        view.filled(tvProfile, mode: .both)
        
        let btnLogout = UIButton.customButton()
        btnLogout.frame = CGRect(x: 0, y: 0, width: SWDefinitions.ScreenWidth, height: 44)

        btnLogout.setBackgroundImage(UIImage.colorImage(UIColor.init(red: 0.91, green: 0.19, blue: 0.18, alpha: 1), size: CGSize(width: 1, height: 1)), for: .normal)
        btnLogout.setTitleColor(UIColor.white, for: .normal)
        btnLogout.setTitle("注销", for: .normal)
        btnLogout.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnLogout.addTarget(self, action: #selector(logoutClicked), for: .touchUpInside)
        
        tvProfile.tableFooterView = btnLogout
    }
    
    func logoutClicked() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"LogoutAccount"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - UITableView Delegate & Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ProfileCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "余额"
            let balance = MDataProvider.myInfo()?.double(forKey: "balance") ?? 0
            cell.detailTextLabel?.text = String(format: "%.2f", balance)
            cell.accessoryType = .none
        case 1:
            cell.textLabel?.text = "历史消费记录"
        default:
            ()
        }
        
        
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let total = self.numberOfSections(in: tableView)
        
        return section == total - 1 ? 40 : 0
    }

}
