//
//  UIViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/9/20.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorWith(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert) 
        let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
}
