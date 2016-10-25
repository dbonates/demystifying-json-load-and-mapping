import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

typealias UsersArray = [[String:Any]]

let usersUrlStr = "https://goo.gl/vyibzH"
let usersUrl = URL(string:usersUrlStr)!


enum NetError : Error {
    case notFound(Int)
    case forbidden(Int)
    case serverResponseError(Int)
    case fatalError
    case unknown
}

struct User {
    let id:Int
    let name:String
    let avatar:String
}

extension User {
    
    init?(json:[String:Any]) {
        
        guard
            let id = json["id"] as? Int,
            let name = json["user_fullname"] as? String,
            let avatar = json["user_avatar"] as? String
            else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.avatar = avatar
    }
    
}

// Request and JSON parse

var users = [User]() // to be filled
let session = URLSession.shared
(session.dataTask(with: usersUrl) { data, response, error in

    guard error == nil else { return }

    let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)

    if let json = json as? [[String:Any]] { // checking correct format
        users = json.flatMap(User.init) // where the magic happens!
    }


}).resume()
