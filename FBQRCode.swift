//
//  FBQRCode.swift
//  HB10
//
//  Created by JD on 2017/7/24.
//  Copyright © 2017年 JD. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class FBQRCode: NSObject {
    
   private var desString:String = String()
    
    /// 生成二维码
    ///
    /// - Parameter content: 需要输入的内容  字符串
    /// - Returns: 最后输出的图片.
    class func creartQRCode(content:String,size:CGSize,logoImage:UIImage)->UIImage?{
        
        //创建一个滤镜
        let filter:CIFilter = CIFilter.init(name: "CIQRCodeGenerator")!
        filter.setDefaults()
        let QRData:NSData = content.data(using: String.Encoding.isoLatin1)! as NSData
        filter.setValue(QRData, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        let extent:CGRect = (filter.outputImage?.extent)!
        // 1.创建Transform
        let scale = size.width/extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        // 2.放大图片
        if let hdImage =  filter.outputImage?.applying(transform){
            return UIImage.init(ciImage: hdImage).addMask(size:CGSize.init(width:60, height:60), maskImage: logoImage)
        }
        
        return nil
    }
    
    convenience init(describeString:String) {
        self.init()
        self.desString = describeString
    }
    
    /// 进入扫描界面
    func intoQRcodePage(fromVC:UIViewController,result:@escaping (String)->()){
        let toVC:FBQRCodeScanVC = FBQRCodeScanVC()
        toVC.aTitle = self.desString
        toVC.handle = result
        if let nav = fromVC.navigationController{
            nav.pushViewController(toVC, animated: true)
        }else{
            fromVC.present(toVC, animated: true, completion: nil)
        }
    }
}

extension FBQRCodeScanVC:AVCaptureMetadataOutputObjectsDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        Dlog(item: "进入代理了")
        for metaData in metadataObjects as! [AVMetadataObject] {
            if metaData.type == AVMetadataObjectTypeQRCode { //如果扫描的是二维码
                
                if let data = metaData as? AVMetadataMachineReadableCodeObject{
                    let QRString :String = data.stringValue
                    self.back(content: QRString)
                }
            }
        }
        session.stopRunning()  //停止扫描
    }
    
  
}


/// 扫描界面
fileprivate class FBQRCodeScanVC: UIViewController {
    var handle:((String)->())? = nil
    var session:AVCaptureSession = AVCaptureSession.init()
    var effectiveRect:CGRect = CGRect.init(x: ScreenWidth/8.0, y: 80+64, width: ScreenWidth*3/4.0, height: ScreenWidth*3/4.0)
    var aTitle:String = String()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Dlog(item: "是不是执行")
    }

        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.creatUI()

        let state = AVMediaTypeVideo
        let anthor = AVCaptureDevice.authorizationStatus(forMediaType: state)
        if anthor == .restricted||anthor == .denied{
            self.noCameraTip()
            return
        }
        
        self.creatScan()
    }
    
    func noCameraTip() {
        let alertVC = UIAlertController.init(title:Local(A: "Can not turn on the camera"), message: Local(A: "使用该功能需要APP具有相机权限，请在iPhone的设置中进行设置。"), preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title:  Local(A: "OK"), style: .default, handler: { (actino) in
            alertVC.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func back(content:String){
        if(self.handle != nil){
            self.handle!(content)
        }
        if(self.navigationController?.topViewController == self){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
//    QRCode_borde
    /// 扫描区域 线框
    func creatUI(){
        //添加窟蝼
        self.view.creatHollowInMap(hollowRect: effectiveRect, BGColor: UIColor.black.withAlphaComponent(0.8),handle: { maskView in
        })
        self.view.addSubview(QRAnimation.init(frame: effectiveRect))
        
        //添加描述文字
        let label:UILabel = UILabel.init(frame: CGRect.init(x: 0, y: effectiveRect.origin.y + effectiveRect.size.height + 10, width: ScreenWidth, height: 30))
        label.numberOfLines = 0
        label.text = self.aTitle
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        self.view.addSubview(label)
        
        self.title = Local(A: "Scan QR code")
    }

    func creatScan()  {
        let cameraDevice:AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)  //找到设备
        session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        do {
            let inPut:AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: cameraDevice)  //创建输入流
            session.addInput(inPut)
        } catch  {
            Dlog(item: " 创建输入流 出错误了")
        }
        let outPut:AVCaptureMetadataOutput = AVCaptureMetadataOutput.init() //创建输出流
        session.addOutput(outPut)

        outPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        outPut.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]

        let layer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: session)  // 创建显示层 ， 接口连接显示器
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        session.startRunning()
    }
}

class QRAnimation: UIImageView {
    
    var linView:UIImageView = UIImageView()
    var animationTime:Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.image = UIImage.init(named: "QRCode_borde")
        self.linView.frame = CGRect.init(x: 0, y: -ScreenWidth/10.0, width: self.Width, height: ScreenWidth/10.0)
        self.linView.image = UIImage.init(named: "QRlineView")
        self.addSubview(linView)
        animationTime = Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(stratAnimation), userInfo: nil, repeats: true)
    }
    
    /// 开始动画
    func stratAnimation() {
        self.linView.Y = -self.linView.Height
        UIView.animate(withDuration: 1.5) {
            self.linView.Y += self.Height + self.linView.Height * 2.0
        }
    }

    /// 停止动画
    func endAnimation() {
        animationTime?.invalidate()
        animationTime = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.endAnimation()
    }
    
}
