//
//  WelcomeViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/2/20.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import AuthenticationServices
import SVProgressHUD

class WelcomeViewController: UIViewController {

    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createAcountBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var brnSignIn: UIButton!
    @IBOutlet weak var btnAppleSIgnin: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        try? Auth.auth().signOut()
        if let user = Auth.auth().currentUser {
            getLocalUserData(uid: user.uid)
            return
        }
    
        setConstraintsForSmallerDevices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setConstraintsForSmallerDevices() {
        if DeviceType.IS_IPHONE_6 {
            imageTopConstraint.constant = 60
            createAcountBottomConstraint.constant = 70
        } else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            imageTopConstraint.constant = 40
            imageWidthConstraint.constant = imageWidthConstraint.constant / 2.0
            imageHeightConstraint.constant = imageHeightConstraint.constant / 2.0
            createAcountBottomConstraint.constant = 40
        }
    }
    
    func userDidLogin(token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                let user = authResult.user
                print(user)
                self.getLocalUserData(uid: user.uid)
            }
        }
    }
    
    func getLocalUserData(uid: String) {
        SVProgressHUD.show()
        DataStore.shared.getUser(uid: uid) { (user, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let user = user {
                DataStore.shared.localUser = user
                self.continueToHomeScreen()
            }
        }
    }

    func continueToHomeScreen() {
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
    @IBAction func onFacebook(_ sender: UIButton) {
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile","email"], from: self) { (loginResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let result = loginResult, !result.isCancelled, let token = result.token {
                    self.userDidLogin(token: token.tokenString)
                } else {
                    print("User Canceled flow")
                }
            }
        }
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginSegue", sender: nil)
    }
}
