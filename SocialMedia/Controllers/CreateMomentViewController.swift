//
//  CreateMomentViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/30/20.
//

import UIKit
import SVProgressHUD

protocol CreateMomentDelegate: class {
    func didPostItem(item: Feed)
}

class CreateMomentViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var captionHolder: UIView!
    @IBOutlet weak var peopleHolderView: UIView!
    @IBOutlet weak var locationHolderVIew: UIView!
    
    @IBOutlet weak var txtCaption: UITextField!
    @IBOutlet weak var txtPeople: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnPost: UIButton!
    
    var pickedImage: UIImage?
    
    weak var delegate: CreateMomentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        
        txtCaption.delegate = self
        txtPeople.delegate = self
        txtLocation.delegate = self
        
        imageView.image = pickedImage
        
        btnSave.layer.borderWidth = 1.0
        btnSave.layer.borderColor = UIColor(named: "MainPink")?.cgColor
        
        btnSave.layer.cornerRadius = 8
        btnSave.layer.masksToBounds = true
        
        btnPost.layer.cornerRadius = 8
        btnPost.layer.masksToBounds = true
        
        peopleHolderView.layer.borderColor = UIColor(hex: "#F1F1F1").cgColor
        peopleHolderView.layer.borderWidth = 1        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
    @IBAction func onPost(_ sender: UIButton) {
        
        guard let caption = txtCaption.text?.trimmingCharacters(in: .whitespacesAndNewlines), caption != "" else { 
            showErrorWith(title: "Error", msg: "Moment must have caption")
            return
        }
        
        guard let localUser = DataStore.shared.localUser else {
            return
        }
        
        guard let pickedImage = pickedImage else {
            showErrorWith(title: "Error", msg: "Image not found")
            return
        }
        
        var moment = Feed()
        moment.caption = caption
        moment.creatorId = localUser.id
        moment.createdAt = Date().toMiliseconds()
        SVProgressHUD.show()
        
        //To generate unique 128-bit Identifier
        let uuid = UUID().uuidString
        DataStore.shared.uploadImage(image: pickedImage, itemId: uuid, isUserImage: false) { (url, error) in
            
            if let error = error {
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let url = url {
                moment.imageUrl = url.absoluteString
                DataStore.shared.createFeedItem(item: moment) { (feed, error) in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        self.showErrorWith(title: "Error", msg: error.localizedDescription)
                        return
                    }
                    
                    self.delegate?.didPostItem(item: moment)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            SVProgressHUD.dismiss()
        }
    }
}
