//
//  AlbumTableViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/5.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewController: UITableViewController {

    /// 父级控制器
    var presentViewController: AlbumGridViewController!
    /// 数据源
    var assetCollecitons = [PHFetchResult<PHAssetCollection>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 注册监听
        PHPhotoLibrary.shared().register(self)
        // 刷新数据
        refreshData()
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    fileprivate func refreshData() {
        assetCollecitons.append(AlbumManager.sharedInstance.getAssetCollections())
        assetCollecitons.append(PHAssetCollection.fetchTopLevelUserCollections(with: nil) as! PHFetchResult<PHAssetCollection>)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return assetCollecitons.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "系统相册"
        } else if section == 1 {
            return "自定义相册"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollecitons[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 数据
        let collection = assetCollecitons[indexPath.section][indexPath.item]
        let phAssetFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        // cell
        let cell = tableView.dequeueReusableCell(withIdentifier: kAlbumTableViewCell, for: indexPath)
        cell.textLabel?.text = collection.localizedTitle
        cell.detailTextLabel?.text = "\(phAssetFetchResult.count)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentViewController.assetCollection = assetCollecitons[indexPath.section][indexPath.item]
        presentViewController.refreshData()
        _ = navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver
extension AlbumTableViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { () -> Void in
            self.refreshData()
        }
    }
}
