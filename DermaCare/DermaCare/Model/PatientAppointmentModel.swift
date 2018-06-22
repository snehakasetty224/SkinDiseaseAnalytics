//
//  AppointmentModel.swift
//  DermaCare
//
//  Created by Pooj on 5/1/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

import UIKit

class PatientAppointmentModel: NSObject {
    
    var docName: String?
    var date: String?
    var doctorGender: String?
    var doctorPhoto: String?
    var doctorExperience : String?
    var doctorSpecialization: String?
    var doctorAddress: String?
    
    override init()
    {
        
    }
    
    init(docName: String, date: String, doctorGender: String, doctorPhoto: String, doctorExperience:String, doctorSpecialization:String, doctorAddress:String)
    {
        self.docName = docName
        self.date = date
        self.doctorGender = doctorGender
        self.doctorPhoto = doctorPhoto
        self.doctorExperience = doctorExperience
        self.doctorSpecialization = doctorSpecialization
        self.doctorAddress = doctorAddress
    }
    
}
