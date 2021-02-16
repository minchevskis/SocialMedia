//
//  StatsTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/18/20.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMoments: UILabel!
    @IBOutlet weak var lblMomentsValue: UILabel!
    @IBOutlet weak var lblFollowersValue: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowingValue: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    
    var userId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblMoments.alpha = 0.5
        lblFollowers.alpha = 0.5
        lblFollowing.alpha = 0.5
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCounts() {
        setFollowersCount()
        setFollowingCount()
    }
    
    private func setFollowersCount() {
        guard let userId = userId else { return }
        DataStore.shared.getFollowersCount(userId: userId, isFollowers: true) { (count, _) in
            self.lblFollowersValue.text = "\(count)"
        }
    }
    
    private func setFollowingCount() {
        guard let userId = userId else { return }
        DataStore.shared.getFollowersCount(userId: userId, isFollowers: false) { (count, _) in
            self.lblFollowingValue.text = "\(count)"
        }
    }
    
    
}
