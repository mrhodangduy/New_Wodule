//
//  SplashScreenVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/30/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notifiLabel: UILabel!
    
    let username = userDefault.object(forKey: USERNAMELOGIN) as? String
    let password = userDefault.object(forKey: PASSWORDLOGIN) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicator.hidesWhenStopped = true
        notifiLabel.isHidden = true
        self.loadingIndicator.startAnimating()
        
        
        if Connectivity.isConnectedToInternet
        {
            if username != nil && password != nil
            {
                self.notifiLabel.isHidden = false
            }
            
            self.perform(#selector(self.onHanldeAutoLogin), with: self, afterDelay: 1)
            
        }
        else
        {
            self.loadingIndicator.stopAnimating()
            displayAlertNetWorkNotAvailable()
            NotificationCenter.default.addObserver(self, selector: #selector(self.onHanldeAutoLogin), name: NSNotification.Name.available, object: nil)
        }
        
        print("username:", username as Any, "password:", password as Any)
        
    }
    
    func onHanldeAutoLogin()
    {
        
        if self.loadingIndicator.isAnimating == false
        {
            self.loadingIndicator.startAnimating()
        }
        if username == nil && password == nil
        {
            let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: true)
            
        }
        else
        {
            self.notifiLabel.isHidden = false
            self.onHandleLogin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("WILL APPEAR..........")
        super.viewWillAppear(animated)
        super.navigationController?.isNavigationBarHidden = true
        
        print(userDefault.object(forKey: TOKEN_STRING) as? String as Any)
        print(userDefault.object(forKey: SOCIALKEY) as? String as Any)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.loadingIndicator.stopAnimating()
        NotificationCenter.default.removeObserver(self)
    }
    
    func onHandleLogin()
    {
        DispatchQueue.global(qos: .default).async(execute: {
            UserInfoAPI.LoginUser(username: self.username!, password: self.password!, completion: { (status) in
                
                if status != nil && status!
                {
                    let token = userDefault.object(forKey: TOKEN_STRING) as? String
                    
                    UserInfoAPI.getUserInfo(withToken: token!, completion: { (userinfo) in
                        
                        if userinfo!["type"] as? String == UserType.assessor.rawValue
                        {
                            let assessor_homeVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessor_homeVC") as! Assessor_HomeVC
                            
                            assessor_homeVC.userInfomation = userinfo!
                            autologin = true
                            
                            self.navigationController?.pushViewController(assessor_homeVC, animated: true)
                        }
                        else
                        {
                            let examiner_homeVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "examiner_homeVC") as! Examiner_HomeVC
                            
                            examiner_homeVC.userInfomation = userinfo!
                            autologin = true
                            
                            self.navigationController?.pushViewController(examiner_homeVC, animated: true)
                        }
                        print("-----> LOGIN SUCCESSFUL")
                    })
                    
                }
                else
                {
                   
                    print("-----> AUTOLOGIN FALED")
                    let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
                    self.navigationController?.pushViewController(loginVC, animated: false)
                    
                }
                
            })
            
        })
    }
}
