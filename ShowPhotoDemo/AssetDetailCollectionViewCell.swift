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
    var asset: PHAsset? {
        didSet {
            updateUI()
        }
    }
    private var isPlaying = false
    
    // MARK: 懒加载
    fileprivate lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.maximumZoomScale = 3.0
        return sv
    }()
    fileprivate lazy var videoPlayBtn: UIButton = {
        let width = kScreenWidth / 3.0
        let frame = CGRect(x: (kScreenWidth-width) / 2.0, y: (kScreenHeight-width) / 2.0, width: width, height: width)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "video-play"), for: .normal)
        return btn
    }()
    fileprivate lazy var assetImageView: UIImageView = UIImageView()
    fileprivate lazy var assetPhotoLiveView: PHLivePhotoView = PHLivePhotoView()
    fileprivate lazy var player: AVPlayer = AVPlayer()
    fileprivate lazy var playerLayer: AVPlayerLayer = AVPlayerLayer()
    fileprivate lazy var controlView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 44, width: kScreenWidth, height: 44))
        view.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        return view
    }()
    fileprivate lazy var controlBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: (kScreenWidth - 32) / 2.0, y: 6, width: 32, height: 32))
        btn.addTarget(self, action: #selector(clickControlBtn), for: .touchUpInside)
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
        // Image容器
        scrollView.addSubview(assetImageView)
        // PhotoLive
        scrollView.addSubview(assetPhotoLiveView)
        contentView.addSubview(scrollView)
        // Video
        contentView.layer.addSublayer(playerLayer)
        // 播放按钮
        contentView.addSubview(videoPlayBtn)
        videoPlayBtn.addTarget(self, action: #selector(clickControlBtn), for: .touchUpInside)
        // 播放控制区
        controlView.addSubview(controlBtn)
        contentView.addSubview(controlView)
    }
    
    // MARK: 内部方法
    // 更新UI
    private func updateUI() {
        controlView.isHidden = true
        assetImageView.image = nil
        assetImageView.isHidden = true
        assetPhotoLiveView.livePhoto = nil
        assetPhotoLiveView.isHidden = true
        
        isPlaying = false
        videoPlayBtn.isHidden = true
        playerLayer.isHidden = true
        
        guard let asset = asset else { return }
        if asset.mediaSubtypes == .photoLive {
            assetPhotoLiveView.isHidden = false
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestLivePhoto(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: { (photoLive, info) in
                guard let photoLive = photoLive else { return }
                self.assetPhotoLiveView.frame = self.resetFrame(size: photoLive.size)
                self.assetPhotoLiveView.livePhoto = photoLive
                self.assetPhotoLiveView.startPlayback(with: .hint)
            })
        } else {
            // 普通图片(png,jpg,gif) 和视频的缩略图
            assetImageView.isHidden = false
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, _, _, _) in
                guard let data = data else { return }
                guard let image = OLImage(data: data) else { return }
                self.assetImageView.frame = self.resetFrame(size: image.size)
                self.assetImageView.image = image
            })
            
            if asset.mediaType == .video {
                videoPlayBtn.isHidden = false
                playerLayer.isHidden = false
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avAsset: AVAsset?, mix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        guard let avAsset = avAsset else { return }
                        let playItem = AVPlayerItem(asset: avAsset)
                        playItem.audioMix = mix
                        self.player.replaceCurrentItem(with: playItem)
                        self.playerLayer.player = self.player
                        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                        self.playerLayer.frame = self.resetFrame(size: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
                    })
                })
            }
        }
    }
    
    @objc private func clickControlBtn() {
        isPlaying ? pause() : play()
    }
    
    private func play() {
        player.play()
        isPlaying = true
        videoPlayBtn.isHidden = true
        controlView.isHidden = false
        controlBtn.setImage(UIImage(named: "zanting"), for: .normal)
    }
    
    private func pause() {
        player.pause()
        isPlaying = false
        self.videoPlayBtn.isHidden = false
        self.controlView.isHidden = true
        self.controlBtn.setImage(UIImage(named: "play"), for: .normal)
    }
    
    fileprivate func resetFrame(size: CGSize) -> CGRect {
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

// MARK: - UIScrollViewDelegate
extension AssetDetailCollectionViewCell: UIScrollViewDelegate {
    /**
     *  返回一个scrollView的子控件进行缩放
     */
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !self.assetImageView.isHidden {
            return self.assetImageView
        }
        if !self.assetPhotoLiveView.isHidden {
            return self.assetPhotoLiveView
        }
        return nil
    }
    
    // 让图片居中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        let center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        assetImageView.center = center
        assetPhotoLiveView.center = center
    }
}
