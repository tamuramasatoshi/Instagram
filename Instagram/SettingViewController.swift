//
//  SettingViewController.swift
//  Instagram
//
//  Created by 田村尚利 on 2018/12/21.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import SVProgressHUD

class SettingViewController: UIViewController {
    
    @IBOutlet weak var displayNametextField: UITextField!
    
    @IBAction func handleChangeButton(_ sender: Any) {
        if let displayName = displayNametextField.text{
            //表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }
        
        //表示名を設定する
        let user = Auth.auth().currentUser
            if let user =  user {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: "表示に失敗しました")
                print("DEBUG_PRINT:" + error.localizedDescription)
                return
            }
            print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                
                //HUDで完了を知らせてくれる
                SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
            
        }
    }
}
//キーボードを閉じる
self.view.endEditing(true)
}

 //ログアウトボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLogoutButton(_ sender: Any) {
        //ログアウトする
    try!Auth.auth().signOut()
        //ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        //ログイン画面を戻ってきた時のためにホーム画面（index = 0)を選択している状態にしておく
        let tabBarController = parent as! ESTabBarController

        tabBarController.setSelectedIndex(0,animated: false)
        
   
    
}
override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //表示名を取得してTextFieldに設定する
    let user = Auth.auth().currentUser
    if let user = user {
        displayNametextField.text = user.displayName
    }
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
 
 */

}
