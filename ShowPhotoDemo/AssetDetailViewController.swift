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
    var assets: [HWAsset]!
    var indexPath: IndexPath!
    
    // MARK: 懒加载
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: kScreenBounds, collectionViewLayout: AssetDetailLayout())
        clv.dataSource = self
        clv.register(AssetDetailCollectionViewCell.self, forCellWithReuseIdentifier: assetDetailCell)
        return clv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: UICollectionViewDelegatem, UICollectionViewDataSource
extension AssetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: assetDetailCell, for: indexPath) as! AssetDetailCollectionViewCell
        cell.asset = assets[indexPath.item]
        return cell
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
