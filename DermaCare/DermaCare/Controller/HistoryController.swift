//
//  HistoryController.swift
//  DermaCare
//
//  Created by Pooj on 4/17/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class HistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var imgURL = [String]()
    var imagename = [String]()
    var results = [String]()
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var noTable: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        loaddata()
        self.tableview.reloadData()
        
    }
    
    func loaddata(){
        let userID: String = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
        
        let refuser = ref.child("userlist/\(userID)").child("Photos")
        refuser.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                
                let child = (item as! DataSnapshot).value as? [String:Any]
                let childkey = (item as! DataSnapshot).key
                
                self.imagename.append(childkey)
                print("id", self.imagename)
                
                let result = child?["result"] as? String ?? ""
                let url = child?["url"] as? String ?? ""
                
                self.imgURL.append(url)
                self.results.append(result)
                print("result",self.results)
                print("url", self.imgURL)
                
                DispatchQueue.main.async(execute: {
                    self.tableview.reloadData()
                })
            }
        })
        
        
        /*  refuser.observe(.value, with: {(snapshot) in
         
         
         for item in snapshot.children{
         let child = item as AnyObject
         
         
         self.imagename.append(child.key)
         self.imgURL.append(child.value)
         
         DispatchQueue.main.async(execute: {
         self.tableview.reloadData()
         })
         }
         }) */
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.imagename.count > 0) {
            self.noTable.text = ""
            return self.imagename.count
        }
        else {
            self.noTable.text = "No App Diagnosis Found."
            tableView.separatorStyle = .none
            return 0
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableview.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as?HistoryTableViewCell else {
            return UITableViewCell()
        }
        if(self.imagename.count == 0){
            cell.ressultLabel?.text = "No App Diagnosis Found"
        }
        
        let userID: String = (Auth.auth().currentUser?.uid)!
        let imageNameLocal = self.imagename[indexPath.row]
        let resultLocal = self.results[indexPath.row]
        
        let storage = Storage.storage().reference(forURL: "gs://dermacare-b1017.appspot.com/ImagesUploaded/\(userID)/\(imageNameLocal)")
        
        storage.getMetadata { metadata, error in
            if let error = error {
                print("error occurred", error)
            }else{
                let date = metadata?.timeCreated
                //print("date", date )
                cell.ressultLabel?.text = resultLocal
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                cell.idLabel?.text = imageNameLocal
                cell.dateLabel?.text = formatter.string(from: date as! Date)
            }
        }
        
        /*    storage.getData(maxSize: 10 * 1024 * 1024) { data, error in
         if data != nil{
         let loadedImage = UIImage(data: data!)
         DispatchQueue.main.async {
         cell.imageView?.image = loadedImage
         self.tableview.reloadData()
         }
         }
         }
         */
        
        
        //print(imageURL)
        /*
         storage.downloadURL(completion: { (url, error) in
         
         if error != nil {
         print(error?.localizedDescription)
         return
         }
         
         URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
         
         if error != nil {
         print(error)
         return
         }
         
         guard let imageData = UIImage(data: data!) else { return }
         
         DispatchQueue.main.async {
         cell.imageView?.image = imageData
         self.tableview.reloadData()
         }
         
         }).resume()
         
         }) */
        
        if let imageURL = URL(string: self.imgURL[indexPath.row]) {
            //let url = NSURL(String: imageURL)
            URLSession.shared.dataTask(with: imageURL, completionHandler: {(data,response,error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imgView?.image = UIImage(data: data!)
                    
                }
            }).resume()
        }
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.borderWidth = 1.0
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 1
        cell.layer.borderWidth = 1
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        let borderColor: UIColor = .gray
        cell.layer.borderColor = borderColor.cgColor

        return cell
    }
    
    
    
}
