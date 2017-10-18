//
//  PublicContent.swift
//  HB10
//
//  Created by JD on 2017/6/27.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit
import CoreData

// MARK - 替代宏定义**************************************************
func recordTimeSec(time:UInt64) -> Double{
    var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t.init()
    mach_timebase_info(&timebase);
    return Double(time) * Double(timebase.numer) / Double(timebase.denom) / 1e9;
}

func doSomeBeging()->UInt64{
    return mach_absolute_time()
}

func doSomeEnd()->UInt64{
    return mach_absolute_time()
}

/// 描述是否在DEBUG模式下 进行输出。 使用@autoclosure的目的是将值放在必包之中求值
public func Dlog( item:Any...){
    #if DEBUG
        print(item)
    #else
        
    #endif
}

public func Dlog( item:@autoclosure ()->Any){
    #if DEBUG
        print(item())
    #else
        
    #endif
}


// MARK - 变量 常量  *****************************************************
var ScreenWidth:CGFloat = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
var ScreenHeight:CGFloat = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
var PublicCornerRadius :CGFloat = 5.0
let NavbarHei:CGFloat = 64
let APPLINECOLOR:UIColor = RGBA(r:180,g:180,b:190,a:1)  //线条颜色

func RandowColor()->UIColor{ //随机颜色
   return UIColor(red: CGFloat(arc4random()%40+70)/255.0, green:  CGFloat(arc4random()%180)/255.0, blue:  CGFloat(arc4random()%80+160)/255.0, alpha: 1.0)
}
func RGBA(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
let APPMASKCOLOR:UIColor = RGBA(r:0,g:0,b:0,a:0.5)  //遮罩颜色
let APPGRAYBLACKCOLOR = RGBA(r:50,g:50,b:50,a:1)// 灰黑色 文字 重点／标题
let APPGRAYBLACKMINCOLOR = RGBA(r:120,g:120,b:120,a:1) // 灰黑色 文字 描述
let APPWHITEALPHACOLOR =  UIColor.init(white: 1.0, alpha: 0.7) // 白色透明字体
let APPREDCOLOR:UIColor = RGBA(r:230,g:69,b:69,a:1)  // 橘红色
let APPBACKGROUNDCOLOR:UIColor = RGBA(r: 237, g: 236, b: 236, a: 1.0)
let APPSHOLLOWBLUECOLOR:UIColor = RGBA(r:57,g:171,b:249,a:1)  //浅蓝色

// MARK - 扩展  *****************************************************
// MARK - 扩展 - NS
extension NSObject{

    /// 获取指定类的属性和属性值  返回一个以属性名的为键 属性值为值的 字典
    ///
    /// - Parameter filter: 需要过滤的属性
    /// - Returns: 返回对象的所有的属性的健值对
    func classAllPorp(filter:NSArray) -> NSDictionary {
        var count: UInt32 = 0
        //获取类的属性列表,返回属性列表的数组,可选项
        let list = class_copyPropertyList(self.classForCoder, &count)
        Dlog(item:"属性个数:\(count)")
        let propDic :NSMutableDictionary = NSMutableDictionary.init()
        for i in 0..<Int(count) {
            //根据下标获取属性
            let pty = list?[i]
            //获取属性的名称<C语言字符串>
            //转换过程:Int8 -> Byte -> Char -> C语言字符串
            let cName = property_getName(pty!)
            //转换成String的字符串
            let name:String = String(utf8String: cName!)!
            if !filter.contains(name){
                propDic.setValue(self.value(forKey: name), forKey: name)
                print(name)
            }
        }
        free(list) //释放list
        return propDic
    }
    
    
    /// 延时函数
    ///
    /// - Parameters:
    ///   - atime: 时间
    ///   - closures: 回调
    public func delayAction(atime:TimeInterval,closures: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + atime, execute:closures)
    }
    
    
    /// 计算字符宽度
    ///
    /// - Parameters:
    ///   - labelStr: 文字
    ///   - font: 字体
    ///   - height: 设定高度
    /// - Returns: 返回的字符串宽度
    func getLabWidth(labelStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        
        let statusLabelText: NSString = labelStr as NSString
        
        let size = CGSize.init(width: 900, height: height)
        
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
        
        return strSize.width
    }
    
    
    /// 获取字符的高度 （同上）
    ///
    /// - Parameters:
    ///   - labelStr: <#labelStr description#>
    ///   - font: <#font description#>
    ///   - Width: <#Width description#>
    /// - Returns: <#return value description#>
    func getLabHeight(labelStr:String,font:UIFont,Width:CGFloat) -> CGFloat{
    
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize.init(width: Width, height: 999)
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
        return strSize.height
    }
    
}

extension UIView{
    
    public var Width: CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            var r = self.frame
            r.size.width = newValue
            self.frame = r
        }
    }
    
    public var Height: CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            var r = self.frame
            r.size.height = newValue
            self.frame = r
        }
    }
    
    public var X: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var r = self.frame
            r.origin.x = newValue
            self.frame = r
        }
    }
    
    public var Y: CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var r = self.frame
            r.origin.y = newValue
            self.frame = r
        }
    }
    
    public var CenterX: CGFloat{
        get{
            return self.center.x
        }
        set{
            var r = self.center
            r.x = newValue
            self.center = r
        }
    }
    
    public var CenterY: CGFloat{
        get{
            return self.center.y
        }
        set{
            var r = self.center
            r.y = newValue
            self.center = r
        }
    }
    
    public var Top: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            self.frame.origin.y = newValue
        }
    }
    
    public var Left: CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            self.frame.origin.y = newValue
        }
    }
    
    public var Bottom: CGFloat{
        get{
            return self.frame.origin.y + self.frame.size.height
        }
        set{
            let buff:CGFloat = newValue - self.frame.size.height
            self.frame.origin.y = buff
        }
    }
    
    public var right: CGFloat{
        get{
            return self.frame.origin.x + self.frame.size.width
        }
        set{
            let buff:CGFloat = newValue-self.frame.size.width
            self.frame.origin.x = buff
        }
    }
    
    public var size: CGSize{
        get{
            return self.frame.size
        }
        set{
            var r = self.frame.size
            r = newValue
            self.frame.size = r
        }
    }
}

// MARK: - 一些UIView常用的方法
fileprivate var halowViewHandle:((UIView)->(Void))? = nil
extension UIView{
    
    /// 添加 毛玻璃 缺点：如果对象是变动的话， 就没有这个效果了
    ///
    /// - Parameter effStyle: UIBlurEffectStyle类型
    public func addBlurEffect(effStyle:UIBlurEffectStyle){
        let eff:UIBlurEffect = UIBlurEffect.init(style: effStyle)
        let effView:UIVisualEffectView = UIVisualEffectView.init(frame: self.bounds)
        effView.effect = eff
        self.addSubview(effView)
        self.sendSubview(toBack: effView)
    }
    
    
    /// 添加投影
    ///
    /// - Parameters:
    ///   - color: 投影的颜色
    ///   - gap: 投影到对象的距离
    ///   - shaadowImage: 投影使用的图片
    public func castShadow(color:UIColor,gap:CGFloat,shadowImage:UIImage?){
        let shawView:UIImageView = UIImageView.init(frame:CGRect.init(x: 0, y: 0, width: 50, height: 50))
        guard shadowImage != nil else {
            Dlog(item: errSecTimestampRevocationWarning)
            return
        }
        shawView.image = shadowImage?.BlendingColor(color:color)
        let superV:UIView = self.superview!
        superV.addSubview(shawView)
        superV.sendSubview(toBack: shawView)
        shawView.CenterX = self.CenterX
        shawView.Y = self.Bottom
        shawView.Width = self.Width*0.6
        shawView.Height = shawView.Width*0.2
        shawView.translatesAutoresizingMaskIntoConstraints = false
        superV.addConstraints([
            NSLayoutConstraint.init(item: shawView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.9, constant: 0),
            NSLayoutConstraint.init(item: shawView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: shawView, attribute: NSLayoutAttribute.width, multiplier: 0.15, constant: 0),
            NSLayoutConstraint.init(item: shawView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: shawView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant:gap)])
    }
    
    
    /// 创建一个漏洞涂层
    ///
    /// - Parameters:
    ///   - hollowRect: 漏洞的大小
    ///   - BGColor: 涂层的背景颜色
    ///   - handle: 点击图层执行的动作  可以为空
    public func creatHollowInMap(hollowRect:CGRect,BGColor:UIColor,handle:@escaping (UIView)->(Void)){
        let bgView:UIView = UIView.init(frame: self.bounds)
        bgView.backgroundColor = BGColor
        //创建一个大的背景层
        let bigPath:UIBezierPath = UIBezierPath.init(rect: self.bounds)
        //创建一个小的图层
        let smallPath:UIBezierPath = UIBezierPath.init(rect: hollowRect)
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
        bgView.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(disMissHollowView))
        bgView.addGestureRecognizer(tap)
        halowViewHandle = handle
    }
    
    
    @objc private func disMissHollowView(tap:UITapGestureRecognizer){
        Dlog(item: "点击到了遮罩")
        if halowViewHandle != nil{
            halowViewHandle!(tap.view!)
        }
    }
}


extension UIColor{
    
    /// 通过字符代码获取颜色
    ///
    /// - Parameter RGBA: 如 #FFFFFF 参数
    convenience init(RGBA: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if RGBA.hasPrefix("#") {
            let hex:String  = RGBA.subString(start: 2, end: RGBA.characters.count)
            let scanner:Scanner = Scanner.init(string: hex)
            var hexValue: UInt64 = 0
            if(scanner.scanHexInt64(&hexValue)){
                switch hex.characters.count {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    Dlog(item:"Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            }else {
                    Dlog(item:"Scan hex error")
            }
        } else {
                Dlog(item:"Invalid RGB string, missing '#' as prefix")
        }
            self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// MARK: - 图片的扩展
extension UIImage{
    
    //改变图片的颜色
    public func BlendingColor(color:UIColor)->UIImage{
        let Galpha:CGFloat = color.cgColor.alpha
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        let rect:CGRect = CGRect.init(x: 0, y: 0, width:self.size.width ,height: self.size.height)
        UIRectFill(rect)
        self.draw(in: rect, blendMode: CGBlendMode.overlay, alpha: Galpha)
        self.draw(in: rect, blendMode: CGBlendMode.destinationIn, alpha: Galpha)
        let newimage:UIImage =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newimage
    }
    
    //将view生成一张图片
    class public func creatImage(aView:UIView)->UIImage{
        if(UIScreen.main.scale > 1){ //选用不同的context  让图片不模糊
            UIGraphicsBeginImageContextWithOptions(aView.bounds.size, false, UIScreen.main.scale)
        }else{
            UIGraphicsBeginImageContext(aView.bounds.size)
        }
        aView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return viewImage
    }
    
    //改变图片的尺寸  注意 这只能返回 8 位通道的上下文  即 矢量图可以使用该函数进行放大和缩小
    public func imageSizeToInBit8(size:CGSize,xGap:CGFloat,yGap:CGFloat)->UIImage{

        if(UIScreen.main.scale > 1){ //选用不同的context,适用不同的@2x／@3x 的屏幕。让图片不模糊
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        }else{
            UIGraphicsBeginImageContext(size)
        }
        self.draw(in: CGRect.init(x: xGap, y: yGap, width: CGFloat(Int(size.width)-Int(xGap*2.0)), height: CGFloat(Int(size.height)-Int(yGap*2.0))))
        let newimage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newimage
    }
    
    public func imageSizeToInBitmap(){
    
    }

    /// 添加 水印图片  在一张画布上画两次
    func addMask(size:CGSize,maskImage:UIImage) -> UIImage {
        
        if(UIScreen.main.scale > 1){ //选用不同的context,适用不同的@2x／@3x 的屏幕。让图片不模糊
            UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        }else{
            UIGraphicsBeginImageContext(self.size)
        }
        
        let rect:CGRect = CGRect.init(x: self.size.width / 2.0 - size.width / 2.0, y: self.size.height / 2.0 - size.height / 2.0, width: size.width, height: size.height)

        self.draw(in: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: self.size))
        maskImage.draw(in:rect)
        let newimage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newimage
    }
    

    /// 截切指定图片上的某部分
    func cropImage(rect : CGRect) -> UIImage {
        let scale:CGFloat = UIScreen.main.scale
        let dianRect:CGRect = CGRect.init(x: rect.origin.x*scale, y: rect.origin.y*scale, width: rect.size.width*scale, height: rect.size.height*scale)
        if(UIScreen.main.scale > 1){ //选用不同的context,适用不同的@2x／@3x 的屏幕。让图片不模糊
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
        }else{
            UIGraphicsBeginImageContext(size)
        }
        let newCgImage:CGImage = (self.cgImage?.cropping(to: dianRect))!
        
        return UIImage.init(cgImage: newCgImage, scale: scale, orientation: UIImageOrientation.up)
    }
    
    ///生成指定颜色的图片（ 这里生成的图片是纯色的图片 ）
    class public func createImageWithColor(color:UIColor) -> UIImage{
        let rect:CGRect = CGRect.init(x: 0.0, y: 0.0, width: 200, height: 200.0)
        if(UIScreen.main.scale > 1){ //选用不同的context  让图片不模糊
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        }else{
            UIGraphicsBeginImageContext(rect.size)
        }
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
        let newimage:UIImage =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newimage
    }
    
    
    
}

/**
 *  按钮的类别
 */
internal enum FBButtonType{
    case ImageLeft    //图片在左边
    case ImageTop     //图片在上方
    case ImageRight   //图片在右边
    case ImageBottom  //图片在下边
}

// MARK: - 按钮的文字和图片的排版
extension UIButton{
    //设置buton的文字和图片的位置
    func setButtonImageSize(type:FBButtonType, space:CGFloat){
        let space:CGFloat = space
        // 1. 得到imageView和titleLabel的宽、高
        var imageWith:CGFloat = self.imageView!.frame.size.width
        var imageHeight:CGFloat = self.imageView!.frame.size.height
        let labelWidth:CGFloat = self.titleLabel!.intrinsicContentSize.width
        let labelHeight:CGFloat = self.titleLabel!.intrinsicContentSize.height
        
        if type == .ImageTop || type == .ImageBottom{
            let scale:CGFloat = imageWith/imageHeight
            if imageHeight > self.Height - labelHeight{
                if scale > 1 {
                    imageHeight = imageHeight - labelHeight - (scale-1)*imageHeight
                    imageWith = imageHeight*scale
                }else{
                    imageHeight = imageHeight - labelHeight
                    imageWith = imageHeight*scale
                }
                self.setImage(self.currentImage?.imageSizeToInBit8(size: CGSize.init(width: imageWith, height: imageHeight), xGap: 0, yGap: 0), for: .normal)
            }
        }
        
        if(type == FBButtonType.ImageLeft){
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }else if(type == FBButtonType.ImageBottom){
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            self.titleEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }else if(type == FBButtonType.ImageTop){
            self.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }else if(type == FBButtonType.ImageRight){
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
    }
}


// MARK: - 字符串的拓展
extension String {
    
    /// 删除字符串中的字符
    ///
    /// - Parameter charSet: 需要删除的字符的集合数组
    /// - Returns: 返回删除之后的字符
    public func removeChars(charSet:[String])->String{
        var newStr:String = String()
        let stringArr:[String] = self.splitStringToArr()
        for string in stringArr {
            var k:NSInteger = 0
            for fifterStr in charSet {
                if string == fifterStr {
                    k = k+1
                }
            }
            if k==0 { //木有一样的
                newStr.append(string)
            }
        }
        return newStr
    }
    
    /// 提取指定位置的字符串
    ///
    /// - Parameters:
    ///   - start: 起始位置（含）
    ///   - end: 结束位置（含）
    /// - Returns: 返回提取字符串
    public func subString(start:NSInteger,end:NSInteger) -> String{
        var desStr :String = String()
        if(start<=0||end>self.characters.count||start>end){ //如果范围不对   就会返回一个空的字符串 表示没有获取到字符
            return ""
        }else{
            var strArr: [String] = self.splitStringToArr()
            for i in (start-1)..<end {
                desStr.append(strArr[i])
            }
        }
        return desStr
    }
    
    public func subStringAtIndex(index:NSInteger) -> String{
        return self.subString(start: index, end: index)
    }
    
    /* 将一个完整的字符 的每一个字母拆解出来 并放进一个数组中 */
    public func splitStringToArr() -> [String]{
        var index1 = self.startIndex
        var index2 :String.Index = self.endIndex
        var desStr :String
        var strArr: [String] = [String]()
        var strBuff :String = String()
        while index1 != index2{
            index2 = self.index(after: index1)
            desStr = self.substring(with: Range.init(uncheckedBounds: (lower: index1, upper: index2)))
            if(desStr.characters.count != 0){
                strBuff.append(desStr)
                strArr.append(strBuff)
            }
            strBuff.removeAll()
            index1 = index2
            //检测是不是到头了
            if(index2 != self.endIndex){ //如果没有到头 那么就会继续执行程序
                index2 = self.index(after: index2)
            }else{  //说明到了最后了  这时候就应该将数据作为最后一个数组
                if(strBuff.characters.count > 0){
                    strArr.append(strBuff)
                }
            }
        }
        return strArr
    }
    
    /* 根据写入的字符穿拆分出数组  一般可用于将单词写进一个数组中  */
    public func splitStringToArr(filterStr:String)-> [String] {
        var index1 = self.startIndex
        var index2 :String.Index = self.endIndex
        var desStr :String
        var strArr: [String] = [String]()
        var strBuff :String = String()
        while index1 != index2{
            index2 = self.index(after: index1)
            desStr = self.substring(with: Range.init(uncheckedBounds: (lower: index1, upper: index2)))
            if(desStr == filterStr){
                strArr.append(strBuff)
                strBuff.removeAll()
            }else{
                strBuff.append(desStr)
            }
            index1 = index2
            //检测是不是到头了
            if(index2 != self.endIndex){ //如果没有到头 那么就会继续执行程序
                index2 = self.index(after: index2)
            }else{  //说明到了最后了  这时候就应该将数据作为最后一个数组
                strArr.append(strBuff)
            }
        }
        return strArr
    }
    
    
    /// 删除最后一个字符
    ///
    /// - Returns: 新的字符串
    func deleteLastChar()->String {
        var newStr:String = String()
        var stringArr:[String] = self.splitStringToArr()
        stringArr.removeLast()
        for string in stringArr {
            newStr.append(string)
        }
        return newStr
    }
    
    
    
}

extension NSSet{

    /// 根据属性  获取当前对象中的指定子对象
    ///
    /// - Parameters:
    ///   - attribute: 属性
    ///   - value: 值
    /// - Returns: 返回结果
    func findObj(attribute:String?,value:String) -> [AnyObject?]?{
        
        var resultArr:[AnyObject] = [AnyObject]()
        for item in self {
            let obj = item as! NSObject
            if let newValue = obj.value(forKey: attribute!) as? String{
                if newValue == value{
                    resultArr.append(obj)
                }
            }
        }
        return resultArr
    }

}

// MARK: - 字典的类别
extension NSDictionary{

    func contains(key:String)->Bool{
        guard self.allKeys.count>0 else {
            return false
        }
        guard self.allKeys.contains(where: { (str) -> Bool in
            if let strkey = str as? String{
                return strkey == key
            }
            return false
        }) else {
            return false
        }
        return true
    }
}

/// 针对数据类型转换 类型转换器
protocol TypeConvert{}
extension Int:TypeConvert{
    func string() -> String {
        return "\(self)"
    }

    func cgfloat() -> CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat:TypeConvert{
    func string() -> String {
        return "\(self)"
    }

    func nsinteger() -> NSInteger {
        return NSInteger(self)
    }
}

extension String:TypeConvert{

    func nsinteger() -> NSInteger{
        return NSInteger.init(self)!
    }
    
    func cgfloat() -> CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
}


///  指定时间只执行一次  注意：这个方法有bug， 暂时不要使用
fileprivate var loadOnceDuration : TimeInterval = NSDate.init().timeIntervalSince1970
func loadOnce(in time:TimeInterval,action:(()->())?){
    let now:TimeInterval = NSDate.init().timeIntervalSince1970
    if now - loadOnceDuration > time{
        if let act = action {
            act()
        }
        loadOnceDuration = now
    }
}

// MARK - 语言本地化// MARK - 语言本地化相关代码  **************************************************
let AppLanguage:String = "appLanguage"
public func setAppLanguage(type:JDGSMLaunageType){
    var aStr:String? = ""
    if(type == JDGSMLaunageType.EN){
        aStr = "en"
    }else if(type == JDGSMLaunageType.CH){
        aStr = "zh-Hans"
    }else if(type == JDGSMLaunageType.SP){
        aStr = "es"
    }else if(type == JDGSMLaunageType.RU){
        aStr = "ru"
    }else{
        aStr = "en"
    }
    UserDefaults.standard.set(aStr, forKey: AppLanguage)
    UserDefaults.standard.synchronize()
}

func appLanguage()->JDGSMLaunageType{  //默认情况使用当前APP使用的语言。当没有任何设置的时候， 只要设置一次之后就会使用中文了／
    var obj = UserDefaults.standard.object(forKey: AppLanguage)
    if(obj == nil){
        let languages = Locale.preferredLanguages
        obj = languages.first!
    }
    if((obj as! String).contains("en"))
    {
        return JDGSMLaunageType.EN
    }else if((obj as! String).contains("zh-Hans")){
        return JDGSMLaunageType.CH
    }else if((obj as! String).contains("es")){
        return JDGSMLaunageType.SP
    }else if((obj as! String).contains("ru")){
        return JDGSMLaunageType.RU
    }else{
        return JDGSMLaunageType.EN
    }
}

func Local(A: String)->String{
    
    var s:String = "本地语言设置失败"
    let type:JDGSMLaunageType = appLanguage()
    var path:String? = ""
    if(type == JDGSMLaunageType.EN){
        path = Bundle.main.path(forResource: "en", ofType: "lproj")!
    }else if(type == JDGSMLaunageType.CH){
        path = Bundle.main.path(forResource: "zh-Hans", ofType: "lproj")
    }else if(type == JDGSMLaunageType.RU){
        path = Bundle.main.path(forResource: "ru", ofType: "lproj")
    }else{
        path = Bundle.main.path(forResource: "en", ofType: "lproj")!
    }

    if let bundle = Bundle.init(path: path!){
        s = (bundle.localizedString(forKey: A, value: "", table: nil))
    }
    return s
}

// MARK - 枚举  *****************************************************

/// 语言类型
///
/// - EN: 英文
/// - CH: 中文
/// - SP: 西班牙语
public enum JDGSMLaunageType:String{
    case EN = "English"        //英文
    case CH = "中文"        //中文
    case SP = "xiix"        //西班牙语
    case RU = "русский"        //俄罗斯语
    
   static func instance(str: String)->JDGSMLaunageType {
        if str == "English"{
            return JDGSMLaunageType.EN
        }else if str == "中文"{
            return JDGSMLaunageType.CH
        }else if str == "русский"{
            return JDGSMLaunageType.RU
        }else{
            return JDGSMLaunageType.EN
        }
    }
}
/// 错误类型
///
/// - errorStringContentNil: 错误类型，字符串为空
/// - errorStringContentLength0: 错误类型， 字符串的长度为零
public enum MyErrorType:String {
    case errorStringContentNil = "content is nil"
    
    case errorStringContentLength0 = "content lenth is 0"
}



// MARK - 协议  *****************************************************

//协议then  用于将部分分散的代码放进一个花括号中
public protocol Then {}
extension Then where Self: Any {
    public func then_Any( block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension Then where Self: AnyObject {
    public func then( block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}











//MARK -- 下面是一些不常用的小方法
/*  16进制字符串  转化成 2进制     */
public func SixteenToTwo(aStr:String) -> [String] {
    var content:String = ""
    var buff:String = ""
    let Dic:Dictionary = [
        "0" : "0000",
        "1" : "0001",
        "2" : "0010",
        "3" : "0011",
        "4" : "0100",
        "5" : "0101",
        "6" : "0110",
        "7" : "0111",
        "8" : "1000",
        "9" : "1001",
        "A" : "1010",
        "B" : "1011",
        "C" : "1100",
        "D" : "1101",
        "E" : "1110",
        "F" : "1111",
        "a" : "1010",
        "b" : "1011",
        "c" : "1100",
        "d" : "1101",
        "e" : "1110",
        "f" : "1111",
        ]
    let strArr:[String] = aStr.splitStringToArr()
    for str in strArr {
        let s:String = Dic[str]!
        buff.append(s)
        if(buff.characters.count == 8){
            for i in 0..<buff.characters.count {
                content.append(buff.subStringAtIndex(index:8-i))
            }
            buff = "" //重置
        }
    }
    return  content.splitStringToArr()
}

public func BCDToTwo(aStr:String) -> [String] {
    var content:String = ""
    var buff:String = ""
    let Dic:Dictionary = [
        "0" : "0000",
        "1" : "0001",
        "2" : "0010",
        "3" : "0011",
        "4" : "0100",
        "5" : "0101",
        "6" : "0110",
        "7" : "0111",
        "8" : "1000",
        "9" : "1001",
        "A" : "1010",
        "B" : "1011",
        "C" : "1100",
        "D" : "1101",
        "E" : "1110",
        "F" : "1111",
        "a" : "1010",
        "b" : "1011",
        "c" : "1100",
        "d" : "1101",
        "e" : "1110",
        "f" : "1111",
        ]
    let strArr:[String] = aStr.splitStringToArr()
    for str in strArr {
        let s:String = Dic[str]!
        buff.append(s)
        if(buff.characters.count == 4){
            for i in 0..<buff.characters.count {
                content.append(buff.subStringAtIndex(index:4-i))
            }
            buff = "" //重置
        }
    }
    return  content.splitStringToArr()
}


func twoToBCD(str:String)->String {
    var Dic:Dictionary = [
        "0000":"0",
        "0001":"1",
        "0010":"2",
        "0011":"3",
        "0100":"4",
        "0101":"5",
        "0110":"6",
        "0111":"7",
        "1000":"8",
        "1001":"9",
        "1010":"a",
        "1011":"b",
        "1100":"c",
        "1101":"d",
        "1110":"e",
        "1111":"f"
        ]
    if Dic.keys.contains(str) {
        return Dic[str]!
    }
    return ""
}


//创建一个进度条的视图
class ProgressView:UIView{

    var sharpLayer:CAShapeLayer!
    
    convenience init(atView:UIView,frame:CGRect){
        self.init()
        //创建一个底色
        self.frame = frame
        self.center = CGPoint.init(x: atView.frame.width/2.0, y:  atView.frame.height/2.0)
        atView.addSubview(self)
        
        let leftG : CAGradientLayer = CAGradientLayer.init()
        leftG.colors = [UIColor.blue.cgColor,UIColor.red.cgColor,UIColor.orange.cgColor,UIColor.yellow.cgColor]
        leftG.locations = [0,0.3,0.6,0.9]
        leftG.startPoint = CGPoint.init(x: 0, y: 0)
        leftG.endPoint = CGPoint.init(x: 0, y: 1.0)
        leftG.frame = CGRect.init(x: 0, y: 0, width: frame.width/2.0, height: frame.height)
        
        let rightG : CAGradientLayer = CAGradientLayer.init()
        rightG.colors = [UIColor.blue.cgColor,UIColor.init(red: 50/255.0, green: 1.0, blue: 163/255.0, alpha: 1.0).cgColor,UIColor.green.cgColor,UIColor.yellow.cgColor]
        rightG.locations = [0,0.35,0.7,0.9]
        rightG.startPoint = CGPoint.init(x: 0, y: 0)
        rightG.endPoint = CGPoint.init(x: 0, y: 1.0)
        rightG.frame = CGRect.init(x: frame.width/2.0, y: 0, width: frame.width/2.0, height: frame.height)
        
        self.layer.addSublayer(leftG)
        self.layer.addSublayer(rightG)
        
        let lineWidth:CGFloat = 10.0  //线宽
        let CASharp:CAShapeLayer = CAShapeLayer.init()
        CASharp.lineWidth = lineWidth
        CASharp.lineCap = "round"
        CASharp.lineJoin = "round"  //包角为圆形
        
        
        //      通过调整起始角度 来控制环形的长度
        let path1:UIBezierPath = UIBezierPath.init(arcCenter:CGPoint.init(x: frame.width/2.0, y: frame.width/2.0), radius: self.frame.width/2.0 - lineWidth, startAngle:-CGFloat(Double.pi)/2.0, endAngle:-CGFloat(Double.pi)/2.0, clockwise: true)

        
        CASharp.strokeColor = UIColor.blue.cgColor
        CASharp.path = path1.cgPath
        CASharp.fillColor = UIColor.clear.cgColor
        self.layer.mask = CASharp
        self.sharpLayer = CASharp
    }
    
    func setProgress(progress:Double){
        let lineWidth:CGFloat = 10.0  //线宽
        let path1:UIBezierPath = UIBezierPath.init(arcCenter:CGPoint.init(x: self.frame.width/2.0, y: self.frame.width/2.0), radius: self.frame.width/2.0 - lineWidth, startAngle:-CGFloat(Double.pi)/2.0, endAngle:CGFloat(progress - Double.pi/2.0), clockwise: true)
        self.sharpLayer.path = path1.cgPath
    }
    
    func changeProgress(aView:UIView, progress:CGFloat){
        
        let lineWidth:CGFloat = 10.0  //线宽
        let CASharp:CAShapeLayer = CAShapeLayer.init()
        CASharp.lineWidth = lineWidth
        CASharp.lineCap = "round"
        CASharp.lineJoin = "round"  //包角为圆形
        let frame:CGRect = aView.frame
        //通过调整起始角度 来控制环形的长度
        let path1:UIBezierPath = UIBezierPath.init(arcCenter:CGPoint.init(x: frame.width/2.0, y: frame.width/2.0), radius: aView.frame.width/2.0 - lineWidth, startAngle:-CGFloat(Double.pi)/2.0, endAngle: CGFloat(Double.pi)*progress*2.0-CGFloat(Double.pi)/2.0, clockwise: true)
        CASharp.strokeColor = UIColor.blue.cgColor
        CASharp.path = path1.cgPath
        CASharp.fillColor = UIColor.clear.cgColor
        aView.layer.mask = CASharp
        
        Dlog(item:"完成")
    }
}
