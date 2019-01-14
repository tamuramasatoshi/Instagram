//
//  LoginViewController.swift
//  Instagram
//
//  Created by 田村尚利 on 2018/12/21.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
         //アドレスとパスワード名のいずれかでも入力されていない時は何もない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus:"必要項目を入力して下さい。")
                return
            }
            
        //HUDで処理中を表示
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password) { user,error in
                if let error = error{
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }else {
                    print("DEBUG_PRINT:ログインに成功しました。")
                    
        //HUDを消す
            SVProgressHUD.dismiss()
        //画面を閉じてviewControllerに戻る
            self.dismiss(animated: true, completion: nil)
          }
        }
      }
     }

    //アカント作成ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text,
            let displayName = displayNameTextField.text {
            
       //アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT:何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
        //HUDで処理中を表示
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする。
            Auth.auth().createUser(withEmail: address, password: password ){ user,error in
                if let error = error {
                    //エラーがあったら原因をプリントして、returnする事で以降の処理を実行せずに処理を終了する。
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "必要な項目を入力して下さい")
                    return
                }
                
               print("DEBUG_PRINT:ユーザー作成に成功しました。")
                
                //表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user{
                    let changeRequst = user.createProfileChangeRequest()
                    changeRequst.displayName = displayName
                    changeRequst.commitChanges { error in
                        if let error = error{
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT:" + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.dismiss()
                        
                        //画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
