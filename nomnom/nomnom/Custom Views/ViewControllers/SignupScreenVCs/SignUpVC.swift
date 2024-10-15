import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

protocol SignUpVCDelegate: AnyObject {
    func didCompleteSignUp()
}

class SignUpVC: UIViewController {

    let containerView       = SPContainerView(frame: .zero)
    let greetingLabel       = SPTitleLabel(textAlignment: .left, fontSize: 50)
    let warningLabel        = SPSecondaryTitleLabel(fontSize: 20)
    let nameField           = SPTextField(placeholder: "Name")
    let eMailField          = SPTextField(placeholder: "Email")
    let passwordField       = SPTextField(placeholder: "Password")
    let signupButton        = SPButton(backgroundColor: .systemMint, title: "Sign up")
    let stackView           = UIStackView()
    var email: String?
    
    weak var delegate: SignUpVCDelegate?
    weak var coordinator: WelcomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "signup")
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImageView, at: 0)
        
        view.addSubviews(containerView,greetingLabel)
        containerView.addSubviews(stackView)
        configureStackView()
        layoutUI()
        
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    }
    
    class LoginValidator {
        func isValidEmail( email: String) -> Bool{
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
            return predicate.evaluate(with: email)
        }
        
        func isValidPassword( password:String) -> Bool{
            // Password requirements: minimum 8 characters, at least one uppercase,
            // one lowercase, one number and one special character
            let regex = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&*]).{8,}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: password)
        }
    }
    
    func registerNewUser(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let userData: [String: Any] = [
                "name": name,
                "email": email,
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(authResult!.user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("User data saved successfully")
                    let nomnomUser = User(uid: authResult!.user.uid, name: name, profileImageUrl: "", bookmarkedRecipes: [])
                    completion(.success(nomnomUser))
                }
            }
        }
    }
   
    
    func updateWarningLabel(with email: String?) {
            if let email = email {
                warningLabel.text = "Looks like you don't have an account. Let's create a new account for \(email)"
            } else {
                warningLabel.text = "Looks like you don't have an account. Let's create a new account."
            }
        }
    
    @objc func signupButtonTapped() {
        let validator = LoginValidator()
        guard let name = nameField.text, !name.isEmpty,
              let email = eMailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            print("Name, Email or password is empty")
            let alertVC = SPAlertVC(title: "error signing up", message: "Please double check your information, make sure none of the fields are empty", buttonTitle: "Ok")
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if validator.isValidEmail(email: email ) && validator.isValidPassword(password: password ) {
                registerNewUser(name: name, email: email, password: password) { result in
                    switch result {
                    case .success(_):
                        print("successful")
                        let alertVC = SPAlertVC(title: "Signup Successful", message: "", buttonTitle: "Ok")
                        self.present(alertVC, animated: true, completion: nil)
                    case .failure(_):
                        print("fail")
                        let alertVC = SPAlertVC(title: "Signup Failed", message: "please make sure you are using a proper email address", buttonTitle: "Ok")
                        self.present(alertVC, animated: true, completion: nil)
                    }
                }
                let welcomeVC = WelcomeVC()
                let alertVC = SPAlertVC(title: "Signup Successful", message: "please signin using the correct details", buttonTitle: "Ok")
                self.present(alertVC, animated: true, completion: nil)
                self.navigationController?.pushViewController(welcomeVC, animated: true)
        } else{
            let alertVC = SPAlertVC(title: "Signup Failed", message: "please make sure the email address is correct, the password must contains 8 characters, with 1 upper case, 1 number and 1 special character", buttonTitle: "Ok")
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        stackView.addArrangedSubviews(warningLabel, nameField, eMailField, passwordField, signupButton)
    }
    
    
    private func layoutUI() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.textColor = .white
        greetingLabel.text = "Sign up"
        
        warningLabel.textColor = .white
            
        signupButton.setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -350),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 350),
            
            greetingLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -25),
            greetingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            warningLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            nameField.heightAnchor.constraint(equalToConstant: 50),
            nameField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            eMailField.heightAnchor.constraint(equalToConstant: 50),
            eMailField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            eMailField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            signupButton.heightAnchor.constraint(equalToConstant: 50),
            signupButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            signupButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

}
