//
//  HWAssetManager.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import Foundation
import Photos

class HWAssetManager {
    
    static let sharedInstance = HWAssetManager()
    
    var assets: [HWAsset] {
        var assets = [HWAsset]()
        guard let assetsResults = assetsResults else { return assets }
        for i in 0 ..< assetsResults.count {
            let asset = assetsResults[i]
            switch asset.mediaType {
            case .image:
                assets.append(handlerImage(asset: asset))
            case .video:
                assets.append(handlerVideo(asset: asset))
            default:
                assets.append(HWAsset(asset: asset, type: .none))
            }
        }
        return assets
    }
    
    // MARK: 私有属性
    // 全部媒体资源
    private var assetsResults: PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        if albums.count > 0 {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            return PHAsset.fetchAssets(in: albums[0], options: fetchOptions)
        }
        return nil
    }
    
    // 延时视频
    private var timelapsesResults: PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumTimelapses, options: nil)
        if albums.count > 0 {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d && mediaSubtype == %d", PHAssetMediaType.video.rawValue, PHAssetMediaSubtype.videoTimelapse.rawValue)
            return PHAsset.fetchAssets(in: albums[0], options: fetchOptions)
        }
        return nil
    }
    
    // 慢动作视频
    private var slomosResults: PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSlomoVideos, options: nil)
        if albums.count > 0 {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d && mediaType == %d", PHAssetMediaType.video.rawValue, PHAssetMediaSubtype.videoTimelapse.rawValue)
            return PHAsset.fetchAssets(in: albums[0], options: fetchOptions)
        }
        return nil
    }
    
    // MARK: 私有方法
    
    private func handlerImage(asset:PHAsset) -> HWAsset {
        return HWAsset(asset: asset, type: .none)
    }
    
    private func handlerVideo(asset:PHAsset) -> HWAsset {
        return HWAsset(asset: asset, type: .none)
    }
    
}
