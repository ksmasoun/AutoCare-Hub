import Foundation
import UIKit

class CarConfirmationViewController: UIViewController {

    var userName: String?
    var carYear: Int?
    var carMake: String?
    var carModel: String?
    var currentUser: UserData?

    @IBOutlet weak var confirmationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for checking and debugging, ignore
        print("userName: \(userName ?? "nil")")
        print("carYear: \(carYear?.description ?? "nil")")
        print("carMake: \(carMake ?? "nil")")
        print("carModel: \(carModel ?? "nil")")

        
        //to display confirmation message
        if let name = userName,
           let year = carYear,
           let make = carMake,
           let model = carModel {
            confirmationLabel.text = "Hello \(name), your \(year) \(make) \(model) has been added to the system!"
        } else {
            confirmationLabel.text = "Something went wrong." //more debbugging!
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewCars",
           let dest = segue.destination as? ViewCarsViewController {
            dest.currentUser = currentUser // continuing to pass on current user info
        }
    }
}
