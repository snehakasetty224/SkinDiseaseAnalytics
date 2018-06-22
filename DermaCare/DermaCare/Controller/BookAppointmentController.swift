//
//  BookAppointmentController.swift
//  DermaCare
//
//  Created by Pooj on 2/1/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import SystemConfiguration
class BookAppointmentController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noHistoryData: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var experience: UILabel!
    
    @IBOutlet weak var hours: UILabel!
    
    @IBOutlet weak var fees: UILabel!
    
    let width = UIScreen.main.bounds.width
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var historyModel=Array<HistoryModel>()
    var selectedHistoryModel=Array<HistoryModel>()
    
    var selectedDoctor: DoctorModel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var activityAnimator: UIActivityIndicatorView!
    
    @IBOutlet weak var docname: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection=true
        
        docname.text = selectedDoctor.docName
        gender.text = selectedDoctor.gender
        experience.text = selectedDoctor.experience! + " of Experience"
        hours.text = selectedDoctor.hours
        fees.text = selectedDoctor.fees
        let photoURL = selectedDoctor.userphoto
        if let imageURL = URL(string: photoURL!) {
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
            }).resume()
        }
        
        if(isInternetAvailable()) { // Validate network connectivity
            loadHistoryData()
            renderUI(width: Int(width/4), height: Int(width/2))
        } else{
            let alert = UIAlertController(title: "Error!", message: "Please check the network connectivity. History data could not be loaded ", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // Fetch All Photos
    func loadHistoryData(){
        
        activityAnimator.isHidden = false
        activityAnimator.startAnimating()
        activityAnimator.sizeToFit()
        
        let userID: String = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
        let refuser = ref.child("userlist/\(userID)").child("Photos")
        refuser.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                
                let child = (item as! DataSnapshot).value as? [String:Any]
                let childkey = (item as! DataSnapshot).key
                
                let result = child?["result"] as? String ?? ""
                let url = child?["url"] as? String ?? ""
                
                let historyItem = HistoryModel(result: result, url: url, name: childkey)
                self.historyModel.append(historyItem)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                    
                    self.activityAnimator.stopAnimating()
                    self.activityAnimator.isHidden = true
                })
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    // Render each cell using cellForItemAt
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.historyModel.count > 0) {
            self.noHistoryData.text = ""
            return self.historyModel.count
        }
        else {
            self.noHistoryData.text = "No App Diagnosis Found."
            return 0
        }
    }
    
    // Render each cell using cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryImageCell", for: indexPath) as! AppointmentViewCell
        
        let userID: String = (Auth.auth().currentUser?.uid)!
        let imageNameLocal = self.historyModel[indexPath.row].name
        let storage = Storage.storage().reference(forURL: "gs://dermacare-b1017.appspot.com/ImagesUploaded/\(userID)/\(imageNameLocal)")
        
        storage.getMetadata { metadata, error in
            if let error = error {
                print("error occurred", error)
            }else{
                let date = metadata?.timeCreated
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }
        }
        
        if let imageURL = URL(string: self.historyModel[indexPath.row].url!) {
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                
                if error != nil{
                    print(error as Any)
                    return
                }
                DispatchQueue.main.async {
                    cell.historyImage?.image = UIImage(data: data!)
                }
            }).resume()
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        //add the selected cell contents to _selectedCells arr when cell is selected
        selectedHistoryModel.append(historyModel[indexPath.row])
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedHistoryModel.remove(at: indexPath.row)
        collectionView.reloadItems(at: [indexPath])
    }
    
    
    
    @IBAction func bookAppointment(_ sender: Any) {
        
        var urls = Array<String>()
        for lists in selectedHistoryModel {
            urls.append(lists.url!)
        }
        
        let user :User = (Auth.auth().currentUser)!
        let usersReference = Database.database().reference(withPath: "userlist")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        
        //set id with apptdate
        let list = usersReference.child(user.uid)
        
        let phone = list.child("phone")
        let name = list.child("userName")
        var phoneNoVal:String?
        var username:String?
        
        phone.observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                phoneNoVal = item
            }
        })
        
        name.observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                username = item
            }
        })
        
        let lists = list.child("appointments").child(selectedDate)
        lists.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("doctor"){
                self.showAlert("You already have an Appointment")
            }else{
                lists.child("doctor").setValue(self.selectedDoctor.docName)
                lists.child("doctorGender").setValue(self.selectedDoctor.gender)
                lists.child("doctorPhoto").setValue(self.selectedDoctor.userphoto)
                lists.child("doctorExperience").setValue(self.selectedDoctor.experience)
                lists.child("doctorSpecialization").setValue(self.selectedDoctor.specialization)
                lists.child("doctorAddress").setValue(self.selectedDoctor.address)
                let details = lists.child("details")
                for img in self.selectedHistoryModel {
                    details.child("url").setValue(img.url)
                    details.child("result").setValue(img.result)
                    
                }
                self.setAppointmentWithDoctor(docid: self.selectedDoctor.id!, phone: phoneNoVal!, username: username!, apptdate: selectedDate, patient: user, selectedHistoryModel: self.selectedHistoryModel)
                
                self.showAlert("Your Appointment is confirmed with Doctor \(String(describing: self.selectedDoctor.docName)) on \(selectedDate)" )
            }
        })
        
    }
    
    
    func setAppointmentWithDoctor(docid: String, phone:String, username: String, apptdate: String, patient: User, selectedHistoryModel: Array<HistoryModel>) {
        let usersReference = Database.database().reference(withPath: "userlist")
        
        //set id with apptdate
        let appts = usersReference.child(docid).child("appointments").child(apptdate)
        appts.child("patient").setValue(patient.uid)
        appts.child("userName").setValue(username)
        appts.child("phone").setValue(phone)
        let details = appts.child("details")
        
        for img in selectedHistoryModel {
            details.child("result").setValue(img.result)
            details.child("url").setValue(img.url)
        }
    }
    
    // Validate Network Connectivity
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // Render Initial UI
    func renderUI(width: Int, height: Int){
        
        self.collectionView?.backgroundColor = UIColor(white: 0.2, alpha: 1)
        
        self.layout.sectionInset = UIEdgeInsets(top: 0, left: 0.5, bottom: 0, right: 0.5)
        self.layout.itemSize = CGSize(width: width , height: height)
        self.layout.minimumInteritemSpacing = 0
        self.layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = self.layout
    }
    
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Appointment Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

