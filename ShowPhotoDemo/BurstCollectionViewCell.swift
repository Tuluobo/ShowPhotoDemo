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
    
    @IBOutlet weak var assetImageView: UIImageView!
    
    var asset: PHAsset? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        assetImageView.image = nil
        
        guard let asset = asset else { return }
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
            self.assetImageView.frame = self.resetFrame(size: image?.size ?? CGSize.zero)
            self.assetImageView.image = image
        })
        
    }
    
    /// 计算图像的Frame
    fileprivate func resetFrame(size: CGSize) -> CGRect {
        // 调整
        let scale = size.width / size.height
        let newHeight = kScreenWidth / scale
        let x: CGFloat = 0.0
        let y = (kScreenHeight - newHeight) / 2
        return CGRect(x: x, y: y, width: kScreenWidth, height: newHeight)
    }
    
}
