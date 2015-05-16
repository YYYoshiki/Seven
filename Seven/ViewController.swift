//
//  ViewController.swift
//  Seven
//
//  Created by 指山喜伎 on 2015/02/19.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {


    @IBOutlet weak var comment: UITextField!
    var ActiveField = UITextField()
    //テキストフィールドの編集開始時に編集対象の情報を保持
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool{
        ActiveField = textField
        return true
    }
    //キーボードのリターンキーを押された時にキーボードを閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
//    //キーボードが表示された時の処理
//    func handleKeyboardWillShowNotification(notification: NSNotification){
//        let userInfo = notification.userInfo!
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
//        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
//        
//        let txtLimit = txtActiveField.frame.origin.y + txtActiveField.frame.height + 8.0
//        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
//        
//        if txtLimit >= kbdLimit {
//     //       mainView.contentOffset.y = txtLimit - kbdLimit
//        }
//    }
//    
//    func handleKeyboardWillHideNotification(notification: NSNotification) {
//     //   tableView.contentOffset.y = 0
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

