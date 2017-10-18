//
//  FBRollView.swift
//  HB10
//
//  Created by JD on 2017/7/11.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit


enum scrollDirection {
    case Left
    case Right
    case Middle
}

/// 建立在该View之上
class FBRollView: UIView {
    
    /// 代理
    var delegate:FBRollViewDelegate! = nil
    
    /// item数量
    var itemCount:NSInteger = 0
    
    /// 实时滑动方向
    var direction:scrollDirection? = nil
    
    /// 历史X位置
    var historyX:CGFloat = 0

    /// 所有的item
    var allItems:[RollViewItem] = [RollViewItem]()

    /// 当前展示的item
    var currentSelectorItemIndex:NSInteger = 0
    
    //设备显示的比例  默认为最小的尺寸
    var _itemW :CGFloat = 0
    var itemW:CGFloat {
        get{
//            if(_itemW>0){
//                return _itemW
//            }
            return ScreenWidth/self.itemGapCoefficient
        }
        set{
           _itemW = newValue
        }
    }
    
    /// 间隔系数 1.1 - 3  scroll宽跟条目宽的比例
    var _itemGapCoefficient :CGFloat = 1.4
    var itemGapCoefficient:CGFloat {
        get{
            if(_itemGapCoefficient > 3){
                return 3
            }else if(_itemGapCoefficient < 1.1){
                return 1.1
            }else{
                return _itemGapCoefficient
            }
        }
        set{
            _itemGapCoefficient = newValue
        }
    }
    
    //最大缩放比例 当控件最小的时候的比例 默认是0.2 可调节  0.05 - 0.4
    var _itemScale :CGFloat = 0.2
    var itemScale:CGFloat {
        set{
            _itemScale = newValue
        }
        get{
            if(_itemScale < 0.05){
                return 0.05
            }else if(_itemScale >= 0.8){
                return 0.8
            }else{
                return _itemScale
            }
        }
    }

    lazy var scroll: UIScrollView = {
        let scrollView :UIScrollView = UIScrollView.init(frame: self.bounds)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    convenience init(frame: CGRect,delegate:Any) {
        self.init(frame: frame)
        self.delegate = delegate as! FBRollViewDelegate
        self.initUI()
    }
    
    fileprivate func initUI(){
        self.reloadData()
    }
    
    public func reloadData(){
        
        for item in self.allItems {
            item.removeFromSuperview()
        }
        
        self.scroll.removeFromSuperview()
//        self.currentSelectorItemIndex = 0
        if let itemScale = delegate?.scaleInItem?(rollView: self) {
            self.itemScale = itemScale
        }
        if let itemGapCoefficient = delegate?.gapInItem?(rollView: self) {
            self.itemGapCoefficient = itemGapCoefficient
        }
        self.itemCount = delegate.numOfItemInRollView(rollView: self)
        
        guard itemCount > 0 else {
            return Dlog(item:"没有项目")
        }
        
        self.scroll.contentSize = CGSize.init(width: CGFloat(itemCount )*self.itemW + (ScreenWidth - itemW) + 1, height: 0)

        for i in 0..<itemCount {
            
            let rollItem : RollViewItem = delegate.roolViewItem(index: i, inRollView: self)!
            rollItem.frame = CGRect.init(x: (ScreenWidth - itemW)/2 + itemW * CGFloat(i), y: 0, width: itemW, height: self.Height)
            rollItem.index = i
            rollItem.tag = 100 + i
            rollItem.alpha = 0
            self.scroll.addSubview(rollItem)
            UIView.animate(withDuration: 0.6, animations: {
                rollItem.alpha = 1
            })
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(clickAction))
            rollItem.addGestureRecognizer(tap)
            self.allItems.append(rollItem)
        }
        
        self.addSubview(self.scroll)
        delayAction(atime: 0.01) {
            self.scroll.setContentOffset(CGPoint.init(x: CGFloat(self.currentSelectorItemIndex) * self.itemW+1, y: self.scroll.contentOffset.y), animated: true)
            self.scrollAction(offSetX: CGFloat(self.currentSelectorItemIndex) * self.itemW)
        }
        self.delegate.rollViewDidScrollTo(index: self.currentSelectorItemIndex, item: self.allItems[self.currentSelectorItemIndex], inRollView: self)
    }
    
    @objc fileprivate func clickAction(tap:UITapGestureRecognizer){
        self.registerKeyBForView(aView: self)
        if let roolItem = tap.view as? RollViewItem {
            if(roolItem.index == currentSelectorItemIndex ){
                //只有当前的item被点击才有效
                roolItem.didSecelet()
                delegate.didSelectItem(index: roolItem.index, item: roolItem, inRollView: self)
            }
            
        }
    }
}

extension FBRollView{
    //用于消除键盘
    func registerKeyBForView(aView:UIView){
        if(aView.isKind(of: UITextView.classForCoder()) || aView.isKind(of: UITextField.classForCoder())){
            if(aView.isFirstResponder){
                aView.resignFirstResponder()
            }else{
                if(aView.isKind(of: UIView.classForCoder())){
                    for subView:UIView in aView.subviews {
                        self.registerKeyBForView(aView: subView)
                    }
                }
            }
        }else{
            if(aView.isKind(of: UIView.classForCoder())){
                for subView:UIView in aView.subviews {
                    self.registerKeyBForView(aView: subView)
                }
            }
        }
    }
}

// MARK: - scrollView的代理
extension FBRollView:UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.historyX = self.scroll.contentOffset.x
        self.registerKeyBForView(aView: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX:CGFloat = self.scroll.contentOffset.x
        self.scrollAction(offSetX:offSetX)
    }
    
    func scrollAction(offSetX:CGFloat){
        
        if(self.historyX < offSetX - itemW/5.0){
            self.direction = scrollDirection.Left
        }else if(self.historyX > offSetX + itemW/5.0){
            self.direction = scrollDirection.Right
        }else{
            self.direction = scrollDirection.Middle
        }
        
        for sub:UIView in self.scroll.subviews {
            //缩放
            let index:NSInteger = sub.tag - 100
            var absW:CGFloat = abs(offSetX - CGFloat(index)*itemW)
            
            if(absW > itemW){
                absW = itemW
            }
            var scale:CGFloat = 1 - absW/itemW*itemScale
            if(scale>1){
                scale = 1
            }else if(scale < 0.7){
                scale = 0.7
            }
            //            Dlog(item: "\(scale)------\(index)")
            
            sub.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        }

    }

    
    //Page处理
    func action() {
        var offSetX:CGFloat = self.scroll.contentOffset.x
        var index :NSInteger = self.currentSelectorItemIndex
        let queue: DispatchQueue = DispatchQueue.main
        queue.async {
            
            Dlog(item: self.historyX)
            self.scroll.decelerationRate = 0.1  //速率
            if self.direction ==  scrollDirection.Left{ //向左滑动
//                Dlog(item: "左")
                offSetX = self.historyX + self.itemW + (ScreenWidth - self.itemW)/2
                index = NSInteger(offSetX/self.itemW)
//                Dlog(item: NSInteger(offSetX/self.itemW))
                offSetX = CGFloat(index) * self.itemW
                
                if(index < self.itemCount){
                    self.scroll.setContentOffset(CGPoint.init(x: offSetX , y: 0), animated: true)
                }else{
                    self.scroll.setContentOffset(CGPoint.init(x: self.historyX , y: 0), animated: true)
                }
                index = NSInteger(offSetX/self.itemW)
            }else if self.direction ==  scrollDirection.Right{
//                Dlog(item: "右")
                offSetX = self.historyX - self.itemW + (ScreenWidth - self.itemW)/2
                index = NSInteger(offSetX/self.itemW)
//                Dlog(item: NSInteger(offSetX/self.itemW))
                offSetX = CGFloat(index) * self.itemW
                if(index >= 0){
                    self.scroll.setContentOffset(CGPoint.init(x: offSetX , y: 0), animated: true)
                }else{
                    self.scroll.setContentOffset(CGPoint.init(x: self.historyX , y: 0), animated: true)
                }
                index = NSInteger(offSetX/self.itemW)
    
            }else{
                self.scroll.setContentOffset(CGPoint.init(x: self.historyX , y: 0), animated: true)
            }
            self.currentSelectorItemIndex = index
            
            if self.currentSelectorItemIndex < self.allItems.count{
                self.delegate.rollViewDidScrollTo(index: self.currentSelectorItemIndex, item: self.allItems[self.currentSelectorItemIndex], inRollView: self)
            }
        }
        self.scroll.isUserInteractionEnabled = false
        delayAction(atime: 0.2) { () -> (Void) in
            self.scroll.isUserInteractionEnabled = true
        }
    }
    
    //拖动结束
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.action()
    }
}


/// 默认的创建的item
class RollViewItem: UIView {
    
    var index:NSInteger = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = PublicCornerRadius
        self.layer.masksToBounds = true
    }
    
    public func didSecelet(){
        Dlog(item: "\(index) -- 被点击了")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


/// 定义一个协议
@objc protocol FBRollViewDelegate{

    /// 获取个数
    ///
    /// - Parameter rollView: 当前的rollView
    func numOfItemInRollView(rollView:FBRollView)->NSInteger

    
    /// item的长宽比例
    ///
    /// - Returns: 返回比例
    @objc optional func scaleInItem(rollView:FBRollView)->CGFloat

    
    /// 两个item 之间的间隔系数 越小间隔越小 范围跟itemScale有关
    ///
    /// - Parameter rollView:
    /// - Returns: 返回的间隔系数
    @objc optional func gapInItem(rollView:FBRollView)->CGFloat
    
    /// 可自定义item
    ///
    /// - Parameters:
    ///   - forItem: item
    ///   - inRollView: 当前的rollView
    func roolViewItem(index:NSInteger,inRollView:FBRollView)->RollViewItem?
    
    
    /// 选中某个item
    ///
    /// - Parameters:
    ///   - index: item的位置
    ///   - item: item
    ///   - inRollView: 当前的rollView
    func didSelectItem(index:NSInteger,item:RollViewItem,inRollView:FBRollView)
    
    
    /// 滚动到对应的目标是触发
    ///
    /// - Parameters:
    ///   - index: 序号
    ///   - item: 项目实例
    ///   - inRollView: rollView
    func rollViewDidScrollTo(index:NSInteger,item:RollViewItem,inRollView:FBRollView);
    
}
