//
//  RegisterController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import HealthKit

class RegisterController: UIViewController {
    
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var verifyText: UITextField!
    
    @IBOutlet weak var phoneNo: UITextField!
    
    @IBOutlet weak var loginTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var healthDataConnectSwitch: UISwitch!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var loginType: String?

    private let dataModel = HKManager()
    
    private var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        usernameText.placeholder = "Enter Full Name"
        passwordText.placeholder = "Enter Password"
        verifyText.placeholder = "Re-Enter Password"
        emailText.placeholder = "Enter E-Mail"
        phoneNo.placeholder = "Enter Phone Number"
        loginType = "Patient"
        
         self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerAction(_ sender: Any) {
        
        if(emailText.text != "" && passwordText.text != "") {
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                if user != nil {
                    if(self.loginType == "Patient") {
                        let usersReference = Database.database().reference(withPath: "userlist")
                        let lists = usersReference.child((user?.uid)!)
                        lists.child("email").setValue(self.emailText.text)
                        lists.child("userName").setValue(self.usernameText.text)
                        lists.child("userphoto").setValue("nil")
                        lists.child("phone").setValue(self.phoneNo.text)
                        lists.child("userType").setValue(self.loginType)
                        lists.child("isHealthSync").setValue(self.healthDataConnectSwitch.isOn)
                        
                        //Import healhkit data
                        if(self.healthDataConnectSwitch.isOn) {
                            self.dataModel.delegate = self
                            self.dataModel.requestData(user: user!, callback: { (isHealthSync: Bool) -> Void in
                        })
                            
                        }
                        self.performSegue(withIdentifier: "patientDashboardSegue", sender: self)
                    } else {
                        let usersReference = Database.database().reference(withPath: "userlist")
                        let lists = usersReference.child((user?.uid)!)
                        lists.child("email").setValue(self.emailText.text)
                        lists.child("userName").setValue(self.usernameText.text)
                        lists.child("phone").setValue(self.phoneNo.text)
                        lists.child("userType").setValue(self.loginType)
                        lists.child("isHealthSync").setValue(self.healthDataConnectSwitch.isOn)
                        
                        //Import healhkit data
                        if(self.healthDataConnectSwitch.isOn) {
                            self.dataModel.delegate = self
                            self.dataModel.requestData(user: user!, callback: { (isHealthSync: Bool) -> Void in
                            })
                            
                        }
                        
                        self.performSegue(withIdentifier: "docRegisterDetailsSegue", sender: self)
                        
                    }
                    print("User is registered successfully for \(String(describing: user?.email))")
                    
                    
                } else {
                    
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            switch errCode {
                            case .invalidEmail:
                                self.showAlert("Enter a valid email.")
                            case .emailAlreadyInUse:
                                self.showAlert("Email already in use.")
                            default:
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                        return
                    }
                }
            })
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        switch loginTypeSegmentedControl.selectedSegmentIndex {
        case 0:
           self.loginType = "Patient"
        case 1:
           self.loginType = "Doctor"
        default:
            self.loginType = "Patient"
        }
    }

    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "DermaCare User Login", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension RegisterController: HKManagerDelegate {
    func didRecieveDataUpdate(data: HKManager) {
        print("Health Data Imported")
        
    }
    
}

extension RegisterController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameText {
            usernameText.becomeFirstResponder()
        }
        if textField == passwordText {
            usernameText.resignFirstResponder()
        }
        return true
    }
    
}
