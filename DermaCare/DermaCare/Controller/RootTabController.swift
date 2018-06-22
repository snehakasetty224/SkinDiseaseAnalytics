//
//  RootTabController.swift
//  DermaCare
//
//  Created by Pooj on 4/22/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import FirebaseAuth

class RootTabController: UITabBarController, UITabBarControllerDelegate {
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
        // Create Tab one
        let tabOne = HomeController()
        
        tabOne.user = self.user
        // Create Tab two
        let tabTwo = DoctorController()
        
        let tabThree = AccountController()
        
        self.viewControllers = [tabOne, tabTwo, tabThree]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
    }
}
