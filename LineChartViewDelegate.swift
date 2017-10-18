//
//  LineChartViewDelegate.swift
//  SleepAssistant
//
//  Created by JD on 2017/10/12.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit



protocol LineChartViewDelegate {

    ///  底部水平上的展示文字
    ///
    /// - Parameter index: 位置，从左至右 0-N N取决于设定的默认格栅数
    /// - Returns: 展示文字的内容
    func horizontalText(atIndex index:NSInteger)->String
    
    /// 单位字符
    ///
    /// - Returns: 垂直单位字符
    func verticalUnitText()->String
    
    
    func values()->[CGFloat]
    
}

