import Alamofire
import UIKit


public enum ViewModifier {
    case none, showHud, showSuccessMessage, doNotShowFailureMessage, doNotHideKeyboard, withEncyption, pop, popToRoot, dismiss, logout
}

public enum SessionErrors : Error {
    case generalErrors(NetworkingErrors)
    case apiErrors(APIStatusCodes)
    case decodingFailed
    case decryptionFailed
    case emptyOrNilResponse
    case unknown(AFError?)
}

public enum NetworkingErrors : Error {
    case internetConnection, unknown, sessionTimeOut
}

public enum APIStatusCodes : Int, Error {
    case failure = 0, success = 1, emptyResponse = 2, userNotRegistered = 13
}


/*
extension UIViewController {

    func showHud() {
        print("Inside Module")
    }

    func hideHud() {
        print("Inside Module")
    }

    func showMessage(message: String) {
        print("Inside Module")
    }

    func deauthorize() {
        print("Inside Module")
    }

}


public class SessionManager {
    
    public init() { }
    

    public static let shared = SessionManager()
    var isConnectedToInternet : Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    func showNetworkError() {
        ShowAlert(title: AppInfo.appName, message: AlertMessages.noInternet)
    }
    
    func showSessionTimeOutError(on : UIViewController?) {
        ShowAlert(title: AppInfo.appName, message: AlertMessages.sessionTimeOut) { _ in
            on?.deauthorize()
        }
    }
    
    func handleResponseWithError<M:Codable>(response : AFDataResponse<M>, options : [ViewModifier], on : UIViewController? = nil, responseModel : @escaping (Result<M,SessionErrors>) -> ()) {
        
        on?.hideHud()
        switch response.response?.statusCode ?? 0 {
        case 200...299:
            guard let jsonModel = response.value else {
                responseModel(.failure(.emptyOrNilResponse))
                return
            }
            if options.contains(.showSuccessMessage) {
                if let model = response.data?.toObject(type: GeneralModel.self) {
                    on?.showMessage(message: model.message)
                    responseModel(.success(jsonModel))
                } else {
                    responseModel(.failure(.decodingFailed))
                }
            } else {
                responseModel(.success(jsonModel))
                if options.contains(.pop) {
                    on?.navigationController?.popViewController()
                } else if options.contains(.popToRoot) {
                    on?.navigationController?.popToRootViewController(animated: true)
                } else if options.contains(.logout) {
                    on?.deauthorize()
                }
            }
            
        case 401:
            showSessionTimeOutError(on: on)
            responseModel(.failure(.generalErrors(.sessionTimeOut)))
        default:
            print("error ------->","\(String(describing: response.request))-------> Unable to decode response of \(M.self)")
            if options.contains(.doNotShowFailureMessage) {
                responseModel(.failure(.unknown(response.error)))
            } else {
                if let model = response.data?.toObject(type: GeneralModel.self) {
                    on?.showMessage(message: model.message)
                } else {
                    responseModel(.failure(.decodingFailed))
                }
            }
        }
    }
}


public extension SessionManager {
    
    func execute<T : URLRequestConvertible, M : Codable>(router : T, options: [ViewModifier] = [.showHud], responseModel : @escaping (Result<M,SessionErrors>) -> Void) {
        
        let on = UIApplication.topViewController()
        
        if !options.contains(.doNotHideKeyboard) {
            on?.view.endEditing(true)
        }
        
        if !isConnectedToInternet {
            showNetworkError()
            return
        }
        
        options.contains(.showHud) ? on?.showHud() : ()
        
        AF.request(router).responseDecodable(of: M.self) { afResponse in
            self.handleResponseWithError(response: afResponse, options: options, on: on) { (response : Result<M,SessionErrors>) in
                responseModel(response)
            }
        }
        
    }
    
}

*/
