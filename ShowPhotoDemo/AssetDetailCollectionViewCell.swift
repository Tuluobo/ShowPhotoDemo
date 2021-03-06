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
import YYImage

class AssetDetailCollectionViewCell: UICollectionViewCell {
    
    /// 数据源
    var asset: PHAsset? {
        didSet {
            updateUI()
        }
    }
    /// 视频播放状态
    private var isPlaying = false
    
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
        // 进度指示器
        contentView.addSubview(indicatorView)
        // 控制区
        contentView.addSubview(controlView)
        controlView.addSubview(controlPlayBtn)
    }
    
    // MARK: 内部方法
    // 更新UI
    private func updateUI() {
        
        controlView.isHidden = true
        isPlaying = false
        controlPlayBtn.isHidden = true
        videoPlayBtn.isHidden = true
        playerLayer.isHidden = true
        
        assetImageView.image = nil
        assetImageView.isHidden = true
        assetPhotoLiveView.livePhoto = nil
        assetPhotoLiveView.isHidden = true
        
        indicatorView.stopAnimating()

        guard let asset = asset else { return }
        if asset.mediaSubtypes == .photoLive {
            assetPhotoLiveView.isHidden = false
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            indicatorView.startAnimating()
            DispatchQueue.global().async {
                PHImageManager.default().requestLivePhoto(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: { (photoLive, info) in
                    DispatchQueue.main.async {
                        guard let photoLive = photoLive else { return }
                        self.assetPhotoLiveView.frame = self.resetFrame(size: photoLive.size)
                        self.assetPhotoLiveView.livePhoto = photoLive
                        self.assetPhotoLiveView.startPlayback(with: .hint)
                        self.indicatorView.stopAnimating()
                    }
                })
            }
        } else {
            // 普通图片(png,jpg,gif) 和视频的缩略图
            assetImageView.isHidden = false
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            indicatorView.startAnimating()
            DispatchQueue.global().async {
                PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, _, _, _) in
                    guard let data = data else { return }
                    guard let decoder = YYImageDecoder(data: data, scale: 1.0) else { return }
                    var image: UIImage?
                    if decoder.type == YYImageType.GIF {
                        var images = [UIImage]()
                        var duration: TimeInterval = 0.0
                        for i in 0..<decoder.frameCount {
                            images.append(decoder.frame(at: i, decodeForDisplay: true)!.image!)
                            duration += decoder.frameDuration(at: i)
                        }
                        image = UIImage.animatedImage(with: images, duration: duration)
                    } else {
                        image = decoder.frame(at: 0, decodeForDisplay: true)?.image
                    }
                    DispatchQueue.main.async {
                        self.assetImageView.image = image
                        self.assetImageView.frame = self.resetFrame(size: image?.size ?? CGSize.zero)
                        self.indicatorView.stopAnimating()
                    }
                })
            }
            
            if asset.mediaType == .video {
                videoPlayBtn.isHidden = false
                playerLayer.isHidden = false
                controlPlayBtn.isHidden = false
                self.indicatorView.startAnimating()
                DispatchQueue.global().async {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avAsset: AVAsset?, mix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                        DispatchQueue.main.async(execute: { () -> Void in
                            guard let avAsset = avAsset else { return }
                            let playItem = AVPlayerItem(asset: avAsset)
                            playItem.audioMix = mix
                            self.player.replaceCurrentItem(with: playItem)
                            self.playerLayer.player = self.player
                            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                            self.playerLayer.frame = self.resetFrame(size: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
                            self.indicatorView.stopAnimating()
                        })
                    })
                }
            }
        }
    }
    
    @objc private func clickControlPlayBtn() {
        isPlaying ? pause() : play()
    }
    
    private func play() {
        player.play()
        isPlaying = true
        videoPlayBtn.isHidden = true
        controlView.isHidden = false
        controlPlayBtn.setImage(UIImage(named: "zanting"), for: .normal)
    }
    
    private func pause() {
        player.pause()
        isPlaying = false
        videoPlayBtn.isHidden = false
        controlView.isHidden = true
        controlPlayBtn.setImage(UIImage(named: "play"), for: .normal)
    }
    
    /// 计算图像的Frame
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
    
    // MARK: 懒加载
    /// 图片的ScrollView容器
    fileprivate lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.maximumZoomScale = 3.0
        return sv
    }()
    /// 图片的视图
    fileprivate lazy var assetImageView: UIImageView = UIImageView()
    /// LivePhoto
    fileprivate lazy var assetPhotoLiveView: PHLivePhotoView = PHLivePhotoView()
    /// 播放按钮
    fileprivate lazy var videoPlayBtn: UIButton = {
        let width = kScreenWidth / 3.0
        let frame = CGRect(x: (kScreenWidth-width) / 2.0, y: (kScreenHeight-width) / 2.0, width: width, height: width)
        let btn = UIButton(frame: frame)
        btn.setImage(UIImage(named: "video-play"), for: .normal)
        btn.addTarget(self, action: #selector(clickControlPlayBtn), for: .touchUpInside)
        return btn
    }()
    /// 播放器
    fileprivate lazy var player: AVPlayer = AVPlayer()
    /// 播放图层
    fileprivate lazy var playerLayer: AVPlayerLayer = AVPlayerLayer()
    /// 控制区容器
    fileprivate lazy var controlView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 44, width: kScreenWidth, height: 44))
        view.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        return view
    }()
    /// 播放控制按钮
    fileprivate lazy var controlPlayBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: (kScreenWidth - 32) / 2.0, y: 6, width: 32, height: 32))
        btn.addTarget(self, action: #selector(clickControlPlayBtn), for: .touchUpInside)
        return btn
    }()
    /// 进度指示器
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        let iView = UIActivityIndicatorView()
        iView.center = self.contentView.center
        return iView
    }()

}

// MARK: - UIScrollViewDelegate
extension AssetDetailCollectionViewCell: UIScrollViewDelegate {
    /// 返回一个scrollView的子控件进行缩放
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !self.assetImageView.isHidden {
            return self.assetImageView
        }
        if !self.assetPhotoLiveView.isHidden {
            return self.assetPhotoLiveView
        }
        return nil
    }
    
    /// 图片居中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        let center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        assetImageView.center = center
        assetPhotoLiveView.center = center
    }
}
