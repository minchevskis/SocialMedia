//
//  LoginViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/9/20.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailHolderView: UIView!
    @IBOutlet weak var passwordHolderView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBordersAndFields()
    }
    
    func setupBordersAndFields() {
        emailHolderView.layer.borderWidth = 1.0
        emailHolderView.layer.borderColor = UIColor(hex: "#F1F1F1").cgColor
        emailHolderView.layer.cornerRadius = 8

        txtEmail.delegate = self
        txtEmail.returnKeyType = .done
        
        passwordHolderView.layer.borderWidth = 1.0
        passwordHolderView.layer.borderColor = UIColor(hex: "#F1F1F1").cgColor
        passwordHolderView.layer.cornerRadius = 8
        txtPassword.delegate = self
        txtPassword.returnKeyType = .continue
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onGoToFeed(_ sender: UIButton) {
        
        guard let email = txtEmail.text, email != "" else { 
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        
        guard let pass = txtPassword.text, pass != "" else {
            showErrorWith(title: "Error", msg: "Please enter password")
            return
        }
        
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: pass) { (authResult, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                let specificError = error as NSError
               
                if specificError.code == AuthErrorCode.invalidEmail.rawValue && specificError.code == AuthErrorCode.wrongPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Incorect email or password")
                    return
                }
                
                if specificError.code == AuthErrorCode.userDisabled.rawValue {
                    self.showErrorWith(title: "Error", msg: "You account was disabled")
                    return
                }
                
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let authResult = authResult { 
                self.getLocalUserData(uid: authResult.user.uid)
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
                self.continuteToHome()
                return
            }
            self.continueToSetUserProfile()
        }
    }
    
    func continuteToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabBar")
        present(controller, animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: false)
    }
    
    func continueToSetUserProfile() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SetupProfileViewController") as! SetupProfileViewController
        controller.state = .login
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    } 
}
