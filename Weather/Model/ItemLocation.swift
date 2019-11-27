//
//  ItemLocation.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON


class ItemLocation: Object {
    
    @objc dynamic var cityLoc: String = ""
    @objc dynamic var iconLoc: String = ""
    @objc dynamic var tempLoc: Int = 0
    @objc dynamic var baseLoc: String = ""
   
    func updateLocationData(url: String, parameters: [String: String]) {
       
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let json : JSON = JSON(response.result.value!)
                let realm = try! Realm()
                try! realm.write {
                   self.cityLoc = json["name"].stringValue
                   self.iconLoc = ClimaDataModel.updateIcon(condition: json["weather"][0]["id"].intValue)
                   self.tempLoc = Int(json["main"]["temp"].doubleValue)
                   self.baseLoc = ClimaDataModel.updateBackground(conditionB: json["weather"][0]["id"].intValue)
                }
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
}
