//
//  HomeViewController.swift
//  Instagram
//
//  Created by 田村尚利 on 2018/12/21.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var postArray: [PostData] = []
    
    //DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブルの高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        //テーブル行の高さの概算値を設定しておく
        //高さ概算値　＝　「縦横比1:1のUIimageViewの高さ(=画質幅)」＋　「いいねボタン、キャプションラベル、その他余白の高さの合計概算値（＝100pt）」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                //要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    //PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at:0)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                        
                    }
                })
                
                //要素が変更されたら当該のデータをpostArrayから一度削除した後に新しいデータを追加してtableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangeイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //postDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        //保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        //差し替えるために一旦削除する
                        self.postArray.remove(at: index)
                        
                        //削除したところで更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                //DataBaseのobserveEventが上記コードにより登録されたため
                //trueとする
                observing = true
            }
        }else {
            if observing == true {
                //ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                //テーブルをクリアする
                postArray = []
                tableView.reloadData()
                //オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                //DatabaseのobserveEventが上記コードにより解除されたため
                //falseとする
                observing = false
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        //セル内のボタンをアクションをソースコードで設定する
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //セル内のボタンをタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                //すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        //削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                        
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            //増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    
    //セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton,forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメントボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let uid = Auth.auth().currentUser?.displayName
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        let cell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        
        let commentText = "\(uid!) : \(cell.commentTextField.text!)"
    
    
            //コメントを追加
        postData.comments.append(commentText)
        
        //増えたコメントをfirebaseに保存する
        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
        let comments = ["comments": postData.comments]
        postRef.updateChildValues(comments)
        
        cell.commentTextField.text = ""
        
    }
    
}


