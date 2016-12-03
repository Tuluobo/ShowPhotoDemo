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
                handlerImage(asset: data)
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
    
    // 图片的处理
    private func handlerImage(asset: HWAsset) {
        
        if asset.assetType != .none {
            if asset.assetType == .photoLive {
                tagLabel.isHidden = false
                tagLabel.text = "PhotoLive"
            } else if asset.assetType == .burst {
                tagLabel.isHidden = false
                tagLabel.text = "连拍"
            }
        } else {
            // 判断普通图片的格式
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            PHImageManager.default().requestImageData(for: asset.asset, options: options) { (data, _, _, _) in
                guard let imageData = data else { return }
                if let resType = UIImage.typeForImageData(data: NSData(data: imageData)) {
                    switch resType {
                        case "image/jpeg":
                        asset.assetType = .jpeg
                        case "image/png":
                        asset.assetType = .png
                        case "image/gif":
                        asset.assetType = .gif
                        self.tagLabel.isHidden = false
                        self.tagLabel.text = "GIF"
                        default: break
                    }
                }
            }
        }
        
    }
}
