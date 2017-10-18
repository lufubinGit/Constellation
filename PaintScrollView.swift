//
//  PaintScrollView.swift
//  SleepAssistant
//
//  Created by JD on 2017/10/12.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit

typealias ChartPoint = UIView

class PaintScrollView: UIScrollView,ClearSubsable {
   
    /// 当前是不是隐藏虚线
    fileprivate var horDashLineIshidden:Bool = false
    fileprivate var verDashLineIshidden:Bool = true
    fileprivate var chartPointColor:UIColor = UIColor.blue
    fileprivate var valueTitleColor:UIColor = UIColor.black.withAlphaComponent(0.6)
}


// MARK: - UILoad
extension PaintScrollView{
   

    /// 画虚线
    ///
    /// - Parameters:
    ///   - type: 方向 水平或者垂直
    ///   - count: 总数
    ///   - color: 虚线的颜色
    func paintDashLine(type:DashLineDirection,gapCount count:Int,color:UIColor) {
        
        //如果设置了隐藏虚线 那么就会直接返回
        if type == .Horizontal && self.horDashLineIshidden {
            return
        }
        if type == .Vertical && self.verDashLineIshidden {
            return
        }

        let lineView:UIView = UIView.init().then { (lineV) in
            lineV.frame = CGRect.init(x: 0, y: 0, width: self.contentSize.width, height: self.Height)
            lineV.backgroundColor = UIColor.clear
        }
        
        let lineW:Float = 3.0
        let lineH:CGFloat = 0.4
        var startPoint = CGPoint()
        var endPoint = CGPoint()
        var guidGap:CGFloat!
    
        //虚线 样式
        let calayer: CAShapeLayer = CAShapeLayer.init()
        calayer.strokeColor = color.cgColor
        calayer.fillColor = UIColor.clear.cgColor
        calayer.lineCap = kCALineCapRound
        calayer.lineJoin = kCALineJoinRound
        calayer.lineWidth = lineH
        calayer.lineDashPattern = [NSNumber.init(value: lineW),NSNumber.init(value: lineW)]
        
        let path: UIBezierPath = UIBezierPath.init()

        for i in 0..<count{
            //虚线 路径
            if type == .Horizontal{
                
                guidGap = self.contentSize.height/count.cgfloat()
                startPoint = CGPoint.init(x: 0, y: guidGap*i.cgfloat())
                endPoint = CGPoint.init(x: lineView.Width, y: guidGap*i.cgfloat())
                
            }else if type == .Vertical{
                
                if i == 0{continue}
                guidGap = self.contentSize.width/count.cgfloat()
                startPoint = CGPoint.init(x: guidGap*i.cgfloat(), y: 0)
                endPoint = CGPoint.init(x: guidGap*i.cgfloat(), y: lineView.Height)
            }
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        calayer.path = path.cgPath
        lineView.layer.addSublayer(calayer)
        self.addSubview(lineView)
    }

    /// 画折线 和 遮罩
    ///
    /// - Parameter count: 折线的总数目
    func paintPolyline(_ values:[CGFloat],pointType:LineChartPointType,lineColor:UIColor,maskColor:UIColor){
    
        var max = values.max()!*CGFloat(maxValueScale)
        max = (max.nsinteger()/10).cgfloat()*10.cgfloat()
        let percentage:[CGFloat] = values.map { (flo) -> CGFloat in
            let scale = flo/max
            return  self.Height*(1-scale)
        }
        let horStep: CGFloat = self.contentSize.width/values.count.cgfloat()

        //折线 样式.
        let lineW:CGFloat = 2.0

        let calayer: CAShapeLayer = CAShapeLayer.init()
        calayer.strokeColor = lineColor.cgColor
        calayer.fillColor = UIColor.clear.cgColor
        calayer.lineCap = kCALineCapRound
        calayer.lineJoin = kCALineJoinRound
        calayer.lineWidth = lineW

        let lineView:UIView = UIView.init().then { (lineV) in
            lineV.frame = CGRect.init(x: 0, y: 0, width: self.contentSize.width, height: self.Height)
            lineV.backgroundColor = UIColor.clear
        }
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: percentage[0].nsinteger().cgfloat()))
        
        for i in 0..<percentage.count{
            // 根据percentage 获取每个点
            let point:CGPoint = CGPoint.init(x: horStep*i.cgfloat(), y: percentage[i].nsinteger().cgfloat())
            
            //画上折线
            if i > 0{
                path.addLine(to: point)
            }
            let value:CGFloat = values[i]
            let chartTitle = self.make("\(value.nsinteger())")
            let chartPointV = self.makePoint(pointType)
            
            chartPointV.center = point
            chartTitle.center = point
            chartTitle.CenterY = chartTitle.CenterY - chartTitle.Height/2.0 - chartPointV.Height/2.0-1  //上移20个像素
            if i == 0{
                chartTitle.X = 0
                chartPointV.X = 0
            }
            self.addSubview(chartPointV)
            self.addSubview(chartTitle)
        }
        
        calayer.path = path.cgPath
        lineView.layer.addSublayer(calayer)
        self.addSubview(lineView)
        self.sendSubview(toBack: lineView)
        
        //遮罩
        path.addLine(to:CGPoint.init(x: self.contentSize.width - horStep, y: self.Height))
        path.addLine(to:CGPoint.init(x: self.contentSize.width, y:self.Height))
        path.addLine(to:CGPoint.init(x:  self.contentSize.width, y: 0))
        path.addLine(to:CGPoint.init(x:  0, y: 0))
        path.addLine(to: CGPoint.init(x: 0, y: percentage[0].nsinteger().cgfloat()))
        
        path.addLine(to:CGPoint.init(x: 0, y: self.Height))

        self.paintMask(withPath: path, maskColor: maskColor)
    }
    
    /// 画遮罩
    ///
    /// - Parameters:
    ///   - values: 值
    ///   - color: 遮罩的颜色
    func paintMask(withPath path:UIBezierPath,maskColor:UIColor) {
        
        let mask = CAShapeLayer.init()
        mask.fillColor = maskColor.cgColor
        mask.strokeColor = UIColor.clear.cgColor
        
        let bgView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height))
        bgView.backgroundColor = maskColor
        //创建一个大的背景层
        let bigPath:UIBezierPath = UIBezierPath.init(rect: bgView.bounds)
        //创建一个小的图层
        let smallPath:UIBezierPath = path
        bigPath.append(smallPath)
        //创建显示图层
        let  showShareLayer:CAShapeLayer = CAShapeLayer.init()
        showShareLayer.path = bigPath.cgPath
        showShareLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则 这里采用的是奇偶规则
        showShareLayer.fillColor = UIColor.gray.cgColor;
        showShareLayer.opacity = 0.8;
        bgView.layer.mask = showShareLayer;
        bgView.layer.masksToBounds = false;
        self.addSubview(bgView)
    }
    
}

// MARK: - ACTION
extension PaintScrollView{
    
    /// 隐藏水平虚线
    func hiddenHorLine(_ isHidden:Bool){
        self.horDashLineIshidden = isHidden
    }
    
    /// 隐藏垂直虚线
    func hiddenVerLine(_ isHidden:Bool){
        self.verDashLineIshidden = isHidden
    }
    
    /// 更新折线
    ///
    /// - Parameter animation: 是否开启动画
    func refreshPolyline(_ animation:Bool){
    
    }
    
    /// 设置折线点的颜色
    func chartPointColor(_ color:UIColor){
        self.chartPointColor = color
    }
    
    
    /// 文字值的颜色
    ///
    /// - Parameter color: 颜色参数
    func vallueTitleColor(_ color:UIColor){
      self.valueTitleColor = color
    }
}

extension PaintScrollView{
    
    /// 设置按钮的样式
    ///
    /// - Parameter type: 样式   4.3.2
    func makePoint(_ type:LineChartPointType)->ChartPoint{
        let point:ChartPoint = ChartPoint.init().then(block: { (pointV) in
           
            let padding: CGFloat
            let marging: CGFloat
            
            switch type {
            case .HollowPoint:
                marging = 8.0
                padding = 4.0
            case .SolidPoint:
                marging = 6.0
                padding = 0.0
            }
            
            pointV.frame = CGRect.init(x: 0, y: 0, width: marging, height: marging)
            pointV.backgroundColor = self.chartPointColor
            pointV.layer.cornerRadius = marging/2.0

            guard padding > 0 else{
               return
            }
            let paddingView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: padding, height: padding) ).then(block: { (pad) in
                pad.backgroundColor = UIColor.white
                pad.layer.cornerRadius = padding/2.0
                pad.center = pointV.center
            })
           pointV.addSubview(paddingView)
        })
        return point
    }
    

    /// 文字描述
    ///
    /// - Parameter title: 值
    /// - Returns: 返回一个lable
    func make(_ title:String)->UILabel {
        //点的上方放置值
        let titleLabel = UILabel.init().then(block: { (label) in
            label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            let labelW = self.getLabWidth(labelStr: title, font: UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat()), height: 100) + 10  //默认高度 15像素
            let labelH = self.getLabHeight(labelStr: title, font: UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat()), Width: 100)
            label.frame = CGRect.init(x: 0, y: 0, width: labelW, height: labelH)
            label.font = UIFont.systemFont(ofSize: defaultTextFontSize.cgfloat())
            label.textAlignment = .center
            label.layer.cornerRadius = min(labelW/2.0, labelH/2.0)
            label.layer.masksToBounds = true
            label.text = title
            label.textColor = self.valueTitleColor
        })
        return titleLabel
    }
    
}
