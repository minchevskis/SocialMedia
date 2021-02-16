//
//  LoadingCollectionViewCell.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 25.12.20.
//

import UIKit
import SnapKit

class LoadingCollectionViewCell: UICollectionViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = false
        return activityIndicator
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(named: "MainDark")
        label.text = "Loading data..."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.size.equalTo(50)
            make.bottom.equalTo(label.snp.top).inset(10)
            make.centerX.equalToSuperview()
        }
        
    }
}
