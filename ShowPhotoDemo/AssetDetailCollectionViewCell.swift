//
//  AssetDetailCollectionViewCell.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos

class AssetDetailCollectionViewCell: UICollectionViewCell {
    
    // 数据源
    var asset: HWAsset? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: 懒加载
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
//        sv.backgroundColor = UIColor.black
        return sv
    }()
    private lazy var assetImageView: UIImageView = UIImageView()
    private lazy var videoPlayBtn: UIButton = {
        let width = kScreenWidth / 3.0
        let frame = CGRect(x: (kScreenWidth-width) / 2.0, y: (kScreenHeight-width) / 2.0, width: width, height: width)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "video-play"), for: .normal)
        return btn
    }()
    
    
    // MARK: 生命周期方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        scrollView.frame = kScreenBounds
        scrollView.addSubview(assetImageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(videoPlayBtn)
    }
    
    // MARK: 内部方法
    // 更新UI
    private func updateUI() {
        
        assetImageView.image = nil
        videoPlayBtn.isHidden = true
        
        guard let data = asset else { return }
        // 设置Image
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        PHImageManager.default().requestImage(for: data.asset, targetSize: CGSize(width: data.asset.pixelWidth, height: data.asset.pixelHeight), contentMode: .aspectFit, options: options) { (image, info) in
            guard let image = image else { return }
            // 调整
            let scale = image.size.width / image.size.height
            let newHeight = kScreenWidth / scale
            let x: CGFloat = 0.0
            var y = (self.frame.size.height - newHeight) / 2
            if y < 0  {
                y = 0.0
                self.scrollView.contentSize = CGSize(width: kScreenWidth, height: newHeight)
            }
            self.assetImageView.frame = CGRect(x: x, y: y, width: kScreenWidth, height: newHeight)
            self.assetImageView.image = image
        }
        // 设置Video
        if asset?.asset.mediaType == .video {
            videoPlayBtn.isHidden = false
        }
    }
}
