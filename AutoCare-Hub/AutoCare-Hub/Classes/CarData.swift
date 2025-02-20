//
//  CarData.swift
//  Midterm-Karanveer
//
//  Created by Karanveer Singh on 2/14/25.
//

import UIKit

class CarData: NSObject {
    var carMake: String?
    var carModel: String?
    var carYear: String?
    var carColor: String?
    var carKms: String?
    
    func initWithCarDetails(make: String, model: String, year: String, color: String, kms: String) {
        carMake = make
        carModel = model
        carYear = year
        carColor = color
        carKms = kms
    }
}
