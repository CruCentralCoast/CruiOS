//
//  MaterialArticleTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import Material

class MaterialArticleTableViewCell: TableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private var spacing: CGFloat = 20
    
    /// A boolean that indicates whether the cell is the last cell.
    public var isLast = false
    
    //public lazy var card: PresenterCard = PresenterCard()
    public lazy var imgCard: ImageCard = ImageCard()
    
    /// Toolbar views.
    private var toolbar: Toolbar!
    private var moreButton: IconButton!
    
    /// Presenter area.
    //private var presenterImageView: UIImageView!
    fileprivate var imgView: UIImageView!
    fileprivate var conView: UILabel!
    
    /// Content area.
    //private var contentLabel: UILabel!
    
    /// Bottom Bar views.
    private var bottomBar: Bar!
    private var dateFormatter: DateFormatter!
    private var dateLabel: UILabel!
    private var favoriteButton: IconButton!
    private var shareButton: IconButton!
    
    public var article: Article? {
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
    /*open override var height: CGFloat {
     get {
     return imgCard.height + spacing
     }
     set(value) {
     super.height = value
     }
     }*/
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*guard let d = data else {
         return
         }*/
        
        //toolbar.title = d["title"] as? String
        //toolbar.detail = d["detail"] as? String
        
        
        
        
        
        
        /*if let image = d["photo"] as? UIImage {
         presenterImageView.height = image.height
         DispatchQueue.main.async { [weak self, image = image] in
         self?.presenterImageView.image = image
         }
         }*/
        
        
        if article?.imgURL != "" {
            imgView = UIImageView()
            imgView.load.request(with: (article?.imgURL)!, onCompletion: {success in
                //self.imgView.image?.resize(toWidth: self.contentView.width)
                
                self.imgView.height = CGFloat(100)
                print("Done loading image")
            })
            /*presenterImageView.load.request(with: (article?.imgURL)!, onCompletion: { _ in
             self.presenterImageView.height = (self.presenterImageView.image?.height)!
             })*/
            
            /*var img = UIImageView()
             img.load.request(with: (article?.imgURL)!)
             presenterImageView.height = (img.image?.height)!
             DispatchQueue.main.async { [weak self, image = img.image] in
             self?.presenterImageView.image = image
             }*/
            
        }
        
        //contentLabel.text = d["content"] as? String
        toolbar.title = article?.title
        conView.text = article?.abstract
        
        //dateLabel.text = dateFormatter.string(from: d.createdDate)
        dateLabel.text = "Change this, 2017"
        
        //imgCard.x = 0
        //imgCard.y = 0
        imgCard.width = width
        
        imgCard.setNeedsLayout()
        imgCard.layoutIfNeeded()
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
        toolbar = Toolbar(rightViews: [moreButton])
        toolbar.backgroundColor = nil
        
        
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .center
        
        /*toolbar.detail = article?.abstract
         toolbar.detailLabel.textColor = .white
         toolbar.detailLabel.textAlignment = .center*/
        
    }
    
    
    private func prepareContentLabel() {
        conView = UILabel()
        conView.numberOfLines = 0
        conView.font = RobotoFont.regular(with: 14)
        
    }
    
    private func prepareBottomBar() {
        /*bottomBar = Bar()
         bottomBar.heightPreset = .xlarge
         bottomBar.contentEdgeInsetsPreset = .square3
         bottomBar.centerViews = [dateLabel]
         bottomBar.leftViews = [favoriteButton]
         bottomBar.rightViews = [shareButton]
         bottomBar.dividerColor = Color.grey.lighten3*/
        bottomBar = Bar(leftViews: [favoriteButton], rightViews: [shareButton], centerViews: [dateLabel])
    }
    
    private func preparePresenterCard() {
        
        imgCard = ImageCard()
        imgCard.toolbar = toolbar
        imgCard.toolbarEdgeInsetsPreset = .square3
        imgCard.imageView = imgView
        
        imgCard.contentView = conView
        
        //imgCard.presenterView = imgView
        //imgCard.contentView = contentLabel
        imgCard.contentViewEdgeInsetsPreset = .square3
        imgCard.contentViewEdgeInsets.bottom = 0
        imgCard.bottomBar = bottomBar
        imgCard.depthPreset = .none
        imgCard.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        contentView.addSubview(imgCard)
    }

}
