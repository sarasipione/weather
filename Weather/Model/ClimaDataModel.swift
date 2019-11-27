//
//  ClimaDataModel.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClimaDataModel {
    
    var city : String = ""
    var day : String = ""
    var date : String = ""
    
    var condition : Int = 0
    var climaIconName : String = ""
    
    var temperature : Int = 0
    var description : String = ""
    
    var background : String = ""
    
    var humidity: Int = 0
    var pressure: Int = 0
    var windSpeed: Double = 0
    var clouds: Int = 0

   
    class func updateIcon(condition: Int) -> String {
        
    switch (condition) {
    
        case 0...300 :
            return "iconStorm"
        
        case 301...500 :
            return "iconRainy"
        
        case 501...600 :
            return "iconRainy"
        
        case 601...700 :
            return "iconSnow"
        
        case 701...771 :
            return "iconCloudySun"
        
        case 772...799 :
            return "iconStorm"
        
        case 800 :
            return "iconSunny"
        
        case 801...804 :
            return "iconCloudy"
        
        case 900...903, 905...1000  :
            return "iconStorm"
        
        case 903 :
            return "iconSnow"
        
        case 904 :
            return "iconSunny"
        
        default :
            return "dunno"
        }
    }
    
    class func updateBackground(conditionB: Int) -> String {
        
    switch (conditionB) {
    
        case 0...300 :
            return "baseStorm"
        
        case 301...500 :
            return "baseRainy"
        
        case 501...600 :
            return "baseRainy"
        
        case 601...700 :
            return "baseSnow"
        
        case 701...771 :
            return "baseCloudySun"
        
        case 772...799 :
            return "baseStorm"
        
        case 800 :
            return "baseSunny"
        
        case 801...804 :
            return "baseCloudySun"
        
        case 900...903, 905...1000  :
            return "baseStorm"
        
        case 903 :
            return "baseSnow"
        
        case 904 :
            return "baseSunny"
        
        default :
            return "dunno"
        }
    }
}
