//
//  HKManager.swift
//  DermaCare
//
//  Created by Pooj on 2/14/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit
import HealthKit
import Firebase

class HKManager {

    let healthKitStore:HKHealthStore = HKHealthStore()
    
    //var height : String!, weight:String!, bloodType:String!, birthDate: String!, sex:String!, heartRate:String!, respRate:String!, age:String!, date:String!, patient:String!
   
    weak var delegate: HKManagerDelegate?
    
    var healthTree: DatabaseReference?
    
    private var databaseHandle: DatabaseHandle!
    
    var user: User?
    
    var ifHealthSyc = false
    
    func requestData(user: User, callback: @escaping (Bool) -> ()) {
        // the data was received and parsed to String
        self.user = user
        self.healthTree = Database.database().reference(withPath: "userlist").child(user.uid).child("health")
        
        if HKHealthStore.isHealthDataAvailable() {
            authorizeHealthKit() {
                success, error in
                if !success {
                    self.ifHealthSyc = false
                    print( "ERROR in permission")
                }
            }
        }
         callback(ifHealthSyc)
    }
    /*
     Generate the query to get Quantity for Weight
     */
    func getWeightFromHealth() {
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        
        // 2. Call the method to read the most recent weight sample
        readMostRecentSample(sampleType: sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(String(describing: error?.localizedDescription))")
                return;
            }
            
            var weightLocalizedString = "Unknown";
            // 3. Format the weight to display it on the screen
            let weight1 = mostRecentWeight as? HKQuantitySample;
            if let kilograms = weight1?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) {
                let weightFormatter = MassFormatter()
                weightFormatter.isForPersonMassUse = true;
                weightLocalizedString = weightFormatter.string(fromKilograms: kilograms)
            }
            
            // 4. Update UI in the main thread
            DispatchQueue.main.async(execute: { () -> Void in
                //self.weight = weightLocalizedString
                self.healthTree?.child("weight").setValue(weightLocalizedString)
            });
        });
    }
    
    /*
     Generate the query to get Quantity for Height
     */
    func getHeightFromHealth()
    {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)
        
        // 2. Call the method to read the most recent Height sample
        readMostRecentSample(sampleType: sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if( error != nil ) {
                print("Error reading weight from HealthKit Store: \(String(describing: error?.localizedDescription))")
                return;
            }
            
            var heightLocalizedString = "Unknown";
            let height1 = mostRecentHeight as? HKQuantitySample;
            // 3. Format the height to display it on the screen
            if let meters = height1?.quantity.doubleValue(for: HKUnit.meter()) {
                let heightFormatter = LengthFormatter()
                heightFormatter.isForPersonHeightUse = true;
                heightLocalizedString = heightFormatter.string(fromMeters : meters);
            }
            
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            DispatchQueue.main.async(execute: { () -> Void in
               self.healthTree?.child("height").setValue(heightLocalizedString)
            });
        })
        
    }
    
   
    func authorizeHealthKit(_ completion: ((_ success: Bool, _ error: String?) -> Void)!) {
        if !HKHealthStore.isHealthDataAvailable() {
            
            if (completion != nil) {
                ifHealthSyc = false
                completion(false, "Health Kit not available")
            }
            return
        }
        
        
        let healthKitTypesToRead = Set([
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)! as HKCharacteristicType,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)! as HKCharacteristicType,
            HKObjectType.characteristicType(forIdentifier: .bloodType)! as HKCharacteristicType,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)! as HKQuantityType,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)! as HKQuantityType,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)! as HKQuantityType,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)! as HKQuantityType,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)! as HKQuantityType
            
        ])
        
        healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) {
            (success, error) -> Void in
            if !success {
                let error = "Error while requesting authorization."
                if (completion != nil) {
                    self.ifHealthSyc = false
                    completion(false, error)
                }
                return
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    
                    //1. Get Weight
                    self.getHeightFromHealth()
                    
                    //2. Get Height
                    self.getWeightFromHealth()
                    
                    //3. Get Blood Type, Gender, Age, DOB
                    self.readProfile()
                    
                    self.ifHealthSyc = true
                })
                
                self.delegate?.didRecieveDataUpdate(data: self)
                self.startObservingDatabase(user: self.user!)
            }
        }
    }
    
    
    
    /**
     Generate the query to get the charatcteristic data
     */
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample?, NSError?) -> Void)!)
    {
        
        // 1. Build the Predicate
        let past = NSDate.distantPast as NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past as Date, end:now as Date, options: .strictEndDate)
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            if error != nil {
                completion(nil,error! as NSError)
                return;
            }
            
            // Get the first sample
            let mostRecentSample = results?.first as? HKQuantitySample
            
            // Execute the completion closure
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        // 5. Execute the Query
        self.healthKitStore.execute(sampleQuery)
    }
    
    func readProfile() {
        var ageStr:String?
        /** DOB **/
        if let birthDay = try? healthKitStore.dateOfBirth() {
            let today = Date()
            _ = Calendar.current
            let differenceComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: birthDay, to: today, options: NSCalendar.Options(rawValue:0) )
            let age = differenceComponents.year
            
            ageStr = "\(age ?? 0)"
            self.healthTree?.child("dob").setValue(String(describing: birthDay))
        } else {
            ageStr = "Not Set"
            self.healthTree?.child("dob").setValue("Not Set")
        }
        
        /** Age **/
        self.healthTree?.child("age").setValue(ageStr)
        
        
        /** GENDER **/
        var sexStr:String = "Unknown"
        let biologicalSex:HKBiologicalSexObject? = try? healthKitStore.biologicalSex()
        if biologicalSex?.biologicalSex == HKBiologicalSex.notSet {
            sexStr = "Not Set"
        } else{
            if(biologicalSex == nil) {
                sexStr = "Not Set"
            } else{
                sexStr = String(self.biologicalSexLiteral(biologicalSex!.biologicalSex))
            }
            self.healthTree?.child("sex").setValue(sexStr)
        }
        
        
        /** BLOOD TYPE **/
        var typeStr:String = "Unknown"
        let bloodType:HKBloodTypeObject? = try? healthKitStore.bloodType()
        
        if bloodType?.bloodType == HKBloodType.notSet {
            typeStr = "Not Set"
        } else{
            //typeStr = String(describing: bloodType?.bloodType)
            typeStr = self.bloodTypeLiteral(bloodType?.bloodType)
        }
        self.healthTree?.child("bloodType").setValue(String(typeStr))
    
        fetchLatestHeartRateSample()
        
        
        self.healthTree?.child("respiratoryRate").setValue("No Data")
        self.healthTree?.child("bodyTemperature").setValue("No Data")
        
    }
    
    /*
     Get Blood Type text from defined parameters
     */
    func bloodTypeLiteral(_ bloodType:HKBloodType?)->String
    {
        
        var bloodTypeText = "Unknown";
        if bloodType != nil {
            
            switch( bloodType! ) {
            case .aPositive:
                bloodTypeText = "A+"
            case .aNegative:
                bloodTypeText = "A-"
            case .bPositive:
                bloodTypeText = "B+"
            case .bNegative:
                bloodTypeText = "B-"
            case .abPositive:
                bloodTypeText = "AB+"
            case .abNegative:
                bloodTypeText = "AB-"
            case .oPositive:
                bloodTypeText = "O+"
            case .oNegative:
                bloodTypeText = "O-"
            default:
                break;
            }
            
        }
        return bloodTypeText;
    }

    /*
     Get Gender Type text from defined parameters
     */
    func biologicalSexLiteral(_ biologicalSex:HKBiologicalSex?)->String
    {
        var biologicalSexText = "Unknown"
        
        if  biologicalSex != nil {
            
            switch( biologicalSex! )
            {
            case .female:
                biologicalSexText = "Female"
            case .male:
                biologicalSexText = "Male"
            default:
                break;
            }
            
        }
        return biologicalSexText;
    }

   
    public func fetchLatestHeartRateSample() {
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                //completion(nil)
                return
        }
        
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                let cnt = (results?.count)! - 1
                //latest
                guard let currData1:HKQuantitySample = results![cnt] as? HKQuantitySample else { return }
                
                let heartrateval = currData1.quantity.doubleValue(for: heartRateUnit)
                print("Heart Rate: \(heartrateval)")
                self.healthTree?.child("heartrate").setValue("\(heartrateval)")
                
        }
        
        healthKitStore.execute(query)
    }
    
    func startObservingDatabase (user: User) {
        databaseHandle = healthTree?.observe(.value, with: { (snapshot) in
            var newItems = [HealthModel]()
            
            for itemSnapShot in snapshot.children {
                let item = HealthModel(snapshot: itemSnapShot as! DataSnapshot)
                newItems.append(item)
            }
            
        })
    }
    
    deinit {
        healthTree?.removeObserver(withHandle: databaseHandle)
    }
}

