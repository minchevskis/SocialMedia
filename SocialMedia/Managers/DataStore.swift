//
//  DataStore.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/11/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

typealias FeedItemsCompletion = (_ items: [Feed]?,_ lastDocument: DocumentSnapshot?,_ error: Error?) -> Void

class DataStore {
    static let shared = DataStore()
    init() {}
    
    var localUser: User? {
        didSet {
            FollowManager.shared.getFollowing()
            FollowManager.shared.getFollowers()
        }
    }
    
    private let storage = Storage.storage()

    private let database = Firestore.firestore()
    
    func setUserData(user: User, completion: @escaping (_ success: Bool,_ error: Error?)-> Void) {
            guard let uid = user.id else {
                completion(false,nil)
                return
            }
            do {
                let usersRef = database.collection("users").document(uid)
                try usersRef.setData(from: user, completion: { error in
                    if let loggedInUser = Auth.auth().currentUser, loggedInUser.uid == uid {
                        self.localUser = user
                    }
                    if let error = error {
                        completion(false, error)
                            return
                    }
                    completion(true, nil)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    
    func getUser(uid: String, completion: @escaping (_ user: User?,_ error: Error?) -> Void) {
        let userRef = database.collection("users").document(uid)

        userRef.getDocument { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = snapshot {
                do {
                    let user = try document.data(as: User.self)
                    completion(user, nil)
                } catch {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, itemId: String, isUserImage: Bool = true, completion: @escaping (_ imageUrl: URL?,_ error: Error?) -> Void) {
        var imageRef = storage.reference()
        
        if isUserImage {
            imageRef = imageRef.child("profile_pictures/" + itemId + ".jpg")
        } else {
            imageRef = imageRef.child("feed_images/" + itemId + ".jpg")
        }
            
        let imageData = image.jpegData(compressionQuality: 0.1)        
        guard let data = imageData else {
            completion(nil, nil)
            return
        }
        
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                completion(nil, nil)
                return
            }
            imageRef.downloadURL { (imageUrl, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(imageUrl, nil)
            }
        }
    }
    
    func getAllUsers(completion: @escaping (_ users: [User]?,_ error: Error?) -> Void) {
        let usersRef = database.collection("users")
        
        usersRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let snapshot = snapshot {
                do {
                    let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })
                    completion(users, nil)
                } catch (let error) {
                    completion(nil, error)
                }
            }
        }
    }
    
    func createFeedItem(item: Feed, completion: @escaping (_ item: Feed?,_ error: Error?) -> Void) {
        var newItem = item
        let feedRef = database.collection("feed").document()
        newItem.id = feedRef.documentID
    
        do {
            try feedRef.setData(from: newItem) { error in
                completion(newItem, error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchFeedItems(lastDocument:DocumentSnapshot? ,pageSize: Int ,completion: @escaping FeedItemsCompletion) {
        let feedRef = database.collection("feed")
        //Collection reference is subclass of Query, so it can be casted to Query
        var feedQuery: Query = feedRef
        if let lastDocument = lastDocument {
            feedQuery = feedRef.order(by: "createdAt").start(afterDocument: lastDocument).limit(to: pageSize)
        } else {
            feedQuery = feedRef.order(by: "createdAt").limit(to: pageSize)
        }
        
        
        if let localUser = DataStore.shared.localUser, let blockedUsers = localUser.blockedUsersIds, blockedUsers.count > 0 {
            feedQuery = feedRef.whereField("creatorId", notIn: blockedUsers)
        }
        
        feedQuery.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, nil,error)
                return
            }
            
            if let snapshot = snapshot {
                do {
                    let feeds = try snapshot.documents.compactMap({ try $0.data(as: Feed.self) })
                    completion(feeds,snapshot.documents.last ,nil)
                } catch (let error) {
                    completion(nil, nil,error)
                }
            }
        }
    }
    
    func saveComment(comment: Comment, updateBlock: @escaping (_ comment: Comment) -> Void, completion: @escaping (_ comment: Comment?,_ error: Error?) -> Void) {
        var newComment = comment
        let commentRef = database.collection("comment").document()
        newComment.id = commentRef.documentID
        
        updateBlock(newComment)
        
        do {
            try commentRef.setData(from: newComment) { error in
                completion(newComment, error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchComments(feedId: String,pageSize: Int, lastDocument: DocumentSnapshot?, completionBlock: @escaping (_ comments: [Comment]?, _ error: Error?, _ lastDocument: DocumentSnapshot?) -> Void) {
        
        let commentsRef = database.collection("comment")
        var commentsQuery: Query
        if let lastDocument = lastDocument {
            commentsQuery = commentsRef.whereField("momentId", isEqualTo: feedId).order(by: "createdAt").start(afterDocument: lastDocument).limit(to: pageSize)
        } else {
            commentsQuery = commentsRef.whereField("momentId", isEqualTo: feedId).order(by: "createdAt").limit(to: pageSize)
        }
        
        commentsQuery.getDocuments { (snapshot, error) in
            if let error = error {
                completionBlock(nil, error, nil)
                return
            }
            
            if let snapshot = snapshot {
                do {
                    let comments = try snapshot.documents.compactMap({ try $0.data(as: Comment.self) })
                    completionBlock(comments, nil, snapshot.documents.last)
                } catch {
                    print(error.localizedDescription)
                    completionBlock(nil, error, nil)
                }
            }
        }
    }
    
    func unfollow(followingId: String, completion: @escaping (_ success: Bool,_ error: Error?) -> Void) {
        guard let localUser = localUser, let localUserId = localUser.id else {return}
        let followingRef = database.collection("users").document(localUserId).collection("following").document(followingId)
        followingRef.delete { (error) in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        
    }
    
    

    func followUser(user: User, completion: @escaping (_ following: Following?,_ error: Error?) -> Void) {
        guard let localUser = localUser,
              let localUserId = localUser.id,
              let followUserId = user.id else {
            completion(nil, nil)
            return
        }
        
        let followingRef = database.collection("users").document(localUserId).collection("following").document()
        var following = Following()
        following.userId = followUserId
        following.id = followingRef.documentID
        following.createdAt = Date().toMiliseconds()
        
        do {
           try followingRef.setData(from: following) { (error) in
                if let error = error {
                    completion (nil, error)
                    return
                }
                completion(following, nil)
            }
        } catch {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func getFollowersCount(userId: String ,isFollowers: Bool, completion: @escaping (_ count: Int, _ error: Error?) -> Void) {
        
        
        let collectionName = isFollowers ? "followers" : "following"
        let followersRef = database.collection("users").document(userId).collection(collectionName)
        followersRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(0, error)
                return
            }
            
            if let snapshot = snapshot {
                completion(snapshot.documents.count, nil)
            }
        }
    }
    
    func getFollowers(completion: @escaping(_ followers: [Follower]?, _ error: Error?) -> Void) {
        guard let localUser = localUser,
              let localUserId = localUser.id else {
            completion(nil, nil)
            return
        }
        let followersRef = database.collection("users").document(localUserId).collection("followers")
        followersRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let snapshot = snapshot {
                do {
                    let followers = try snapshot.documents.compactMap({ try $0.data(as: Follower.self) })
                    completion(followers, nil)
                } catch {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    }
    
    func getFollowings(completion: @escaping(_ following: [Following]?, _ error: Error?) -> Void) {
        guard let localUser = localUser,
              let localUserId = localUser.id else {
            completion(nil, nil)
            return
        }
        let followingRef = database.collection("users").document(localUserId).collection("following")
        followingRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let snapshot = snapshot {
                do {
                    let following = try snapshot.documents.compactMap({ try $0.data(as: Following.self) })
                        completion(following, nil)
                    
                } catch {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    }
    
    
    
}



