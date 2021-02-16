//
//  File.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/11/20.
//

import Foundation

typealias UserSaveCompletion = (_ success: Bool,_ error: Error?)-> Void

struct User: Codable {
    var email: String?
    var fullName: String?
    var dob: String?
    var gender: String?
    var aboutMe: String?
    var id: String?
    var location: String?    
    var imageUrl: String?
    var followers: Int? = 0
    var following: Int? = 0
    var moments: Int? = 0
    var likedMoments: [String]?
    var blockedUsersIds: [String]?
    
    
    init(id: String) {
        self.id = id
    }
    
    mutating func blockUserWithId(id:String) {
        guard let blockedUsers = blockedUsersIds else {
            blockedUsersIds = [id]
            return
            
        }
        
        if blockedUsers.contains(id) {
            return
        }
        blockedUsersIds!.append(id)
}
    
    func isBlockedUserWith(id: String) -> Bool {
        guard let blockedUsers = blockedUsersIds else { return false }
        return blockedUsers.contains(id)
    }
    
    mutating func unblockedUserWithId(id: String) {
        guard let blockedUsers = blockedUsersIds else { return }
        
        if !blockedUsers.contains(id) {
            return
        }
        blockedUsersIds!.removeAll(where: {$0 == id})
    }
    
    func save(completion: UserSaveCompletion?) {
//        DataStore.shared.localUser = self
        
        DataStore.shared.setUserData(user: self) { (sucess, error) in 
            completion?(sucess, error)
        }
    }
}
