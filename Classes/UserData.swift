import UIKit

class UserData: NSObject {
    
    var id: Int?
    var name: String?
    var email: String?
    var password: String?
    var googleUserId: String?
    var authProvider: String?
    
    func initWithData(theRow i:Int, theName n: String, theEmail e: String, thePassword p: String = "",
                      theGoogleUserId g: String? = nil, theAuthProvider a: String = "local") {
        id = i
        name = n
        email = e
        password = p
        googleUserId = g
        authProvider = a
    }
}
