//
//  CTTabBar.swift
//  Constellation
//
//  Created by JD on 2017/10/17.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit

class CTTabBarCreater: NSObject {

    class func getTabBar()->UITabBarController{
    
        let titles = ["星座","段子","探索","设置"]
        
        let images = [#imageLiteral(resourceName: "icon_home"),]
        
        return UITabBarController.init(titles: titles, titleColor: nil, selectTitleColor: nil, images: [], selectImages: [], chindViewControllers: [])
    }

}
