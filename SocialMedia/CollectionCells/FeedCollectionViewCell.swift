//
//  FeedCollectionViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 12/2/20.
//

import UIKit
import Kingfisher

class FeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var feedItem: Feed?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 16
        profileImage.layer.masksToBounds = true
        // Initialization code1
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        //Always when cell does reuse
        profileImage.image = nil
        lblUsername.text = nil
    }
    
    func setupCell(feedItem: Feed) {
        self.feedItem = feedItem
        feedImage.kf.setImage(with: URL(string: feedItem.imageUrl!))
        setDate(feedItem: feedItem)
        fetchCreatorDetails(feedItem: feedItem)
        
        guard let localUser = DataStore.shared.localUser,
              let likedMoments = localUser.likedMoments else { return }
        if likedMoments.contains(feedItem.id!) {
            btnLike.isSelected = true
        } else {
            btnLike.isSelected = false
        }
    }
    
    func fetchCreatorDetails(feedItem: Feed) {
        guard let creatorId = feedItem.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            if let user = user {
                self.lblUsername.text = user.fullName
                if let imageUrl = user.imageUrl {
                    self.profileImage.kf.setImage(with: URL(string: imageUrl))
                } else {
                    self.profileImage.image = UIImage(named: "userPlaceholder")
                }
            }
        }
    }
    
    func setDate(feedItem: Feed) {
        let date = Date(with: feedItem.createdAt!)
        lblDate.text = date?.timeAgoDisplay()
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
//        let string = dateFormatter.string(from: date!)
    }
    
    @IBAction func onLike(_ sender: UIButton) {
        guard let item = feedItem else { return }
        var localUser = DataStore.shared.localUser

        if btnLike.isSelected {
            //already linked
            guard let index = localUser?.likedMoments?.firstIndex(where: {$0 == item.id!}) else {
                return
            }
            localUser?.likedMoments?.remove(at: index)
        } else {
        //first time like
            if localUser?.likedMoments != nil {
                localUser?.likedMoments?.append(item.id!)
            } else {
                localUser?.likedMoments = [item.id!]
            }            
        }
        btnLike.isSelected = !btnLike.isSelected
        //save user to firebase
        localUser?.save(completion: nil)
    }
}
