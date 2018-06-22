//
//  DoctorController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation

import UIKit

class DoctorController: UIViewController {
    
     var doctorDetails = DoctorModel()
    
    @IBOutlet weak var docImage: UIImageView!
    @IBOutlet weak var docName: UILabel!
    @IBOutlet weak var docAge: UILabel!
    @IBOutlet weak var docHours: UILabel!
    @IBOutlet weak var docFees: UILabel!
    @IBOutlet weak var docMedicalPractise: UILabel!
    @IBOutlet weak var docSpec: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadViews()
        //print(doctorDetails.docName)
    }
    
    func loadViews(){
        
        docName.text = doctorDetails.docName
        docAge.text = doctorDetails.age! + " Years Old"
        docHours.text = doctorDetails.hours
        docFees.text = doctorDetails.fees
        docMedicalPractise.text = doctorDetails.experience! + " of Experience"
        docSpec.text = doctorDetails.specialization
        address.text = doctorDetails.address
        gender.text  = doctorDetails.gender
        let photoURL = doctorDetails.userphoto
        if let imageURL = URL(string: photoURL!) {
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    self.docImage.image = UIImage(data: data!)
                }
            }).resume()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bookAppointment(_ sender: Any) {
        performSegue(withIdentifier: "doctor", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "doctor"){
            let doctorDetailView = segue.destination as? BookAppointmentController
            doctorDetailView?.selectedDoctor = doctorDetails
        }
    }
    
    
    
}
