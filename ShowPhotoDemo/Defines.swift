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

let itemWH = UIScreen.main.bounds.width / 4.0 - 1.0
let targetSize = CGSize(width: itemWH, height: itemWH)
