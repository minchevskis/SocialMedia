//
//  UserInfoTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 14.12.20.
//

import UIKit
import Kingfisher

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(moment: Feed) {
        guard let creatorId = moment.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            guard let user = user else { return }
            self.lblUsername.text = user.fullName
            if let imageUrl = user.imageUrl {
                self.profileImage.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }
}
