//
//  VideoTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import Material

class MaterialVideoTableViewCell: TableViewCell {
    private var spacing: CGFloat = 10
    
    /// A boolean that indicates whether the cell is the last cell.
    public var isLast = false
    
    public lazy var card: PresenterCard = PresenterCard()
    
    /// Toolbar views.
    private var toolbar: Toolbar!
    private var moreButton: IconButton!
    
    /// Presenter area.
    private var presenterImageView: UIImageView!
    
    /// Content area.
    private var contentLabel: UILabel!
    
    /// Bottom Bar views.
    private var bottomBar: Bar!
    private var dateFormatter: DateFormatter!
    private var dateLabel: UILabel!
    private var favoriteButton: IconButton!
    private var shareButton: IconButton!
    
    public var video: Video? {
        didSet{
            layoutSubviews()
        }
    }
    /*public var data: Entity? {
     didSet {
     layoutSubviews()
     }
     }*/
    
    /// Calculating dynamic height.
    open override var height: CGFloat {
        get {
            return card.height + spacing
        }
        set(value) {
            super.height = value
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*guard let d = data else {
         return
         }*/
        
        //toolbar.title = d["title"] as? String
        //toolbar.detail = d["detail"] as? String
        
        
        toolbar.title = video?.title
        toolbar.detail = video?.abstract
        
        
        
        /*if let image = d["photo"] as? UIImage {
         presenterImageView.height = image.height
         DispatchQueue.main.async { [weak self, image = image] in
         self?.presenterImageView.image = image
         }
         }*/
        
        //contentLabel.text = d["content"] as? String
        contentLabel.text = "Bah bah black sheep have you any booze?"
        
        //dateLabel.text = dateFormatter.string(from: d.createdDate)
        dateLabel.text = "Change this, 2017"
        
        card.x = 0
        card.y = 0
        card.width = width
        
        card.setNeedsLayout()
        card.layoutIfNeeded()
    }
    
    open override func prepare() {
        super.prepare()
        
        layer.rasterizationScale = Screen.scale
        layer.shouldRasterize = true
        
        pulseAnimation = .none
        backgroundColor = nil
        
        prepareDateFormatter()
        prepareDateLabel()
        prepareMoreButton()
        prepareToolbar()
        prepareFavoriteButton()
        prepareShareButton()
        preparePresenterImageView()
        prepareContentLabel()
        prepareBottomBar()
        preparePresenterCard()
    }
    
    private func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
    }
    
    private func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.blueGrey.base)
    }
    
    private func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.red.base)
    }
    
    private func prepareShareButton() {
        shareButton = IconButton(image: Icon.cm.share, tintColor: Color.blueGrey.base)
    }
    
    private func prepareToolbar() {
        toolbar = Toolbar()
        toolbar.heightPreset = .xlarge
        toolbar.contentEdgeInsetsPreset = .square3
        toolbar.titleLabel.textAlignment = .left
        toolbar.detailLabel.textAlignment = .left
        toolbar.rightViews = [moreButton]
        toolbar.dividerColor = Color.grey.lighten3
        toolbar.dividerAlignment = .top
    }
    
    private func preparePresenterImageView() {
        presenterImageView = UIImageView()
        presenterImageView.contentMode = .scaleAspectFill
    }
    
    private func prepareContentLabel() {
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = RobotoFont.regular(with: 14)
    }
    
    private func prepareBottomBar() {
        bottomBar = Bar()
        bottomBar.heightPreset = .xlarge
        bottomBar.contentEdgeInsetsPreset = .square3
        bottomBar.centerViews = [dateLabel]
        bottomBar.leftViews = [favoriteButton]
        bottomBar.rightViews = [shareButton]
        bottomBar.dividerColor = Color.grey.lighten3
    }
    
    private func preparePresenterCard() {
        card.toolbar = toolbar
        card.presenterView = presenterImageView
        card.contentView = contentLabel
        card.contentViewEdgeInsetsPreset = .square3
        card.contentViewEdgeInsets.bottom = 0
        card.bottomBar = bottomBar
        card.depthPreset = .none
        
        contentView.addSubview(card)
    }

}
