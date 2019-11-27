//
//  ClimaUtils.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import Foundation

class ClimaUtils {

   static func degreeConverter(degreeK: Int, currentDegree: String) -> Int {
        if currentDegree == "℃" {
            return Int(degreeK - 273)
        } else {
            return Int((degreeK - 273) * 9 / 5 + 32)
        }
    }
}
