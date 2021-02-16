//
//  RegisterViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/4/20.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

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
        emailHolderView.layer.borderColor = UIColor.black.cgColor
        emailHolderView.layer.cornerRadius = 8

        txtEmail.delegate = self
        txtEmail.returnKeyType = .done
        
        passwordHolderView.layer.borderWidth = 1.0
        passwordHolderView.layer.borderColor = UIColor.black.cgColor
        passwordHolderView.layer.cornerRadius = 8
        txtPassword.delegate = self
        txtPassword.returnKeyType = .continue
    }

    @IBAction func onContinue(_ sender: UIButton) {
        
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
        
        guard pass.count >= 6 else {
            showErrorWith(title: "Error", msg: "Password must contain at least 6 characters")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { (authResult, error) in
            if let error = error {
                let specificError = error as NSError
               
                if specificError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showErrorWith(title: "Error", msg: "Email already in use!")
                    return
                }
                
                if specificError.code == AuthErrorCode.weakPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Your password is too weak")
                    return
                }
                
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                self.saveUser(uid: authResult.user.uid)
            }
        }
    }
    
    func saveUser(uid: String) {
        let user = User(id: uid)
        SVProgressHUD.show()
        DataStore.shared.setUserData(user: user) { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if success {
                DataStore.shared.localUser = user
                self.continueToSetupProfile()
            }
        }
    }
    
    func continueToSetupProfile() {
        performSegue(withIdentifier: "setupProfile", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile" {
            let controller = segue.destination as! SetupProfileViewController
            controller.state = .register
        }
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    } 
}
