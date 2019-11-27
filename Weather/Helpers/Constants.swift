//
//  Constants.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import Foundation

struct K {
    static let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    
    struct MainVC {
        static let cellIdentifier = "ClimaCell"
        static let cellIdentifier1 = "ClimaCell1"
        static let cellIdentifier2 = "ClimaCell2"
        static let cellNibName = "CustomClimaCell"
        static let cellNibName1 = "CustomClimaCell1"
        static let cellNibName2 = "CustomClimaCell2"
        static let segueIdentifier = "goToLocation"
    }
    
    struct LocationVC {
        static let cellIdentifier = "LocationCell"
        static let cellNibName = "CustomLocationCell"
    }
}
