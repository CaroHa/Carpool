//
//  OfferedRideTableViewCell.swift
//  ComeUp
//
//  Created by Eva on 21.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit


class OfferedRideTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var seatsPriceLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}