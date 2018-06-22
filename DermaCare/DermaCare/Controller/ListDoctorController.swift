//
//  ListDoctorController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//


import Foundation
import Firebase
import UIKit

class ListDoctorController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var doctorTableView: UITableView!
    
    var docList=Array<DoctorModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        doctorTableView.delegate = self
        doctorTableView.dataSource = self
        
        fetchDoctorListData()
        
        doctorTableView.rowHeight = UITableViewAutomaticDimension
        doctorTableView.estimatedRowHeight = 140
    }
    
    func fetchDoctorListData(){
        let rootRef=Database.database().reference()
        //let refuser = rootRef.child("userlist").queryEqual(toValue: "doctor", childKey: "userType")
        let refuser = rootRef.child("userlist")
        //refuser.queryOrdered(byChild: "userType").queryEqual(toValue: "doctor")
        
        refuser.observe(.value, with: {(snapshot) in
        
            if let users = snapshot.value as? [String:AnyObject] {
                for (key, user) in users {
                    let userType  = user["userType"] as? String
                    if(userType == "Doctor"){
                        let user_name = user["userName"] as! String
                        let userphoto = user["userphoto"] as! String
                        let doc_details = user["details"] as! [String : AnyObject]
                        let spec = doc_details["specialization"] as! String
                        let experience = doc_details["experience"] as! String
                        let hours = doc_details["hours"] as! String
                        let fees = doc_details["fees"] as! String
                        let address = doc_details["address"] as! String
                        
                        let doc_health = user["health"] as! [String : AnyObject]
                        let age = doc_health["age"] as? String ?? ""
                        let gender = doc_health["sex"] as? String ?? ""
                        
                        let doctorItem = DoctorModel(id: key, name: user_name,spec: spec, exp: experience, hours: hours, fees: fees, address: address, userphoto: userphoto, age: age, gender: gender)
                        self.docList.append(doctorItem)
                        
                        DispatchQueue.main.async(execute: {
                            self.doctorTableView.reloadData()
                        })
                    }
                }
            }
            
            
            /*for rest in snapshot.children.allObjects as! [DataSnapshot] {
                print(rest.value)
            }*/
            
            /*for item in snapshot.children{
                let child = item as AnyObject
                print("doc list")
                for i in child.allObjects as! [DataSnapshot]{
                    print("child")
                    print(i)
                }
                print(child)
            }*/
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = doctorTableView.dequeueReusableCell(withIdentifier: "DoctorTableViewCell") as?DoctorTableViewCell else {
            return UITableViewCell()
        }
        cell.docImage.image = UIImage()//named: "doc.png")
        cell.docName.text = docList[indexPath.row].docName
        cell.docSpec.text = docList[indexPath.row].specialization
        cell.hours.text = docList[indexPath.row].hours
        cell.address.text = docList[indexPath.row].address
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 1
        cell.layer.borderWidth = 1
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        let borderColor: UIColor = .gray
        cell.layer.borderColor = borderColor.cgColor

        let imageNameLocal = docList[indexPath.row].userphoto

        /*let docid = docList[indexPath.row].id
        let storage = Storage.storage().reference(forURL: "gs://dermacare-b1017.appspot.com/UserPhotos/\(docid)")
        
        storage.getMetadata { metadata, error in
            if let error = error {
                print("error occurred", error)
            }else{
                let date = metadata?.timeCreated
                //print("date", date )
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }
        }*/
        
        if let imageURL = URL(string: imageNameLocal!) {
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data!)
                    
                }
            }).resume()
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if(segue.identifier == "showDoctorDetail"){
            let doctorDetailView = segue.destination as? DoctorController
            
            guard let selectedTableCell = sender as? DoctorTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = doctorTableView.indexPath(for: selectedTableCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedDoctor = docList[indexPath.row]
            doctorDetailView?.doctorDetails = selectedDoctor
            
        }
    }
    
    
}
