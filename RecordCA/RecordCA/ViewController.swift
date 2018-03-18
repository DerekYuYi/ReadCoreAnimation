//
//  ViewController.swift
//  RecordCA
//
//  Created by yuyi on 2018/3/11.
//  Copyright © 2018年 Wenlemon. All rights reserved.
//

/* Abstract: CALayer 的寄宿图：图层中包括的图 */

import UIKit

class ViewController: UIViewController, CALayerDelegate {

    // MARK: - Properties
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 1. 使用 CALayer 的 contents 属性来显示一张图（与 UIImageView 不同），虽然是 Any 类型，但是只有在接受一个 CGImage 对象时才会显示图片
        let image = UIImage(named: "sweatHeart")
        self.layerView.layer.contents = image?.cgImage
        
//        testContentsRect()
//        testContentsCenter()
        customDrawing()
    }

    // MARK: - Test Examples
    func testContentsGravity() {
        /* 2. CALayer 中使用 contentsGravity 来调整图像：决定内容怎么匹配进 layer 的 bounds 区域内
         * Note that "bottom" always means "Minimum Y" and "top"
         * always means "Maximum Y".
         * Note that "bottom" is always means "Minimun Y" and "top" always means "Maximum Y". */
        self.layerView.layer.contentsGravity = kCAGravityCenter
    }
    
    func testContentsScale(_ scale: CGFloat) {
        
        /* 3. contentsScale:寄宿图的像素尺寸和视图大小的比例，如果使用 contentsGravity 来拉伸图片，那么这里设置将无效，上述 Center 并未拉伸
         支持高分辨率屏幕机制的一部分，如果值为 1.0， 将会以每个点 1 个像素绘制图片，如果设置为 2.0， 则会以每个点 2 个像素绘制图片，即为 Retina 屏幕*/

        self.layerView.layer.contentsScale = scale
        
        // 设置 Retina 属性
        self.layerView.layer.contentsScale = UIScreen.main.scale
        
    }
    
    func testContentsRect() {
        /* 4. contentsRect: 显示寄宿图的一个子区域. 用途为图像拼合(image sprites)
         *  好处：图片拼合后可以打包整合到一张大图上一次性载入，相比多次载入不同的图片，这样做能够带来很多好处：内存使用，载入时间，渲染性能等
         */
        if let image = UIImage(named: "sweatHeart") {
            addSpriteImage(to: firstView.layer, image, CGRect(x: 0, y: 0, width: 0.5, height: 0.5)) // left-top
            addSpriteImage(to: secondView.layer, image, CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5)) // left-bottom
            addSpriteImage(to: thirdView.layer, image, CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)) // right-bottom
            addSpriteImage(to: fourthView.layer, image, CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5)) // right-top
        }
        
        /* contectsRect 使用单位坐标
         * 和 bounds, frame 是使用 点 来计算的。单位坐标指定在 0 到 1 之间，是一个相对值（像素和点都是绝对值）。所以 contectsRect 是相对于寄宿图的尺寸，这里总结一下 iOS 中使用的坐标系统：
         * `点` - 在 iOS 和 MacOS 中最常见的坐标体系。点被称为逻辑像素，在标准设备上，一个点就是一个像素，但是在 Retina 设备上，一个点等于 2*2 个像素，iOS 用点做为屏幕的坐标测算体系就是为了在 Retina 设备上和普通设备上能有一致的视觉效果；
         * `像素` - 物理像素坐标并不会用来屏幕布局。但是仍然与屏幕有相对关系。UIImage 是一个屏幕分辨率解决方案，所以指定`点`来度量大小，但是一些底层的图片入 CGImage 就会使用像素。所以要清楚在 Retina 屏和普通设备表现出来了不同的大小；
         * `单位` - 对于与图片大小和图片边界相关的显示，单位坐标是一个方便的度量方式，当大小改变时，也不需要再次调整。单位坐标在 OpenGL 这种纹理坐标系统中用的很多，Core Animation 中也用到了单位坐标。
         */
    }
    
    func testContentsCenter() {
        /*
         5. contentsCenter: CGRect 类型，定义一个固定的边框和一个在图层上可拉伸的区域，默认 (0, 0, 1, 1)
         */
        self.layerView.layer.contentsCenter = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 1.0)
    }
    
    // MARK: - Custom Drawing
    func customDrawing() {
        /*
         给 contents 赋值CGImage 不是唯一设置寄宿图的办法，另一种方法是直接通过 Core Graphics 直接来绘制寄宿图，通过 UIView 实现 `-drawRect:` 方法来自定义绘制。
         如果 UIView 检测到了 `-drawRect:` 方法被调用了，他就会为视图分配一个寄宿图，如果不需要寄宿图，就不要创建这个方法，这个方法会造成 CPU 资源和内存的浪费，苹果建议：如果没有自定义绘制任务，不要实现空的 `-drawRect:` 方法。
         CALayer 如何被绘制： 当需要被绘制时，CALayer 会请求它的代理给他一个寄宿图来显示，通过
            `display(_ layer: CALayer)`
            来拿到需要显示的寄宿图，如果不实现这个方法， CALayer 会转而尝试调用下面方法：
            `draw(_ layer: CALayer, in ctx: CGContext)`
            这个方法会调用一个合适尺寸的空寄宿图和一个 Core Graphics 的绘制上下文环境，为寄宿图绘制做准备
         */
        
        let blueLayer = CALayer()
        blueLayer.frame = CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0)
        blueLayer.backgroundColor = UIColor.blue.cgColor
        blueLayer.delegate = self
        
        blueLayer.contentsScale = UIScreen.main.scale
        self.layerView.layer.addSublayer(blueLayer)
        blueLayer.display() // Note: 不同 UIView, 图层显示在屏幕上时，CALayer 不会自动绘制他的内容，这里显式调用
    }
    
    // MARK: - CALayerDelegate
    func draw(_ layer: CALayer, in ctx: CGContext) {
        // draw a thick red circle
        ctx.setLineWidth(10.0)
        ctx.setStrokeColor(UIColor.red.cgColor)
        ctx.strokeEllipse(in: layer.bounds)
    }
    
    /**
     为什么说我们几乎没有机会使用 CALayerDelegate 代理？
     因为当 UIView 创建了它的宿主图层时，他就会自动地把图层的 delegate 设置为它自己，并且提供一个 `display` 方法的实现，那么所有的工作全部在 CALayer 这步完成。
     **/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addSpriteImage(to layer: CALayer, _ image: UIImage, _ contentRect: CGRect) {
        layer.contents = image.cgImage
        
        layer.contentsGravity = kCAGravityResizeAspect;
        
        layer.contentsRect = contentRect;
    }
}

