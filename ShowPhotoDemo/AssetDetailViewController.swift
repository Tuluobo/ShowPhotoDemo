//
//  AssetDetailViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

class AssetDetailViewController: UIViewController {
    
    // MARK: 数据源
    var assetsResults: PHFetchResult<PHAsset>!
    var indexPath: IndexPath!
    
    /// 对于连拍照片的是否正在展示标记
    fileprivate var isShowing = false
    
    /// 状态栏字体显示为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加子视图 CollectionView
        self.view.addSubview(collectionView)
        // 去除自动调整 Scrollview
        automaticallyAdjustsScrollViewInsets = false
        // 关闭按钮
        self.view.addSubview(closeBtn)
        // 删除按钮
        self.view.addSubview(deleteBtn)
        // 控制区
        view.addSubview(controlView)
        // 选择按钮
        controlView.addSubview(selectBtn)
        // 相册的监听
        PHPhotoLibrary.shared().register(self)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 刷新数据
        collectionView.scrollToItem(at: self.indexPath, at: .left, animated: false)
        controlView.isHidden = !self.assetsResults[self.indexPath.item].representsBurst
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
    
    /// 选择连拍照片
    @objc private func clickControlSelectBtn() {
        if isShowing {
            burstsViewController.view.removeFromSuperview()
            burstsViewController.removeFromParentViewController()
            selectBtn.setTitle("查看连拍", for: .normal)
            isShowing = false
        } else{
            if let indexPath = collectionView.indexPathsForVisibleItems.last, let identifier = assetsResults[indexPath.item].burstIdentifier {
                
                let options = PHFetchOptions()
                options.includeAllBurstAssets = true
                let assets = PHAsset.fetchAssets(withBurstIdentifier: identifier, options: options)
                self.view.insertSubview(burstsViewController.view, belowSubview: controlView)
                self.addChildViewController(burstsViewController)
                burstsViewController.assets = assets
                burstsViewController.collectionView?.reloadData()
                selectBtn.setTitle("完成", for: .normal)
                isShowing = true
            }
        }
    }
    
    // MARK: 懒加载
    /// CollectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: kScreenBounds, collectionViewLayout: AssetDetailLayout())
        clv.delegate = self
        clv.dataSource = self
        clv.register(AssetDetailCollectionViewCell.self, forCellWithReuseIdentifier: kAssetDetailViewCell)
        return clv
    }()
    /// 返回按钮
    fileprivate lazy var closeBtn: UIButton = {
        let frame = CGRect(x: 16, y: 28, width: 32, height: 32)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(closeController), for: .touchUpInside)
        return btn
    }()
    /// 删除按钮
    fileprivate lazy var deleteBtn: UIButton = {
        let frame = CGRect(x: kScreenWidth - (16+32), y: 28, width: 32, height: 32)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "delete"), for: .normal)
        btn.addTarget(self, action: #selector(deleteThisAsset), for: .touchUpInside)
        return btn
    }()
    /// 连拍视图
    fileprivate lazy var burstsViewController: BurstsViewController = {
        return UIStoryboard(name: "Bursts", bundle: nil).instantiateInitialViewController() as! BurstsViewController
    }()
    /// 控制区视图
    fileprivate lazy var controlView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 44, width: kScreenWidth, height: 44))
        view.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        return view
    }()
    /// 选择按钮
    fileprivate lazy var selectBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: (kScreenWidth - 100) / 2.0, y: 6, width: 100, height: 32))
        btn.addTarget(self, action: #selector(clickControlSelectBtn), for: .touchUpInside)
        btn.setTitle("查看连拍", for: .normal)
        return btn
    }()
}

// MARK: UICollectionViewDelegatem, UICollectionViewDataSource
extension AssetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssetDetailViewCell, for: indexPath) as! AssetDetailCollectionViewCell
        cell.asset = assetsResults[indexPath.item]
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isShowing = false
        if let indexPath = collectionView.indexPathsForVisibleItems.last {
            controlView.isHidden = !assetsResults[indexPath.item].representsBurst
        }
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
                    self.collectionView.reloadData()
                }
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
