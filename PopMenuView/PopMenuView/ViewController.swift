//
//  ViewController.swift
//  PopMenuView
//
//  Created by 我是五高你敢信 on 2017/10/19.
//  Copyright © 2017年 我是五高你敢信. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    


}

private let popMenuView = FiveHighPopMenuView()

final class FiveHighPopMenuView: UIView {
    
    static var shared: FiveHighPopMenuView {
        return popMenuView
    }
    
    var 数据源数组 = [PopMenuModel]() {
        didSet {
            
        }
    }
    
    
    init() {
        
        super.init(frame: CGRect.zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct PopMenuModel {
    
    var title = ""
    var imageName = ""
    
}
