//
//  PostViewController.swift
//  Instagram
//
//  Created by 田村尚利 on 2018/12/21.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    
    //投稿ボタンをタップした時に呼ばれるメソッド
    @IBAction func handlePosButton(_ sender: UIButton) {
    //ImageViewから画像を取得する
    let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
    let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
    //postDataに必要な情報を取得しておく
    let time = Date.timeIntervalSinceReferenceDate
        
    let name = Auth.auth().currentUser?.displayName
        
    //辞書を作成してFirebaseに保存する
    let postRef = Database.database().reference().child(Const.PostPath)
    let postDic = ["caption": textField.text!, "image": imageString, "time": String(time), "name": name!]
    postRef.childByAutoId().setValue(postDic)

    //hudで投稿完了する
    SVProgressHUD.showSuccess(withStatus: "投稿しました")
    
    //全てのモーグルを閉じる
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    //キャンセルボタンをタップした時に呼ばれるメソッド
    
    @IBAction func handleCancelButton(_ sender: Any) {
        //画面を閉じる
    dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //受け取った時画像をImageViewに設定する
        imageView.image = image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
