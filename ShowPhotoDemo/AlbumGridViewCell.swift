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
                if data.assetType == .gif {
                    tagLabel.isHidden = false
                    tagLabel.text = "GIF"
                } else if data.assetType == .photoLive {
                    tagLabel.isHidden = false
                    tagLabel.text = "PhotoLive"
                } else if data.assetType == .burst {
                    tagLabel.isHidden = false
                    tagLabel.text = "连拍"
                }
            case .video:
                playImageView.isHidden = false
                tagLabel.isHidden = false
                tagLabel.text = "视频"
            default: break
        }
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        PHImageManager.default().requestImage(for: data.asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            self.thumbImageView.image = image
        }

    }
}
