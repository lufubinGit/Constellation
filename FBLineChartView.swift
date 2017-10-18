//
//  FBLineChartView.swift
//  SleepAssistant
//
//  Created by JD on 2017/10/12.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit
import Foundation

let DefaultRect:CGRect = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth*0.6)

/// 图表的底
class FBLineChartView: UIView {
    
    var delegate:LineChartViewDelegate!
    
    var scrollView:PaintScrollView! = PaintScrollView()
    
    var bottomScroll:UIScrollView!
    
    var currentContentOffset:CGPoint!
    
    /// 左侧和下侧展示文字的空间
    var gap:CGFloat!
    
    var verLabels:[UILabel] = [UILabel]()
    var horLabels:[UILabel] = [UILabel]()
    var verUnitLabel:UILabel!
    
    
    
    fileprivate var dashColor:UIColor = UIColor.init(RGBA: DefaultDashLineColor) ,crossColor = UIColor.init(RGBA: DefaultCrossLineColor),valueTitleColor:UIColor = UIColor.init(RGBA: "#555555"),annotateTitleColor:UIColor = UIColor.white.withAlphaComponent(0.6),unitColor:UIColor = UIColor.white,maskColor:UIColor = UIColor.white.withAlphaComponent(0.3)

    fileprivate var horizontalGridCount:Int = LineChartHorizontalGridCount,verticalGridCount:Int = LineChartVerticalGridCount
    
    fileprivate var values:[CGFloat]!
    

    convenience init(frame:CGRect = DefaultRect,delegate:LineChartViewDelegate){
        self.init()
        self.delegate = delegate
        self.frame = frame
        /*
         内边距的比例(与self的高度相比)、 那边距的临界值
         默认按比例计算， 但是如果比例的值超出了临界值范围，将使用临界值计算
         */
        let gapScale:CGFloat = 1/9
        let maxGapLimit:CGFloat = 50
        let minGapLimit:CGFloat = 15
        gap = self.Height*gapScale
        if gap > maxGapLimit{ gap = maxGapLimit }
        if gap < minGapLimit{ gap = minGapLimit }

        self.createContentScrollView()
        self.setBackGColor()
        
        delayAction(atime: 0.5) { 
            self.refreshUIData()
        }
        
        
    }
}


// MARK: - 颜色初始化设置
extension FBLineChartView{

    func setBackGColor(_ color:UIColor = UIColor.init(RGBA: DefaultBackgroundColor)) {
        self.backgroundColor = color
    }
    
    func setDashLineColor(_ color:UIColor = UIColor.init(RGBA: DefaultDashLineColor)){
        self.dashColor = color
    }
    
    func setCrossLineColor(_ color:UIColor = UIColor.init(RGBA: DefaultCrossLineColor)){
        self.crossColor = color
    }

    
    func setAnnotateTitleColor(_ color:UIColor = APPLINECOLOR){
        self.annotateTitleColor = color
    }
    
    func setUnitColor(_ color:UIColor = APPGRAYBLACKCOLOR) {
        self.unitColor = color
    }
    
    func setMaskColor(_ color:UIColor = APPGRAYBLACKCOLOR){
        self.maskColor = color
    }
    
    /// 隐藏水平虚线
    func hiddenHorLine(_ isHidden:Bool){
        self.scrollView.hiddenHorLine(isHidden)
    }
    
    /// 隐藏垂直虚线
    func hiddenVerLine(_ isHidden:Bool){
        self.scrollView.hiddenVerLine(isHidden)
    }

    /// 设置折线点的颜色
    func chartPointColor(_ color:UIColor){
        self.scrollView.chartPointColor(color)
    }
    
    /// 设置数值的颜色
    func setValueTitleColor(_ color:UIColor){
        self.scrollView.vallueTitleColor(color)
    }
}

// MARK: - makeContent  组合
extension FBLineChartView{
   
    /// 创建包含内容的ScroillView\ bottomScrollerView
    fileprivate func createContentScrollView(){
        let frame:CGRect = CGRect.init(x: gap, y: gap, width: self.Width-2*gap, height: self.Height-2*gap)
        
        self.scrollView = self.scrollView.then { (scorll) in
            scorll.delegate = self
            scorll.frame = frame
            scorll.showsHorizontalScrollIndicator = false
            scorll.showsVerticalScrollIndicator = false
        }
        self.addSubview(scrollView)
        
        
        //为了可以拖动，做成下栏scrollView
        bottomScroll = UIScrollView.init(frame: CGRect.init(x: 0, y: self.Height - gap, width: self.Width, height: gap)).then(block: { (scroll) in
            scroll.contentSize = CGSize.init(width: scrollView.contentSize.width, height: gap)
            scroll.isScrollEnabled = false //禁止手动拖动 ， 只能跟随拖动
        })
    }

    /// 左侧竖直方向的label 最上端展示单位
    fileprivate func createVerLabel(){
        
        for label in self.verLabels{
            label.removeFromSuperview()
        }
        self.verLabels.removeAll()
        
        self.verUnitLabel = UILabel.init().then(block: { (label) in
            
            label.frame = CGRect.init(x: gap/2.0, y: 0, width: gap * 3, height: gap)
            label.numberOfLines = 1
            label.textColor = self.unitColor
            label.font = UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat())
        })
        
        self.addSubview(self.verUnitLabel)
        // 0号位 不展示数据
        for i in 1...LineChartVerticalGridCount {
            
            let index:NSInteger = LineChartVerticalGridCount - i
            let gridHei:CGFloat = (self.Height - 2*gap)/LineChartVerticalGridCount.cgfloat()
            
            let verLabel:UILabel = UILabel.init().then(block: { (label) in
                label.frame = CGRect.init(x: 0, y: 0, width: gap, height: gap)
                label.CenterY = index.cgfloat() * gridHei + gap
                label.numberOfLines = 1
                label.textAlignment = .center
                label.textColor = self.annotateTitleColor
                label.font = UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat())
            })
            self.verLabels.append(verLabel)
            self.addSubview(verLabel)
        }
    }
    
    /// 右侧水平方向的label 最右端展示单位
    fileprivate func createHorLabel(){
        
        for label in self.horLabels{
            label.removeFromSuperview()
        }
        self.horLabels.removeAll()
        
        // 0号位 展示数据
        for i in 0..<self.horizontalGridCount {
            let gridW:CGFloat = (self.scrollView.contentSize.width)/self.horizontalGridCount.cgfloat()
            
            let horLabel:UILabel = UILabel.init().then(block: { (label) in
                label.frame = CGRect.init(x: 0, y: 0, width: gap*2.0, height: gap)
                label.CenterX = i.cgfloat() * gridW + gap
                label.numberOfLines = 1
                label.textAlignment = .center
                label.textColor = self.annotateTitleColor
                label.font = UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat())
            })
            self.horLabels.append(horLabel)
            bottomScroll.addSubview(horLabel)
        }
        
        self.addSubview(bottomScroll)
    }
}


// MARK: - 数据填入／刷新
extension FBLineChartView{
    
    public func refreshUIData() {
        
        //刷新之前  清楚原本有的label和layer
        self.scrollView.clearAllSubview()
        
        //获取数据源
        self.values = delegate.values()
        self.horizontalGridCount = values.count
        
        /// contentSize 的宽度
        var contentScale:CGFloat = self.horizontalGridCount.cgfloat()/LineChartHorizontalGridCount.cgfloat()
        if contentScale < 1{
            contentScale = 1
        }
        self.scrollView.contentSize = CGSize.init(width: scrollView.Width*contentScale, height: scrollView.Height)

        self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentSize.width - self.scrollView.Width, y: 0)

        // 水平、垂直方向的label
        self.createHorLabel()
        self.createVerLabel()

        //获取最大值
        var max = values.max()!*CGFloat(maxValueScale)
        max = (max.nsinteger()/10).cgfloat()*10.cgfloat()
        
        /* 刷新字符 */
        for i in 0..<verLabels.count {
       
            let verLabel:UILabel = verLabels[i]
            let decim = (max/verLabels.count.cgfloat()*(i+1).cgfloat()).nsinteger()/10*10
            
            verLabel.text =  "\(decim)"

            if decim > 1000{
                let kValue = (decim/100).cgfloat()/10.0
                verLabel.text = "\(kValue)K"
            }
            
            if decim > 10000{
                let MValue = (decim/1000).cgfloat()/10.0
                verLabel.text = "\(MValue)M"
            }
        }
        
        for i in 0..<horLabels.count {
            let horLabel:UILabel = horLabels[i]
            horLabel.text = delegate.horizontalText(atIndex: i)
        }
        
        self.verUnitLabel.text = delegate.verticalUnitText()
        
        /* 刷新线条、 折线 和 遮罩 */
        self.scrollView.paintDashLine(type: .Horizontal, gapCount: LineChartVerticalGridCount, color: self.dashColor)
        
        self.scrollView.paintDashLine(type: .Vertical, gapCount:self.horizontalGridCount , color:  self.dashColor)
        
        self.scrollView.paintPolyline(self.values, pointType: .HollowPoint, lineColor: self.crossColor, maskColor: self.maskColor)
        
    }
}



// MARK: - scrollView Delgate
extension FBLineChartView:UIScrollViewDelegate{
    
    fileprivate func stopAction(){
        let step = scrollView.Width/LineChartHorizontalGridCount.cgfloat()
        let offset = scrollView.contentOffset
        scrollView.setContentOffset( CGPoint.init(x: (offset.x/step).rounded() * step, y: offset.y), animated: true)
    }
    
    //滚动期间持续调用
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bottomScroll.contentOffset = CGPoint.init(x: scrollView.contentOffset.x,y:0)
        self.currentContentOffset = scrollView.contentOffset
    }
    
    
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stopAction()
    }
    
     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.stopAction()
    }
}




