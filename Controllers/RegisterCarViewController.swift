import Foundation
import UIKit

class RegisterCarViewController: UIViewController {

    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var kmsTextField: UITextField!
    @IBOutlet weak var lastServicedSegment: UISegmentedControl!
    
    var currentUser: UserData?

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        // getting values from the UI
        guard let make = makeTextField.text,
              let model = modelTextField.text,
              let year = Int(yearTextField.text ?? ""),
              let kms = Double(kmsTextField.text ?? "") else {
            print("Please fill in all fields correctly.")
            return
        }

        // get last serviced from segmented control
        let lastServicedOptions = ["This Month", "Over a Month", "Over a Year"]
        let lastServiced = lastServicedOptions[lastServicedSegment.selectedSegmentIndex]

        // app delegate reference
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        // creating new car object
        let newCar = CarData()
        newCar.make = make
        newCar.model = model
        newCar.year = year
        newCar.kms = kms
        newCar.lastServiced = lastServiced
        newCar.ownerId = currentUser?.id

        // insert to db
        let success = appDelegate.insertCarIntoDatabase(car: newCar)

        if success {
            print("Car inserted successfully")
            print("Current User: \(currentUser?.name ?? "nil") | ID: \(currentUser?.id ?? -1)")
            performSegue(withIdentifier: "toConfirmation", sender: self)
        } else {
            print("Failed to insert car")
            let alert = UIAlertController(title: "Error", message: "Failed to insert car into database.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // preparing data for confirmation view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConfirmation",
           let dest = segue.destination as? CarConfirmationViewController {
            
            dest.userName = currentUser?.name
            dest.carYear = Int(yearTextField.text ?? "")
            dest.carMake = makeTextField.text
            dest.carModel = modelTextField.text
        }
    }
}
