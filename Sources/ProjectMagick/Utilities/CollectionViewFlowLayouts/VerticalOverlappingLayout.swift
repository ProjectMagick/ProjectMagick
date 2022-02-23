//
//  VerticalOverlappingLayout.swift
//  ProjectMagick
//
//  Created by Kishan on 13/01/21.
//  Copyright © 2021 Kishan. All rights reserved.
//

import UIKit


/**Usage-----> var collectionViewVerticallayout = VerticalOverlappingCollectionViewFlowLayout()
 collectionViewVerticallayout.scrollDirection = .vertical
 collection.collectionViewLayout = collectionViewVerticallayout
 Also give minimumLineSpacing in minus to overlap and use _isSticky_ for sticky layout
 */
public class VerticalOverlappingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    public var firstItemTransform: CGFloat?
    public var isSticky = false
        
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let items = NSArray (array: super.layoutAttributesForElements(in: rect)!, copyItems: true)
        var headerAttributes: UICollectionViewLayoutAttributes?
        
        items.enumerateObjects(using: { (object, index, stop) -> Void in
            let attributes = object as! UICollectionViewLayoutAttributes
            
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                headerAttributes = attributes
            } else {
                self.updateCellAttributes(attributes, headerAttributes: headerAttributes)
            }
        })
        return items as? [UICollectionViewLayoutAttributes]
    }
    
    func updateCellAttributes(_ attributes: UICollectionViewLayoutAttributes, headerAttributes: UICollectionViewLayoutAttributes?) {
        let minY = collectionView!.bounds.minY + collectionView!.contentInset.top
        var maxY = attributes.frame.origin.y
        
        if let headerAttributes = headerAttributes {
            maxY -= headerAttributes.bounds.height
        }
        
        let finalY = isSticky ? max(minY, maxY) : maxY
        var origin = attributes.frame.origin
        
        if let itemTransform = firstItemTransform {
            let deltaY = (finalY - origin.y) / attributes.frame.height
            let scale = 1 - deltaY * itemTransform
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        origin.y = finalY
        attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
        attributes.zIndex = attributes.indexPath.row
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
