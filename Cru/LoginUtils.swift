

import Foundation
import Alamofire

class LoginUtils {
    class func login(_ username: String, password :String, completionHandler : @escaping (_ success : Bool) -> Void) {
        
        var params = ["username":username, "password":password]
        let fcmId = CruClients.getSubscriptionManager().loadFCMToken()
        if (fcmId != "") {
            params[Config.fcmIdField] = fcmId
        }
        let url = Config.serverUrl + "api/signin"
        
        Alamofire.request(url, method: .post, parameters: params)
            .responseJSON { response in
                var success : Bool = false
                if let body = response.result.value as? NSDictionary {
                    if let result = body["success"] as? Bool {
                        if result {
                            //GlobalUtils.saveString(Config.leaderApiKey, value: body[Config.leaderApiKey] as! String)
                            GlobalUtils.saveString(Config.username, value: username)
                            GlobalUtils.saveString(Config.userID, value: body[Config.userID] as! String)
                            success = true
                        }
                        
                    }
                }
                
                completionHandler(success)
        }
    }
    
    class func getUserInfo(insert: @escaping (NSDictionary)->(), afterFunc: @escaping (Bool)->Void) {
        if GlobalUtils.loadString(Config.userID) != "" {
            CruClients.getServerClient().getById(DBCollection.User, insert: insert, completionHandler: afterFunc, id: GlobalUtils.loadString(Config.userID))
        }
        
    }

    class func logout() {
        let url = Config.serverUrl + "api/signout"
        GlobalUtils.saveString(Config.userID, value: "")
        
        Alamofire.request(url, method: .post)
            .responseJSON { response in
        }
    }
    
    class func isLoggedIn() -> Bool {
        return GlobalUtils.loadString(Config.userID) != ""
    }
}
