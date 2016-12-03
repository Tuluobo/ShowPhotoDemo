//
//  AlbumManager.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import Foundation
import Photos

class AlbumManager {
    
    static let sharedInstance = AlbumManager()
    
    var assets: [HWAsset] = [HWAsset]()
    
    // MARK: 私有属性
    
    // 全部媒体资源
    private var assetsResults: PHFetchResult<PHAsset>?
    // 延时视频
    private var timelapsesResults: PHFetchResult<PHAsset>?
    // 慢动作视频
    private var slomosResults: PHFetchResult<PHAsset>?
    // 连拍
    private var burstsResults: PHFetchResult<PHAsset>?
    // photoLive
    private var photoLivesResults: PHFetchResult<PHAsset>?
        
    func refreshAllData() {
        assetsResults = getAllAsset()
        timelapsesResults = getTimelapses()
        slomosResults = getSlomoVideos()
        burstsResults = getBursts()
        photoLivesResults = getPhotoLives()
        assets = fetchData()
    }
    
    // MARK: 私有方法
    
    private init() {
        refreshAllData()
    }
    
    private func fetchData() -> [HWAsset] {
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
    
    private func getAllAsset() -> PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        if albums.count > 0 {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            return PHAsset.fetchAssets(in: albums[0], options: fetchOptions)
        }
        return nil
    }
    
    private func getTimelapses() -> PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumTimelapses, options: nil)
        if albums.count > 0 {
            return PHAsset.fetchAssets(in: albums[0], options: nil)
        }
        return nil
    }
    
    private func getSlomoVideos() -> PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSlomoVideos, options: nil)
        if albums.count > 0 {
            return PHAsset.fetchAssets(in: albums[0], options: nil)
        }
        return nil
    }
    
    private func getBursts() -> PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumBursts, options: nil)
        if albums.count > 0 {
            return PHAsset.fetchAssets(in: albums[0], options: nil)
        }
        return nil
    }
    
    private func getPhotoLives() -> PHFetchResult<PHAsset>? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        if albums.count > 0 {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d && mediaSubtype == %d", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoLive.rawValue)
            return PHAsset.fetchAssets(in: albums[0], options: fetchOptions)
        }
        return nil
    }
    
    private func handlerImage(asset: PHAsset) -> HWAsset {
        // photoLive
        if let photoLives = photoLivesResults, photoLives.contains(asset) {
            return HWAsset(asset: asset, type: .photoLive)
        }
        // 连拍
        if let bursts = burstsResults, bursts.contains(asset) {
            return HWAsset(asset: asset, type: .burst)
        }
        // 普通照片
        return HWAsset(asset: asset, type: .none)
    }
    
    private func handlerVideo(asset: PHAsset) -> HWAsset {
        // 慢动作
        if let slomos = slomosResults, slomos.contains(asset) {
            return HWAsset(asset: asset, type: .slomo)
        }
        // 延时
        if let timelapses = timelapsesResults, timelapses.contains(asset) {
            return HWAsset(asset: asset, type: .timeLapse)
        }
        return HWAsset(asset: asset, type: .video)
    }
    
}
