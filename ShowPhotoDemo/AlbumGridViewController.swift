//
//  AlbumGridViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/11/29.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "AlbumGridViewCell"
private let detailSegueIdentifier = "DetailSegue"

class AlbumGridViewController: UICollectionViewController {
    
    // MARK: 普通变量
    /// 数据源
    /// 相册
    var assetCollection: PHAssetCollection?
    fileprivate var assetsResults: PHFetchResult<PHAsset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取权限
        AlbumManager.requestAuth {
            // 请求数据
            self.refreshData()
        }
        PHPhotoLibrary.shared().register(self)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// 刷新数据
    func refreshData() {
        self.assetsResults = AlbumManager.sharedInstance.getAssetsForCollection(collection: assetCollection)
        DispatchQueue.main.async { () -> Void in
            self.collectionView?.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath(row: self.assetsResults.count-1, section: 0), at: .bottom, animated: false)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumGridViewCell
        cell.asset = assetsResults[indexPath.item]
        return cell
    }
    
    // 点击选择
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailSegueIdentifier, sender: indexPath)
    }
    
    // 通过 Segue 展示 Detail Page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == detailSegueIdentifier {
            if let destVC = segue.destination as? AssetDetailViewController {
                destVC.assetCollection = assetCollection
                destVC.indexPath = sender as! IndexPath
            }
        }
    }
}


// MARK: PhotoCollectionViewFlowLayout  流布局
class PhotoCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        // Cell 间隙
        minimumLineSpacing = 1.0
        minimumInteritemSpacing = 1.0
        // Cell Size
        itemSize = kTargetSize
        // 背景色
        collectionView?.backgroundColor = UIColor.white
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension AlbumGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let change = changeInstance.changeDetails(for: self.assetsResults) {
                if change.hasIncrementalChanges {
                    self.refreshData()
                }
            }

        }
    }
}
