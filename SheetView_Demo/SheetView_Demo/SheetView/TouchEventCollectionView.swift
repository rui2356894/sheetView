//
//  TouchEventCollectionView.swift
//  SheetviewDemo
//
//  Created by lanyee-ios2 on 2020/3/27.
//  Copyright © 2020 lanyee-ios2. All rights reserved.
//

import UIKit

//MARK: - 触碰手势代理
public protocol SheetTouchEventDelegate: NSObjectProtocol {
    func sheetViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func sheetViewtouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
}

//MARK: - 触摸事件传递系统控件
class TouchEventCollectionView: UICollectionView {
    /// 触摸手势代理
    weak var touchDelegagte:SheetTouchEventDelegate?
      
      override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesBegan(touches, with: event)
          self.touchDelegagte?.sheetViewTouchesBegan(touches, with: event)
          
      }
      
      public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesCancelled(touches, with: event)
          self.touchDelegagte?.sheetViewtouchesEnded(touches, with: event)
      }
      
      override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesEnded(touches, with: event)
          self.touchDelegagte?.sheetViewtouchesEnded(touches, with: event)
          
      }

}
