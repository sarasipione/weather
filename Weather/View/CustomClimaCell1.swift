//
//  CustomClimaCell1.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit

class CustomClimaCell1: UITableViewCell {

    @IBOutlet weak var humidityClimaCell: UILabel!
    @IBOutlet weak var pressureClimaCell: UILabel!
    
    override func awakeFromNib() {
          super.awakeFromNib()
        setup()
      }
    
    func setup() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = .clear
    }
}
