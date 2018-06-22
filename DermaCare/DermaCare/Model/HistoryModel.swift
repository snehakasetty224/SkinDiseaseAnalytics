//
//  HistoryModel.swift
//  DermaCare
//
//  Created by Pooj on 4/30/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

class HistoryModel: NSObject {
    
    var result: String?
    var url: String?
    var name: String?
    
    init(result: String, url: String, name: String)
    {
        self.result = result
        self.url = url
        self.name = name
    }
    
}
