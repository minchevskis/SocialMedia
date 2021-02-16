//
//  CaptionTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 14.12.20.
//

import UIKit

class CaptionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var lblDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
