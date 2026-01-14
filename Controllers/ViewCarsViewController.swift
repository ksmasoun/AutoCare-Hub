import UIKit

class ViewCarsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userCars: [CarData] = []
    var currentUser: UserData?

    override func viewDidLoad() {
        super.viewDidLoad()

        //testing for connection
        tableView.delegate = self
        tableView.dataSource = self

        // for debbugging
        print("Current user: \(currentUser?.name ?? "nil")")

        // Fetch user cars
        if let userId = currentUser?.id {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            userCars = appDelegate.cars.filter { $0.ownerId == userId }

            print("Found \(userCars.count) cars for user ID \(userId)")
        } else {
            print("currentUser is null cannot fetch cars")
        }

        tableView.reloadData()
    }

    // MARK: - Navigation to Car Details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCarDetails",
           let dest = segue.destination as? CarDetailsViewController,
           let selectedCar = sender as? CarData {
            dest.selectedCar = selectedCar
        }
    }

    // MARK: - TableView DataSource & Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCars.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCar = userCars[indexPath.row]
        performSegue(withIdentifier: "toCarDetails", sender: selectedCar)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let car = userCars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        cell.textLabel?.text = "\(car.year ?? 0) \(car.make ?? "") \(car.model ?? "")"
        return cell
    }
}
