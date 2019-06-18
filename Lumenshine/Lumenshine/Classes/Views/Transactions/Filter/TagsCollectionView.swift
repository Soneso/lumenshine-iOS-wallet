//
//  TagsCollectionView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class TagsCollectionView: UICollectionView {
    
    fileprivate static let CellIdentifier = "TagCollectionCellIdentifier"
    
    fileprivate let collectionLayout = CustomFlowLayout()
    
    var items = [String]() {
        didSet {
            reloadData()
        }
    }
    
    var color: UIColor = Stylesheet.color(.blue)
    
    init() {
        super.init(frame: .zero, collectionViewLayout: collectionLayout)
        
        collectionLayout.minimumInteritemSpacing = 2.0
        collectionLayout.minimumLineSpacing = 2.0
        collectionLayout.sectionInset = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0, right: 0.0)
        collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        isScrollEnabled = false
        dataSource = self
        
        backgroundColor = Stylesheet.color(.clear)
        register(TagCollectionViewItem.self, forCellWithReuseIdentifier: TagsCollectionView.CellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return collectionLayout.collectionViewContentSize
    }
}

extension TagsCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagsCollectionView.CellIdentifier, for: indexPath) as! TagCollectionViewItem
        
        cell.setTitle(items[indexPath.row])
        cell.setColor(color)
        return cell
    }
}

class CustomFlowLayout : UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr = super.layoutAttributesForElements(in: rect)!
        return arr.map {
            atts in
            
            var atts = atts
            if atts.representedElementCategory == .cell {
                let ip = atts.indexPath
                atts = self.layoutAttributesForItem(at:ip)!
            }
            return atts
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var atts = super.layoutAttributesForItem(at:indexPath)!
        if indexPath.item == 0 {
            atts.frame.origin.x = self.sectionInset.left
            return atts
            
        }
        if atts.frame.origin.x - 1 <= self.sectionInset.left {
            return atts
            
        }
        let ipPv = IndexPath(item:indexPath.row-1, section:indexPath.section)
        let fPv = self.layoutAttributesForItem(at:ipPv)!.frame
        let rightPv = fPv.origin.x + fPv.size.width + self.minimumInteritemSpacing
        atts = atts.copy() as! UICollectionViewLayoutAttributes
        atts.frame.origin.x = rightPv
        return atts
    }
    
}
