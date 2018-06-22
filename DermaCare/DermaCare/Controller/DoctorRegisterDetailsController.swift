//
//  DoctorRegisterDetailsController.swift
//  DermaCare
//
//  Created by sindhya on 5/2/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import Firebase

class DoctorRegisterDetailsController: UIViewController {

    
    @IBOutlet weak var specTxtField: UITextField!
    @IBOutlet weak var expTxtField: UITextField!
    @IBOutlet weak var hoursTxtField: UITextField!
    @IBOutlet weak var consultationFeeTxtField: UITextField!
    
    
    @IBOutlet weak var address: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    @IBAction func btnSubmit(_ sender: Any) {
        
        let database = Database.database().reference()
        let userID :String = (Auth.auth().currentUser?.uid)!
        let userDetailRef = database.child("userlist/\(userID)").child("details")
        userDetailRef.updateChildValues(["experience":String(expTxtField.text!),"fees":String(consultationFeeTxtField.text!),"hours":String(hoursTxtField.text!),"specialization":String(specTxtField.text!), "address":String(address.text!) ])
        
        self.performSegue(withIdentifier: "docDashboardSegue", sender: self)
        
    }
    

}
