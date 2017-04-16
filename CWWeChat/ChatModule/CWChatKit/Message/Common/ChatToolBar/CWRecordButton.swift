//
//  CWRecordButton.swift
//  CWWeChat
//
//  Created by chenwei on 2017/4/16.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit
import YYWebImage

class CWRecordButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitle("按住     说话", for: UIControlState())
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.setBackgroundImage(UIImage.yy_image(with: UIColor(hex: "#F6F6F6")), for: .normal)
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.layer.borderColor = UIColor(hex: "#DADADA").cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        self.addTarget(self, action: #selector(recordClick(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(recordComplection(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(recordCancel(_:)), for: .touchUpOutside)

        self.addTarget(self, action: #selector(recordDragOut(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(recordDragIn(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(recordDragIn(_:)), for: .touchDragEnter)

    }
    
    //MARK: 录音相关的
    func recordCancel(_ button: UIButton) {

    }
    
    func recordComplection(_ button: UIButton) {
    }
    
    func recordDragOut(_ button: UIButton) {
    }
    
    func recordDragIn(_ button: UIButton) {
    }
    
    ///录音按钮按下
    func recordClick(_ button: UIButton) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
