//
//  AppointmentViewCell.swift
//  DermaCare
//
//  Created by Pooj on 4/27/18.
//  Copyright © 2018 Pooja. All rights reserved.

import UIKit

class AppointmentViewCell: UICollectionViewCell {
    
    var task = URLSessionDownloadTask()
    var session = URLSession.shared
    
    // Loads Thumbnail
    @IBOutlet weak var historyImage: UIImageView!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
}
