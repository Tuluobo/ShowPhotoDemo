//
//  AlbumGridViewCell.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/11/29.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

class AlbumGridViewCell: UICollectionViewCell {
    
    /// 主缩略图
    @IBOutlet weak var thumbImageView: UIImageView!
    /// Video上的播放图标
    @IBOutlet weak var playImageView: UIImageView!
    /// Tag 信息
    @IBOutlet weak var tagLabel: UILabel!
    
    /// 数据源
    var asset: PHAsset? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // 初始化
        thumbImageView.image = nil
        playImageView.isHidden = true
        tagLabel.isHidden = true
        
        guard let asset = asset else { return }
        switch asset.mediaType {
            case .image:
                if let type = AlbumManager.sharedInstance.getType(asset: asset) {
                    tagLabel.isHidden = false
                    tagLabel.text = type
                }
            case .video:
                playImageView.isHidden = false
                tagLabel.isHidden = false
                if let type = AlbumManager.sharedInstance.getType(asset: asset) {
                    tagLabel.text = type
            }
            default: break
        }
        PHImageManager.default().requestImage(for: asset, targetSize: kTargetSize, contentMode: .aspectFill, options: nil) { (image, info) in
            self.thumbImageView.image = image
        }
    }
}
