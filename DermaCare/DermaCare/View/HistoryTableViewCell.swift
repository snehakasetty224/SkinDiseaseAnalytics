//
//  HistoryTableViewCell.swift
//  DermaCare
//
//  Created by Sneha Kasetty Sudarshan on 4/18/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var ressultLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
