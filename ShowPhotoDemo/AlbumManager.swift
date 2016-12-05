//
//  AlbumManager.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import Foundation
import Photos
import SVProgressHUD

protocol AlbumManagerDelegate {
    func albumChanger()
}

class AlbumManager {
    
    static let sharedInstance = AlbumManager()
    
    // MARK: 私有属性
    /// 缓存管理类
    lazy private var cacheIManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        return manager
    }()
    /// 慢动作视频
    private var slomosResults: PHFetchResult<PHAsset>?
    /// 连拍
    private var burstsResults: PHFetchResult<PHAsset>?
    
    /// 请求权限
    class func requestAuth(completed:(()->Void)?) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completed?()
        case .denied:
            SVProgressHUD.showError(withStatus: "需要在设置中开启相册权限")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    completed?()
                } else {
                    SVProgressHUD.showError(withStatus: "相册访问失败")
                }
            })
        case .restricted:
            SVProgressHUD.showError(withStatus: "系统不允许用户访问相册")
        }
    }
    
    func getAssetsForCollection(collection: PHAssetCollection?) -> PHFetchResult<PHAsset> {
        var album = collection
        if album == nil {
            album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)[0]
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let assets = PHAsset.fetchAssets(in: album!, options: fetchOptions)
        fetchOtherData()
        return assets
    }
    
    func getType(asset: PHAsset) -> String? {
        if asset.mediaType == .image {
            if asset.mediaSubtypes == .photoLive {
                return "PhotoLive"
            }
            // 连拍
            if let bursts = burstsResults, bursts.contains(asset) {
                return "连拍"
            }
            // 普通照片
            return nil
        } else {
            // 延时
            if asset.mediaSubtypes == .videoTimelapse {
                return "延时"
            }
            // 慢动作
            if let slomos = slomosResults, slomos.contains(asset) {
                return "慢动作"
            }
            return "视频"
        }
    }

    // MARK: 私有方法
    /// 计算数据源
    private func fetchOtherData() {
        slomosResults = getSlomoVideos()
        burstsResults = getBursts()
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
}
