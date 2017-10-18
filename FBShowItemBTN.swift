//
//  FBShowItemBTN.swift
//  HB10
//
//  Created by JD on 2017/6/28.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit

class FBShowItemBTN: UIButton {
    
    //重载
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重写初始化方法 携带展现的类型
    ///
    /// - Parameter showTyp: 按钮点击之后展示的类型
    convenience init(showTyp:ShowItemBTNType!){
        self.init()
    
    }
    
    
    

}



/// 点击按钮 展示其他的按钮的形式
///
/// - Vertical: 垂直方向
/// - Horizontal: 水平方向
/// - Encircle: 环绕
public enum ShowItemBTNType {
    case Vertical
    case Horizontal
    case Encircle
}
