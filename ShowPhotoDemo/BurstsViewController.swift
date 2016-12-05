//
//  BurstsViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/5.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "BurstCollectionViewCell"

class BurstsViewController: UICollectionViewController {
    
    var assets: PHFetchResult<PHAsset>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BurstCollectionViewCell
        cell.asset = assets![indexPath.item]
        return cell
    }

}

// MARK: - 自定义布局
class BurstsViewLayout: UICollectionViewFlowLayout {
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
        // 5.回弹
        collectionView?.bounces = false
        // 6.去除滚动条
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}
