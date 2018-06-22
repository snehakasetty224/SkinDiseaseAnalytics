//
//  AddAlarmViewController.swift
//  DermaCare
//
//  Created by Sneha Kasetty Sudarshan on 5/4/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import UserNotifications
import os.log


class AddAlarmViewController: UIViewController, UNUserNotificationCenterDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    // @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //@IBOutlet weak var saveButton: UIButton!
    
    
    let picker = UIDatePicker()
    
    var alarm: Alarm?
    
    var alarms = [Alarm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        // Do any additional setup after loading the view.
        
        registerNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            print("save button error")
            return
        }
        
        let name = descriptionField.text ?? ""
        let date = picker.date as NSDate
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        //meal = Meal(name: name, photo: photo, rating: rating, date: date)
        alarm = Alarm(name: name, date: date)
    }
    
    func registerNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow, error in })
        
    }
    
    func sendNotification(date1 :NSDate){
        
        
        
        let content = UNMutableNotificationContent()
        content.title = "Pill Reminder"
        //content.subtitle = "Time to take your pill"
        content.body = descriptionField.text ?? ""
        content.sound = UNNotificationSound(named : "bell.mp3")
        content.badge = 0
        
        let date = date1
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date as Date)
        
        
        //  dateComponents.hour = 2
        // dateComponents.minute = 11
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func createDatePicker(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
        
        picker.datePickerMode = .time
        
    }
    
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: picker.date)
        
        dateField.text = "\(timeString)"
        sendNotification(date1: picker.date as NSDate)
        
        self.view.endEditing(true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
 /*   @IBAction func saveButton(_ sender: Any) {
        
        //  super.prepare(for: segue, sender: sender)
        
        if let savedAlarms = loadalarms() {
            alarms += savedAlarms
        }
        
        let name = descriptionField.text ?? ""
        let date = picker.date as NSDate
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        //meal = Meal(name: name, photo: photo, rating: rating, date: date)
        alarm = Alarm(name: name, date: date)
        
        alarms.append(alarm!)
        // Save the meals.
        saveAlarms()
        
        
        
    } */
    
    private func saveAlarms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(alarms, toFile: Alarm.ArchiveURL.path)
        if isSuccessfulSave {
            print("success  saved" )
            // os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            // os_log("Failed to save meals...", log: OSLog.default, type: .error)
            print("error")
        }
    }
    
    private func loadalarms() -> [Alarm]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Alarm.ArchiveURL.path) as? [Alarm]
        //  companyTableView.reloadData()
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

