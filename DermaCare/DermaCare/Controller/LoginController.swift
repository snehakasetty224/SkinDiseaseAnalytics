//
//  LoginController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordtext: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func loginAction(_ sender: Any) {
        let database = Database.database().reference()
        
        
        if(emailText.text != "" && passwordtext.text != "") {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordtext.text!) { (user, error) in
                if let user = user {
                    // The user's ID, unique to the Firebase project.
                    // To handle auth token. Use getTokenWithCompletion:completion: instead.
                    let email = user.email
                    self.user = user
                    print("Sign in successful for \(String(describing: email))")
                    
                    let userDetailRef = database.child("userlist/\(user.uid)")
                    
                    userDetailRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? [String: Any] {
                            let userType = value["userType"] as? String ?? ""
                            if(userType == "Doctor"){
                                self.performSegue(withIdentifier: "doctorLoginSegue", sender: self)
                            }else if(userType == "Patient"){
                                self.performSegue(withIdentifier: "patientLoginSegue", sender: self)
                            }
                        }
                        
                    })
                    
                } else {
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            switch errCode {
                            case .appNotAuthorized:
                                self.showAlert("User account may not exist. Try registering")
                            case .wrongPassword:
                                self.showAlert("Incorrect username/password combination")
                            default:
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                        return
                    }
                    assertionFailure("user and error are nil")
                }
            }
            
        }
     
        
      //  self.performSegue(withIdentifier: "loginSegue", sender: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Add listener
         handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //Detach the listener
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    @IBAction func forgotPassword(_ sender: Any) {
        let prompt = UIAlertController(title: "DermaCare Password Reset Request", message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .userNotFound:
                            DispatchQueue.main.async {
                                self.showAlert("User account not found. Try registering")
                            }
                        default:
                            DispatchQueue.main.async {
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("You'll receive an email shortly to reset your password.")
                    }
                }
            })
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Dermacare User Registeration", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "patientLoginSegue"{
            if user != nil {
                let tabBarController = segue.destination as! UITabBarController
                let homeCtrl = tabBarController.viewControllers![0] as! HomeController
             
                homeCtrl.user = user
                
            } else {
                self.showAlert("User account not found. Try registering")
            }
            
        }
    }
    
    
    
}
