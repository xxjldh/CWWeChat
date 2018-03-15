//
//  CWLoginController.swift
//  CWWeChat
//
//  Created by wei chen on 2017/4/3.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit
import MBProgressHUD
import ChatClient
import RxSwift
import RxCocoa

/// 登录界面
class CWLoginController: UIViewController {
    
    let disposeBag = DisposeBag()

    lazy var userNameTextField: UITextField = {
        let userNameTextField = UITextField()
        
        userNameTextField.font = UIFont.systemFont(ofSize: 15)
        userNameTextField.placeholder = "微信号/邮箱地址/QQ号"
        userNameTextField.leftViewMode = .always
        userNameTextField.keyboardType = .asciiCapable
        userNameTextField.returnKeyType = .next
        userNameTextField.spellCheckingType = .no
        userNameTextField.delegate = self
        userNameTextField.leftView = self.leftView("帐号")
        return userNameTextField
    }()
    
    lazy var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.placeholder = "请填写密码"
        passwordTextField.leftViewMode = .always
        passwordTextField.returnKeyType = .done
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.leftView = self.leftView("密码")
        return passwordTextField
    }()
    
    /// 登录按钮
    var loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("登录", for: UIControlState())
        loginButton.commitStyle()
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "使用账号和密码登录"
        self.view.backgroundColor = UIColor.white
        setupUI()
        setupNavigationBar()
        setupRx()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let whiteImage = UIImage.size(CGSize(width: 1, height: 1)).color(UIColor.white).image

        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(whiteImage, for: .default)
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
                          NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.5)]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        let backItem = UIBarButtonItem(image: UIImage(named: "backBarItemImage"), style: .done, target: self, action: #selector(cancelBarItemAction))
        self.navigationItem.leftBarButtonItem = backItem

    }
    
    func setupUI() {
        
        let margin: CGFloat = 20
        //账号和密码
        self.view.addSubview(userNameTextField)
        userNameTextField.snp.makeConstraints { (make) in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.height.equalTo(45)
            make.top.equalTo(30+64)
        }
        
        self.view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.height.equalTo(45)
            make.top.equalTo(userNameTextField.snp.bottom).offset(4)
        }
        
        //登录按钮
        self.view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        loginButton.isEnabled = false
        loginButton.snp.makeConstraints { (make) in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.height.equalTo(44)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
        }
        
        self.userNameTextField.text = "haohao"
//        self.passwordTextField.text = "1234567"
    }
    
    func setupRx() {
        let nickNameValid = userNameTextField.rx.text.orEmpty.map { (text) -> Bool in
            let tLength = text.count
            return tLength >= 3 && tLength <= 50
            }.share(replay: 1)
        
        let passwordValid = passwordTextField.rx.text.orEmpty.map { (text) -> Bool in
            let tLength = text.count
            return tLength >= 3 && tLength <= 50
            }.share(replay: 1)
        
        Observable.combineLatest(nickNameValid, passwordValid) {$0 && $1}.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
    }
    
    func leftView(_ text: String) -> UIView {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 15)
        textLabel.textColor = UIColor.black
        leftView.addSubview(textLabel)
        return leftView
    }
    
    // MARK: 点击事件
    @objc func cancelBarItemAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //
    @objc func loginButtonAction() {
        
        self.view.endEditing(true)
        
        let userName = userNameTextField.text!
        let password = passwordTextField.text!
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
//        hud.contentColor = UIColor.white
//        hud.bezelView.backgroundColor = UIColor.gray
        hud.label.text = "Loading..."
        
        let chatClient = ChatClient.share
        chatClient.initialize(with: ChatClientOptions.default)
        chatClient.loginManager.login(username: userName, password: password) { (username, error) in
           
            DispatchQueue.main.async(execute: {
                hud.mode = .text
                if error == nil {
                    do {
                        let account = CWAccount(username: "haohao", password: "1234567")
                        account.isLogin = true
                        try account.save()
                    } catch {
                        log.error("保存account出错..")
                    }
               
                    // 登陆成功
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.loginSuccess()
                    
                    hud.hide(animated: true)
                } else {
                    hud.label.text = error?.error
                    hud.hide(animated: true, afterDelay: 1.0)
                }
            })
  
        }
        
    }
    
    //
    func loginSuccess() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        log.debug("\(self.classForCoder)销毁")
    }
}


extension CWLoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
            return false
        }
            // 如果是密码 还需要判断
        else if textField == passwordTextField {
            
        }
        return true
    }
    
}