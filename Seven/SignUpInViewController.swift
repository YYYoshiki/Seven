//
//  SignUpInViewController.swift
//  Seven
//
//  Created by 指山喜伎 on 2015/02/27.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

import UIKit

class SignUpInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var daiSeven: UILabel!
    @IBOutlet weak var bgImg: UIImageView!
    override func viewDidAppear(animated: Bool) {
        self.view.sendSubviewToBack(bgImg)
        bgImg.alpha = 0.08
        view.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        daiSeven.font = UIFont(name: "Courier New", size: 40)
        daiSeven.textColor = UIColor.hexStr("737373", alpha: 1)
        loginBtn.backgroundColor = UIColor.hexStr("F58E7E", alpha: 1)
        loginBtn.layer.masksToBounds = true
        if PFUser.currentUser() == nil{
            
        }else{
            self.performSegueWithIdentifier("login", sender: self)
        }
        //ログインしていない場合
        if PFUser.currentUser() == nil{
            loginLabel.text = "たった7文字で思いを伝える"
            loginLabel.textColor = UIColor.hexStr("737373", alpha: 1)
            loginBtn.setTitle("ようこそ", forState: .Normal)
            loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            loginLabel.text = "\(PFUser.currentUser().username)　ログイン中"
            loginBtn.setTitle("logout", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginOrLogout(sender: AnyObject) {
        if PFUser.currentUser() == nil{
            self.performSegueWithIdentifier("login", sender: self)
//            login()
        } else {
            logout()
        }
    }
    
    //ログイン処理
    func login(){
        // Customize the LogInViewController
        let login = PFLogInViewController()
        login.delegate = self
        login.fields = (PFLogInFields.UsernameAndPassword
        | PFLogInFields.LogInButton
        | PFLogInFields.SignUpButton
      //  | PFLogInFields.Facebook
      //  | PFLogInFields.Twitter
        | PFLogInFields.PasswordForgotten
        | PFLogInFields.DismissButton)
        
        //login画面のカスタマイズ
        //ロゴ
        let myLabel: UILabel = UILabel(frame: CGRectMake(0,0,221.5,68))
        myLabel.text = "Seven"
        myLabel.font = UIFont(name: "Courier New", size: 65)
        myLabel.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        myLabel.textColor = UIColor.hexStr("737373", alpha: 1)
        // 枠を丸くする.
        myLabel.layer.masksToBounds = true
        // コーナーの半径.
        myLabel.layer.cornerRadius = 10.0
        login.logInView.logo = myLabel
       // println(login.logInView.logo)
        //背景
        login.view.backgroundColor =  UIColor.hexStr("F5F1E9", alpha: 1.0)        //fieldのカスタマイズ
        login.logInView.usernameField.placeholder = "ニックネーム"
        login.logInView.passwordField.placeholder = "パスワード"
        //ボタンのカスタマイズ
        login.logInView.logInButton.setTitle("ログイン", forState: .Normal)
        login.logInView.logInButton.backgroundColor = UIColor.hexStr("F58E7E", alpha: 1)
        login.logInView.signUpButton.setTitle("登録する", forState: .Normal)
        //押された時
        login.logInView.logInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        //パスワードを忘れた時のボタン
        login.logInView.passwordForgottenButton.setTitle("パスワードを忘れた方はこちら", forState: .Normal)
        login.logInView.passwordForgottenButton.setTitleColor(UIColor.hexStr("737373", alpha: 1), forState: .Normal)
        // Customize the SignUpViewController
        let signup = PFSignUpViewController()
        signup.fields = (PFSignUpFields.UsernameAndPassword
            | PFSignUpFields.SignUpButton
            | PFSignUpFields.Email
            | PFSignUpFields.DismissButton)
        signup.delegate = self
        login.signUpController = signup
        //ロゴ
        let seLabel: UILabel = UILabel(frame: CGRectMake(0,0,221.5,68))
        seLabel.text = "Seven"
        seLabel.font = UIFont(name: "Courier New", size: 65)
        seLabel.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        seLabel.textColor = UIColor.hexStr("737373", alpha: 1)
        // 枠を丸くする.
        seLabel.layer.masksToBounds = true
        // コーナーの半径.
        seLabel.layer.cornerRadius = 10.0

        signup.signUpView.logo = seLabel
        //背景
        signup.view.backgroundColor =  UIColor.hexStr("F5F1E9", alpha: 1.0)
        //fieldのカスタマイズ
        signup.signUpView.emailField.font = UIFont(name:"Helvetica",size:14.5)
        signup.signUpView.usernameField.placeholder = "ニックネーム(6文字以内です)"
        signup.signUpView.passwordField.placeholder = "パスワード(6文字以上です)"
        signup.signUpView.emailField.placeholder = "メールアドレス(パスワード紛失時に必要)"
        signup.signUpView.signUpButton.setTitle("登録する", forState: .Normal)
        self.presentViewController(login, animated: true, completion: nil)
        
    }
    
    // ログアウト処理
    func logout() {
        PFUser.logOut()
        loginLabel.text = "たった7文字で思いを伝える"
        loginBtn.setTitle("ようこそ", forState: .Normal)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        //ユーザー名とパスワードのチェック
        if !username.isEmpty && !password.isEmpty{
            return true
        }
        let alert = UIAlertView(title: "認証エラー", message: "ユーザー名もしくはパスワード入力が間違っています", delegate: self, cancelButtonTitle: "キャンセル")
        alert.show()
        return false
    }
    
    //画面を閉じるボタンをおした時の処理
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Failed to log in...")
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        println("User dismissed the logInViewController")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!,
        shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
            let username = info?["username"] as? String
            let password = info?["password"] as? String
            // パスワードが６文字以下はNG
            if count(password!.utf16) < 6 {
                let alert = UIAlertView(title: "登録エラー", message: "パスワードは6文字以上にして下さい", delegate: self
                    , cancelButtonTitle: "キャンセル")
                alert.show()
                return false
            }
            if count(username!.utf16) > 6{
                let alerts = UIAlertView(title: "登録エラー", message: "ニックネームは6文字以内にして下さい", delegate: self, cancelButtonTitle: "キャンセル")
                alerts.show()
                return false
            }
            
            return true
    }
    
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up...")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


