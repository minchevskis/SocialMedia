//
//  SearchUsersViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/25/20.
//

import UIKit
import SVProgressHUD
import Kingfisher

class SearchUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Users"
        setupTableView()
        fetchUsers()
    }
    
    private func setupTableView() {
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func fetchUsers() {
        SVProgressHUD.show()
        DataStore.shared.getAllUsers { (users, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let users = users {
                self.users = users.filter({ $0.fullName != nil && $0.fullName != "" && $0.id != DataStore.shared.localUser?.id })
                self.tableView.reloadData()
            }  
        }
    }
    
    private func openProfileFor(user: User) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        controller.user = user
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    } 
}   

// MARK: UITableViewDataSource
extension SearchUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.blockingDelegate = self
        cell.setData(user: user)
        return cell
    }
}

extension SearchUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        openProfileFor(user: user)
    }
}

extension SearchUsersViewController: BlockingDelegate {
    func blockUser(user: User, isBlock: Bool) {
        guard var localUser = DataStore.shared.localUser,
              let userId = user.id else { return }
        
        if isBlock {
            localUser.blockUserWithId(id: userId)
        } else {
            localUser.unblockedUserWithId(id: userId)
        }
        
        //If we dont have any data we need to create the array
//        if localUser.blockedUsersIds == nil {
//            localUser.blockedUsersIds = [String]()
//        }
//
//        if isBlock {
//            localUser.blockedUsersIds?.append(userId)
//        } else {
//            localUser.blockedUsersIds?.removeAll(where: {$0 == userId})
//        }
        
        //localUser.save(completion: nil)
        localUser.save { (_, _) in
            self.tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
        }
        //let notification = Notification(name: Notification.Name("ReloadFeedAfterUserAction"))
    }
}
