//
//  CustomClimaCell2.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit

class CustomClimaCell2: UITableViewCell {

    @IBOutlet weak var windSpeedClimaCell: UILabel!
    @IBOutlet weak var cloudsClimaCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = .clear
    }
}
