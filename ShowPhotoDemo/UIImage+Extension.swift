//
//  UIImage+Extension.swift
//  ShowPhotoDemo
//
//  Created by WangHao on 2016/12/3.
//  Copyright © 2016年 Tuluobo. All rights reserved.
//

import UIKit

extension UIImage {
    
    // 仿照 SDWebImage 写的检测图片格式
    class func typeForImageData(data: NSData) -> String? {
        var c: UInt8 = 0
        data.getBytes(&c, length: 1)
        switch c {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        default:
            // 还有其他格式WebP等,这里没有判断
            return nil
        }
    }
}
