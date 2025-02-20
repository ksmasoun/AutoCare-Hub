//
//  EditCarViewController.swift
//  Midterm-Karanveer
//
//  Created by Karanveer Singh on 2/14/25.
//

import UIKit

class EditCarViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tfMake: UITextField!
    @IBOutlet var tfModel: UITextField!
    @IBOutlet var tfYear: UITextField!
    @IBOutlet var tfKms: UITextField!
    @IBOutlet var sgColor: UISegmentedControl!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
        
    @IBAction func submitCarDetails(_ sender: Any) {
        
        if (tfMake.text!.isEmpty || tfModel.text!.isEmpty || tfYear.text!.isEmpty || tfKms.text!.isEmpty) {
            let alert = UIAlertController(title: "Incomplete Field(s)", message: "Complete all fields to Submit", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAction)
            present(alert, animated: true)
        }
        
        let alert = UIAlertController(title: "Submit Details", message: "Do you want to submit?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
            self.submitCarInfo()
            self.dismiss(animated: true, completion: nil)
            
        })
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    func submitCarInfo() {
        let make = tfMake.text!
        let model = tfModel.text!
        let year = tfYear.text!
        let kms = tfKms.text!
        let sgColorVal = sgColor.selectedSegmentIndex
        
        let color: String
        if sgColorVal == 0 {
            color = "Red"
        } else if sgColorVal == 1 {
            color = "Blue"
        } else if sgColorVal == 2 {
            color = "White"
        } else if sgColorVal == 3 {
            color = "Grey"
        } else {
            color = "Green"
        }
        
        let car = CarData()
        car.initWithCarDetails(make: make, model: model, year: year, color: color, kms: kms)

        let mainDelegate = (UIApplication.shared.delegate as! AppDelegate)
        mainDelegate.carData = car
    }
}
