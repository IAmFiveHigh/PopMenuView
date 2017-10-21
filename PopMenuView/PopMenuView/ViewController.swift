//
//  ViewController.swift
//  PopMenuView
//
//  Created by 我是五高你敢信 on 2017/10/19.
//  Copyright © 2017年 我是五高你敢信. All rights reserved.
//

import UIKit
import Masonry

class ViewController: UIViewController {

    var a: FiveHighPopMenuView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let bg = UIImageView(frame: UIScreen.main.bounds)
        bg.image = UIImage(named: "空的.jpg")
        view.addSubview(bg)
        
        a = FiveHighPopMenuView.shared
        a.模糊模式 = .light
        
        let array = ["微信","朋友圈","QQ","QQ空间"]
        var models = [PopMenuModel]()
        for name in array {
            
            let model = PopMenuModel(title: name, imageName: name)
            models.append(model)
        }
        a.数据源数组 = models
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        a.open()
    }


}

private let popMenuView = FiveHighPopMenuView()

final class FiveHighPopMenuView: UIView {
    
    static var shared: FiveHighPopMenuView {
        return popMenuView
    }
    
    private let sW = UIScreen.main.bounds.width
    private let sH = UIScreen.main.bounds.height
    private let bottomH: CGFloat = 22.0
    
    enum 模糊 {
        case dark
        case light
    }
    
    var 模糊模式: 模糊 = .dark
    
    var 数据源数组 = [PopMenuModel]() {
        didSet {
            设置分享图标()
        }
    }
    
    fileprivate var iconArray = [PopMenuIconView]()
    fileprivate var backgroundView: UIView!
    fileprivate var iconView: UIView!
    init() {
        
        super.init(frame: UIScreen.main.bounds)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    private func 获取模糊背景() -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(frame: UIScreen.main.bounds)
        switch 模糊模式 {
        case .dark:
            let blurEffect = UIBlurEffect(style: .dark)
            blurEffectView.effect = blurEffect
            
            
        case .light:
            let blurEffect = UIBlurEffect(style: .light)
            blurEffectView.effect = blurEffect
        }
        
        return blurEffectView
    }
    
    private func 设置分享图标() {
        let iconH = sH * 0.2
        
        iconArray.removeAll()
        iconView = UIView()
        
        for (index, model) in 数据源数组.enumerated() {
            model.index = index
            let iHorizen = CGFloat(index % 3)
            let iVertical = CGFloat(index / 3)
            
            let icon = PopMenuIconView(with: model)
            icon.frame = CGRect(x: iHorizen * sW / 3, y: sH + iconH, width: sW / 3, height: iconH)
            self.iconView.addSubview(icon)
            
            model.destinationPoint = CGPoint(x: iHorizen * sW / 3, y: sH / 3 + iVertical * iconH)
            model.originPoint = CGPoint(x: iHorizen * sW / 3, y: sH + iconH)
            
            backgroundView = 获取模糊背景()
            
            iconArray.append(icon)
        }
        
        iconView.frame = CGRect(x: 0, y: 0, width: sW, height: sH)
    }
    
    func open() {
        
        guard let back = backgroundView else { return }
        back.alpha = 0
        self.addSubview(back)
        self.addSubview(iconView)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(close))
        self.addGestureRecognizer(tapgesture)
        
        if let window = UIApplication.shared.keyWindow {
            
            window.addSubview(self)
        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            back.alpha = 1
        }) { (finish) in
            self.show(index: 0)
        }
        
        
    }
    
    private func show(index: Int) {
        
        if index == 数据源数组.count - 1 {
            return
        }
        
        let model = 数据源数组[index]
        
        let view = iconArray[index]
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
            let size = view.frame.size
            view.frame = CGRect(x: model.destinationPoint.x, y: model.destinationPoint.y, width: size.width, height: size.height)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { 
            
            self.show(index: index + 1)
        }
    }
    
    func close() {
    
        for (index,model) in 数据源数组.enumerated() {
            
            let view = iconArray[index]
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
                let size = view.frame.size
                view.frame = CGRect(x: model.originPoint.x, y: model.originPoint.y, width: size.width, height: size.height)
                
            }, completion: nil)

        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (finish) in
                
                self.backgroundView.removeFromSuperview()
                self.removeFromSuperview()
            })
        }

    }
    
    deinit {
        print("分享界面被销毁了")
    }
}

extension FiveHighPopMenuView: PopMenuIconClickProtocol {
    func popIconBeClick(with type: PopMenuIconView.点击状态, index: Int) {
        
        let icon = iconArray[index]
        
        switch type {
        case .按下:
            print("")
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 1.3
            animation.duration = 0.2
            icon.layer.add(animation, forKey: "fangda")
            
        case .拖出圈外松开:
            print("")
        case .点击:
            print("")
        }
    }


}

protocol PopMenuIconClickProtocol: class {
    func popIconBeClick(with type: PopMenuIconView.点击状态, index: Int)
}

class PopMenuIconView: UIView {
    
    enum 点击状态 {
        case 按下
        case 点击
        case 拖出圈外松开
    }
    
    weak var delegate: PopMenuIconClickProtocol?
    
    private var btn: UIButton!
    private var title: UILabel!
    private var img: UIImageView!
    
    private let imgRadius = UIScreen.main.bounds.width / 5
    
    var model: PopMenuModel
    init(with model: PopMenuModel) {
        
        self.model = model
        
        super.init(frame: CGRect.zero)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        img = UIImageView(image: UIImage(named: model.imageName))
        img.layer.cornerRadius = imgRadius / 2
        img.layer.masksToBounds = true
        addSubview(img)
        
        img.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(self)
            make?.size.equalTo()(CGSize(width: imgRadius, height: imgRadius))
        }
        
        title = UILabel()
        title.text = model.title
        title.textColor = model.titleColor
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 14)
        addSubview(title)
        
        title.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.img.mas_bottom)?.with().offset()(8)
            make?.centerX.equalTo()(self.img)
        }
        
        btn = UIButton()
        btn.addTarget(self, action: #selector(按住), for: .touchDown)
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        btn.addTarget(self, action: #selector(拖出圈外), for: .touchUpOutside)
        addSubview(btn)
        btn.mas_makeConstraints { (make) in
            make?.left.and().right().and().top().and().bottom().equalTo()(self)
            make?.bottom.equalTo()(self.title.mas_bottom)?.with().offset()(20)
        }
    }
    
    @objc private func 按住() {
        if let delegate = delegate {
            delegate.popIconBeClick(with: .点击, index: model.index)
        }
    }
    
    @objc private func click() {
        if let delegate = delegate {
            delegate.popIconBeClick(with: .点击, index: model.index)
        }
    }
    
    @objc private func 拖出圈外() {
        if let delegate = delegate {
            delegate.popIconBeClick(with: .拖出圈外松开, index: model.index)
        }
    }
}

class PopMenuModel {
    
    var title: String
    var imageName: String
    var titleColor: UIColor
    var destinationPoint = CGPoint(x: 0, y: 0)
    var originPoint = CGPoint(x: 0, y: 0)
    
    var index = 0
    
    init(title: String, imageName: String, titleColor: UIColor = UIColor.black) {
        self.title = title
        self.imageName = imageName
        self.titleColor = titleColor
    }
}
