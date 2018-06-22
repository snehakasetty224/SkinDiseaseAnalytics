//
//  AccountController.swift
//  DermaCare
//
//  Created by Dermacare Team on 2/1/18.
//  Copyright © 2018 Dermacare. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseDatabase
import Firebase

class AccountController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userNameText: UILabel!
    
    @IBOutlet weak var ageText: UILabel!
    
    @IBOutlet weak var genderText: UILabel!
    
    @IBOutlet weak var heartrateText: UILabel!
    
    @IBOutlet weak var bpText: UILabel!
    
    @IBOutlet weak var weightText: UILabel!
    
    @IBOutlet weak var temperatureText: UILabel!
    
    @IBOutlet weak var calText: UILabel!
    
    @IBOutlet weak var heightText: UILabel!
    
    @IBOutlet weak var respRate: UILabel!
    
    @IBOutlet weak var healthSyncButton: UISwitch!
    
    @IBOutlet weak var accountImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var ref = Database.database().reference(withPath: "userlist")
    private var databaseHandle: DatabaseHandle!
    
    var HealthModelItems = [HealthModel]()
    
    @IBAction func healthKitSyncSwitch(_ sender: Any) {
        let user = Auth.auth().currentUser
        let userID = Auth.auth().currentUser?.uid
        let lists = ref.child(userID!)
        
        if(self.healthSyncButton.isOn){
            let dataModel = HKManager()
            dataModel.delegate = self
            dataModel.requestData(user: user!, callback: { (ifHealthSyc: Bool) -> Void in
                
            })
            
            print("if sync \(dataModel.ifHealthSyc )")
            while (dataModel.ifHealthSyc){
                print("sleep for 2 seconds.")
                sleep(2) // working
            }
            print("if sync \(dataModel.ifHealthSyc )")
            lists.child("isHealthSync").setValue(true)
            lists.child("health").observeSingleEvent(of: .value, with: { (snapshot) in
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
                
                if(age != ""){
                    self.ageText.text = "\(age) Years"
                }
                self.bpText.text = bp
                self.weightText.text = wt
                self.heightText.text = ht
                self.genderText.text = gender
                self.heartrateText.text = heartrate
                self.temperatureText.text = bodytemperature
                 self.respRate.text = respRate
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        } else {
            //remove health data
            lists.child("isHealthSync").setValue(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let healthTree = Database.database().reference(withPath: "patientlist").child(uid!).child("health")
        
        startObservingDatabase()
    }
    
    
    @IBAction func savePhoto(_ sender: Any) {
        let database = Database.database().reference()
        let userID :String = (Auth.auth().currentUser?.uid)!
        let storage = Storage.storage().reference()
        
        let tempImageRef = storage.child("UserPhotos/\(userID)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        tempImageRef.putData(UIImageJPEGRepresentation(accountImageView.image!, 0.8)!, metadata: metaData){ (metaData, error) in
            if error == nil {
                print ("upload successful")
                let imageURL = metaData!.downloadURL()?.absoluteString
                let refUser = database.child("userlist/\(userID)")
                //refUser.setValue(nil)
                refUser.updateChildValues(["userphoto" : imageURL!])
                
                let alert = UIAlertController(title: "Message", message: "Photo saved Successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                print (error?.localizedDescription)
            }
            
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            
        }
        
        self.accountImageView.clipsToBounds = true
        self.accountImageView.layer.cornerRadius = self.accountImageView.frame.size.width / 2
        self.accountImageView.layer.cornerRadius = 18;
        
    }
    
    @IBAction func userLogOut(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    func startObservingDatabase () {
        let userID = Auth.auth().currentUser?.uid
        
        ref.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let ifON = value?["isHealthSync"] as? Bool ?? true
            
            if(ifON){
                self.healthSyncButton.setOn(true, animated: true)
            } else {
                self.healthSyncButton.setOn(false, animated: true)
            }
            
            self.userNameText.text = value?["userName"] as? String ?? "Error"
            
            let photoURL = value?["userphoto"] as? String ?? "Error"
            if let imageURL = URL(string: photoURL) {
                //let url = NSURL(String: imageURL)
                URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    DispatchQueue.main.async {
                        self.accountImageView.image = UIImage(data: data!)
                    }
                }).resume()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child(userID!).child("health").observeSingleEvent(of: .value, with: { (snapshot) in
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
            
            self.ageText.text = "\(age) Years Old"
            self.bpText.text = bp
            self.weightText.text = wt
            self.heightText.text = ht
            self.genderText.text = gender
            self.heartrateText.text = heartrate
            self.temperatureText.text = bodytemperature
            self.respRate.text = respRate
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    /*
     * Pick Image
     */
    func imagePickerController(_ _picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[String : Any]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            accountImageView.contentMode = .scaleToFill
            accountImageView.image = pickedImage
            
        }
        _picker.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Set Image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinisjPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            accountImageView.image = image
        } else{
            print("Error in importing image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*deinit {
     ref.child(self.user.uid).child("health").removeObserver(withHandle: databaseHandle)
     }*/
}


extension AccountController: HKManagerDelegate {
    func didRecieveDataUpdate(data: HKManager) {
        print("Health Data Imported")
        
    }
    
}




