import Foundation

public enum PassportEntryPoint: String {
    case defaultPath = "/"
    case createAvatar = "/create-avatar"
    case onboarding = "/onboarding"
    case profile = "/profile"
    case challenges = "/challenges"
    case rewards = "/rewards"

    var path: String {
        return self.rawValue
    }
}


public enum Environment {
    case development
    case production
}



class ICCFanSDK {
    static var enableLogging = true
    static var userData: UserData?
    static var sharedFanView: ICCWebView?
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}
