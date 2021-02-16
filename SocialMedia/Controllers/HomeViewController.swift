//
//  HomeViewController.swift
//  LogInFB
//
//  Created by Stefan Minchevski on 11/2/20.
//

import UIKit
import Firebase
import CoreServices
import SVProgressHUD
import FirebaseFirestore

enum CollectionData: Equatable {
    case feedItems([Feed])
    case loading
    
    static func == (lhs: CollectionData, rhs: CollectionData) -> Bool {
        switch (lhs, rhs) {
        case (.feedItems(_), .feedItems(_)):
            return true
        case (.loading, .loading):
        return true
        default:
            return  false
        }
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblNoResults: UILabel!
    @IBOutlet weak var btnPost: UIButton!
    
    var refreshControll = UIRefreshControl()
    private var lastDocument: DocumentSnapshot?
    private var pageSize = 5
    var feedItems = [Feed]()
    var tableData: [CollectionData] = [.feedItems([])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchFeedItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
    }
    
    func setupCollectionView() {
        refreshControll.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControll
        
        collectionView.register(UINib(nibName: "FeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedCollectionViewCell")
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: 200)
            layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 200)
        }
    }
    
    @objc func reloadFeedNotification() {
        guard let localUser = DataStore.shared.localUser,
              let blockedUsers = localUser.blockedUsersIds else { return }
        
        feedItems = feedItems.filter({ !blockedUsers.contains($0.creatorId!) })
        collectionView.reloadData()
    }
    
    @objc func refresh() {
        lastDocument = nil
        self.feedItems.removeAll()
        fetchFeedItems()
    }

    private func fetchFeedItems() {
        SVProgressHUD.show()
        DataStore.shared.fetchFeedItems(lastDocument: lastDocument, pageSize: pageSize) { (feeds, lastDocument, error) in
            SVProgressHUD.dismiss()
            self.refreshControll.endRefreshing()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
        
            
            self.lastDocument = lastDocument
            self.tableData.removeAll()
            if let feeds = feeds {
                let filteredFeeds = self.filteredBlockedUsers(feeds: feeds)
                self.feedItems.append(contentsOf: filteredFeeds)
                self.tableData.append(.feedItems(self.feedItems))
                
                if self.feedItems.count == 0 {
                    self.lblNoResults.isHidden = false
                } else {
                    self.lblNoResults.isHidden = true
                }
                if feeds.count == self.pageSize {
                    self.tableData.append(.loading)
                }
                self.collectionView.reloadData()            }
        }
    }
    
    private func filteredBlockedUsers(feeds: [Feed]) -> [Feed] {
        guard let localUser = DataStore.shared.localUser else {
            return feeds
        }
        return feeds.filter { (feed) -> Bool in
            guard let creatorId = feed.creatorId else { return true }
            return !localUser.isBlockedUserWith(id: creatorId)
        }
    }
    
    private func sortAndReload() {
        self.feedItems.sort { (feedOne, feedTwo) -> Bool in
            guard let oneDate = feedOne.createdAt else { return false }
            guard let twoDate = feedTwo.createdAt else { return false }
            
            return oneDate > twoDate
        }
        reloadFeedNotification()
        collectionView.reloadData()
    }
    
    @IBAction func onNewPost(_ sender: UIButton) {
        openImagePickerSheet()
    }
    
    private func openImagePickerSheet() {
        let actionSheet = UIAlertController(title: "Post moment", message: "Plaese pick an image for your moment", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.openImagePicker(sourceType: .camera)
            }
        }
        let library = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(camera)
        actionSheet.addAction(library)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        if sourceType == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCreateMomentWith(image: UIImage) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateMomentViewController") as! CreateMomentViewController
        controller.pickedImage = image
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController: CreateMomentDelegate {
    func didPostItem(item: Feed) {
        feedItems.append(item)
        sortAndReload()
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.openCreateMomentWith(image: image)
            }
        }
    }
}
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = tableData[section]
        switch data {
        case .loading:
            return 1
        case .feedItems(let feedItems):
            return feedItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = tableData[indexPath.section]
        switch data {
        case .loading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            return cell
        case .feedItems(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionViewCell", for: indexPath) as! FeedCollectionViewCell
            let feed = items[indexPath.row]
            cell.setupCell(feedItem: feed)
            return cell
        }
        
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = tableData[indexPath.section]
        switch data {
        case .loading:
            return CGSize(width: collectionView.frame.width, height: 70)
        default:
            return CGSize(width: collectionView.frame.width, height: 200)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feed = feedItems[indexPath.row]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MomentDetailsViewController") as! MomentDetailsViewController
        controller.moment = feed
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is LoadingCollectionViewCell {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchFeedItems()
            }
        }
    }
}
