//
//  UserTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/25/20.
//

import UIKit

protocol BlockingDelegate: class {
    func blockUser(user: User, isBlock: Bool)
    //isBlock = true if we block the user
    //isBlock = false if we unblock the user
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    
    var user: User?
    
    weak var blockingDelegate: BlockingDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(user: User) {
        self.user = user
        lblName.text = user.fullName
        if let imageUrl = user.imageUrl {
            profileImage.kf.setImage(with: URL(string: imageUrl))
        } else {
            profileImage.image = UIImage(named: "userPlaceholder")
        }
        
        guard let localUser = DataStore.shared.localUser,
              let userId = user.id else {
            return
        }

        btnBlock.isSelected = localUser.isBlockedUserWith(id: userId)
    }
    
    @IBAction func onBlock(_ sender: UIButton) {
        guard let user = user else {
            return
        }
        if btnBlock.isSelected {
            blockingDelegate?.blockUser(user: user, isBlock: false)
            btnBlock.isSelected = false
        } else {
            blockingDelegate?.blockUser(user: user, isBlock: true)
            btnBlock.isSelected = true
        }
        
        //blockingDelegate?.blockUser(user: user, isBlock: !btnBlock.isSelected)
        //btnBlock.isSelected = !btnBlock.isSelected
    }
}
