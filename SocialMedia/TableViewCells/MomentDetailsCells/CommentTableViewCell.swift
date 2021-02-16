//
//  CommentTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 14.12.20.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblComment: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let adjustedFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        lblComment.adjustsFontForContentSizeCategory = true
        lblComment.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: adjustedFont)

        // Initialization code
    }
    
    func setComment(comment: Comment) {
        lblComment.text = comment.body
        lblDate.text = Date(with: comment.createdAt!)?.timeAgoDisplay()
        
        guard let creatorId = comment.creatorId else { return }
        
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            guard let user = user else { return }
            self.lblUsername.text = user.fullName
            if let imageUrl = user.imageUrl {
                self.userImage.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
