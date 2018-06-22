//
//  CoreMlViewController.swift
//  DermaCare
//
//  Created by Sneha Kasetty Sudarshan on 5/5/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Social
import MessageUI
import Firebase


class CoreMlViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var coremlresult : [VNClassificationObservation] = []
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func detect(image: CIImage) {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: inception_coreml().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            self.coremlresult = results
            
            guard var nextresults = request.results as? [VNClassificationObservation],
                let nextresult = nextresults.popLast()
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            if ((topResult.identifier.contains("Melanoma")) && (topResult.confidence > 0.90)) {
                DispatchQueue.main.async {
                   /* self.navigationItem.title = "Rash!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false */
                    self.resultLabel.text = "This might be Melanoma"
                    
                }
            } else if ((topResult.identifier.contains("Basal")) && (topResult.confidence > 0.90)){
                DispatchQueue.main.async {
                   
                    self.resultLabel.text = "This might be Carcinoma"
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    self.resultLabel.text = "This might not be any serious problem"
                    
                }
            }
            
           self.performSegue(withIdentifier: "result", sender: self)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            
            detect(image: ciImage)
            
        }
    }

    @IBAction func cameraClicked(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func emailDoctor(_ sender: Any) {
     
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self;
            //mail.setCcRecipients(["yyyy@xxx.com"])
            mail.setSubject("Your messagge")
            mail.setMessageBody("Message body", isHTML: false)
            if let imageData: NSData = UIImagePNGRepresentation(imageView.image!)! as NSData{
                mail.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName.png")
            }
            self.present(mail, animated: true, completion: nil)
        }

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveImage(_ sender: Any) {
        
        
        let database = Database.database().reference()
        let userID :String = (Auth.auth().currentUser?.uid)!
        let storage = Storage.storage().reference()
        
        let tempImageRef = storage.child("ImagesUploaded/\(userID)")
        let id = String(format:"%.0f", Date().timeIntervalSince1970*1000)
        let image = self.imageView.image
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
                refUser.child("result").setValue(self.resultLabel.text)
                
                //refUser.setValue(imageURL)
                
                let alert = UIAlertController(title: "Alert", message: "Saved Successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                print (error?.localizedDescription)
            }
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result" {
            let resultcontroller = segue.destination as! DiagnoseController
            resultcontroller.result = self.coremlresult
        }
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

