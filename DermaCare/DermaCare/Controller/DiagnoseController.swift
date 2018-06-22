//
//  DiagnoseController.swift
//  DermaCare
//
//  Created by Pooj on 2/1/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Vision
import CoreML
import Firebase
class DiagnoseController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var chatData = [[String:Any]]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var textInput: UITextField!
    @IBOutlet var bottomBarConstraint: NSLayoutConstraint!
    
    var ref = Database.database().reference(withPath: "userlist")
    private var databaseHandle: DatabaseHandle!
    var result : [VNClassificationObservation] = []
    
    var finalResultString =  String()
    var chatbotresult : String?
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingDatabase ()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: UIImage(named: "chat"))
       
        //let topResult = self.result.first!
        //print(topResult.confidence)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //tableView.separatorStyle = .none
    }
    
    @IBAction func goToDashboard(_ sender: UIBarButtonItem) {
        //navigationController?.popToRootViewController(animated: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: false, completion: {
            self.navigationController?.popToRootViewController(animated: true)
            if let tabBarController = appDelegate.window!.rootViewController as? RootTabController {
                tabBarController.selectedIndex = 1
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        let value = textInput.text
        if ((value?.characters.count)! > 0) {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let time = String(format: "%d : %d",hour,minute)
            displayMessage(message: value!, from: "me", time:time)
            textInput.text = ""
            
            ChatModel.getChatString(message: value!) { (json) in
                //print(json.message!)
                var responseMessage = json.message!
                if(json.message!.contains("result:")) {
                    
                    responseMessage = "Please click on Next to view the final result"
                    //self.displayMessage(message: responseMessage, from: "server", time: json.time!)
                    
                    let arr = json.message!.components(separatedBy: ":")
                    self.chatbotresult = arr[1]
                    print(arr[1])
                    
                    let topResult = self.result.first!
                    
                    let chatbotres = self.chatbotresult ?? " "
                    
                   
                    let melanomaResultString = "You could be suffering from : Melanoma \n Please contact our doctor immediately. \n\nYou can find more details about the Melanoma here : \nhttps://www.mayoclinic.org/diseases-conditions/melanoma/symptoms-causes/syc-20374884"
                    
                     let carcinomaResultString = "You could be suffering from : Carcinoma \n Please contact our doctor immediately. \n\nYou can find more details about the Carcinoma here : \nhttps://www.mayoclinic.org/diseases-conditions/basal-cell-carcinoma/symptoms-causes/syc-20354187"
                    
                    let bothResultString =  "You could be suffering from : Melanoma or Carcinoma \n\n Please contact our doctor immediately. \n\nYou can find more details about the Melanoma here : \nhttps://www.mayoclinic.org/diseases-conditions/melanoma/symptoms-causes/syc-20374884 \n\nYou can find more details about the Carcinoma here : \nhttps://www.mayoclinic.org/diseases-conditions/basal-cell-carcinoma/symptoms-causes/syc-20354187 \n"
                    
                    if(chatbotres == "Melonama,Carcinoma") {
                        if ((topResult.identifier.contains("Melanoma")) && (topResult.confidence > 0.90)) {
                            self.finalResultString.append(melanomaResultString)
                        } else if ((topResult.identifier.contains("Basal")) && (topResult.confidence > 0.90)){
                            self.finalResultString.append(carcinomaResultString)
                        } else {
                            self.finalResultString.append(bothResultString)
                        }
                    }
                    else if(chatbotres == "Carcinoma") {
                        if ((topResult.identifier.contains("Melanoma")) && (topResult.confidence > 0.90)) {
                            self.finalResultString.append(bothResultString)
                        } else {
                            self.finalResultString.append(carcinomaResultString)
                        }
                    }
                        
                    else if(chatbotres == "Melanoma") {
                        if ((topResult.identifier.contains("Basal")) && (topResult.confidence > 0.90)){
                            self.finalResultString.append(bothResultString)
                        } else {
                            self.finalResultString.append(melanomaResultString)
                        }
                    } else if(chatbotres == "notrash"){
                        self.finalResultString.append("You are not suffering from any Skin Cancer! Please see some nearby pharmacy and apply an ointment")
                    }
                  
                } else {
                    //continue
                }
                
                self.displayMessage(message: responseMessage, from: "server", time: json.time!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "finalresult" {
            let resultcontroller = segue.destination as! FinalResultController
            resultcontroller.resultmessage = self.finalResultString
        }
    }
    
    func displayMessage(message:String, from:String, time:String) {
        chatData.append(["time":time, "message":message, "from":from])
         DispatchQueue.main.async {
            self.tableView.reloadData()
            //self.tableView.scrollToLastRow(animated:animated)
        }
    }
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(self)
        return false
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        bottomBarConstraint.constant = keyboardSize - 1.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        bottomBarConstraint.constant = -1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageData = chatData[indexPath.row]
        var cell:ChatMessageViewCell? = nil
        if ( (messageData["from"] as? String) != "me" ) {
            cell = tableView.dequeueReusableCell(withIdentifier: "serverChatViewCell") as? ChatMessageViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "myChatViewCell") as? ChatMessageViewCell
        }
        
        cell?.setMessage(data:messageData)
        
        return cell!
    }
    
    
    func startObservingDatabase () {
        let userID = Auth.auth().currentUser?.uid
        
        ref.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.username = value!["userName"] as? String
            let startmessage = "Hello \(self.username ?? " ") How are you doing today?"
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let time = String(format: "%d : %d",hour,minute)
            
            self.displayMessage(message: startmessage, from: "server", time: time)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func finalNextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "finalresult", sender: self)
    }
    
}


