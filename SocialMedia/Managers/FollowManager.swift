//
//  FollowManager.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 28.12.20.
//

import Foundation

class FollowManager {
    static let shared = FollowManager()
    init() {}
    
    var following = [Following]()
    var followers = [Follower]()
    
    func getFollowing() {
        DataStore.shared.getFollowings { (followings, error) in
            if let followings = followings {
                self.following = followings
            }
        }
    }
    
    func getFollowers() {
        DataStore.shared.getFollowers { (followers, error) in
            if let followers = followers {
                self.followers = followers
            }
        }
    }
    
    func followUser(user: User, completion: @escaping (_ success: Bool,_ error: Error?) -> Void) {
        DataStore.shared.followUser(user: user) { (following, error) in
            if let following = following {
                self.following.append(following)
                completion(true, nil)
                return
            }
            if let error = error {
                completion(false, error)
            }
        }
    }
    
    func unFollowUser(user: User, completion: @escaping (_ success: Bool,_ error: Error?) -> Void) {
        guard let following = following.first(where: {$0.userId == user.id}),
              let followingId = following.id else { return }
        
        DataStore.shared.unfollow(followingId: followingId) { (succes, error) in
            if succes {
                self.following.removeAll(where: { $0.id == followingId })
                completion(true, nil)
                return
            }
            completion(false, error)
        }
    }
}
