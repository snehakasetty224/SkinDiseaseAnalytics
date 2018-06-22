//
//  Alarm.swift
//  DermaCare
//
//  Created by Sneha Kasetty Sudarshan on 5/4/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

import os.log

class Alarm: NSObject, NSCoding{
    
    //MARK: Properties
    var name : String
    var date : NSDate
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    // static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("alarms")
    
    //MARK: Types
    
    struct Keys{
        static let name = "name"
        static let date = "date"
    }
    
    
    //MARK: Initialization
    
    
    init?(name: String, date: NSDate){
        self.name = name
        self.date = date
    }
    
    
    //MARK: NSCoding
    
    
    func encode(with acoder: NSCoder){
        acoder.encode(name, forKey: Keys.name)
        acoder.encode(date, forKey: Keys.date)
        
    }
    
   
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: Keys.name) as? String else {
            os_log("Unable to decode the name for a Alarm object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // let name = aDecoder.decodeInteger(forKey: Keys.name) as? String
        
        let date = aDecoder.decodeObject(forKey: Keys.date)
        // Must call designated initializer.
        self.init(name: name, date: date as! NSDate)
        
    }
    
    
}
