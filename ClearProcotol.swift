//
//  ClearProcotol.swift
//  SleepAssistant
//
//  Created by JD on 2017/10/13.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit


/// 清理之前的数据 协议
protocol ClearSubsable {
    
}

extension ClearSubsable {
    
    func  clearAllSubview() {
        if let view = self as? UIView{
            for v in view.subviews{
                if v.isKind(of: UIView.classForCoder()){
                    v.removeFromSuperview()
                }
            }
            
            for layer in view.subviews{
                if layer.isKind(of: CAShapeLayer.classForCoder()){
                    layer.removeFromSuperview()
                }
            }
        }
    }
}
