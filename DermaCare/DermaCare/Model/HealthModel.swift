//
//  HealthModel.swift
//  DermaCare
//
//  Created by Pooj on 2/19/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HealthModel {
    
    let key: String?
    let age: String?
    let bloodType: String?
    let sex: String?
    let dob: String?
    let weight: String?
    let height: String?
    
    let ref: DatabaseReference?
    
    
    init(snapshot: DataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
       
        let snapshotValue = snapshot.value as? [String : String]
        
        age = snapshotValue?["age"]
        bloodType = snapshotValue?["bloodType"]
        sex = snapshotValue?["sex"]
        dob = snapshotValue?["dob"]
        weight = snapshotValue?["weight"]
        height = snapshotValue?["height"]
    }
    
}
