//
//  LineChartConfig.swift
//  SleepAssistant
//
//  Created by JD on 2017/10/12.
//  Copyright © 2017年 JD. All rights reserved.
//

let Version: Float = 1.0 //当前版本

//默认背景颜色  黑色
let DefaultBackgroundColor:String = "#7A378B"


/// 默认的边框颜色 浅灰色
let DefaultDashLineColor:String = "#a8a8a8"


//默认线条颜色（折线） 橘黄色
let DefaultLineColor:String = "#00FFFF"


/// 默认的交叉线的颜色 石英色
let DefaultCrossLineColor:String = "#FF8C00"


/***************************/

/// 横向和竖直方向上的默认的值(也是显示的范围，默认显示的格栅树数目)  注意对应的线条就是 N-1
let LineChartHorizontalGridCount:Int = 6
let LineChartVerticalGridCount:Int = 3

/// 默认的字体的大小
let defaultTextFontSize:Int = 9

/// 图表高度和最大高度的比值
let maxValueScale = 1.2



public enum LabelIdentity:Int {
    
    case verOne = 101
    case verTwo = 102
    case verThree = 103
    case verUnit = 104

    case horOne = 201
    case horTwo = 202
    case horThree = 203
    case horFour = 204
    case horFive = 205
    case horSix = 206
    case horSeven = 207

}

/// 图表中，连接折线的点的样式，有两种
///
/// - Hollow: 空心的圆
/// - Solid: 实心的圆
enum LineChartPointType{
    case HollowPoint
    case SolidPoint
}


/// 虚线的样式
///
/// - Horizontal: 水平方向样式
/// - Vertical: 垂直方向样式
enum DashLineDirection {
    case Horizontal
    case Vertical
}
