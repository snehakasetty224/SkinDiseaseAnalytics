//
//  HKManagerDelegate.swift
//  DermaCare
//
//  Created by Pooj on 2/16/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

protocol HKManagerDelegate: class {
    func didRecieveDataUpdate(data: HKManager)
}
