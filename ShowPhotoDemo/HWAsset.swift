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
 jpeg,png,gif
 livephoto
 视频
 延时拍摄
 慢动作
 连拍
***************/
enum HWAssetType: Int {
    case none = 0
    case photoLive
    case burst      ///> 连拍
    
    case video
    case timeLapse  ///> 延时拍摄
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
    }
}
