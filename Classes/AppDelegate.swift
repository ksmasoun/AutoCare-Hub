import UIKit
import SQLite3
import GoogleSignIn

//a lot of work was knowledge from class, will try to still explain
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var databaseName: String? = "swiftwheels.db"
    var databasePath: String? = ""
    var user: [UserData] = []
    var cars: [CarData] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir = documentPaths[0]
        databasePath = documentsDir.appending("/" + databaseName!)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                print("Successfully restored previous sign-in: \(user.profile!)")
            }
        }
        
        readCarDataFromDatabase() //Tristan Added, for receiving car data
        checkAndCreateDatabase() //creating user data
        readDataFromDatabase() //reading user data
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func checkAndCreateDatabase() {
        
        var success = false
        let fileManager = FileManager.default
        
        success = fileManager.fileExists(atPath: databasePath!)
        
        if success
        {
            return
        }
        
        let databasePathFromApp =
        Bundle.main.resourcePath?.appending("/"+databaseName!)
        
        try? fileManager.copyItem(atPath: databasePathFromApp!, toPath: databasePath!)
        
        return
    }
    
    private func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            return db
        } else {
            print("Unable to open database")
            return nil
        }
    }
    
    //mainly used for signing up for an account
    func insertUserIntoDatabase(users: UserData) -> Bool {
        var returnCode = false
        
        if let db = openDatabase() {
            print("Success opened database connection")
            
            var insertStatement: OpaquePointer? = nil
            let insertQuery = "INSERT INTO users VALUES (NULL, ?, ?, ?, ?, ?)";
            
            if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
                let nameStr = users.name! as NSString
                let emailStr = users.email! as NSString
                let passwordStr = users.password!as NSString
                let googleUserIdStr = (users.googleUserId ?? "") as NSString
                let authProviderStr = (users.authProvider ?? "local") as NSString
                
                sqlite3_bind_text(insertStatement, 1, nameStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, emailStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, passwordStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 4, googleUserIdStr.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 5, authProviderStr.utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("Successfully inserted user with ID \(rowID)")
                    returnCode = true
                } else {
                    print("Could not insert user")
                    returnCode = false
                }
                sqlite3_finalize(insertStatement)
            } else {
                print("Insert could not be prepared")
                returnCode = false
            }
            sqlite3_close(db)
        } else {
            print("Unable to open the db")
            returnCode = false
        }
        return returnCode
    }
    
    // for logging in and checking car ownership
    func readDataFromDatabase() {
        user.removeAll()
        
        if let db = openDatabase() {
            print("Successfully connected to database at \(databasePath!)")
            
            var queryStatement: OpaquePointer? = nil
            let queryStatementString = "SELECT * FROM users"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                print("Select statement prepared successfully")
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id: Int = Int(sqlite3_column_int(queryStatement, 0))
                    let cname = sqlite3_column_text(queryStatement, 1)
                    let cemail = sqlite3_column_text(queryStatement, 2)
                    let cpassword = sqlite3_column_text(queryStatement, 3)
                    let cgoogleUserId = sqlite3_column_text(queryStatement, 4)
                    let cauthProvider = sqlite3_column_text(queryStatement, 5)
                    
                    let name = String(cString: cname!)
                    let email = String(cString: cemail!)
                    let password = String(cString: cpassword!)
                    let googleUserId = cgoogleUserId != nil ? String(cString: cgoogleUserId!) : nil
                    let authProvider = cauthProvider != nil ? String(cString: cauthProvider!) : "local"
                    
                    let data = UserData()
                    data.initWithData(
                        theRow: id,
                        theName: name,
                        theEmail: email,
                        thePassword: password,
                        theGoogleUserId: googleUserId,
                        theAuthProvider: authProvider
                    )
                    
                    user.append(data)
                    print("User Details: \(id) - \(name) - \(email) - Auth: \(authProvider)")
                }
                
                sqlite3_finalize(queryStatement)
            } else {
                print("Select could not be prepared for users")
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("SQLite Error: \(errorMessage)")

            }
            sqlite3_close(db)
        }
    }
    
    func findUserByEmail(email: String) -> UserData? {
        return user.first { userData in userData.email == email }
    }

    // Search for and returns a user with the specified Google ID
    func findUserByGoogleId(googleId: String) -> UserData? {
        return user.first { userData in userData.googleUserId == googleId }
    }
    
    //Car db methods - added by Tristan
    //for car registration
    func insertCarIntoDatabase(car: CarData) -> Bool {
    var db: OpaquePointer? = nil
    var returnCode = false

    if sqlite3_open(databasePath, &db) == SQLITE_OK {
        let insertQuery = "INSERT INTO cars VALUES (NULL, ?, ?, ?, ?, ?, ?)"
        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {

            let makeStr = car.make ?? ""
            let modelStr = car.model ?? ""
            let yearInt = car.year ?? 0
            let kmsDouble = car.kms ?? 0.0
            let lastServicedStr = car.lastServiced ?? ""
            let ownerIdInt = car.ownerId ?? 0

            sqlite3_bind_text(insertStatement, 1, (makeStr as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (modelStr as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(yearInt))
            sqlite3_bind_double(insertStatement, 4, kmsDouble)
            sqlite3_bind_text(insertStatement, 5, (lastServicedStr as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, Int32(ownerIdInt))

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted car.")
                returnCode = true
            } else {
                print("Could not insert car.")
            }

            sqlite3_finalize(insertStatement)
        } else {
            print("Car insert could not be prepared.")
        }

        sqlite3_close(db)
    } else {
        print("Unable to open db for car.")
    }

    return returnCode
}

//for table view, and connecting who owns the car
func readCarDataFromDatabase() {
    cars.removeAll()
    var db: OpaquePointer? = nil

    if sqlite3_open(databasePath, &db) == SQLITE_OK {
        let query = "SELECT * FROM cars"
        var queryStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let make = String(cString: sqlite3_column_text(queryStatement, 1))
                let model = String(cString: sqlite3_column_text(queryStatement, 2))
                let year = Int(sqlite3_column_int(queryStatement, 3))
                let mileage = sqlite3_column_double(queryStatement, 4)
                let lastServiced = String(cString: sqlite3_column_text(queryStatement, 5))
                let ownerId = Int(sqlite3_column_int(queryStatement, 6))

                let car = CarData()
                car.initWithData(
                    theRow: id,
                    theMake: make,
                    theModel: model,
                    theYear: year,
                    theMileage: mileage,
                    theLastServiced: lastServiced,
                    theOwnerId: ownerId
                )
                cars.append(car)
            }
            sqlite3_finalize(queryStatement)
        } else {
            print("select not abble to be prepared")
        }
        sqlite3_close(db)
    } else {
        print("Unable to open db")
    }
}
}
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

