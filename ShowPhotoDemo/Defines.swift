//
//  Defines.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/2.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit

/****** 自定义Log ******/
func HWLog<T>(_ message: T, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        let filename = (fileName as NSString).pathComponents.last
        print("\(filename!)\(function)[\(lineNumber)]: \(message)")
    #endif
}

// MARK: 常量
let kScreenBounds = UIScreen.main.bounds
let kScreenWidth = kScreenBounds.size.width
let kScreenHeight = kScreenBounds.size.height
let kItemWH = (kScreenWidth - 1.0*3) / 4.0
let kTargetSize = CGSize(width: kItemWH, height: kItemWH)

// Identifier
let kAlbumTableViewCell = "kAlbumTableViewCell"
let kAlbumGridViewCell = "kAlbumGridViewCell"
let kAssetDetailViewSegue = "kAssetDetailViewSegue"
let kAlbumTableViewSegue = "kAlbumTableViewSegue"
let kAssetDetailViewCell = "kAssetDetailViewCell"
let kBurstsViewCell = "kBurstsViewCell"
