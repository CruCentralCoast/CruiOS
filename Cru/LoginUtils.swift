

import Foundation
import Alamofire

class LoginUtils {
    class func login(_ username: String, password :String, completionHandler : @escaping (_ success : Bool) -> Void) {
        
        var params = ["username":username, "password":password]
        let gcmId = CruClients.getSubscriptionManager().loadGCMToken()
        if (gcmId != "") {
            params[Config.gcmIdField] = gcmId
        }
        let url = Config.serverUrl + "api/signin"
        
        Alamofire.request(url, method: .post, parameters: params)
            .responseJSON { response in
                var success : Bool = false
                if let body = response.result.value as! NSDictionary? {
                    if (body["success"] as! Bool) {
                        GlobalUtils.saveString(Config.leaderApiKey, value: body[Config.leaderApiKey] as! String)
                        GlobalUtils.saveString(Config.username, value: username)
                        success = true
                    }
                }
                
                completionHandler(success)
        }
    }

    class func logout() {
        let url = Config.serverUrl + "api/signout"
        GlobalUtils.saveString(Config.leaderApiKey, value: "")
        
        Alamofire.request(url, method: .post)
            .responseJSON { response in
        }
    }
    
    class func isLoggedIn() -> Bool {
        return GlobalUtils.loadString(Config.leaderApiKey) != ""
    }
}
