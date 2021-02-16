//
//  BasicInfoTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/16/20.
//

import UIKit

protocol BasicInfoCellDelegate: class {
    func didClickOnEditImage()
    func didTapOnUserImage(user: User?, image: UIImage?)
    func reloadFollowCount()
}

class BasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOtherInfo: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    weak var delegate: BasicInfoCellDelegate?
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        btnFollow.layer.cornerRadius = 4
        btnFollow.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 28
        profileImage.layer.masksToBounds = true        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(user: User) {
        self.user = user
        lblName.text = user.fullName
        
        //Dokolku propertito e nil ke ja zeme desnata vrednost odnosno "defaultValue" (variable ?? defaultValue
        lblOtherInfo.text = (user.gender ?? "") + ", " + (user.location ?? "")
        if let imageUrl = user.imageUrl {
            profileImage.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "userPlaceholder"))
        }
        
        guard let localUser = DataStore.shared.localUser else {
            return
        }
        
        if user.id != localUser.id {
            if FollowManager.shared.following.contains(where: { $0.userId == user.id }) {
                setButtonTitle(title: "Following")
            } else {
                setButtonTitle(title: "Follow")
            }
        } else {
            btnFollow.isHidden = true
        }
    }
    
    func setButtonTitle(title: String) {
        btnFollow.setTitle(title, for: .normal)
        if title == "Follow" {
            btnFollow.backgroundColor = UIColor(named: "MainPink")
            btnFollow.setTitleColor(UIColor.white, for: .normal)
        } else {
            btnFollow.backgroundColor = UIColor(hex: "FF6265").withAlphaComponent(0.2)
            btnFollow.setTitleColor(UIColor(named: "MainPink"), for: .normal)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.delegate?.reloadFollowCount()
        }
    }
    
    @IBAction func onEditImage(_ sender: UIButton) {
        if let user = user, user.id == DataStore.shared.localUser?.id {
            delegate?.didClickOnEditImage()
        } else {
            delegate?.didTapOnUserImage(user: user, image: profileImage.image)
        }
    }
    
    @IBAction func onFollow(_ sender: UIButton) {
        guard let user = user else { return }
        
        if FollowManager.shared.following.contains(where: {$0.userId == user.id}) {
            unFollowUser(user)
            return
        }
        followUser(user)
    }
    
    private func followUser(_ user: User ) {
        FollowManager.shared.followUser(user: user) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if success {
                self.setButtonTitle(title: "Following")
            }
        }
    }
    
    private func unFollowUser(_ user: User) {
        FollowManager.shared.unFollowUser(user: user) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if success {
                self.setButtonTitle(title: "Follow")
            }
        }
    }
    
}
