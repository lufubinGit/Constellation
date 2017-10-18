//
//  FBTipHUD.swift
//  HB10
//
//  Created by JD on 2017/7/12.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit
/**
 *  弹窗类型  一共三种类型。 一种是提示类型，整个条目不可点击，只显示文字，二是可点击的类型，带图片的。 三是选择类型，带确认和取消的。
 */
internal enum JDGSMAlertActionType{
    case tip      //提示类型
    case list     //展示可点击类型
    case judge    //确认取消
}

fileprivate let APPMAINCOLOR:UIColor = RGBA(r:70,g:100,b:220,a:1)  //深蓝色


// MARK - GSM 弹窗系列
class FBAlertView:UIView{
    private var actions:NSMutableArray!
    private var alertTitle:String!
    public var alertHeadColor:UIColor?
    public var alertHeadImage:UIImage?
    public var alert:UIView!
    convenience init(title:String) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        self.backgroundColor = APPMASKCOLOR
        self.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
        alertTitle = title
    }
    func addSubAction(action:FBAlertAction){
        if(self.actions == nil){
            self.actions = NSMutableArray.init()
        }
        self.actions.add(action)
    }
    func show(){
        let widthScale:CGFloat = 0.7  // 弹窗的宽度和屏幕宽度的比例
        let headHei:CGFloat = 40      // 弹窗头部的高度
        let cellHei:CGFloat = 50      // 弹窗中cell的高度
        let headDeafultColor:UIColor = APPMAINCOLOR
        let fontSzie:UIFont = UIFont.systemFont(ofSize: 15) //默认的标题字体的大小
        
        var acount = actions.count
        var addHei:CGFloat = 0
        for item in self.actions {
            let action:FBAlertAction = item as! FBAlertAction
            if(action.actionType == JDGSMAlertActionType.tip){
                acount = acount - 1
                addHei = addHei + action.Height
            }
        }
        alert = UIView.init(frame: CGRect.init(x: 0, y: 0, width:ScreenWidth*widthScale, height: cellHei*(CGFloat)(acount) + headHei+addHei))
        //头部
        let head:UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: alert.Width, height: headHei))
        head.backgroundColor = headDeafultColor
        if(self.alertHeadColor != nil){
            head.backgroundColor = self.alertHeadColor
        }
        head.isUserInteractionEnabled = false
        head.image = self.alertHeadImage
        
        //标题
        let titleL:UILabel = UILabel.init(frame:head.bounds)
        titleL.backgroundColor = UIColor.clear
        titleL.text = alertTitle
        titleL.textColor = UIColor.white
        titleL.textAlignment = NSTextAlignment.center
        titleL.font = fontSzie
        titleL.numberOfLines = 0
        head.addSubview(titleL)
        alert.addSubview(head)
        
        //添加按钮事件
        for  i in 0..<actions.count{
            let action:FBAlertAction = actions[i] as! FBAlertAction
            if(i>0){
                let lastAction:FBAlertAction = actions[i-1] as! FBAlertAction
                
                if(action.actionType == JDGSMAlertActionType.tip){
                    action.frame = CGRect.init(x: 0, y: lastAction.Bottom, width: alert.Width, height: action.frame.size.height)
                }else{
                    action.frame = CGRect.init(x: 0, y: lastAction.Bottom, width: alert.Width, height: cellHei)
                }
            }else{
                if(action.actionType == JDGSMAlertActionType.tip){
                    action.frame = CGRect.init(x: 0, y: headHei+(CGFloat)(i)*cellHei, width: alert.Width, height: action.frame.size.height)
                }else{
                    action.frame = CGRect.init(x: 0, y: headHei+(CGFloat)(i)*cellHei, width: alert.Width, height: cellHei)
                }
            }
            
            alert.addSubview(action)
        }
        alert.backgroundColor = UIColor.white
        alert.layer.cornerRadius = PublicCornerRadius
        alert.layer.masksToBounds = true
        alert.center = (UIApplication.shared.windows.first?.center)!
        self.addSubview(alert)
        
        alert.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        self.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UIApplication.shared.windows.first?.addSubview(self)
            self.alert.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.alpha = 1.0
        }) { (abool) in
        }
    }
    
    func dismiss(){
        self.actions.removeAllObjects()
//        POPAnimationManger.sharePOPManeger.addPopAlphaAnimation(aView: self, formValue: 1.0, toValue: 0, duration: 0.3, dismissEnable: true)
        self.alert.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alert.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            self.alert.alpha = 0.1
        }) { (abool) in
            self.alpha = 0.0
            self.removeFromSuperview()
        }
        
    }
}

class FBAlertAction:UIButton{
    private var actionImage:UIImage!
    private var actionTitle:String!
    public var actionType:JDGSMAlertActionType!
    var clickAction:(()->())?
    var cancleClickAction:(()->())?
    var OkCLickAction:(()->())?
    
    convenience init(actionImage:UIImage,actionTitle:String,actionDo:@escaping (()->())){ //初始化
        self.init(frame:CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        self.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        self.setBackgroundImage(UIImage.createImageWithColor(color: APPLINECOLOR), for: UIControlState.highlighted)
        self.clickAction = actionDo
//        self.actionImage = actionImage.BlendingColor(color: )
        self.actionTitle = actionTitle
        self.actionType = JDGSMAlertActionType.list
        let imageScale:CGFloat = 0.6  //图片在cell中的高度的比例
        let cellHei:CGFloat = 50  //cell的默认的高度
        let fontSzie:UIFont = UIFont.systemFont(ofSize: 15) //默认的cell字体的大小
        let imageV:UIImageView = UIImageView.init(frame: CGRect.init(x: cellHei*(1 - imageScale)/2.0, y: cellHei*(1 - imageScale)/2.0, width: cellHei*imageScale, height: cellHei*imageScale))
        let titleL:UILabel = UILabel.init(frame: CGRect.init(x: cellHei, y: 0, width: self.Width - cellHei, height: cellHei))
        imageV.image = self.actionImage
        imageV.layer.cornerRadius = PublicCornerRadius
        imageV.layer.masksToBounds = true
        titleL.text = self.actionTitle
        titleL.textColor = APPGRAYBLACKCOLOR
        titleL.font = fontSzie
        
        let lineView:UIView = UIView.init(frame: CGRect.init(x: 0, y: cellHei-1, width: self.Width, height: 1))
        lineView.backgroundColor = APPLINECOLOR
        self.addSubview(lineView)
        self.addSubview(imageV)
        self.addSubview(titleL)
    }
    
    convenience init(tips:NSString){
        self.init(frame:CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        self.actionType = JDGSMAlertActionType.tip
        let title:UILabel = UILabel.init()
        let maxSize:CGSize = CGSize.init(width: 0.7*ScreenWidth-10, height: CGFloat(MAXFLOAT))
        let hei:CGFloat = tips.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: NSDictionary.init(object: UIFont.systemFont(ofSize: 15), forKey: NSFontAttributeName as NSCopying) as? [String : Any], context: nil).height
        self.size = CGSize.init(width:  0.7*ScreenWidth, height: hei+30)  //多处30 的空间
        title.font = UIFont.systemFont(ofSize: 15)
        title.text = tips as String
        title.textAlignment = NSTextAlignment.center
        title.textColor = APPGRAYBLACKMINCOLOR
        title.numberOfLines = 0
        title.frame = self.bounds
        title.X = title.X + 5;
        title.Width = title.Width - 10
        //横线
        let lineView2:UIView = UIView.init(frame: CGRect.init(x: 0, y: self.Height-1, width: self.Width, height: 1))
        lineView2.backgroundColor = APPLINECOLOR
        
        self.addSubview(title)
        self.addSubview(lineView2)
    }
    
    convenience init(cancleButtonTitle:String,OKButtonTitle:String, cancleActionDO:@escaping(()->()), OKActionDO:@escaping(()->())){
        self.init(frame:CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        self.actionType = JDGSMAlertActionType.judge
        let cancleButton:UIButton = UIButton.init(type: UIButtonType.custom)
        cancleButton.frame = CGRect.init(x: 0, y: 0, width: self.Width/2.0, height: self.Height)
        cancleButton.addTarget(self, action: #selector(canclebuttonAction), for: UIControlEvents.touchUpInside)
        cancleButton.setTitle(cancleButtonTitle, for: UIControlState.normal)
        cancleButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        cancleButton.setBackgroundImage(UIImage.createImageWithColor(color: APPBACKGROUNDCOLOR), for: UIControlState.highlighted)
        
        let OKbutton:UIButton = UIButton.init(type: UIButtonType.custom)
        OKbutton.frame = CGRect.init(x:self.Width/2.0, y: 0, width: self.Width/2.0, height: self.Height)
        OKbutton.addTarget(self, action: #selector(OKbuttonAction), for: UIControlEvents.touchUpInside)
        OKbutton.setTitle(OKButtonTitle, for: UIControlState.normal)
        OKbutton.setBackgroundImage(UIImage.createImageWithColor(color: APPBACKGROUNDCOLOR), for: UIControlState.highlighted)
        OKbutton.setTitleColor(APPSHOLLOWBLUECOLOR, for: UIControlState.normal)
        
        self.cancleClickAction = cancleActionDO
        self.OkCLickAction = OKActionDO
        
        //竖线
        let lineView1:UIView = UIView.init(frame: CGRect.init(x: self.Width/2.0-0.5, y: 0, width: 1.0, height: self.Height))
        lineView1.backgroundColor = APPLINECOLOR
        
        //横线
        let lineView2:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.Width, height: 1))
        lineView2.backgroundColor = UIColor.clear
        
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        OKbutton.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(cancleButton)
        self.addSubview(OKbutton)
        self.addSubview(lineView1)
        self.addSubview(lineView2)
        self.addConstraints([
            NSLayoutConstraint.init(item: cancleButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint.init(item: cancleButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: cancleButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: cancleButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
        self.addConstraints([
            NSLayoutConstraint.init(item: OKbutton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint.init(item: OKbutton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: OKbutton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: OKbutton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
        self.addConstraints([
            NSLayoutConstraint.init(item: lineView1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: lineView2, attribute: NSLayoutAttribute.height , multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: lineView1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: lineView1, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: lineView1, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
    }
    
    func OKbuttonAction(){
        if(self.OkCLickAction != nil){
            self.OkCLickAction!()
        }
    }
    
    func canclebuttonAction(){
        if(self.cancleClickAction != nil){
            self.cancleClickAction!()
        }
    }
    
    func buttonAction(){
        if(self.clickAction != nil){
            self.clickAction!()
        }
    }
}
