//
//  DoctorAccountController.swift
//  DermaCare
//
//  Created by sindhya on 5/5/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import Firebase

class DoctorAccountController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docAgeLabel: UILabel!
    @IBOutlet weak var docGenderLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImage.clipsToBounds = true
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.cornerRadius = 18;
        // Do any additional setup after loading the view.
        fetchDoctorProfileData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchDoctorProfileData(){
        let rootRef = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let refuser = rootRef.child("userlist")
        
        refuser.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            self.docNameLabel.text = value?["userName"] as? String ?? ""
            let doc_details = value!["details"] as! [String : AnyObject]
            self.specialityLabel.text = doc_details["specialization"] as? String ?? ""
            self.experienceLabel.text = doc_details["experience"] as? String ?? ""
            self.hoursLabel.text = doc_details["hours"] as? String ?? ""
            self.feesLabel.text = doc_details["fees"] as? String ?? ""
            self.address.text = doc_details["address"] as? String ?? ""
            
            let doc_health = value!["health"] as! [String : AnyObject]
            let age = doc_health["age"] as? String ?? ""
            if(age != ""){
                self.docAgeLabel.text = age + "years"
            }
            
            self.docGenderLabel.text = doc_health["sex"] as? String ?? ""
            
            let photoURL = value?["userphoto"] as? String ?? "Error"
            if let imageURL = URL(string: photoURL) {
                URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(data: data!)
                    }
                }).resume()
            }
        })
        
    }

    
    @IBAction func btnAddPhoto(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            
        }
        
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.cornerRadius = 18;
    }
    
    
    @IBAction func btnSavePhoto(_ sender: Any) {
        
        let database = Database.database().reference()
        let userID :String = (Auth.auth().currentUser?.uid)!
        let storage = Storage.storage().reference()
        
        let tempImageRef = storage.child("UserPhotos/\(userID)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        tempImageRef.putData(UIImageJPEGRepresentation(profileImage.image!, 0.8)!, metadata: metaData){ (metaData, error) in
            if error == nil {
                print ("upload successful")
                let imageURL = metaData!.downloadURL()?.absoluteString
                let refUser = database.child("userlist/\(userID)")
                //refUser.setValue(nil)
                refUser.updateChildValues(["userphoto" : imageURL!])
                
                let alert = UIAlertController(title: "Update Profile", message: "Photo saved Successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                print (error?.localizedDescription)
            }
            
        }
        
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "docLogoutSegue", sender: self)
    }
    
    /*
     * Pick Image
     */
    func imagePickerController(_ _picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[String : Any]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profileImage.contentMode = .scaleToFill
            profileImage.image = pickedImage
            
        }
        _picker.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Set Image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinisjPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
        } else{
            print("Error in importing image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
