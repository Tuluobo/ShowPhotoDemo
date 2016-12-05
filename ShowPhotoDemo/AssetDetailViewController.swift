//
//  AssetDetailViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

private let assetDetailCell = "AssetDetailCell"

class AssetDetailViewController: UIViewController {
    
    // MARK: 数据源
    var assetCollection: PHAssetCollection?
    fileprivate var assetsResults: PHFetchResult<PHAsset>!
    var indexPath: IndexPath!
    
    // MARK: 懒加载
    fileprivate lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: kScreenBounds, collectionViewLayout: AssetDetailLayout())
        clv.delegate = self
        clv.dataSource = self
        clv.register(AssetDetailCollectionViewCell.self, forCellWithReuseIdentifier: assetDetailCell)
        return clv
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 相册的监听
        PHPhotoLibrary.shared().register(self)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setupUI() {
        // 添加子视图 CollectionView
        self.view.addSubview(collectionView)
        // 去除自动调整 Scrollview
        automaticallyAdjustsScrollViewInsets = false
        // 关闭按钮
        let closeBtnFrame = CGRect(x: 16, y: 28, width: 32, height: 32)
        let closeBtn = UIButton(frame: closeBtnFrame)
        closeBtn.setImage(UIImage(named: "back"), for: .normal)
        self.view.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(closeController), for: .touchUpInside)
        // 删除按钮
        let deleteBtnFrame = CGRect(x: kScreenWidth - (16+32), y: 28, width: 32, height: 32)
        let deleteBtn = UIButton(frame: deleteBtnFrame)
        deleteBtn.setImage(UIImage(named: "delete"), for: .normal)
        self.view.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(deleteThisAsset), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 获取权限
        AlbumManager.requestAuth {
            // 请求数据
            self.refreshData()
        }
    }
    
    /// 刷新数据
    func refreshData() {
        self.assetsResults = AlbumManager.sharedInstance.getAssetsForCollection(collection: assetCollection)
        DispatchQueue.main.async { () -> Void in
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: self.indexPath, at: .left, animated: false)
        }
    }
    
    /// 关闭视图
    @objc private func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 删除资源
    @objc private func deleteThisAsset() {
        if let iPath = collectionView.indexPathsForVisibleItems.last {
            let asset = assetsResults[iPath.item]
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(NSArray(array: [asset]))
            })
        }
    }
    
}

// MARK: UICollectionViewDelegatem, UICollectionViewDataSource
extension AssetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: assetDetailCell, for: indexPath) as! AssetDetailCollectionViewCell
        cell.asset = assetsResults[indexPath.item]
        return cell
    }

}

// MARK: PHPhotoLibraryChangeObserver
extension AssetDetailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let collectionChanges = changeInstance.changeDetails(for: self.assetsResults) {
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
                    self.collectionView.performBatchUpdates(
                        {
                            if removedPaths.count > 0 {
                                self.collectionView.deleteItems(at: removedPaths)
                            }
                            if insertedPaths.count > 0 {
                                self.collectionView.insertItems(at: insertedPaths)
                            }
                    }, completion: nil)
                } else {
                    self.refreshData()
                }
            }
 
        }
    }
    
    private func indexPathsFromIndexSet(indexSet: IndexSet) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for index in indexSet {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        return indexPaths
    }
}

// MARK: - 自定义布局
class AssetDetailLayout: UICollectionViewFlowLayout {
    // 准备布局
    override func prepare() {
        // 1.设置每一个 cell 的尺寸
        itemSize = kScreenBounds.size
        // 2.设置cell之间的间隙
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置滚动方向
        scrollDirection = .horizontal
        // 4.设置分页
        collectionView?.isPagingEnabled = true
        // 5.去除滚动条
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}
