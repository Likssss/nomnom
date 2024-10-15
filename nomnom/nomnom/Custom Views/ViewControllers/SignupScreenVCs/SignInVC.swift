import UIKit
import FirebaseAuth

class SignInVC: UIViewController {

    let containerView       = SPContainerView(frame: .zero)
    let greetingLabel       = SPTitleLabel(textAlignment: .left, fontSize: 50)
    let userImage           = UIImageView()
    let usernameLabel       = SPTitleLabel(textAlignment: .left, fontSize: 20)
    let emailLabel          = SPSecondaryTitleLabel(fontSize: 15)
    let eMailField          = SPTextField(placeholder: "Email")
    let passwordField       = SPTextField(placeholder: "Password")
    let signinButton        = SPButton(backgroundColor: .systemMint, title: "Sign in")
    let forgotPassButton    = SPButton(backgroundColor: .clear, title: "Forgot your password?")
    let stackView           = UIStackView()
    static let profileVC    = ProfileVC()
    var email: String?
    weak var coordinator: WelcomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(containerView,greetingLabel)
        containerView.addSubviews(userImage, stackView, usernameLabel, emailLabel)
        configureStackView()
        layoutUI()
        signinButton.addTarget(self, action: #selector(signinButtonTapped), for: .touchUpInside)
    }
    
    
    @objc func signinButtonTapped() {
        guard let email = eMailField.text, !email.isEmpty else {
            print("Please enter an email")
            let alertVC = SPAlertVC(title: "Please enter an email", message: "it looks like you didn't enter an email, please enter a proper email!", buttonTitle: "Ok")
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        let password = passwordField.text ?? ""
        print(password)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            print("User Signed In Successfully")
            
            let alertVC = SPAlertVC(title: "Signin Successful", message: "Press the Home button to start your culinary adventure!", buttonTitle: "Ok")
            self.present(alertVC, animated: true, completion: nil)
            
            self.navigationController?.pushViewController(SignInVC.profileVC, animated: true)
            SignInVC.profileVC.navigationItem.hidesBackButton = true
            
            SignInVC.profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
            self.navigationController?.setViewControllers([SignInVC.profileVC], animated: true)
        }
    }
    
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        stackView.addArrangedSubviews(eMailField, passwordField, signinButton, forgotPassButton)
    }
    
    
    private func layoutUI() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        greetingLabel.textColor = .white
        greetingLabel.text = "Sign in"
        userImage.image = UIImage(systemName: "person.circle")
        usernameLabel.text = "Sevket-i Bostan"
        usernameLabel.textColor = .white
        emailLabel.textColor = .white
        
        signinButton.setTitleColor(.white, for: .normal)
        forgotPassButton.contentHorizontalAlignment = .left
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 350),
            
            greetingLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -25),
            greetingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            userImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            userImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            userImage.heightAnchor.constraint(equalToConstant: 60),
            userImage.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: userImage.centerYAnchor, constant: -10),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            eMailField.heightAnchor.constraint(equalToConstant: 50),
            eMailField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            eMailField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            signinButton.heightAnchor.constraint(equalToConstant: 50),
            signinButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            signinButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            forgotPassButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 110),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }


}
