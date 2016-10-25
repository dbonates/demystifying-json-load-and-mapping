//: ## Load JSON/ Mapping using Protocols + callback + NetError check
//: << [Previous implementation](@previous)
import Foundation
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

// the protocol
protocol JSONParselable {
    static func withJSON(json: [String:Any]) -> Self? // Note the use of Self here
}

struct User {
    let id:Int
    let name:String
    let avatar:String
}

extension User:JSONParselable {
    static func withJSON(json: [String:Any]) -> User? { // Note that Self became the Model type
        guard
            let id = json["id"] as? Int,
            let name = json["user_fullname"] as? String,
            let avatar = json["user_avatar"] as? String
            else {
                return nil
        }
        
        return User(id: id, name: name, avatar: avatar)
    }
}


func getUsersFrom(url:URL, callback: @escaping (UsersArray?, NetError?) -> ()) {
    
    let session = URLSession.shared
    (session.dataTask(with: url) { data, response, error in
        
        guard error == nil else {
            callback(nil, NetError.fatalError)
            return
        }
        
        guard let serverReponse = response as? HTTPURLResponse else { return }
        
        switch serverReponse.statusCode {
            
        case 200..<300:
            let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            
            if let json = json as? UsersArray {
                callback(json, nil)
            }
            
        case 403:
            callback(nil, NetError.forbidden(403))
        case 404:
            callback(nil, NetError.notFound(404))
        default:
            callback(nil, NetError.unknown)
        }
        
    }).resume()
}

getUsersFrom(url: usersUrl) { json, error in
    
    guard error == nil else { return }
    
    let users = json!.flatMap(User.withJSON)
    dump(users.first) //verifying with dump
    
}