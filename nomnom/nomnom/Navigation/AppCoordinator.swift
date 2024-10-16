import UIKit

class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let mainTabBarController = SPTabBarController()
        navigationController.viewControllers = [mainTabBarController]
    }
    
    func childDidFinish(_ child: Coordinator) {
            // Remove the child coordinator from the array when it's done
            for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    
    func startAuthenticationFlow(from viewController: UIViewController) {
        let welcomeCoordinator = WelcomeCoordinator(navigationController: UINavigationController())
        welcomeCoordinator.parentCoordinator = self
        childCoordinators.append(welcomeCoordinator)
        welcomeCoordinator.start()
        
        viewController.present(welcomeCoordinator.navigationController, animated: true)
    }
}
