//
//  DoctorModel.swift
//  DermaCare
//
//  Created by sindhya on 4/30/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit

class DoctorModel: NSObject {
    
    var docName: String?
    var specialization: String?
    var experience: String?
    var hours: String?
    var fees: String?
    var id: String?
    var address: String?
    var userphoto: String?
    var age: String?
    var gender: String?
    override init()
    {
        
    }
    
    init(id: String, name: String, spec: String,exp: String,hours:String,fees:String, address:String, userphoto: String, age: String, gender: String)
        {
            self.docName = name
            self.specialization = spec
            self.hours = hours
            self.experience = exp
            self.fees = fees
            self.id = id
            self.address = address
            self.userphoto = userphoto
            self.age = age
            self.gender = gender
        }
    
}
