//
//  CustomLocationCell.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit

class CustomLocationCell: UITableViewCell {

    @IBOutlet weak var cityLocationCell: UILabel!
    @IBOutlet weak var iconLocationCell: UIImageView!
    @IBOutlet weak var tempLocationCell: UILabel!
    @IBOutlet weak var baseLocationCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
