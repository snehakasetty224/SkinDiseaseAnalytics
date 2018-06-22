//
//  PharmacyViewCell.swift
//  DermaCare
//
//  Created by Pooj on 4/27/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit

class PharmacyViewCell: UITableViewCell {
    
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UIImageView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    var business: PharmacyModel! {
        didSet {
            
            nameLabel.text = business.name
            if(business.imageURL != nil){
                thumbImageView.setImageWith(business.imageURL!)
            }
            
            if(business.ratingImageURL != nil){
                ratingLabel.setImageWith(business.ratingImageURL!)
            }
            
            if(business.categories != nil){
                categoryLabel.text = business.categories
            }
            
            reviewLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance
            categoryLabel.text = business.categories
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
