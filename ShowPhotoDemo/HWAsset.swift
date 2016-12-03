//
//  HWAsset.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import Foundation
import Photos

/***************
 jpeg,png
 gif
 livephoto
 视频
 延时拍摄
 慢动作
 连拍
***************/
enum HWAssetType: Int {
    case none = 0
    case jpeg
    case png
    case gif
    case photoLive
    case video
    case timeLapse  ///> 延时拍摄
    case burst      ///> 连拍
    case slomo      ///> 慢动作
}

class HWAsset {
    
    /// 资源文件的类型
    var assetType: HWAssetType = .none
    /// 资源文件
    var asset: PHAsset!

    // 初始化
    init(asset: PHAsset, type: HWAssetType) {
        self.asset = asset
        self.assetType = type
        if type == .none {
            reSetType()
        }
    }
    
    // 获取图片的类型，并设置
    private func reSetType() {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, _, _) in
            guard let imageData = data else { return }
            if let resType = UIImage.typeForImageData(data: NSData(data: imageData)) {
                switch resType {
                    case "image/jpeg":
                        self.assetType = .jpeg
                    case "image/png":
                        self.assetType = .png
                    case "image/gif":
                        self.assetType = .gif
                    default: break
                }
            }
        }
    }
    
}
