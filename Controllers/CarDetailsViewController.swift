import UIKit
import MapKit
import CoreLocation
import WeatherKit

class CarDetailsViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var selectedCar: CarData?
    var weatherService = WeatherService()
    
    @IBOutlet weak var lblMake: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblKms: UILabel!
    @IBOutlet weak var lblServiced: UILabel!
    @IBOutlet weak var lblRepairStatus: UILabel!
    
    //map
    @IBOutlet var myMapView: MKMapView!
    @IBOutlet var tbLocEntered: UITextField!
    var locationManager = CLLocationManager()
    
    // Initial location (Sheridan College Brampton)
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534) // Sheridan College
    

    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Selected Car: \(selectedCar?.make ?? "nil")")//testing
        
        // Display car details
        if let car = selectedCar
        {
            lblMake.text = "Make: \(car.make ?? "-")"
            lblModel.text = "Model: \(car.model ?? "-")"
            lblYear.text = "Year: \(car.year?.description ?? "-")"
            lblKms.text = "KM: \(car.kms?.description ?? "-")"
            lblServiced.text = "Last Serviced: \(car.lastServiced ?? "-")"
            
            
            switch car.lastServiced?.lowercased() {
            case "this month":
                lblRepairStatus.text = "You're good! Your car was serviced recently."
                lblRepairStatus.textColor = .systemGreen

            case "over a month":
                lblRepairStatus.text = "Please schedule a maintenance check-up."
                lblRepairStatus.textColor = .systemOrange

            case "over a year":
                lblRepairStatus.text = "Emergency! Immediate service required."
                lblRepairStatus.textColor = .systemRed

            default:
                lblRepairStatus.text = "repair nil"
            
            }
        }
        
        // Setup map and starting location
        centerMapOnLocation(location: initialLocation)
        addPinAtLocation(location: initialLocation, title: "Starting at Sheridan College")
        
        // Ask for location access and fetch weather
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Test hardcoded weather data for Sheridan College
        testHardcodedWeatherAlert(for: initialLocation)
    }
    
    // Center map on a location
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0,
                                                  longitudinalMeters: regionRadius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Add a pin at the given location
    func addPinAtLocation(location: CLLocation, title: String) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location.coordinate
        dropPin.title = title
        myMapView.addAnnotation(dropPin)
        myMapView.selectAnnotation(dropPin, animated: true)
    }
    
    // Location Manager Delegate - Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        print("Location updated: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        // Center map and add pin for the current location
        centerMapOnLocation(location: currentLocation)
        addPinAtLocation(location: currentLocation, title: "You are here")
        
        // Fetch dynamic weather alerts for the current location
        fetchWeather(for: currentLocation)
    }
    
    // Test weather data for Sheridan College
    func testHardcodedWeatherAlert(for location: CLLocation)
    {
        print("Testing hardcoded weather alert for Sheridan College")
        if location.coordinate.latitude == initialLocation.coordinate.latitude &&
            location.coordinate.longitude == initialLocation.coordinate.longitude
        {
            showAlert(title: "Freezing Rain Alert", message: "Freezing rain expected! Please change to winter tires.")
        }
    }
    
    // Fetch weather for the given location and display alerts dynamically
    @MainActor
    func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let current = weather.currentWeather
                
                switch current.condition {
                case .snow:
                    showAlert(title: "Snowstorm Warning", message: "Snow is expected. Time to check your winter tires!")
                case .freezingRain:
                    showAlert(title: "Freezing Rain Alert", message: "Drive cautiously due to icy conditions.")
                case .rain:
                    showAlert(title: "Rain Alert", message: "Expect rain. Stay safe on the road!")
                default:
                    print("Weather is clear: \(current.condition.description)")
                }
            } catch {
                print("Failed to get weather data: \(error)")
                showAlert(title: "Weather Error", message: "Couldn't retrieve weather info.")
            }
        }
    }
    
    // Display weather alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Handle "Enter Destination" input
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func findNewLocation(sender: Any) {
           guard let locEnteredText = tbLocEntered.text, !locEnteredText.isEmpty else { return }
           let geocoder = CLGeocoder()
           
           geocoder.geocodeAddressString(locEnteredText, completionHandler: { placemarks, error in
               if let error = error {
                   print("Geocoding error: \(error)")
                   return
               }
               
               if let placemark = placemarks?.first, let coordinates = placemark.location?.coordinate {
                   let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                   self.centerMapOnLocation(location: newLocation)
                   self.addPinAtLocation(location: newLocation, title: placemark.name ?? "New Location")
                   
                   // Search for car shops near the new location
                   self.findNearestCarShop(from: newLocation)
               }
           })
       }

       func findNearestCarShop(from location: CLLocation) {
           let request = MKLocalSearch.Request()
           request.naturalLanguageQuery = "Car Repair Shop"
           request.region = MKCoordinateRegion(center: location.coordinate,
                                               latitudinalMeters: 5000,
                                               longitudinalMeters: 5000) // Define search radius

           let search = MKLocalSearch(request: request)
           
           search.start { response, error in
               guard let response = response, error == nil else {
                   print("Error searching for car shops: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }

               let carShops = response.mapItems
               if carShops.isEmpty {
                   print("No car shops found nearby.")
                   return
               }

               for carShop in carShops {
                   if let carShopLocation = carShop.placemark.location {
                       let carShopName = carShop.name ?? "Car Repair Shop"
                       self.addPinAtLocation(location: carShopLocation, title: carShopName)
                       print("Found car shop: \(carShopName) at \(carShopLocation.coordinate.latitude), \(carShopLocation.coordinate.longitude)")
                   }
               }
           }
       }


    
}
