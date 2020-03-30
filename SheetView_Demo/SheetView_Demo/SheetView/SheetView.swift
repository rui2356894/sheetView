//
//  SheetView.swift
//  SheetviewDemo
//
//  Created by lanyee-ios2 on 2020/3/27.
//  Copyright © 2020 lanyee-ios2. All rights reserved.
//

import UIKit

class SheetView: UIView {
    
    //是否自适应宽度
       public var isAutoLayout:            Bool          = false
    //item最小宽度
    public var itemMinWidth:            CGFloat       = 50
    //item高度
       public var itemHeight: CGFloat = 50
    //头部高度
    public var headerViewHeight:CGFloat = 30
    
    //补充视图高度
    public var supplementViewHeight:CGFloat = 50
    
    //一行条目
       public  var rowCount:               Int           = 0
       //冻结列数
       public var freezeColumn: Int = 1 {
           didSet {
               if self.freezeColumn > self.rowCount{
                   self.freezeColumn = 0
               }
           }
       }
    
//    //展现数据控件
//    public lazy var collectionView : TouchEventCollectionView = {
//        let collectionView:TouchEventCollectionView = TouchEventCollectionView.init(frame:self.bounds, collectionViewLayout: self.viewLayout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.touchDelegagte = self
//        collectionView.backgroundColor = UIColor.white
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.bounces = false
//        collectionView.isDirectionalLockEnabled = true
//        collectionView.allowsMultipleSelection = true
//        collectionView.alwaysBounceVertical = true
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        }
//        return collectionView
//    }()
    
    //初始化
      public override init(frame: CGRect) {
          super.init(frame: frame)
//          self.addSubview(self.collectionView)
    }

    
    required public init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
       }
}
