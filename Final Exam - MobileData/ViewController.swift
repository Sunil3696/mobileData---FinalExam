//
//  ViewController.swift
//  Final Exam - MobileData
//
//  Created by Sunil Balami on 2024-08-08.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBOutlet weak var loginbutton: UIButton!
    
    @IBOutlet weak var signupbutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.layer.cornerRadius = 10
        emailTextfield.layer.masksToBounds = true
        emailTextfield.layer.borderColor = UIColor.gray.cgColor
        emailTextfield.layer.borderWidth = 1.0
        let placeholderText = "Enter your email"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        emailTextfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        if let heightConstraint = emailTextfield.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = 45
        } else {
            emailTextfield.heightAnchor.constraint(equalToConstant: 45).isActive = true
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
        
        loginbutton.layer.cornerRadius = 20
        signupbutton.layer.cornerRadius = 20
        autoLoginIfPossible()
    }
    
    func autoLoginIfPossible() {
          if let tokenData = KeychainHelper.load(key: "userToken"), !tokenData.isEmpty {
              // If a token exists, proceed to the main app screen without requiring login
              self.performSegue(withIdentifier: "showHome", sender: self)
          } else {
              // No token found, stay on the login screen
              print("No token found, user must log in")
          }
      }
    
    
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        let email = emailTextfield.text!
                let password = passwordField.text!
                
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        // Handle the error
                        self.showAlert(message: "Error: \(error.localizedDescription)")
                    } else {
                        // Successfully logged in
                        if let user = authResult?.user {
                            print("User object: \(user)")
                            print("User ID: \(user.uid)")
                            print("Email: \(user.email ?? "No email")")
                            print("Display Name: \(user.displayName ?? "No display name")")
                            print("Photo URL: \(user.photoURL?.absoluteString ?? "No photo URL")")
                            print("Phone Number: \(user.phoneNumber ?? "No phone number")")
                            print("Email Verified: \(user.isEmailVerified)")
                            
                            // Retrieve the ID token
                            user.getIDTokenForcingRefresh(true) { token, error in
                                if let token = token {
                                    self.saveToKeychain(token: token, email: email)
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "showHome", sender: self)
                                    }
                                } else {
                                    self.showAlert(message: "Failed to retrieve token")
                                }
                            }
                        }
                    }
                }
            }
            
            func saveToKeychain(token: String, email: String) {
                if let tokenData = token.data(using: .utf8) {
                    KeychainHelper.save(key: "userToken", data: tokenData)
                }
                if let emailData = email.data(using: .utf8) {
                    KeychainHelper.save(key: "userEmail", data: emailData)
                }
            }
            
            // MARK: Showing alert
            func showAlert(message: String) {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            // Override prepare for segue to pass data if needed
            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "showHome" {
                    let destinationVC = segue.destination as! HomeViewController
//                    destinationVC.userEmail = emailTextfield.text
                }
            }
        }
