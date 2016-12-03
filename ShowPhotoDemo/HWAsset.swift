//
//  HWAsset.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import Foundation
import Photos

enum HWAssetType: String {
    case none = "none"
    case jpeg = "image/jpg"
    case png = "image/png"
    case gif = "image/gif"
    case photoLive = "photoLive"
    case video = "video"
}

class HWAsset {
    
    /// 资源文件
    var asset: PHAsset! {
        didSet {
            updateOtherData()
        }
    }
    /// 资源文件的类型
    var assetType: HWAssetType = .none
    /// 资源文件的数据
    var assetData: NSData?
    
    
    // 初始化
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    // MARK: 内部方法
    
    private func updateOtherData() {
        switch asset.mediaType {
        case .image:
            handlerImage()
        case .video:
            handlerVideo()
        default:break
        }
    }
    
    private func handlerImage() {
//        switch asset.mediaSubtypes {
//        // photoLive
//        case .photoLive:
//            assetType = .ph
//        default:
//            let options = PHImageRequestOptions()
//            options.isNetworkAccessAllowed = false
//            options.isSynchronous = false
//            options.deliveryMode = .highQualityFormat
//            options.resizeMode = .exact
//            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
//                print("image info: \(info)")
//                self.thumbImageView.image = image
//            }
//        }
    }
        
    private func handlerVideo() {
        
    }
}
