//
//  SignupViewController.swift
//  Final Exam - MobileData
//
//  Created by Sunil Balami on 2024-08-08.
//

import Foundation
import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupBUtton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.layer.cornerRadius = 10
        emailField.layer.masksToBounds = true
        emailField.layer.borderColor = UIColor.gray.cgColor
        emailField.layer.borderWidth = 1.0
        let placeholderText = "Enter your email"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        emailField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        if let heightConstraint = emailField.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = 45
        } else {
            emailField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        passwordField.layer.cornerRadius = 10
        passwordField.layer.masksToBounds = true
        passwordField.layer.borderColor = UIColor.gray.cgColor
        passwordField.layer.borderWidth = 1.0
        let placeholderTextpassword = "Enter your Password"
        let attributespassword = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        passwordField.attributedPlaceholder = NSAttributedString(string: placeholderTextpassword, attributes: attributes)
        if let heightConstraint = passwordField.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = 45
        } else {
            passwordField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        signupBUtton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
    }
    
    
    
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
       
        let email = emailField.text
        let password = passwordField.text
        
        print(email!)
        print (password!)
        if email == "" || password == "" {
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        if password!.count < 6 {
            showAlert(message: "Password must be at least 6 char long")
        }
        
    
        Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
            if let error = error {
                // An error occurred, handle it here
                self.showAlert(message: "Error: \(error)")
            } else {
                // User created successfully, handle success here
                self.showAlert(message: "Signup successful!")
            }
        }

        
        
        
        
        
    }
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
