//
//  FinalResultController.swift
//  DermaCare
//
//  Created by Pooj on 5/8/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import MessageUI

class FinalResultController: UIViewController {

    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var resultText: UITextView!
    
    var resultmessage: String?
    var ref = Database.database().reference(withPath: "userlist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingDatabase ()
        
        print("result : \( resultmessage ?? " ")")
        resultText.text = resultmessage
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        resultText.layer.borderWidth = 0.5
        resultText.layer.borderColor = borderColor.cgColor
        resultText.layer.cornerRadius = 5.0
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //tableView.separatorStyle = .none
        
        
    }
    
    
    func startObservingDatabase () {
        let userID = Auth.auth().currentUser?.uid
        
        ref.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let uname = value!["userName"] as? String
            let startmessage = "Hello \(uname ?? " ")"
            self.username.text = startmessage
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
