//
//  AssetDetailCollectionViewCell.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import OLImageView.OLImage
import OLImageView.OLImageView

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
        return sv
    }()
    private lazy var videoPlayBtn: UIButton = {
        let width = kScreenWidth / 3.0
        let frame = CGRect(x: (kScreenWidth-width) / 2.0, y: (kScreenHeight-width) / 2.0, width: width, height: width)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "video-play"), for: .normal)
        return btn
    }()
    private lazy var assetImageView: UIImageView = UIImageView()
    private lazy var assetPhotoLiveView: PHLivePhotoView = {
        let livePhotoView = PHLivePhotoView(frame: kScreenBounds)
        return livePhotoView
    }()
    private lazy var playerLayer: AVPlayerLayer = AVPlayerLayer()
    
    
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
        // 媒体容器
        scrollView.addSubview(assetImageView)
        scrollView.addSubview(assetPhotoLiveView)
        contentView.addSubview(scrollView)
        // 播放按钮
        contentView.addSubview(videoPlayBtn)
        videoPlayBtn.addTarget(self, action: #selector(clickPlay), for: .touchUpInside)
        contentView.layer.addSublayer(playerLayer)
    }
    
    // MARK: 内部方法
    // 更新UI
    private func updateUI() {
        
        assetImageView.image = nil
        assetImageView.isHidden = true
        assetPhotoLiveView.livePhoto = nil
        assetPhotoLiveView.isHidden = true
        
        videoPlayBtn.isHidden = true
        playerLayer.isHidden = true
        
        
        guard let data = asset else { return }
        
        if data.assetType == .photoLive {
            assetPhotoLiveView.isHidden = false
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestLivePhoto(for: data.asset, targetSize: CGSize(width: data.asset.pixelWidth, height: data.asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: { (photoLive, info) in
                self.assetPhotoLiveView.livePhoto = photoLive
                self.assetPhotoLiveView.startPlayback(with: .hint)
            })
        }else {
            // 普通图片(png,jpg,gif) 和 视频的缩略图
            assetImageView.isHidden = false
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            PHImageManager.default().requestImageData(for: data.asset, options: options, resultHandler: { (data, _, _, _) in
                guard let data = data else { return }
                guard let image = OLImage(data: data) else { return }
                self.assetImageView.frame = self.resetFrame(size: image.size)
                self.assetImageView.image = image
            })
            // 设置Video
            if asset?.asset.mediaType == .video {
                videoPlayBtn.isHidden = false
                playerLayer.isHidden = false
            }
        }
    }
    
    @objc private func clickPlay() {
        
        guard let data = asset else { return }
        PHImageManager.default().requestAVAsset(forVideo: data.asset, options: nil, resultHandler: { (asset: AVAsset?, mix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if asset != nil {
                    let playItem = AVPlayerItem(asset: asset!)
                    playItem.audioMix = mix
                    let player = AVPlayer(playerItem: playItem)
                    self.playerLayer.player = player
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                    self.playerLayer.frame = self.resetFrame(size: CGSize(width: data.asset.pixelWidth, height: data.asset.pixelHeight))
                    player.play()
                }
            })
        })
    }
    
    private func resetFrame(size: CGSize) -> CGRect {
        // 调整
        let scale = size.width / size.height
        let newHeight = kScreenWidth / scale
        let x: CGFloat = 0.0
        var y = (kScreenHeight - newHeight) / 2
        if y < 0  {
            y = 0.0
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: newHeight)
        }
        return CGRect(x: x, y: y, width: kScreenWidth, height: newHeight)
    }
}
