//
//  LoadingTableViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 21.12.20.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    lazy  var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = false
        return activityIndicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(activityIndicator)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[activityIndicator(50)]", options: [.alignAllCenterX], metrics: nil, views: ["activityIndicator": activityIndicator]))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[activityIndicator(50)]", options: [.alignAllCenterY], metrics: nil, views: ["activityIndicator": activityIndicator]))

        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
