//
//  AlbumGridViewController.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/11/29.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

private let reuseIdentifier = "AlbumGridViewCell"
private let detailSegueIdentifier = "DetailSegue"

class AlbumGridViewController: UICollectionViewController {
    
    // MARK: 懒加载
    
    // MARK: 普通变量
    private var assetsResults = [HWAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取权限
        requestAuth { 
            // 请求数据
            self.assetsResults = AlbumManager.sharedInstance.assets
        }
    }
    
    /// 请求权限
    private func requestAuth(completed:(()->Void)?) {
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumGridViewCell
        cell.asset = assetsResults[indexPath.item]
        return cell
    }
    
    // 点击选择
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailSegueIdentifier, sender: indexPath)
    }
    
    // 通过 Segue 展示 Detail Page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == detailSegueIdentifier {
            if let destVC = segue.destination as? AssetDetailViewController {
                destVC.assets = assetsResults
                destVC.index = sender as! IndexPath
            }
        }
    }

}

// MARK: PhotoCollectionViewFlowLayout  流布局
class PhotoCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        // Cell 间隙
        minimumLineSpacing = 1.0
        minimumInteritemSpacing = 1.0
        // Cell Size
        itemSize = targetSize
        // 背景色
        collectionView?.backgroundColor = UIColor.white
    }
}
