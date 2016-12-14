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
    
    // MARK: 属性
    /// 对于连拍照片的是否正在展示标记
    fileprivate var isShowing = false
    /// 状态栏字体显示为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1.内容区域
        self.view.addSubview(contentView)
        // 去除自动调整 Scrollview
        automaticallyAdjustsScrollViewInsets = false
        contentView.addSubview(assetCellView)
        // 2.Nav区域
        self.view.addSubview(closeBtn)
        self.view.addSubview(deleteBtn)
        // 3.TabBar区域
        view.addSubview(controlView)
        controlView.addSubview(selectBtn)
        // 4.Other
        setupCellView(row: indexPath.item)
        // 相册的监听
        PHPhotoLibrary.shared().register(self)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    fileprivate func setupCellView(row: Int) {
        let asset = assetsResults[row]
        assetCellView.frame = contentView.bounds
        assetCellView.asset = asset
        controlView.isHidden = !asset.representsBurst
    }
    
    /// 关闭视图
    @objc private func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 删除资源
    @objc private func deleteThisAsset() {
        let row = Int(contentView.contentOffset.y / kScreenWidth)
        let asset = assetsResults[row]
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(NSArray(array: [asset]))
        })
    }
    
    /// 选择连拍照片
    @objc private func clickControlSelectBtn() {
        if isShowing {
            burstsViewController.view.removeFromSuperview()
            burstsViewController.removeFromParentViewController()
            selectBtn.setTitle("查看连拍", for: .normal)
            isShowing = false
        } else{
            let row = Int(contentView.contentOffset.y / kScreenWidth)
            if let identifier = assetsResults[row].burstIdentifier {
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
    /// UIScrollView
    fileprivate lazy var contentView: UIScrollView = {
        let cv = UIScrollView(frame: kScreenBounds)
        cv.backgroundColor = UIColor.black
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.contentSize = CGSize(width: kScreenWidth*CGFloat(self.assetsResults.count), height: kScreenHeight)
        var offset = cv.contentOffset
        offset.x = CGFloat(self.indexPath.item) * kScreenWidth
        cv.setContentOffset(offset, animated: false)
        return cv
    }()
    /// 展示图片的View
    fileprivate lazy var assetCellView: AssetDetailView = {
        let view = AssetDetailView(frame: kScreenBounds)
        return view
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
extension AssetDetailViewController: UIScrollViewDelegate {
    
    /**
     * 在scrollView滚动动画结束时, 就会调用这个方法
     * 前提: 人为拖拽scrollView产生的滚动动画
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let row = Int(scrollView.contentOffset.x / kScreenWidth)
        setupCellView(row: row)
    }

}

// MARK: PHPhotoLibraryChangeObserver
extension AssetDetailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
