//
//  MomentDetailsViewController.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 14.12.20.
//

import UIKit
import InputBarAccessoryView
import FirebaseFirestore

enum MomentDetailsTableData: Equatable {
    static func == (lhs: MomentDetailsTableData, rhs: MomentDetailsTableData) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.userInfo, .userInfo):
            return true
        case (.image, .image):
            return true
        case (.caption, .caption):
            return true
        case (.comments, .comments):
            return true
        case (.counters, .counters):
            return true
        default:
            return false
        }
    }
    
    case userInfo
    case image
    case caption
    case counters
    case comments(comments: [Comment])
    case loading
}

class MomentDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var inputBar = InputBarAccessoryView()
    
    private var dataSource: [MomentDetailsTableData] = [.userInfo, .image, .caption, .counters]
    private var comments = [Comment]()
    
    var moment: Feed?
    
    private var hasNextPage = true
    private var pageSize = 2
    private var lasCommentDocument: DocumentSnapshot?
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
//    var computedProperty: Int {
//        return 43
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupShareButton()
        setupInputBar()
        getComments()
        navigationController?.navigationBar.tintColor = UIColor(named: "MainPink")
        
    }
        
    private func getComments() {
        guard let moment = moment, 
              let feedId = moment.id else { return } 
        
        DataStore.shared.fetchComments(feedId: feedId, pageSize: pageSize, lastDocument: lasCommentDocument) { (comments, error, lastDocument) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.dataSource.removeAll(where: { $0 == .loading || $0 == .comments(comments: []) })
            
            if let comments = comments {
                self.lasCommentDocument = lastDocument
                self.comments.append(contentsOf: comments)
                self.dataSource.append(.comments(comments: self.comments))
                
                if comments.count == self.pageSize {
                    self.dataSource.append(.loading)
                }
                self.tableView.reloadData()
//                self.tableView.insertSections(IndexSet(integer: self.dataSource.count - 1
//                ), with: .automatic)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    private func setupInputBar() {
        inputBar.delegate = self
        inputBar.inputTextView.placeholder = "Write a comment"
    }
    
    private func setupTableView() {
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingTableViewCell")
        
        tableView.register(UINib(nibName: "UserInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoTableViewCell")
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
        tableView.register(UINib(nibName: "CaptionTableViewCell", bundle: nil), forCellReuseIdentifier: "CaptionTableViewCell")
        tableView.register(UINib(nibName: "CountersTableViewCell", bundle: nil), forCellReuseIdentifier: "CountersTableViewCell")
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    private func setupShareButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "share"), for: .normal)
        button.addTarget(self, action: #selector(onShare), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func onShare() {
        guard let moment = moment, 
              let imageUrl = moment.imageUrl,
              let caption = moment.caption else { return }
        
        let items = [URL(string: imageUrl), caption] as [Any]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
    func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
        tableView.scrollIndicatorInsets = .zero
    }
    
    private func setDataSourceAndReload() {

        if dataSource.count == 4 {
            dataSource.append(.comments(comments: comments))
        } else {
            dataSource.remove(at: 4)
            dataSource.insert(.comments(comments: comments), at: 4)
        }
        
        tableView.reloadData()
    }
}

extension MomentDetailsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.resignFirstResponder()
        inputBar.inputTextView.text = nil
        
        guard let localUser = DataStore.shared.localUser,
              let moment = moment else { return }
        
        let comment = Comment(id: UUID().uuidString,
                              creatorId: localUser.id,
                              momentId: moment.id,
                              createdAt: Date().toMiliseconds(),
                              body: text)
        
        DataStore.shared.saveComment(comment: comment) { newComment in
            self.comments.append(newComment)
            self.setDataSourceAndReload()
        } completion: { (comment, error) in
            
        }
    }
}

extension MomentDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = dataSource[section]
        switch data {
        case .userInfo,.image,.caption,.counters, .loading:
            return 1
        case .comments(let comments): 
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.section]
        guard let moment = moment else { return UITableViewCell() }
        
        switch data {
        case .userInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableViewCell") as! UserInfoTableViewCell
            cell.setData(moment: moment)
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as! ImageTableViewCell
            if let momentImage = moment.imageUrl {
                cell.momentImageView.kf.setImage(with: URL(string: momentImage))
            }
            return cell
        case .caption:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CaptionTableViewCell") as! CaptionTableViewCell
            cell.lblCaption.text = moment.caption
            cell.selectionStyle  = .none
            if let createdAt = moment.createdAt, let date = Date(with: createdAt) {
                cell.lblDate.text = date.timeAgoDisplay()
            }
            return cell
        case .counters:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountersTableViewCell") as! CountersTableViewCell
            cell.lblLikesCount.text = "0"
            cell.lblShareCount.text = "0"
            return cell
        case .comments(let comments):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            let comment = comments[indexPath.row]
            cell.setComment(comment: comment)
            return cell
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell") as! LoadingTableViewCell
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
}

extension MomentDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is LoadingTableViewCell {
            getComments()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataSource[indexPath.section]
        switch data {
        case .image:
            return 343
        default:
            return UITableView.automaticDimension
        }
    }
}
