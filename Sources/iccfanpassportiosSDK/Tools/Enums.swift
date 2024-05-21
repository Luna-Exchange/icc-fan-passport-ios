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
