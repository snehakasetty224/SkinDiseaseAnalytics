//
//  ProfileController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var userNameText: UILabel!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.text = Auth.auth().currentUser?.email
        userNameText.text = Auth.auth().currentUser?.email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func updateProfileAction(_ sender: Any) {
        
    }
    
    
}
