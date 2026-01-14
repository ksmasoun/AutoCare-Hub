import UIKit

class LoginSuccessfulRedirectViewController: UIViewController {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!

    var user: UserData?
    
    @IBAction func unwindToDashboardViewController(sender: UIStoryboardSegue){
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblName.text = user?.name
        lblEmail.text = user?.email
    }
    
    
    
    //sending the user forward to car registeration or for viewing cars
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegisterCar",
           let dest = segue.destination as? RegisterCarViewController {
            dest.currentUser = self.user
        } else if segue.identifier == "toViewCars",
                  let dest = segue.destination as? ViewCarsViewController {
            dest.currentUser = self.user
        }
    }

}
