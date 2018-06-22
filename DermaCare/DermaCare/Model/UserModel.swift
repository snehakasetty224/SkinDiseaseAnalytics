//
//  UserModel.swift
//  DermaCare
//
//  Created by Pooj on 2/19/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserModel {
    
    let key: String
    let userName: String
    let email: String
    let userType: String
    let phone: String
    
    let ref: DatabaseReference?
    var isHealthSync: Bool
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        userName = snapshotValue["userName"] as! String
        email = snapshotValue["email"] as! String
        userType = snapshotValue["userType"] as! String
        phone = snapshotValue["phone"] as! String
        isHealthSync = snapshotValue["isHealthSync"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "userName": userName,
            "email": email,
            "userType": userType,
            "phone": phone,
            "isHealthSync" : isHealthSync
        ]
    }
    
}
