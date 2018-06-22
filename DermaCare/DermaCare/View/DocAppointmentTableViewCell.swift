//
//  DocAppointmentTableViewCell.swift
//  DermaCare
//
//  Created by sindhya on 5/3/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit

class DocAppointmentTableViewCell: UITableViewCell {

    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var appmtDate: UILabel!
    @IBOutlet weak var patientPhone: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
