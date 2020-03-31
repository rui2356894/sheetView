//
//  SheetViewLayout.swift
//  SheetviewDemo
//
//  Created by lanyee-ios2 on 2020/3/27.
//  Copyright © 2020 lanyee-ios2. All rights reserved.
//

import UIKit

class SheetViewLayout: UICollectionViewLayout {
    /// 弱引用外面的控件 为了拿属性
    public weak var         sheetView:                  SheetView?
    /// 我们计算内容大小
    private     var         contentSize:                CGSize                          = .zero
    //item距离左边距离
    private     var         itemLeftWidth                                               = [CGFloat]()
    //是否是单选
    public      var         isSingleSelect                                              = true
    //每行可添加补充视图属性
    public      var         supplementAttributes                                        = [UICollectionViewLayoutAttributes]()
    /// 删除的补充视图
    private     var         deleteSupplementAttributes                                  = [UICollectionViewLayoutAttributes]()
    /// 所有屏幕内非补充视图的item属性集合
    public      var         allItemsAttributes                                          = [[UICollectionViewLayoutAttributes]]()
    /// 重写控件尺寸大小返回
    override public var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    /// 存储一行实际item宽度
    private     var itemsWidth = [CGFloat](){
        didSet {
            self.itemLeftWidth = []
            var leftWidth:CGFloat = 0
            self.itemLeftWidth.append(leftWidth)
            for index in self.itemsWidth {
                leftWidth += index
                self.itemLeftWidth.append(leftWidth)
            }
        }
    }
    ///列数
    private var numberOfColumns:Int {
        if let collectionView = collectionView {
            return collectionView.numberOfItems(inSection: 0)
        }
        return 0
    }
    
    //最多展现section值
    public var numberOfMaxSection:Int {
        guard let sheet = self.sheetView else { return 0}
        if let view = collectionView {
            //+2 默认添加表头
            return Int((view.frame.height - sheet.headerViewHeight)/sheet.itemHeight) + 3
        }
        return 0
    }
    //滑动偏移的section值
    public var offsetYOfMaxSction:Int {
        guard let sheet = self.sheetView else { return 0}
        if let view = collectionView {
            if view.contentOffset.y < 0 {return 0}
            if self.supplementAttributes.count == 0 {
                return  Int(view.contentOffset.y/sheet.itemHeight)
            }else{
                //添加补充视图计算
                let supplemnetItems = self.supplementAttributes.filter { (supplementItem) -> Bool in
                    return supplementItem.indexPath.section < Int(view.contentOffset.y/sheet.itemHeight)
                }
                return Int((view.contentOffset.y-(CGFloat(supplemnetItems.count) * sheet.supplementViewHeight))/sheet.itemHeight)
            }
        }
        return 0
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - 重写UICollectionView系统方法
    
    /// 准备布局调用的方法.
    public override func prepare() {
        
        super.prepare()
        self.invalidateLayout()
        
        guard let collectionView = collectionView else {return }
        
        guard collectionView.numberOfSections != 0 else { return }
        
        guard self.numberOfColumns != 0 else {return }
        
        self.generateItemAttributes(collectionView: collectionView)
    }
    
    ///
    /// - Parameters: 是从 cell的 preferredLayoutAttributesFitting 这个方法来的 当cell内容宽度发生变化 我是否需要重新布局
    ///   - preferredAttributes: 返回cell的布局属性
    ///   - originalAttributes: 这个属性没有用到 解释是 建议布局
    /// - Returns: 是否需要重新布局
    public override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let sheet = self.sheetView,
            preferredAttributes.indexPath.item < self.itemsWidth.count else {return false}
        if !sheet.isAutoLayout,preferredAttributes.frame.width > self.itemsWidth[preferredAttributes.indexPath.item] {
            self.itemsWidth[preferredAttributes.indexPath.item] = preferredAttributes.frame.width
            return true
        }
        return false
    }
    
    
    /// 提供指定item内容布局
    /// - Parameter indexPath: 索引
    /// - Returns: 返回布局信息
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.row == self.itemsWidth.count {
            let l = self.supplementAttributes.filter { (attr) -> Bool in
                attr.indexPath.section == indexPath.section
            }
            return l.first
        }
        return self.allItemsAttributes[indexPath.section][indexPath.row].copy() as? UICollectionViewLayoutAttributes
    }
    
    /// 根据区域返回该区域所有布局
    /// - Parameter rect: 区域位置
    /// - Returns: 布局所有信息
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard  self.allItemsAttributes.count != 0 else { return super.layoutAttributesForElements(in: rect) }
        var attributesArr = [UICollectionViewLayoutAttributes]()
        self.allItemsAttributes.forEach { (v) in
            attributesArr = attributesArr + v
        }
        
        for section in self.offsetYOfMaxSction..<self.numberOfMaxSection+self.offsetYOfMaxSction {
            if self.allItemsAttributes.count <= section { break }
            let asupplemnet = self.supplementAttributes.filter { (a) -> Bool in
                return a.indexPath.section == section
            }
            attributesArr = attributesArr + asupplemnet
            
        }
        return attributesArr
    }
    
    /// 是否需要重新布局
    /// - Parameter newBounds: 新的布局
    /// - Returns: bool
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let sheet = self.sheetView else {return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)}
        if itemIndexPath.item == self.itemsWidth.count {
            var deleteIndex = -1
            for index in 0..<self.deleteSupplementAttributes.count {
                if self.deleteSupplementAttributes[index].indexPath.section == itemIndexPath.section {
                    deleteIndex = index
                }
                if deleteIndex != -1 {
                    let deleAttributes = self.deleteSupplementAttributes[deleteIndex].copy() as! UICollectionViewLayoutAttributes
                    deleAttributes.frame.origin.y -= sheet.supplementViewHeight
                    self.deleteSupplementAttributes.remove(at: deleteIndex)
                    return deleAttributes
                }
            }
            
        }
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    
    
    
}
//MARK: - 内容布局部分
extension SheetViewLayout {
    
    /// 生成布局
    /// - Parameter collectionView: 控件
    private func generateItemAttributes(collectionView: UICollectionView) {
        guard let sheet = self.sheetView else {return}
        if self.itemsWidth.count != self.numberOfColumns{
            self.itemsWidth = [CGFloat](repeating: sheet.itemMinWidth, count: self.numberOfColumns)
            self.allItemsAttributes.removeAll()
        }
        
        self.generateHeaderAttributes(collectionView: collectionView)
        
        self.generateContentAttributes(collectionView: collectionView)
        
        var contentHeight = (CGFloat(collectionView.numberOfSections-1) * sheet.itemHeight) + sheet.headerViewHeight
        let count:CGFloat = CGFloat(self.supplementAttributes.count)
        contentHeight = contentHeight + (count * (self.sheetView?.supplementViewHeight)!)
        self.contentSize = CGSize(width:self.itemLeftWidth[self.itemLeftWidth.count-1], height:contentHeight)
        
    }
    
    
    /// 表头布局
    /// - Parameter collectionView: 控件
    private func generateHeaderAttributes(collectionView: UICollectionView) {
        guard let sheet = self.sheetView else {return}
        var headerAttributesArr =  [UICollectionViewLayoutAttributes]()
        for index in 0..<self.numberOfColumns {
            let indexPath = IndexPath(item:index, section: 0)
            var headerAttributes:UICollectionViewLayoutAttributes
            if self.allItemsAttributes[0].count == 0 {
                headerAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            }else{
                headerAttributes = self.allItemsAttributes[0][index]
            }
            if index < sheet.freezeColumn {
                // 处理冻结列逻辑 当横向滑动时候 加上偏移值
                headerAttributes.frame = CGRect(x:collectionView.contentOffset.x < 0 ? self.itemLeftWidth[index] : collectionView.contentOffset.x + self.itemLeftWidth[index], y:collectionView.contentOffset.y, width:self.itemsWidth[index], height:sheet.headerViewHeight)
                headerAttributes.zIndex = 1025
            }else{
                headerAttributes.frame = CGRect(x:self.itemLeftWidth[index], y:collectionView.contentOffset.y, width:self.itemsWidth[index], height:sheet.headerViewHeight)
                headerAttributes.zIndex = 1024
            }
            headerAttributesArr.append(headerAttributes)
        }
        self.allItemsAttributes[0] = headerAttributesArr
    }
    
    
    
    /// 生成内布局
    /// - Parameter collectionView: 控件
    private func generateContentAttributes(collectionView: UICollectionView) {
        guard let sheet = self.sheetView else {return}
        for sectionIndex in self.offsetYOfMaxSction..<self.numberOfMaxSection+self.offsetYOfMaxSction {
            if sectionIndex > collectionView.numberOfSections-1 {break}
            if sectionIndex == 0{ continue }
            if self.allItemsAttributes.count <= sectionIndex {
                /// 防止未初始化数据 初始化数组
                self.allItemsAttributes.append([UICollectionViewLayoutAttributes]())
            }
            // 获取界面划出上面的补充视图
            let supplementSectionArr = self.supplementAttributes.filter { (supplmentItem) -> Bool in
                return supplmentItem.indexPath.section < sectionIndex
            }
            
            var contentAttributesArr:[UICollectionViewLayoutAttributes] = []
            for item in 0..<self.numberOfColumns {
                let indexPath = IndexPath(item: item, section: sectionIndex)
                var contentAttributes:UICollectionViewLayoutAttributes
                if self.allItemsAttributes[sectionIndex].count > item {
                    contentAttributes = self.allItemsAttributes[sectionIndex][item]
                }else{
                    contentAttributes  = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                }
                let contentAttributesHeight = (CGFloat(sectionIndex-1) * sheet.itemHeight) + sheet.headerViewHeight + CGFloat(CGFloat(supplementSectionArr.count) * sheet.supplementViewHeight)
                if item < sheet.freezeColumn {
                    /// 设置冻结逻辑
                    contentAttributes.frame = CGRect(x:collectionView.contentOffset.x < 0 ? self.itemLeftWidth[item] : collectionView.contentOffset.x + self.itemLeftWidth[item], y:contentAttributesHeight, width:self.itemsWidth[item], height:sheet.itemHeight)
                    contentAttributes.zIndex = 1023
                }else{
                    contentAttributes.frame = CGRect(x:self.itemLeftWidth[item], y:contentAttributesHeight, width:self.itemsWidth[item], height:sheet.itemHeight)
                    contentAttributes.zIndex = 1022
                }
                contentAttributesArr.append(contentAttributes)
            }
            // 对一行布局进行赋值
            self.allItemsAttributes[sectionIndex] = contentAttributesArr
            
            if collectionView.numberOfItems(inSection: sectionIndex) == self.itemsWidth.count + 1{
                // 设置补充视图
                let supplementIndex =  self.supplementAttributes.firstIndex { (a) -> Bool in
                    return a.indexPath.section == sectionIndex
                }
                if let index = supplementIndex {
                    /// 有则直接修改x轴
                    self.supplementAttributes[index].frame.origin.x = collectionView.contentOffset.x
                }else{
                    /// 无则初始化对象
                    let indexPath = IndexPath(item: self.itemsWidth.count, section: sectionIndex)
                    let sAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    sAttributes.zIndex = 1000
                    if self.isSingleSelect {
                        /// 单选则这个的位置
                        sAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:(CGFloat(indexPath.section) * sheet.itemHeight)+sheet.headerViewHeight, width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
                    }else{
                        let supplementItems = self.supplementAttributes.filter { (supplmentItem) -> Bool in
                            let istrue = supplmentItem.indexPath.section > indexPath.section
                            if istrue {
                                self.allItemsAttributes[supplmentItem.indexPath.section][self.itemsWidth.count].frame.origin.y += sheet.supplementViewHeight
                            }
                            return istrue
                        }
                        sAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:sheet.headerViewHeight + (CGFloat(indexPath.section) * sheet.itemHeight) + (CGFloat(self.supplementAttributes.count - supplementItems.count) * sheet.supplementViewHeight), width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
                    }
                    self.supplementAttributes.append(sAttributes)
                }
                
            }
            
        }
    }
}

//MARK: - 触碰事件
extension SheetViewLayout {
    
    /// 点击某个item
    /// - Parameters:
    ///   - indexPath: 索引
    ///   - collectionView: 控件
    public func selectItem(indexPath:IndexPath,collectionView:UICollectionView) {
        if self.isSingleSelect {
            if self.supplementAttributes.count == 1{
                if self.supplementAttributes[0].indexPath.section == indexPath.section{
                    /// 点击收回逻辑
                    self.deleteSupplementItem(indexPath: indexPath)
                    collectionView.performBatchUpdates({
                        collectionView.deleteItems(at: [IndexPath(item: self.itemsWidth.count, section:indexPath.section)])
                    }, completion: nil)
                    return
                }else{
                    /// 点击展开 同时收回原来展开
                    let deleteIndexPath = IndexPath(item: self.itemsWidth.count, section: self.supplementAttributes[0].indexPath.section)
                    
                    collectionView.performBatchUpdates({
                        self.deleteSupplementItem(indexPath:deleteIndexPath)
                        self.addSupplementItem(indexPath: indexPath)
                        collectionView.insertItems(at: [IndexPath(item: self.itemsWidth.count, section:indexPath.section)])
                        collectionView.deleteItems(at: [deleteIndexPath])
                    }, completion: nil)
                    return
                }
            }
            // 无收回 只展开
            collectionView.performBatchUpdates({
                self.addSupplementItem(indexPath: indexPath)
                collectionView.insertItems(at: [IndexPath(item: self.itemsWidth.count, section:indexPath.section)])
            }, completion: nil)
            return
        }
        
        
        // 处理多个附属视图展开
        let isdeleteArr = self.supplementAttributes.filter { (supplmentItem) -> Bool in
            return supplmentItem.indexPath.section == indexPath.section
        }
        if isdeleteArr.count > 0{
            /// 收回逻辑
            self.deleteSupplementItem(indexPath: indexPath)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(item: self.itemsWidth.count, section:indexPath.section)])
            }, completion: nil)
            return
        }
        // 展开逻辑
        self.addSupplementItem(indexPath: indexPath)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [IndexPath(item: self.itemsWidth.count, section:indexPath.section)])
        }, completion: nil)
        return
    }
    
    
    /// 删除附属视图
    /// - Parameter indexPath: 索引
    public func deleteSupplementItem(indexPath:IndexPath){
        guard let sheet = self.sheetView else { return }
        self.sheetView?.delegate?.sheetView(self.sheetView!, isAddSupplement: false, at:IndexPath(item:0, section: indexPath.section - 1))
        if self.isSingleSelect {
            self.supplementAttributes.removeAll()
        }else{
            var deleteIndex = -1
            for index in 0..<self.supplementAttributes.count {
                if self.supplementAttributes[index].indexPath.section == indexPath.section {
                    /// 获取删除的索引
                    deleteIndex = index
                }
                if self.supplementAttributes[index].indexPath.section > indexPath.section {
                    /// 获取所有在添加附属视图下面的section附属视图
                    self.allItemsAttributes[self.supplementAttributes[index].indexPath.section][self.itemsWidth.count].frame.origin.y -= sheet.supplementViewHeight
                }
            }
            if deleteIndex != -1 {
                self.supplementAttributes.remove(at: deleteIndex)
            }
        }
        self.deleteSupplementAttributes = self.supplementAttributes.filter({ (s) -> Bool in
            return s.indexPath.section == indexPath.section
        })
        
    }
    
    
    
    /// 添加附属视图
    /// - Parameter indexPath: 索引
    public func addSupplementItem(indexPath:IndexPath){
        guard let collectionView = collectionView,let sheet = self.sheetView else { return }
        self.sheetView?.delegate?.sheetView(self.sheetView!, isAddSupplement: true, at: IndexPath(item:0, section: indexPath.section - 1))
        let footIndexPath = IndexPath(item: self.itemsWidth.count, section:indexPath.section)
        let footAttributes = UICollectionViewLayoutAttributes(forCellWith: footIndexPath)
        footAttributes.zIndex = 1000
        if self.isSingleSelect {
            self.supplementAttributes.removeAll()
            footAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:(CGFloat(indexPath.section) * sheet.itemHeight)+sheet.headerViewHeight, width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
        }else{
            /// 获取所有在添加附属视图下面的section附属视图
            let supplementItems = self.supplementAttributes.filter { (supplmentItem) -> Bool in
                let istrue = supplmentItem.indexPath.section > indexPath.section
                if istrue {
                    self.allItemsAttributes[supplmentItem.indexPath.section][self.itemsWidth.count].frame.origin.y += sheet.supplementViewHeight
                }
                return istrue
            }
            footAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:sheet.headerViewHeight + (CGFloat(indexPath.section) * sheet.itemHeight) + (CGFloat(self.supplementAttributes.count - supplementItems.count) * sheet.supplementViewHeight), width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
        }
        self.supplementAttributes.append(footAttributes)
    }
    
    /// 当刷新某个控件 保持
    /// - Parameter indexPath: 索引
    public func refreshAddSupplementItem(indexPath:IndexPath) {
        guard let collectionView = collectionView,let sheet = self.sheetView else { return }
        let footIndexPath = IndexPath(item: self.itemsWidth.count, section:indexPath.section)
        let footAttributes = UICollectionViewLayoutAttributes(forCellWith: footIndexPath)
        footAttributes.zIndex = 1000
        if self.isSingleSelect {
            self.supplementAttributes.removeAll()
            footAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:(CGFloat(indexPath.section) * sheet.itemHeight)+sheet.headerViewHeight, width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
        }else{
            let supplementItems = self.supplementAttributes.filter { (supplmentItem) -> Bool in
                let istrue = supplmentItem.indexPath.section > indexPath.section
                if istrue {
                    self.allItemsAttributes[supplmentItem.indexPath.section][self.itemsWidth.count].frame.origin.y += sheet.supplementViewHeight
                }
                return istrue
            }
            footAttributes.frame = CGRect(x: collectionView.contentOffset.x, y:sheet.headerViewHeight + (CGFloat(indexPath.section) * sheet.itemHeight) + (CGFloat(self.supplementAttributes.count - supplementItems.count) * sheet.supplementViewHeight), width:collectionView.frame.size.width, height: sheet.supplementViewHeight)
        }
        self.supplementAttributes.append(footAttributes)
    }
}
