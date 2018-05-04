//
//  ResourcesCollectionViewLayout.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/3/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//  Credit to http://dativestudios.com/blog/2015/01/10/collection_view_sticky_headers/

import UIKit

class ResourcesCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollDirection = .horizontal
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Get the layout attributes for a standard flow layout
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        // If this is a header, we should tweak it's attributes
        if elementKind == UICollectionElementKindSectionHeader {
            attributes?.bounds = CGRect(x: (collectionView?.bounds.minX)!, y: 0, width: collectionView!.frame.size.width, height: 20)
        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Get the layout attributes for a standard UICollectionViewFlowLayout
        guard var elementsLayoutAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }


        // Loop through the layout attributes we have
        elementsLayoutAttributes = elementsLayoutAttributes.map() { layoutAttributes -> (UICollectionViewLayoutAttributes) in
            switch layoutAttributes.representedElementCategory {
            case .supplementaryView:
                // If this is a set of layout attributes for a section header, replace them with modified attributes
                if layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader {
                    if let newLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: layoutAttributes.indexPath) {
                        return newLayoutAttributes
                    }
                }
            case .cell:
                break
            case .decorationView:
                break
            }
            
            return layoutAttributes
        }
        if let newAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0)) {
            elementsLayoutAttributes.append(newAttributes)
        }
        
        return elementsLayoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Return true so we're asked for layout attributes as the content is scrolled
        return true
    }
    
}
