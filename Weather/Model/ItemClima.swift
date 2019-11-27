//
//  ItemClima.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class ItemClima: Object {
    
    @objc dynamic var dayNameClima: String = ""
    @objc dynamic var iconClima: String = ""
    @objc dynamic var tempMaxClima: Int = 0
    @objc dynamic var tempMinClima: Int = 0
    
    @objc var humidityClima: Int = 0
    @objc var pressureClima: Int = 0
    @objc var windSpeedClima: Double = 0
    @objc var cloudsClima: Int = 0
}
