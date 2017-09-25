

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
        GlobalUtils.saveBool(UserKeys.isCommunityGroupLeader, value: false)
        Alamofire.request(url, method: .post)
            .responseJSON { response in
        }
    }
    
    class func updateCommunityGroups() {
        var groups = [CommunityGroup]()
        
        guard let groupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let groupArray = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        let userID = GlobalUtils.loadString(Config.userID)
        //Remove user's Leader groups from local storage
        for group in groupArray {
            if group.role == "member" || !group.leaderIDs.contains(userID) {
                groups.append(group)
            }
        }
        
        // Save member groups into local storage
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: groups)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
        
        
    }
    
    class func isLoggedIn() -> Bool {
        return GlobalUtils.loadString(Config.userID) != ""
    }
}
