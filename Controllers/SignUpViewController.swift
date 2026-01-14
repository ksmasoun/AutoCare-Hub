import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tfname: UITextField!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var tfConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfname.delegate = self
        tfEmail.delegate = self
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        tfPassword.isSecureTextEntry = true
        tfConfirmPassword.isSecureTextEntry = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //Handling user registeration when the button signup button is tapped.
    @IBAction func signUpTapped(_ sender: Any) {
        let name = tfname.text
        let email = tfEmail.text
        let password = tfPassword.text
        let confirmPassword = tfConfirmPassword.text

        if name?.isEmpty ?? true || email?.isEmpty ?? true || password?.isEmpty ?? true || confirmPassword?.isEmpty ?? true {
            let alert = UIAlertController(title: "Incomplete Field(s)", message: "All fields are required.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        if password != confirmPassword {
            let alert = UIAlertController(title: "Error", message: "Passwords do not match.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Submit Details", message: "Do you want to submit?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            
            self.submitUserInfo(name: name!, email: email!, password: password!)
        })
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
    //Handling user data when the user submits the info.
    func submitUserInfo(name: String, email: String, password: String) {
        let newUser = UserData()
        newUser.initWithData(theRow: 0, theName: name, theEmail: email, thePassword: password)

        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        if mainDelegate.insertUserIntoDatabase(users: newUser) {
            
            tfname.text = ""
            tfEmail.text = ""
            tfPassword.text = ""
            tfConfirmPassword.text = ""
            
            let successAlert = UIAlertController(title: "Sign Up Completed", message: "Your account has been created successfully.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            successAlert.addAction(okAction)
            present(successAlert, animated: true)
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "Failed to sign up. Try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            errorAlert.addAction(okAction)
            present(errorAlert, animated: true)
        }
    }
}
