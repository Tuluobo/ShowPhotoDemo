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
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var asset: HWAsset? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // 初始化
        thumbImageView.image = nil
        playImageView.isHidden = true
        tagLabel.isHidden = true
        
        guard let data = asset else { return }
        
        switch data.asset.mediaType {
            case .image:
                if data.assetType == .photoLive {
                    tagLabel.isHidden = false
                    tagLabel.text = "PhotoLive"
                } else if data.assetType == .burst {
                    tagLabel.isHidden = false
                    tagLabel.text = "连拍"
                } else if data.assetType == .gif {
                    tagLabel.isHidden = false
                    tagLabel.text = "GIF"
                }
            case .video:
                playImageView.isHidden = false
                tagLabel.isHidden = false
                tagLabel.text = "视频"
                if data.assetType == .slomo {
                    tagLabel.text = "慢动作"
                } else if data.assetType == .timeLapse {
                    tagLabel.text = "延时"
                }
            default: break
        }
        
        PHImageManager.default().requestImage(for: data.asset, targetSize: kTargetSize, contentMode: .aspectFill, options: nil) { (image, info) in
            self.thumbImageView.image = image
        }
    }
}
