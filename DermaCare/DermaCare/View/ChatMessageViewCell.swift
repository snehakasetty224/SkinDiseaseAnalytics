//
//  ChatMessageViewCell.swift
//  DermaCare
//
//  Created by Pooj on 4/23/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation

import SwiftyJSON
import UIKit

class ChatMessageViewCell: UITableViewCell {
    
    @IBOutlet var messageWrapperView: UIView!
    @IBOutlet public var messageLabel: UILabel!
    @IBOutlet public var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.numberOfLines = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setMessage(data: [String:Any]) {
        timeLabel.text = "\(data["time"]!)"
        messageLabel.text = "\(data["message"]!)"
        
        
        if let messageWrapperView = messageWrapperView {
            let labelSize = messageLabel.sizeThatFits( CGSize(width:messageWrapperView.frame.size.width, height:CGFloat.greatestFiniteMagnitude))
            
            let size = messageLabel.sizeThatFits(labelSize)
            var labelFrame = messageLabel.frame;
            labelFrame.size.height = size.height;
            messageLabel.frame = labelFrame;
        }
    }
    
}
