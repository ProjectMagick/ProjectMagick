//
//  File.swift
//  
//
//  Created by Kishan on 06/01/22.
//

import UIKit

//MARK: - Tableview
open class TablePlus : UITableView {
    
    //MARK: - Variables
    public var lblNoDataLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = AlertMessages.noDataAvailable
        return label
    }()
    
    public var padding : (top : Double, bottom : Double) = (0,0) {
        didSet {
            tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: padding.0))
            tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: padding.1))
        }
    }
    
    public var lblNoDataPadding : CGFloat = 10
    var refresher = UIRefreshControl()
    public var refreshCallback : (()->())?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        applyBasicSetup()
    }
    
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        applyBasicSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        lblNoDataLabel.frame = bounds.inset(by: .init(horizontal: lblNoDataPadding, vertical: 0))
    }
    
    
    private func applyBasicSetup() {
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        tableFooterView = UIView()
    }
    
}


public extension TablePlus {
    
    func showNoDataLabel(show : Bool, message : String = AlertMessages.noDataAvailable) {
        lblNoDataLabel.text = message
        backgroundView = lblNoDataLabel
    }
    
    func startRefreshing(needCallback : Bool = true, animateScroll : Bool = true) {
        refresher.beginRefreshing(in: self, animated: animateScroll, sendAction: needCallback)
    }
    
    func stopRefreshing() {
        refresher.endRefreshing()
    }
    
    func addRefreshControl(tint : UIColor = .systemGray, title : String? = nil) {
        refreshControl = refresher
        refresher.tintColor = tint
        if let value = title {
            refresher.attributedTitle = NSAttributedString(string: value).colored(with: tint)
        }
        refresher.addTarget(self, action: #selector(refreshStarted), for: .valueChanged)
    }
    
    @objc func refreshStarted() {
        refreshCallback?()
    }
    
}


//MARK: - CollectionView
public class CollectionPlus : UICollectionView {
    
    
    //MARK: - Variables
    public var lblNoDataLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = AlertMessages.noDataAvailable
        return label
    }()
    
    public var sectionPadding : UIEdgeInsets = .zero {
        didSet {
            let layout = collectionViewLayout as? UICollectionViewFlowLayout
            layout?.sectionInset = sectionPadding
            layout?.invalidateLayout()
        }
    }
    
    var refresher = UIRefreshControl()
    public var refreshCallback : (()->())?
    
    public var scrollPositionPadding : UIEdgeInsets = .zero {
        didSet {
            contentInset = scrollPositionPadding
        }
    }
    
    public var labelPadding : CGFloat = 10
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        applyBasicSetup()
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        applyBasicSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        lblNoDataLabel.frame = bounds.inset(by: .init(horizontal: labelPadding, vertical: 0))
    }
    
    
    private func applyBasicSetup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = .zero
    }
    
}


public extension CollectionPlus {
    
    func showNoDataLabel(show : Bool, message : String = AlertMessages.noDataAvailable) {
        lblNoDataLabel.text = message
        backgroundView = show ? lblNoDataLabel : nil
    }
    
    func startRefreshing(needCallback : Bool = true, animateScroll : Bool = true) {
        refresher.beginRefreshing(animated: animateScroll, sendAction: needCallback)
    }
    
    func stopRefreshing() {
        refresher.endRefreshing()
    }
    
    func addRefreshControl(tint : UIColor = .systemGray, title : String? = nil) {
        refreshControl = refresher
        refresher.tintColor = tint
        if let value = title {
            refresher.attributedTitle = NSAttributedString(string: value).colored(with: tint)
        }
        refresher.addTarget(self, action: #selector(refreshStarted), for: .valueChanged)
    }
    
    @objc func refreshStarted() {
        refreshCallback?()
    }
    
}


//MARK: - PaddingLabel
open class PaddingLabel: UILabel {

    //MARK: - Variables
    public var topInset: CGFloat = 5.0
    public var bottomInset: CGFloat = 5.0
    public var leftInset: CGFloat = 7.0
    public var rightInset: CGFloat = 7.0
    
    open override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
    open override func textRect(forBounds bounds:CGRect, limitedToNumberOfLines n:Int) -> CGRect {
        let b = bounds
        let UIEI = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        let tr = b.inset(by: UIEI)
        let ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: 0)
        return ctr
    }
    
    open override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        super.draw(rect)
    }
    
    open override var bounds: CGRect {
        didSet {
            // Supported Multiple Lines in Stack views
            // preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
    
}
