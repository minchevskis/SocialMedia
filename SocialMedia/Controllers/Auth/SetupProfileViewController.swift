//
//  SetupProfileViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/13/20.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

enum SetupProfileState {
    case register
    case login
    case editProfile
}

class SetupProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullnameHolderView: UIView!
    @IBOutlet weak var dobHolderView: UIView!
    @IBOutlet weak var genderHolderView: UIView!
    @IBOutlet weak var locationHolderView: UIView!
    @IBOutlet weak var aboutHolderView: UIView!
    
    @IBOutlet weak var txtFullname: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtAbountMe: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var state: SetupProfileState = .register
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBorders()
        
        if state != .editProfile {
            reorderNavigation()
        } else if state == .editProfile {
            setupViewForEdit()
        }
    }
    
    private func setupViewForEdit() {
        guard let localUser = DataStore.shared.localUser else { return }
        btnSave.setTitle("Save profile", for: .normal)
        txtFullname.text = localUser.fullName
        txtDob.text = localUser.dob
        txtGender.text = localUser.gender
        txtLocation.text = localUser.location
        txtAbountMe.text = localUser.aboutMe
    }
    
    func reorderNavigation() {
        var controllers = [UIViewController]()
        navigationController?.viewControllers.forEach({ (controller) in
            if !(controller is RegisterViewController) {
                controllers.append(controller)
            }
        })
//        navigationController?.viewControllers.forEach({ 
//            if !($0 is RegisterViewController) {
//                controllers.append($0)
//            }
//        })
        navigationController?.setViewControllers(controllers, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func setupBorders() {
        for tag in 1...5 {
            if let view = contentView.viewWithTag(tag) {
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor(hex: "#F1F1F1").cgColor
                view.layer.cornerRadius = 8
                view.layer.masksToBounds = true
            }
        }
    }
    
    func getUser() -> User? {
        guard let localUser = DataStore.shared.localUser else {
            return nil
        }
        return localUser
    }
    
    func createUser() -> User? {
        guard let user = Auth.auth().currentUser else { return nil }
        let localUser = User(id: user.uid)
        return localUser
    }
    
    private func saveUserProfile() {
        var user = getUser()
        var shouldUpdate = false

        if user?.fullName != txtFullname.text {
            shouldUpdate = true
            user?.fullName = txtFullname.text
        } else if user?.dob != txtDob.text {
            shouldUpdate = true
            user?.dob = txtDob.text
        } else if user?.aboutMe != txtAbountMe.text {
            shouldUpdate = true
            user?.aboutMe = txtAbountMe.text
        } else if user?.gender != txtGender.text {
            shouldUpdate = true
            user?.gender = txtGender.text
        } else if user?.location != txtLocation.text {
            shouldUpdate = true
            user?.location = txtLocation.text
        }
        
        if shouldUpdate {
            saveUser(user: user!)
        }
    }
    
    @IBAction func onContinue(_ sender: UIButton) {
        var user: User?
     
        switch state {
        case .login:
            user = createUser()
        case .register:
            user = getUser()
        case .editProfile:
            saveUserProfile()
            return
        }
        
        guard var localUser = user else {
            showErrorWith(title: "Error", msg: "User does not exists")
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        localUser.fullName = txtFullname.text
        localUser.aboutMe = txtAbountMe.text
        localUser.gender = txtGender.text
        localUser.dob = txtDob.text
        localUser.location = txtLocation.text
    
        saveUser(user: localUser)
    }
    
    private func saveUser(user: User) {
        SVProgressHUD.show()
        DataStore.shared.setUserData(user: user) { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if success {
                DataStore.shared.localUser = user
                if self.state != .editProfile {
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
