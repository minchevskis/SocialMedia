//
//  ImageTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 14.12.20.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var momentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
