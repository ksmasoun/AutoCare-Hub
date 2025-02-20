//
//  DisplayCarViewController.swift
//  Midterm-Karanveer
//
//  Created by Karanveer Singh on 2/14/25.
//

import UIKit

class DisplayCarViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func unwindToDisplayViewController(sender: UIStoryboardSegue){
    }
    
    @IBOutlet var lbMake: UILabel!
    @IBOutlet var lbModel: UILabel!
    @IBOutlet var lbYear: UILabel!
    @IBOutlet var lbColor: UILabel!
    @IBOutlet var lbKms: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        let car = mainDelegate.carData

        if (car != nil) {
            lbMake.text = "Make: \(car!.carMake!)"
            lbModel.text = "Model: \(car!.carModel!)"
            lbYear.text = "Year: \(car!.carYear!)"
            lbColor.text = "Color: \(car!.carColor!)"
            lbKms.text = "Car Distance travelled: \(car!.carKms!) KM"
        } else {
            lbMake.text = "Make details not found."
            lbModel.text = "Model details not found."
            lbYear.text = "Year details not found."
            lbColor.text = "Color details not found."
            lbKms.text = "Car Distance travelled not found."
        }
    }
}
