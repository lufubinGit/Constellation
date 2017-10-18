//
//  CirculateView.swift
//  HB10
//
//  Created by JD on 2017/7/10.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit

@objc protocol CirculateViewDelegate{

    func didSelector(circulate:CirculateView,index:NSInteger)
}

class CirculateView: UIView {
    var section:NSInteger = 0
    var gap:CGFloat = 0.0
    var timer:Timer? = nil
    var delegate:CirculateViewDelegate?
    
    lazy var scroll: UIScrollView = {
        let scroll:UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.Width, height: self.Height))
        
        scroll.backgroundColor = UIColor.clear
        scroll.contentSize = CGSize.init(width: self.Width*2.0, height: 0)
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.flashScrollIndicators()
        scroll.bounces = false
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        scroll.delegate = self
        return scroll
    }()
    lazy var pageV:UIPageControl = {
        let pageVHei:CGFloat = 30.0
        let pageV:UIPageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: self.Height - pageVHei - self.gap, width: self.Width, height: pageVHei))
        pageV.numberOfPages = 1
        pageV.currentPageIndicatorTintColor = UIColor.red
        pageV.pageIndicatorTintColor = UIColor.white
        return pageV
    }()
    
    func test(tap:UITapGestureRecognizer) {
        Dlog(item: "hahahahah\(String(describing: tap.view?.tag))")
    }
    
    /// 初始化轮播图
    ///
    /// - Parameters:
    ///   - frame: 大小
    ///   - images: 图片的数组
    convenience init(frame: CGRect,images:[UIImage],delegate:CirculateViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
        self.isUserInteractionEnabled = true
        let lineView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        lineView.backgroundColor = UIColor.clear
        self.addSubview(lineView)
        self.upDateImages(images: images)
    }
    
    /// 更新轮播图
    ///
    /// - Parameter images: 图片的数组
    func upDateImages(images:[UIImage]) {
        self.section = images.count
        self.scroll.contentSize = CGSize.init(width: self.Width * CGFloat(self.section+2), height: 0)

        self.scroll.setContentOffset(CGPoint.init(x: ScreenWidth, y: 0), animated: false)
        for subV:UIView in self.scroll.subviews {
            if subV.isKind(of: UIImageView.classForCoder()){
                subV.removeFromSuperview()
            }
        }
        
        for i in 0..<self.section+2 {
            let imageV :UIImageView = UIImageView.init(frame: CGRect.init(x: CGFloat(i)*self.Width+gap, y: gap, width: self.Width-gap*2.0, height: self.Height-gap*2.0))
            imageV.isUserInteractionEnabled = true
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(itemClicked))
            imageV.addGestureRecognizer(tap)
            imageV.tag = i + 10000
            if(i<1){
                imageV.image = images[self.section-1]
            }else if(i>self.section){
                imageV.image = images[0]
            }else{
                imageV.image = images[i-1]
            }
            
            self.scroll.addSubview(imageV)
        }
        self.pageV.numberOfPages = self.section
        self.pageV.currentPage = 0
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refrshImage), userInfo: nil, repeats: true)
        let Rloop :RunLoop = RunLoop.main
        Rloop.add(timer!, forMode: RunLoopMode.commonModes)
        if self.subviews.contains(self.scroll) {
            self.scroll.removeFromSuperview()
        }
        if self.subviews.contains(self.pageV) {
            self.pageV.removeFromSuperview()
        }
        
        self.addSubview(self.scroll)
        self.addSubview(self.pageV)
    }
    
    
    /// 点击当前展示的轮播图
    ///
    /// - Parameter tap: 参数是一个手势，在外部定义手势执行的动作
    func itemClicked(tap:UITapGestureRecognizer) {
        self.delegate?.didSelector(circulate: self, index: (tap.view?.tag)!-10000)
    }
    
    /// 刷新图片 进行轮播
    func refrshImage(){
        self.scroll.setContentOffset(CGPoint.init(x: self.scroll.contentOffset.x + ScreenWidth, y: 0), animated: true)
    }
}

extension CirculateView:UIScrollViewDelegate{
    
    //循环和Page处理
    func action() {
        if(scroll.contentOffset.x == 0){ //第一页 会直接跳到第五页
            self.scroll.setContentOffset(CGPoint.init(x: ScreenWidth*CGFloat(self.section), y: 0), animated: false)
        }else if (scroll.contentOffset.x > CGFloat(self.section) * ScreenWidth){
            self.scroll.setContentOffset(CGPoint.init(x: ScreenWidth, y: 0), animated: false)
        }
        self.pageV.currentPage = NSInteger(scroll.contentOffset.x/ScreenWidth) - 1
    }
    
    //动画结束  定时器滚动
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
       self.action()
    }
    
    //减速结束  手动拖
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       self.action()
    }
}


