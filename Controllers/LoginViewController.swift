import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var googleSignInButton: GIDSignInButton!

    var authenticatedUser: UserData?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        tfPassword.isSecureTextEntry = true
        tfEmail.delegate = self
        tfPassword.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    //Handling user authentication when the button login is tapped.
    @IBAction func loginTapped(_ sender: UIButton) {
        
        let email = tfEmail.text
        let password = tfPassword.text
        
        if email?.isEmpty ?? true || password?.isEmpty ?? true {
            let alert = UIAlertController(title: "Incomplete Fields", message: "Please enter both email and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        mainDelegate.readDataFromDatabase()
        let users = mainDelegate.user
        
        for u in users {
            print("USER: \(u.email ?? "nil") - \(u.password ?? "nil") - \(u.authProvider ?? "nil")")
        }


        var foundUser: UserData? = nil
        for user in users {
            if user.email == email &&
               user.password == password &&
               (user.authProvider == "local" || user.authProvider == nil) {
                foundUser = user
                break
            }
        }

        if let user = foundUser {
            authenticatedUser = user
            performSegue(withIdentifier: "LoginSuccessSegue", sender: self)
        } else {
            let alert = UIAlertController(title: "Login Failed", message: "Incorrect email or password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    
    //Function handling the event when sign in with google button is tapped by the user.
    @IBAction func googleSignInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign In error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Sign In Error", message: "Failed to sign in with Google.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }

            guard let signInResult = signInResult else {
                let alert = UIAlertController(title: "Sign In Error", message: "Sign in result is nil.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let user = signInResult.user
            let profile = user.profile

            guard let userId = user.userID else {
                let alert = UIAlertController(title: "Sign In Error", message: "Could not get user ID.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let email = profile?.email ?? ""
            let name = profile?.name ?? ""
            
            if email.isEmpty || name.isEmpty {
                let alert = UIAlertController(title: "Missing Information", message: "Could not retrieve email or name from Google account.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            print("Successfully signed in with Google: \(name), \(email)")

            self.handleGoogleUser(userId: userId, name: name, email: email)
        }
    }
    
    //Once logged in complete handle the logged in user to dashboard (with data being passed through the segue)
    func handleGoogleUser(userId: String, name: String, email: String) {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        mainDelegate.readDataFromDatabase()

        if let existingUser = mainDelegate.findUserByGoogleId(googleId: userId) {
            self.authenticatedUser = existingUser
            self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self)
            return
        }
        
        if mainDelegate.findUserByEmail(email: email) != nil {
            let alert = UIAlertController(title: "Account Exists", message: "An account with this email already exists. Please use your password to log in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let newUser = UserData()
        newUser.initWithData(
            theRow: 0,
            theName: name,
            theEmail: email,
            thePassword: "",
            theGoogleUserId: userId,
            theAuthProvider: "google"
        )
        
        if mainDelegate.insertUserIntoDatabase(users: newUser) {
            mainDelegate.readDataFromDatabase()
            
            if let createdUser = mainDelegate.findUserByGoogleId(googleId: userId) {
                self.authenticatedUser = createdUser
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: self)
            } else {
                let alert = UIAlertController(title: "Account Error", message: "User created but not found in database.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Sign Up Error", message: "Failed to create new user account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    //Data of logged in user being passed through segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSuccessSegue",
           let dest = segue.destination as? LoginSuccessfulRedirectViewController {
            dest.user = authenticatedUser
        }
    }
}
