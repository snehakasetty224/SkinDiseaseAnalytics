//
//  DetailResultAnalysisController.swift
//  DermaCare
//
//  Created by Pooj on 5/16/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import Firebase

class DetailResultAnalysisController: UIViewController{
    
    @IBOutlet weak var patientImage: UIImageView!
    
    @IBOutlet weak var patientAge: UILabel!
    
    @IBOutlet weak var patientGender: UILabel!
   
    
    @IBOutlet weak var patientName: UILabel!
    
    var docAppointmentList=Array<DoctorAppointmentModel>()
   
    var detailView = DoctorAppointmentModel()
   
    @IBOutlet weak var heartRateText: UILabel!
    
    @IBOutlet weak var bptext: UILabel!
    
    @IBOutlet weak var heightText: UILabel!
    
    @IBOutlet weak var wtText: UILabel!
    
    @IBOutlet weak var bodyText: UILabel!
    
    @IBOutlet weak var respRate: UILabel!
    
    @IBOutlet weak var diagnoseImage: UIImageView!
    
    @IBOutlet weak var appDiagnosis: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchPatientAppointmentData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchPatientAppointmentData(){
        let rootRef = Database.database().reference()
        //let userID: String = (Auth.auth().currentUser?.uid)!
        let refuser = rootRef.child("userlist")
       
        let resulturl = self.detailView.url!
        if(!resulturl.isEmpty) {
            self.appDiagnosis.text = "App diagnosis : \(self.detailView.result as? String ?? " ")"
            if let imageURL = URL(string: resulturl) {
                URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.diagnoseImage.image = UIImage(data: data!)
                    }
                }).resume()
            }
        }
       
        refuser.child(self.detailView.patientId!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let photoURL  = value?["userphoto"] as? String ?? "N/A"
                let patient_name = value?["userName"] as? String ?? "No Data"
                self.patientName.text = patient_name
            
                if let imageURL = URL(string: photoURL) {
                    URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                        if error != nil{
                            print(error as Any)
                            return
                        }
                        DispatchQueue.main.async {
                            self.patientImage.image = UIImage(data: data!)
                        }
                    }).resume()
                }
        }) { (error) in
                print(error.localizedDescription)
        }
        
        refuser.child(self.detailView.patientId!).child("health").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            let age = value?["age"] as? String ?? "No Data"
            let wt = value?["weight"] as? String ?? "No Data"
            let ht = value?["height"] as? String ?? "No Data"
            let gender = value?["sex"] as? String ?? "No Data"
            let bp = value?["bloodType"] as? String ?? "No Data"
            let heartrate = value?["heartrate"] as? String ?? "No Data"
            let bodytemperature = value?["bodyTemperature"] as? String ?? "No Data"
            let respRate = value?["respiratoryRate"] as? String ?? "No Data"
            
            self.patientAge.text = "\(age) Years Old"
            self.bptext.text = bp
            self.wtText.text = wt
            self.heightText.text = ht
            self.patientGender.text = gender
            self.heartRateText.text = heartrate
            self.bodyText.text = bodytemperature
            self.respRate.text = respRate
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
