//
//  ViewAppointmentController.swift
//  DermaCare
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation
import UIKit

import Firebase

class ViewAppointmentController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var apptTableView: UITableView!
    
    @IBOutlet weak var noTable: UILabel!
    
    var docList=Array<PatientAppointmentModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        apptTableView.delegate = self
        apptTableView.dataSource = self
        
        fetchDoctorListData()
        
        //apptTableView.rowHeight = UITableViewAutomaticDimension
        //apptTableView.estimatedRowHeight = 140
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func fetchDoctorListData(){
        let rootRef = Database.database().reference()
        let refuser = rootRef.child("userlist")
        let userID: String = (Auth.auth().currentUser?.uid)!
        refuser.child(userID).child("appointments").observe(.value, with: {(snapshot) in
            if let users = snapshot.value as? [String:AnyObject] {
                for (key, user) in users {
                    let doc  = user["doctor"] as? String
                    let doctorGender  = user["doctorGender"] as? String
                    let doctorPhoto  = user["doctorPhoto"] as? String
                    let doctorExperience  = user["doctorExperience"] as? String
                    let doctorSpecialization  = user["doctorSpecialization"] as? String
                    let doctorAddress  = user["doctorAddress"] as? String
                    
                    let doctorItem = PatientAppointmentModel(docName: doc!, date: key, doctorGender: doctorGender!, doctorPhoto: doctorPhoto!, doctorExperience:doctorExperience!, doctorSpecialization:doctorSpecialization!, doctorAddress:doctorAddress!)
                    
                    self.docList.append(doctorItem)
                    DispatchQueue.main.async(execute: {
                        self.apptTableView.reloadData()
                    })
                }
            }
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.docList.count > 0) {
            self.noTable.text = "You have \(docList.count) appointments!"
            return docList.count;
        }
        else {
            self.noTable.text = "You have no appointments!"
            tableView.separatorStyle = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = apptTableView.dequeueReusableCell(withIdentifier: "ViewAppointmentCell") as? ViewAppointmentCell else {
            return UITableViewCell()
        }
        //cell.docImage.image = UIImage(named: "doc.png")
        cell.docName.text = docList[indexPath.row].docName
        cell.address.text = docList[indexPath.row].doctorAddress
        cell.gender.text = docList[indexPath.row].doctorGender!
        cell.exprience.text = docList[indexPath.row].doctorExperience! + " of Experience"
        
        
        let photoURL = docList[indexPath.row].doctorPhoto
        if let imageURL = URL(string: photoURL!) {
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    cell.docImage.image = UIImage(data: data!)
                }
            }).resume()
        }
        
        
        cell.date.text = docList[indexPath.row].date
        return cell;
    }
    
    
}
