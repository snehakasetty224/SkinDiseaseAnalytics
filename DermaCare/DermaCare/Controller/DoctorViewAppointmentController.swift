//
//  DoctorViewAppointmentController.swift
//  DermaCare
//
//  Created by sindhya on 5/3/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import Firebase

class DoctorViewAppointmentController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var docAppointmentTableView: UITableView!
    
    @IBOutlet weak var numAppmtLabel: UILabel!
    
    
    var docAppointmentList=Array<DoctorAppointmentModel>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        docAppointmentTableView.delegate = self
        docAppointmentTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        fetchDoctorAppointmentData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func fetchDoctorAppointmentData(){
        let rootRef = Database.database().reference()
        let userID: String = (Auth.auth().currentUser?.uid)!
        let refuser = rootRef.child("userlist").child(userID)
        
        
        refuser.child("appointments").observe(.value, with: {(snapshot) in
            if let users = snapshot.value as? [String:AnyObject] {
                for (key, user) in users {
                    
                    let patient_uid  = user["patient"] as? String
                    let patient_name = user["userName"] as? String
                    let patient_phone = user["phone"] as? String
                    var result = ""
                    var url = ""
                
                    refuser.child("appointments").child(key).child("details").observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        result = value?["result"] as? String ?? ""
                        url = value?["url"] as? String ?? ""
                        
                        let patItem = DoctorAppointmentModel(patId: patient_uid!, patName:patient_name!, patPhone:patient_phone!, date: key, result: result, url: url)
                        
                        self.docAppointmentList.append(patItem)
                        
                        DispatchQueue.main.async(execute: {
                            self.docAppointmentTableView.reloadData()
                        })
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                   
                    
                }
            }
        })
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.docAppointmentList.count > 0) {
            self.numAppmtLabel.text = "You have \(docAppointmentList.count) appointments!"
            return docAppointmentList.count;
        }
        else {
            self.numAppmtLabel.text = "You have no appointments!"
            tableView.separatorStyle = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = docAppointmentTableView.dequeueReusableCell(withIdentifier: "DocAppointmentTableViewCell") as? DocAppointmentTableViewCell else {
            return UITableViewCell()
        }
        
        cell.patientName.text = docAppointmentList[indexPath.row].patientName
        cell.appmtDate.text = docAppointmentList[indexPath.row].date
        cell.patientPhone.text = docAppointmentList[indexPath.row].patientPhone
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 1
        cell.layer.borderWidth = 1
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        let borderColor: UIColor = .gray
        cell.layer.borderColor = borderColor.cgColor

        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if(segue.identifier == "showPatientDetail"){
            let doctorDetailView = segue.destination as? DetailResultAnalysisController
            
            guard let selectedTableCell = sender as? DocAppointmentTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = docAppointmentTableView.indexPath(for: selectedTableCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedDoctor = docAppointmentList[indexPath.row]
            
            doctorDetailView?.detailView = selectedDoctor
            
        }
    }
}
