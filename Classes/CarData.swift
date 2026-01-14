import Foundation

class CarData {
    var id: Int?
    //userId -> foreign key from Id in UserData
    var make: String?
    var model: String?
    var year: Int?
    var kms: Double?
    var lastServiced: String?
    var ownerId: Int?

    func initWithData(theRow i: Int, theMake: String, theModel: String, theYear: Int, theMileage: Double, theLastServiced: String, theOwnerId: Int) {
        id = i
        make = theMake
        model = theModel
        year = theYear
        kms = theMileage
        lastServiced = theLastServiced
        ownerId = theOwnerId
    }
}
