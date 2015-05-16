//
//  globalViewController.swift
//  Seven
//
//  Created by 指山喜伎 on 2015/02/24.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

import UIKit

class globalViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource, PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate{
    var comments :NSMutableArray = NSMutableArray()
    var refreshControl:UIRefreshControl!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var daiSeven: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tabItem: UITabBarItem!
    var countNum = 60
    var timer = NSTimer()
    var waitSeconds:String!
    //60秒を数える
    func update(){
        dispatch_async_global { // ここからバックグラウンドスレッド
            self.countNum--
            if self.countNum <= 0 {
                self.countNum = 0
            }
        }
        self.comment.placeholder = "次はだいたい\(countNum)s待ってね"
    }
    @IBAction func sendButton(sender: UIButton) {
        self.view.endEditing(true)
        if PFUser.currentUser() == nil{
            login()
        }else{
        if comment.text != "" && count("\(comment.text)") < 8{
            // Unwrap the current object object
            var object = PFObject(className:"Comment")
            object["comment"] = comment.text.stringByReplacingOccurrencesOfString(" ", withString: "ｗ", options: nil, range: nil)
            //誰がコメントしたか判別するためにuserの固有IDをコメントに紐付ける
            object["userId"] = PFUser.currentUser().objectId
            object["userName"] = PFUser.currentUser().username
            // Save the data back to the server in a background task
            object.saveEventually(nil)
            //コメント欄を空白にする
            comment.text = ""
            usleep(300000)
            self.loadData()
            self.tableView.reloadData()
            //連投禁止
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            self.sendBtn.enabled = false
            self.comment.enabled = false
            let delay = countNum * Int(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.timer.invalidate()
                self.countNum = 60
                self.sendBtn.enabled = true
                self.comment.enabled = true
                self.comment.placeholder = "7文字以内でトピックを作る"
            })
        }else{
            comment.textColor = UIColor.redColor()
        }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue){}
    
    //アクティブキーボードを見つける
    var txtActiveField = UITextField()
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtActiveField = textField
        txtActiveField.textColor = UIColor.blackColor()
        return true
    }
    //returnが押されるとキーボードを閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if PFUser.currentUser() == nil{
            comment.enabled = false
            comment.placeholder = "投稿するにはログイン!"
            sendBtn.setTitle("Login", forState: .Normal)
        }else{
            comment.enabled = true
            comment.placeholder = "7文字以内でトピックを作る"
            sendBtn.setTitle("◯", forState: .Normal)
            ngUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilityCheck () //通信状態チェック
        startIndicator() //activityIndicator start
        daiSeven.font = UIFont(name: "Courier New", size: 25)
        //viewの色を設定
        view.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        tableView.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        //cellの境界線を消す
        tableView.separatorColor = UIColor.clearColor()
        //送信ボタンのカスタマイズ
        sendBtn.setTitle("◯", forState: .Normal)
        sendBtn.setTitleColor(UIColor.whiteColor(), forState:.Normal)
        sendBtn.backgroundColor = UIColor.hexStr("16A6B6", alpha: 1)
        sendBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
        // 枠を丸くする.
        sendBtn.layer.masksToBounds = true
        sendBtn.layer.cornerRadius = 10.0
        //parseからデータ取得
        self.loadData()
        // DataSourceの設定をする.
        tableView.dataSource = self
        
        // Delegateを設定する.
        tableView.delegate = self
        
        //引っ張って更新
        self.pullrefresh()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        
        if PFUser.currentUser() != nil{
            ngUser()
        }
    }
    
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                bottomConstraint.constant = keyboardHeight - 35
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        bottomConstraint.constant = 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //parseからデータ取得
    func loadData() {
        //objectを初期化
        comments.removeAllObjects()
        //cloud codeからgetQuery関数の呼び出し
        PFCloud.callFunctionInBackground("GetQuery", withParameters:["test":"test"], block: {
            (objects: AnyObject!, error: NSError!) -> Void in
            if (error != nil){
                //error処理
            }
            // Task
            //PFObjectのcommentsにparseのデータを収納
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // Task
                if let objectbox: AnyObject = objects{
                    for object in objectbox as! [AnyObject]{
                        self.comments.addObject(object)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    // UI
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
            }
        })
    }
    
    //引っ張って更新関数
    func pullrefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    //更新のデータ取得方法
    func refresh(sender:AnyObject)
    {
        self.loadData()
        //refreshを終える
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    /*
    Cellの総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Cellの.を取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        // Cellに値を設定する.
        var cellComments = self.comments[indexPath.row].objectForKey("comment") as? String
        var cellName = self.comments[indexPath.row].objectForKey("userName") as? String
        // Tag番号 1 で UILabel インスタンスの生成
        var nameLabel = tableView.viewWithTag(1) as! UILabel
        nameLabel.text = "@" + cellName!
        nameLabel.textColor  = UIColor.whiteColor()
        // Tag番号 ２ で UILabel インスタンスの生成
        var commentLabel = tableView.viewWithTag(2) as! UILabel
        commentLabel.text = cellComments
        commentLabel.font = UIFont.systemFontOfSize(40.0)
        commentLabel.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cellの色を指定
        if indexPath.row % 4 == 0 || indexPath.row == 0 {
            cell.backgroundColor = UIColor.hexStr("16A6B6", alpha: 1)
        }else if indexPath.row % 4 == 1 || indexPath.row == 1 {
            cell.backgroundColor = UIColor.hexStr("58BE89", alpha: 1)
        }else if indexPath.row % 4 == 2 || indexPath.row == 2 {
            cell.backgroundColor = UIColor.hexStr("FBA848", alpha: 1)
        }else if indexPath.row % 4 == 3 || indexPath.row == 3 {
            cell.backgroundColor = UIColor.hexStr("F58E7E", alpha: 1)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // セグエの特定
        var reCommentScene = segue.destinationViewController as! RecommentViewController
        
        // データをReCommentControllerに渡す
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let row = Int(indexPath.row)
            reCommentScene.currentObject = comments[row] as? PFObject
        }
    }

    func reachabilityCheck () {
        if Reachability.isConnectedToNetwork() {
           // println("正常な電波状況です")
        } else {
            let alert = UIAlertView()
            alert.title = "通信エラー"
            alert.message = "通信状況がよくありません。電波環境を確認後、再度お試しください。"
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        
        
    }
    
    func ngUser(){
        //NGユーザー判別
        var Nquery:PFQuery = PFQuery(className: "ngUser")
        Nquery.orderByDescending("createdAt")
        Nquery.findObjectsInBackgroundWithBlock{(objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil){
                //error処理
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // Task
                for object in objects {
                    if PFUser.currentUser().username == object["userName"] as? String{
                        println("error")
                        let alerts = UIAlertView(title: "規制中", message: "あなたは規制中です。\nこの件に関して、疑問なことがありましたら、お問い合わせ下さい。\nsevenboyandgirl＠gmail.com", delegate: self, cancelButtonTitle: "OK")
                        PFUser.logOut()
                        self.dismissViewControllerAnimated(true, completion: {alerts.show()})
                    }
                }
                
            }
        }
 
    }
    
    func startIndicator(){
        activityIndicator.hidden = false //activityindicatorを表示
        activityIndicator.startAnimating() //activityindicatorのアニメーションを始める
    }
    
    func stopIndicator(){
        activityIndicator.hidden = true //activityindicatorを表示
        activityIndicator.stopAnimating() //activityindicatorのアニメーションを始める
    }
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
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


}


extension UIColor {
    class func hexStr (var hexStr : NSString, var alpha : CGFloat) -> UIColor {
        hexStr = hexStr.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.whiteColor();
        }
    }
}




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


