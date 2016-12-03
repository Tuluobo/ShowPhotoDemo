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

class AssetDetailViewController: UICollectionViewController {
    
    var assets = [HWAsset]()
    var index: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - 自定义布局
class AssetDetailLayout: UICollectionViewFlowLayout {
    // 准备布局
    override func prepare() {
        // 1.设置每一个 cell 的尺寸
        itemSize = UIScreen.main.bounds.size
        // 2.设置cell之间的间隙
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置滚动方向
        scrollDirection = .horizontal
        // 4.设置分页
        collectionView?.isPagingEnabled = true
        // 5.回弹
        collectionView?.bounces = false
        // 6.去除滚动条
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}
