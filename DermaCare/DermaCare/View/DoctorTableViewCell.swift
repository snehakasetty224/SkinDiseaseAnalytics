//
//  DoctorTableViewCell.swift
//  DermaCare
//
//  Created by sindhya on 4/29/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit

class DoctorTableViewCell: UITableViewCell {

    
    @IBOutlet weak var docImage: UIImageView!
    
    @IBOutlet weak var docName: UILabel!
    
    @IBOutlet weak var docSpec: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    
    @IBOutlet weak var hours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
