import UIKit
import FirebaseAuth
import Foundation

protocol WelcomeVCDelegate: AnyObject {
    func didTapContinueButton(emailIsRegistered: Bool)
}

class WelcomeVC: UIViewController {

    
    let containerView       = SPContainerView(frame: .zero)
    let greetingLabel       = SPTitleLabel(textAlignment: .left, fontSize: 50)
    let orLabel             = SPSecondaryTitleLabel(fontSize: 25)
    let eMailField          = SPTextField(placeholder: "Email")
    let passwordField       = SPTextField(placeholder: "Password")
    let continueButton      = SPButton(backgroundColor: .systemMint, title: "Continue")
    let signupButton        = SPButton(backgroundColor: .clear, title: "Sign up")
//    let forgotPassButton    = SPButton(backgroundColor: .clear, title: "Forgot your password?")
    let stackView           = UIStackView()
    
    weak var coordinator: WelcomeCoordinator?
    weak var delegate: WelcomeVCDelegate?

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
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
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
    
    func checkIfEmailIsRegistered(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @objc func continueButtonTapped(){
        let validator = LoginValidator()
        let email = eMailField.text
        let password = passwordField.text
        
        if validator.isValidEmail(email: email ?? ""){
            if validator.isValidPassword(password: password ?? ""){
                Auth.auth().signIn(withEmail: eMailField.text ?? "", password: passwordField.text ?? "") { (user, error) in
                    if let error = error {
                        print("Failed to sign in with email: ", error)
                        let alertVC = SPAlertVC(title: "Failed to Signin", message: "please Signup using an email below", buttonTitle: "Ok")
                        self.present(alertVC, animated: true, completion: nil)
                        // Navigate to SignUpVC
                        self.navigationController?.pushViewController(SignUpVC(), animated: true)
                        return
                    }
                    print("Successfully logged back in with user: ", user?.user.uid ?? "")
                    let alertVC = SPAlertVC(title: "Signin Successful", message: "Press the Home button to start your culinary adventure!", buttonTitle: "Ok")
                    self.present(alertVC, animated: true, completion: nil)
                    // Navigate to ProfileVC
                    let profileVC = ProfileVC()
                    profileVC.user = User(uid: user?.user.uid ?? "", name: "", profileImageUrl: "", bookmarkedRecipes: [])
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            } else{
                let alertVC = SPAlertVC(title: "Password Incorrect", message: "password must be minimum 8 characters, with 1 lowercase, 1 number & 1 special character", buttonTitle: "Ok")
                self.present(alertVC, animated: true, completion: nil)
            }
        } else {
            let alertVC = SPAlertVC(title: "Email Incorrect", message: "please enter a valid email address", buttonTitle: "Ok")
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @objc func signupButtonTapped(){
        let signupVC = SignUpVC()
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        stackView.addArrangedSubviews(eMailField, passwordField, continueButton, orLabel, signupButton/*, forgotPassButton*/)
    }
    
    
    private func layoutUI() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.textColor = .white
        greetingLabel.text = "Hi!"
        orLabel.text = "or"
        
        continueButton.setTitleColor(.white, for: .normal)
//        forgotPassButton.contentHorizontalAlignment = .left
//        forgotPassButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        signupButton.attributedButton()
        signupButton.contentHorizontalAlignment = .left
        signupButton.setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 350),
            
            greetingLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -25),
            greetingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            eMailField.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 20),
            eMailField.heightAnchor.constraint(equalToConstant: 50),
            eMailField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            eMailField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            continueButton.heightAnchor.constraint(equalToConstant: 40),
            continueButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

}
