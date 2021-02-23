//
//  ViewController.swift
//  Homework23_PicturesRepository
//
//  Created by Pavel Shyker on 11/23/20.
//  Copyright © 2020 Pavel Shyker. All rights reserved.
//

import UIKit
import SwiftyKeychainKit

class ViewController: UIViewController {
    
    var userNameTextField: UITextField?
    var userPasswordTextField: UITextField?
    
    var newUserNameTextField: UITextField?
    var newUserPasswordTextField: UITextField?
    var newUserConfirmPasswordTextField: UITextField?
    
    var credentialsArray = [Credential]()
    var currentUserName: String = ""
    var isAlertAppeared = false
    
    let keychain = Keychain(service: "test.Homework23-PicturesRepository")
    let currentUserNameKey = KeychainKey<String>(key: "currentUserNameKey")
    let credentialsKey = KeychainKey<Data>(key: "credentialsKey")
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    logInButton.layer.cornerRadius = logInButton.frame.size.height/2
    signUpButton.layer.cornerRadius = signUpButton.frame.size.height/2
        
    credentialsArray = getCredentialsArray()
    print (credentialsArray.count)
    print (credentialsArray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        isAlertAppeared = true
        self.animateBlur()
        logIn()
    }
    
    @IBAction func signOnButtonTapped(_ sender: Any) {
        isAlertAppeared = true
        self.animateBlur()
        signUp()
    }
    
    func logIn() {
        let logInAlert = UIAlertController(title: "Log Into Picture guard", message: "Enter your credentials", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let name = self.userNameTextField?.text ?? ""
            let password = self.userPasswordTextField?.text ?? ""
            let isUserExist = self.validateUser(name: name, password: password)
            if isUserExist == true {
                self.navigateToGuardView()
                self.currentUserName = name
                try? self.keychain.set(self.currentUserName, for: self.currentUserNameKey)
            }
                
            else {
                let messageString = "User name or password are not correct. Please try again"
                let attrString = NSMutableAttributedString(string: messageString)
                let wholeRange = (messageString as NSString).range(of: messageString)
                attrString.addAttribute(.foregroundColor, value: UIColor.red, range: wholeRange)
                logInAlert.setValue(attrString, forKey: "attributedMessage")
                self.present(logInAlert, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.isAlertAppeared = false
            self.animateBlur()
        }
        
        logInAlert.addTextField { (nameTextField) in
            self.userNameTextField = nameTextField
            nameTextField.placeholder = "Username"
        }
        
        logInAlert.addTextField { (passwordTextField) in
            self.userPasswordTextField = passwordTextField
            passwordTextField.placeholder = "Password"
            passwordTextField.isSecureTextEntry = true
        }
        
        logInAlert.addAction(okAction)
        logInAlert.addAction(cancelAction)
        present(logInAlert, animated: true)
    }
    
    func signUp() {
        let signUpAlert = UIAlertController(title: "Sign Up", message: "It's quick and easy", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let userName = self.newUserNameTextField?.text ?? ""
            let password1 = self.newUserPasswordTextField?.text ?? ""
            let password2 = self.newUserConfirmPasswordTextField?.text ?? ""
            
            if userName != "" && password1 != "" {
            let compareResult = self.compareTwoPasswords(password1: password1, password2: password2)
            if compareResult == true {
                let isUserSaved = self.saveUserCredential(name: userName, password: password1)
                if isUserSaved == true {
                    self.navigateToGuardView()
                    self.currentUserName = userName
                    try? self.keychain.set(self.currentUserName, for: self.currentUserNameKey)
                }
                else {
                    let messageString = "User with the same name is already exist. Please use another name"
                    let attrString = NSMutableAttributedString(string: messageString)
                    let wholeRange = (messageString as NSString).range(of: messageString)
                    attrString.addAttribute(.foregroundColor, value: UIColor.red, range: wholeRange)
                    signUpAlert.setValue(attrString, forKey: "attributedMessage")
                    self.present(signUpAlert, animated: true)
                }
            }
            else {
                let messageString = "Passwords don't match. Please try again"
                let attrString = NSMutableAttributedString(string: messageString)
                let wholeRange = (messageString as NSString).range(of: messageString)
                attrString.addAttribute(.foregroundColor, value: UIColor.red, range: wholeRange)
                signUpAlert.setValue(attrString, forKey: "attributedMessage")
               self.present(signUpAlert, animated: true)
                }
            }
            else {
                let messageString = "Requared fields can't be empty"
                let attrString = NSMutableAttributedString(string: messageString)
                let wholeRange = (messageString as NSString).range(of: messageString)
                attrString.addAttribute(.foregroundColor, value: UIColor.red, range: wholeRange)
                signUpAlert.setValue(attrString, forKey: "attributedMessage")
                self.present(signUpAlert, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print ("Cancel")
            self.isAlertAppeared = false
            self.animateBlur()
        }
        
        signUpAlert.addTextField { (newUserNameTextField) in
            self.newUserNameTextField = newUserNameTextField
            newUserNameTextField.placeholder = "Username"
        }
        
        signUpAlert.addTextField { (newUserPasswordTextField) in
            self.newUserPasswordTextField = newUserPasswordTextField
            newUserPasswordTextField.placeholder = "Password"
            newUserPasswordTextField.isSecureTextEntry = true
        }
        
        signUpAlert.addTextField { (reenterNewPasswordNameTextField) in
            self.newUserConfirmPasswordTextField = reenterNewPasswordNameTextField
            reenterNewPasswordNameTextField.placeholder = "Confirm Password"
            reenterNewPasswordNameTextField.isSecureTextEntry = true
        }
        
        signUpAlert.addAction(okAction)
        signUpAlert.addAction(cancelAction)
        present(signUpAlert, animated: true)
    }
    
    func navigateToGuardView() {
        let guardStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let guardViewController = guardStoryBoard.instantiateViewController(withIdentifier: String(describing: GuardViewController.self)) as? GuardViewController
        navigationController?.pushViewController(guardViewController ?? UIViewController(), animated: true)
        isAlertAppeared = false
        self.animateBlur()
    }
    
    func compareTwoPasswords(password1: String, password2: String) -> Bool {
        var compareResult = false
        if password1 == password2 {
            compareResult = true
        }
        else {
            compareResult = false
        }
        return compareResult
    }
    
    func saveUserCredential(name: String, password: String) -> Bool {
        let userCredentail = Credential(name, password)
        let similarUser =  credentialsArray.filter ({ $0.userName == name })
        if similarUser.count == 0 {
            credentialsArray.append(userCredentail)
            print (credentialsArray.count)
            do {
                let data = try JSONEncoder().encode(credentialsArray)
                try? keychain.set(data, for: credentialsKey)
            }
            catch {
                print (error.localizedDescription)
            }
            return true
        }
        else {
            return false
        }
    }
    
    func getCredentialsArray() -> [Credential] {
        if let data = try? keychain.get(credentialsKey) {
            do {
                let credentialsArray = try JSONDecoder().decode([Credential].self, from: data)
                self.credentialsArray = credentialsArray
            }
            catch {
                print (error.localizedDescription)
                credentialsArray = [Credential]()
            }
        }
        else {
            credentialsArray = [Credential]()
        }
        return credentialsArray
    }
    
    func validateUser(name: String, password: String) -> Bool {
         let similarUser =  credentialsArray.filter ({ $0.userName == name && $0.password == password})
         if similarUser.count > 0 {
            return true
         }
         else {
            return false
        }
    }
    
    func animateBlur() {
        UIView.animate(withDuration: 0.2, animations: {
            if self.isAlertAppeared == true {
                self.blurView.alpha = 1
            }
            else {
                self.blurView.alpha = 0
            }
        })
    }
}

