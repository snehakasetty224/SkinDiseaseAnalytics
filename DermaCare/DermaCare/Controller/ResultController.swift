//
//  ResultController.swift
//  DermaCare
//
//  Created by Pooj on 4/17/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

import Firebase
import UIKit
import MessageUI

class ResultController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var result = " Severe Rash"
    
    @IBOutlet weak var myImageview: UIImageView!
    
    @IBOutlet weak var debugTextView: UITextView!
    
    @IBAction func saveDiagnosis(_ sender: Any) {
        
        let database = Database.database().reference()
        let userID :String = (Auth.auth().currentUser?.uid)!
        let storage = Storage.storage().reference()
        
        let tempImageRef = storage.child("ImagesUploaded/\(userID)")
        let id = String(format:"%.0f", Date().timeIntervalSince1970*1000)
        let image = self.myImageview.image
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        tempImageRef.child(id).putData(UIImageJPEGRepresentation(image!, 0.8)!, metadata: metaData){ (metaData, error) in
            //tempImageRef.child(id).putData(, metadata: metaData){(metaData,error) in
            if error == nil {
                print ("upload successful")
                let imageURL = metaData!.downloadURL()?.absoluteString
                let refUser = database.child("userlist/\(userID)/Photos/\(id)")
                refUser.setValue(nil)
                refUser.child("url").setValue(imageURL)
                refUser.child("result").setValue(self.result)
                
                //refUser.setValue(imageURL)
                
                let alert = UIAlertController(title: "Alert", message: "Saved Successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                print (error?.localizedDescription)
            }
            
        }
 
        
    }
    
    @IBAction func scanButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker,animated: true,completion: nil)
        }
        
    }
    
    /*
     * Pick Image
     */
    func imagePickerController(_ _picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[String : Any]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            myImageview.contentMode = .scaleToFill
            myImageview.image = pickedImage
            
        }
        _picker.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Set Image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinisjPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImageview.image = image
        } else{
            print("Error in importing image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Consult Doctor
     * Step 1. Store image
     * Step 2. Consult Doctor screen
     */
    

    
    
    @IBAction func emailDoctor(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self;
            //mail.setCcRecipients(["yyyy@xxx.com"])
            mail.setSubject("Your messagge")
            mail.setMessageBody("Message body", isHTML: false)
            if let imageData: NSData = UIImagePNGRepresentation(myImageview.image!)! as NSData{
                mail.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName.png")
            }
            self.present(mail, animated: true, completion: nil)
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}


