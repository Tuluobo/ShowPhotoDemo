//
//  BurstCollectionViewCell.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/5.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

class BurstCollectionViewCell: UICollectionViewCell {
    
    /// 连拍图片视图
    @IBOutlet weak var assetImageView: UIImageView!
    
    /// 数据源
    var asset: PHAsset? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // 初始化
        assetImageView.image = nil
        
        guard let asset = asset else { return }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
            guard let image = image else { return }
            let newHeight = kScreenWidth / (image.size.width / image.size.height)
            self.assetImageView.frame = CGRect(x: 0, y: (kScreenHeight - newHeight) / 2, width: kScreenWidth, height: newHeight)
            self.assetImageView.image = image
        })
    }
}
