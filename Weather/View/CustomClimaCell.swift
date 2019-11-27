//
//  CustomClimaCell.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit

class CustomClimaCell: UITableViewCell {

    @IBOutlet weak var dayClimaCell: UILabel!
    @IBOutlet weak var iconClimaCell: UIImageView!
    @IBOutlet weak var tempMaxClimaCell: UILabel!
    @IBOutlet weak var tempMinClimaCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = .clear
    }
}
