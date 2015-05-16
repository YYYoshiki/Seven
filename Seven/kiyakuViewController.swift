//
//  kiyakuViewController.swift
//  Seven
//
//  Created by 指山喜伎 on 2015/03/27.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

import UIKit

class kiyakuViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!

    @IBAction func agree(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func disAgree(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStr("F5F1E9", alpha: 1.0)
        // 表示させるテキストを設定する.
        textView.text = "皆さんに楽しく当アプリを使っていただくために、私達は利用規約を設けています。\n\n当規約に同意の上、当アプリをご利用いただくようお願いします。\n\nこのアプリには一時的に不適切な発言が、表示されることがあるかもしれません。不適切な発言を見つけた場合は報告をお願いします。早急に対処いたします。\n\nまた、不適切な発言をした者は、ログイン出来ないようにする処理をすることがあります。\n\nこの利用規約に違反した者も上記と同じ処理をさせて頂く場合があります。\n\n2015/3/27\nSeven.team一同"
        // 角に丸みをつける.
        textView.layer.masksToBounds = true
        
        // 丸みのサイズを設定する.
        textView.layer.cornerRadius = 20.0
        
        // 枠線の太さを設定する.
        textView.layer.borderWidth = 1
       
        // 枠線の色を黒に設定する.
        textView.layer.borderColor = UIColor.whiteColor().CGColor
        
        // テキストを編集不可にする.
        textView.editable = false
        // Do any additional setup after loading the view.
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
