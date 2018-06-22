//
//  PillReminderTableViewController.swift
//  DermaCare
//
//  Created by Sneha Kasetty Sudarshan on 5/4/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import os.log

class PillReminderTableViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    var alarms = [Alarm]()
    
    @IBOutlet weak var alarmTableView: UITableView!
    
  //  let companyName = ["Apple", "Alphabet", "Amazon"]
   // let share = [99.99, 87.89, 12.34]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        alarmTableView.delegate = self
        alarmTableView.dataSource = self
        
        if let savedAlarms = loadalarms() {
            alarms += savedAlarms
        }
        else {
            // Load the sample data.
            // loadSampleMeals()
            print("this is else")
        }
    }
    
/*    @IBAction func homeButtonPressed(_ sender: Any) {
        
        for viewcontroller in self.navigationController!.viewControllers as Array {
            if viewcontroller.isKind(of: HomeController.self){ // change HomeVC to your viewcontroller in which you want to back.
                self.navigationController?.popToViewController(viewcontroller as! UIViewController, animated: true)
                break
            }
        }

    } */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("alarm count", alarms.count)
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = alarmTableView.dequeueReusableCell(withIdentifier: "cell")
        
        let alarm = alarms[indexPath.row]
        
        cell?.textLabel?.text = alarm.name
        print("alarm name ", alarm.name)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: alarm.date as Date)
        
        cell?.detailTextLabel?.text =  "\(timeString)"
        print("time string", timeString)
        
        // companyTableView.reloadData()
        
        return cell!
        
        
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            alarms.remove(at: indexPath.row)
            saveAlarms()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     super.prepare(for: segue, sender: sender)
     
     switch(segue.identifier ?? "") {
     
     case "AddItem":
     os_log("Adding a new meal.", log: OSLog.default, type: .debug)
     
     case "ShowDetail":
     guard let mealDetailViewController = segue.destination as? AddViewController else {
     fatalError("Unexpected destination: \(segue.destination)")
     }
     
     guard let selectedMealCell = sender as? cell else {
     fatalError("Unexpected sender: \(sender)")
     }
     
     guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
     fatalError("The selected cell is not being displayed by the table")
     }
     
     let selectedMeal = meals[indexPath.row]
     mealDetailViewController.meal = selectedMeal
     
     default:
     fatalError("Unexpected Segue Identifier; \(segue.identifier)")
     }
     }
     */
    private func loadSampleMeals() {
        
        let date1 =  Date(timeIntervalSinceReferenceDate: -123456789.0)
        print("date", date1)
        
        
        guard let alarm1 = Alarm(name: "pills", date: date1 as NSDate) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let alarm2 = Alarm(name: "pills2", date: date1 as NSDate) else {
            fatalError("Unable to instantiate meal2")
        }
        
        alarms += [alarm1, alarm2]
    }
    
    
    
    @IBAction func unwindToAlarmList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddAlarmViewController, let alarm = sourceViewController.alarm {
            
            if let selectedIndexPath = alarmTableView.indexPathForSelectedRow {
                // Update an existing meal.
                alarms[selectedIndexPath.row] = alarm
                alarmTableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: alarms.count, section: 0)
                
                alarms.append(alarm)
                alarmTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            print("sneha alarms", alarms)
            // Save the meals.
            saveAlarms()
        }
    }
    
    private func saveAlarms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(alarms, toFile: Alarm.ArchiveURL.path)
        if isSuccessfulSave {
            print("success")
            // os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            // os_log("Failed to save meals...", log: OSLog.default, type: .error)
            print("save alarm error")
        }
    }
    
    private func loadalarms() -> [Alarm]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Alarm.ArchiveURL.path) as? [Alarm]
        //  companyTableView.reloadData()
    }
    
}

