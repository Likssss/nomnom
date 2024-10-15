import UIKit

protocol AuthPresenterDelegate: AnyObject {
    
}

typealias PresenterDelegate = AuthPresenterDelegate & UIViewController

class AuthPresenter {
    
    weak var delegate: AuthPresenterDelegate?
    
    public func setViewDelegate(delegate: PresenterDelegate) {
        self.delegate = delegate
    }
}
