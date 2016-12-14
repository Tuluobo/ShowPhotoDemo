//
//  AlbumGridViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/11/29.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

class AlbumGridViewController: UICollectionViewController {
    
    /// 相册
    var assetCollection: PHAssetCollection?
    /// 数据源
    fileprivate var assetsResults: PHFetchResult<PHAsset>?
    
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
        SVProgressHUD.show()
        DispatchQueue.global().async {
            self.assetsResults = AlbumManager.sharedInstance.getAssetsForCollection(collection: self.assetCollection)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.collectionView?.reloadData()
                if let assetsResults = self.assetsResults, assetsResults.count > 0 {
                self.collectionView?.scrollToItem(at: IndexPath(row: assetsResults.count-1, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResults?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAlbumGridViewCell, for: indexPath) as! AlbumGridViewCell
        cell.asset = assetsResults![indexPath.item]
        return cell
    }
    
    /// 点击显示大图
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: kAssetDetailViewSegue, sender: indexPath)
    }
    
    /// 通过 Segue 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 显示大图
        if let identifier = segue.identifier, identifier == kAssetDetailViewSegue {
            if let destVC = segue.destination as? AssetDetailViewController {
                destVC.assetsResults = assetsResults
                destVC.indexPath = sender as! IndexPath
            }
        }
        // 相簿
        if let identifier = segue.identifier, identifier == kAlbumTableViewSegue {
            if let destVC = segue.destination as? AlbumTableViewController {
                destVC.presentViewController = self
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
            guard let assetsResults = self.assetsResults, let collectionChanges = changeInstance.changeDetails(for: assetsResults) else { return }
            self.assetsResults = collectionChanges.fetchResultAfterChanges
            if collectionChanges.hasIncrementalChanges {
                var removedPaths = [IndexPath]()
                var insertedPaths = [IndexPath]()
                if let removed = collectionChanges.removedIndexes {
                    removedPaths = self.indexPathsFromIndexSet(indexSet: removed)
                }
                if let inserted = collectionChanges.insertedIndexes {
                    insertedPaths = self.indexPathsFromIndexSet(indexSet: inserted)
                }
                self.collectionView?.performBatchUpdates(
                    {
                        if removedPaths.count > 0 {
                            self.collectionView?.deleteItems(at: removedPaths)
                        }
                        if insertedPaths.count > 0 {
                            self.collectionView?.insertItems(at: insertedPaths)
                        }
                }, completion: nil)
            } else {
                self.collectionView?.reloadData()
            }
        }
    }
    
    /// 将IndexSet 转 [IndexPath]
    private func indexPathsFromIndexSet(indexSet: IndexSet) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for index in indexSet {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        return indexPaths
    }
}
