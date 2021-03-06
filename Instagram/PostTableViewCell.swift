//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 田村尚利 on 2019/01/03.
//  Copyright © 2019 masatoshi.tamura. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //Firebaseからデータを新たに取ってくる。
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData) {
        self.postImageView.image = postData.image
        
        // let displayName = postData.displayName
        
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        var commentString = ""
        
        let comments = postData.comments
        
        for c in comments {
            commentString += "\(c)\n"
            
            self.commentLabel.text = "\(commentString)"
            
        }
        
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let  formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
    
}
