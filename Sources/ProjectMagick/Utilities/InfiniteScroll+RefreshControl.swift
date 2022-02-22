//
//  InfiniteScroll+RefreshControl.swift
//
//
//  Created by Kishan on 03/02/22.
//


//https://github.com/eggswift/pull-to-refresh.git
//Slightly modify as per our use

import UIKit

public protocol ExtensionsProvider: AnyObject {
    associatedtype CompatibleType
    var pm: CompatibleType { get }
}

extension ExtensionsProvider {
    /// A proxy which hosts reactive extensions for `self`.
    public var pm: PM<Self> {
        return PM(self)
    }

}

public struct PM<Base> {
    public let base: Base
    
    // Construct a proxy.
    //
    // - parameters:
    //   - base: The object to be proxied.
    fileprivate init(_ base: Base) {
        self.base = base
    }
}



extension UIScrollView: ExtensionsProvider {}

private var RefreshFooterKey: Void?

public extension UIScrollView {
    
    /// Infinitiy scroll associated property
    var footer: RefreshFooterView? {
        get {
            return (objc_getAssociatedObject(self, &RefreshFooterKey) as? RefreshFooterView)
        } set(newValue) {
            objc_setAssociatedObject(self, &RefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

public extension PM where Base: UIScrollView {
    
    
    /// Add infinite-scrolling
    @discardableResult
    func addInfiniteScrolling(handler: @escaping RefreshHandler) -> RefreshFooterView {
        removeRefreshFooter()
        let footer = RefreshFooterView(frame: CGRect.zero, handler: handler)
        let footerH = footer.animator.executeIncremental
        footer.frame = CGRect.init(x: 0.0, y: base.contentSize.height + base.contentInset.bottom, width: base.bounds.size.width, height: footerH)
        base.addSubview(footer)
        base.footer = footer
        return footer
    }

    @discardableResult
    func addInfiniteScrolling(animator: RefreshProtocol & RefreshAnimatorProtocol, handler: @escaping RefreshHandler) -> RefreshFooterView {
        removeRefreshFooter()
        let footer = RefreshFooterView(frame: CGRect.zero, handler: handler, animator: animator)
        let footerH = footer.animator.executeIncremental
        footer.frame = CGRect.init(x: 0.0, y: base.contentSize.height + base.contentInset.bottom, width: self.base.bounds.size.width, height: footerH)
        base.footer = footer
        base.addSubview(footer)
        return footer
    }

    func removeRefreshFooter() {
        base.footer?.stopRefreshing()
        base.footer?.removeFromSuperview()
        base.footer = nil
    }
    
    /// Footer notice method
    func noticeNoMoreData() {
        base.footer?.stopRefreshing()
        base.footer?.noMoreData = true
    }
    
    func resetNoMoreData() {
        base.footer?.noMoreData = false
    }
    
    func stopLoadingMore() {
        base.footer?.stopRefreshing()
    }
    
}


open class RefreshFooterView: RefreshComponent {
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    open var noMoreData = false {
        didSet {
            if noMoreData != oldValue {
                animator.refresh(view: self, stateDidChange: noMoreData ? .noMoreData : .pullToRefresh)
            }
        }
    }
    
    open override var isHidden: Bool {
        didSet {
            if isHidden {
                scrollView?.contentInset.bottom = scrollViewInsets.bottom
                var rect = self.frame
                rect.origin.y = scrollView?.contentSize.height ?? 0.0
                self.frame = rect
            } else {
                scrollView?.contentInset.bottom = scrollViewInsets.bottom + animator.executeIncremental
                var rect = self.frame
                rect.origin.y = scrollView?.contentSize.height ?? 0.0
                self.frame = rect
            }
        }
    }
    
    public convenience init(frame: CGRect, handler: @escaping RefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        animator = RefreshFooterAnimator.init()
    }
    
    /**
      In didMoveToSuperview, it will cache superview(UIScrollView)'s contentInset and update self's frame.
      It called RefreshComponent's didMoveToSuperview.
     */
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.async { [weak self] in
            self?.scrollViewInsets = self?.scrollView?.contentInset ?? UIEdgeInsets.zero
            self?.scrollView?.contentInset.bottom = (self?.scrollViewInsets.bottom ?? 0) + (self?.bounds.size.height ?? 0)
            var rect = self?.frame ?? CGRect.zero
            rect.origin.y = self?.scrollView?.contentSize.height ?? 0.0
            self?.frame = rect
        }
    }
 
    open override func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        super.sizeChangeAction(object: object, change: change)
        let targetY = scrollView.contentSize.height + scrollViewInsets.bottom
        if self.frame.origin.y != targetY {
            var rect = self.frame
            rect.origin.y = targetY
            self.frame = rect
        }
    }
    
    open override func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else {
            return
        }
        
        super.offsetChangeAction(object: object, change: change)
        
        guard isRefreshing == false && isAutoRefreshing == false && noMoreData == false && isHidden == false else {
            // When loading more or the content is empty, it does not change accordingly
            return
        }

        if scrollView.contentSize.height <= 0.0 || scrollView.contentOffset.y + scrollView.contentInset.top <= 0.0 {
            self.alpha = 0.0
            return
        } else {
            self.alpha = 1.0
        }
        
        if scrollView.contentSize.height + scrollView.contentInset.top > scrollView.bounds.size.height {
            // The content exceeds one screen Calculate the formula to determine whether it is dragged to the bottom
            if scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom  <= scrollView.bounds.size.height {
                self.animator.refresh(view: self, stateDidChange: .refreshing)
                self.startRefreshing()
            }
        } else {
            // The content does not exceed one screen. At this time, the dragging height is greater than 1/2footer, which means that the pull-up is requested.
            if scrollView.contentOffset.y + scrollView.contentInset.top >= animator.trigger / 2.0 {
                self.animator.refresh(view: self, stateDidChange: .refreshing)
                self.startRefreshing()
            }
        }
    }
    
    open override func start() {
        guard let scrollView = scrollView else {
            return
        }
        super.start()
        
        animator.refreshAnimationBegin(view: self)
        
        let x = scrollView.contentOffset.x
        let y = max(0.0, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        
        // Call handler
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
            scrollView.contentOffset = CGPoint.init(x: x, y: y)
        }, completion: { (animated) in
            self.handler?()
        })
    }
    
    open override func stop() {
        guard let scrollView = scrollView else {
            return
        }
        
        animator.refreshAnimationEnd(view: self)
        
        // Back state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
        }, completion: { (finished) in
            if self.noMoreData == false {
                self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
            }
            super.stop()
        })

        // Stop deceleration of UIScrollView. When the button tap event is caught, you read what the [scrollView contentOffset].x is, and set the offset to this value with animation OFF.
        // http://stackoverflow.com/questions/2037892/stop-deceleration-of-uiscrollview
        if scrollView.isDecelerating {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = min(contentOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
            if contentOffset.y < 0.0 {
                contentOffset.y = 0.0
                UIView.animate(withDuration: 0.1, animations: {
                    scrollView.setContentOffset(contentOffset, animated: false)
                })
            } else {
                scrollView.setContentOffset(contentOffset, animated: false)
            }
        }
        
    }
    
    /// Change to no-more-data status.
    open func noticeNoMoreData() {
        noMoreData = true
    }
    
    /// Reset no-more-data status.
    open func resetNoMoreData() {
        noMoreData = false
    }
    
}


public typealias RefreshHandler = (() -> ())

open class RefreshComponent: UIView {
    
    open weak var scrollView: UIScrollView?
    
    /// @param handler Refresh callback method
    open var handler: RefreshHandler?
    
    /// @param animator Animated view refresh controls, custom must comply with the following two protocol
    open var animator: (RefreshProtocol & RefreshAnimatorProtocol)!
    
    /// @param refreshing or not
    fileprivate var _isRefreshing = false
    open var isRefreshing: Bool {
        get {
            return self._isRefreshing
        }
    }
    
    /// @param auto refreshing or not
    fileprivate var _isAutoRefreshing = false
    open var isAutoRefreshing: Bool {
        get {
            return self._isAutoRefreshing
        }
    }
    
    /// @param tag observing
    fileprivate var isObservingScrollView = false
    fileprivate var isIgnoreObserving = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin]
    }
    
    public convenience init(frame: CGRect, handler: @escaping RefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        animator = RefreshAnimator.init()
    }
    
    public convenience init(frame: CGRect, handler: @escaping RefreshHandler, animator: RefreshProtocol & RefreshAnimatorProtocol) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = animator
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        /// Remove observer from superview immediately
        self.removeObserver()
        DispatchQueue.main.async { [weak self, newSuperview] in
            /// Add observer to new superview in next runloop
            self?.addObserver(newSuperview)
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.scrollView = self.superview as? UIScrollView
        if let _ = animator {
            let v = animator.view
            if v.superview == nil {
                let inset = animator.insets
                self.addSubview(v)
                v.frame = CGRect.init(x: inset.left,
                                      y: inset.right,
                                      width: self.bounds.size.width - inset.left - inset.right,
                                      height: self.bounds.size.height - inset.top - inset.bottom)
                v.autoresizingMask = [
                    .flexibleWidth,
                    .flexibleTopMargin,
                    .flexibleHeight,
                    .flexibleBottomMargin
                ]
            }
        }
    }
    
    // MARK: - Action
    
    public final func startRefreshing(isAuto: Bool = false) -> Void {
        guard isRefreshing == false && isAutoRefreshing == false else {
            return
        }
        
        _isRefreshing = !isAuto
        _isAutoRefreshing = isAuto
        
        self.start()
    }
    
    public final func stopRefreshing() -> Void {
        guard isRefreshing == true || isAutoRefreshing == true else {
            return
        }
        
        self.stop()
    }
    
    public func start() {
        
    }
    
    public func stop() {
        _isRefreshing = false
        _isAutoRefreshing = false
    }
    
    //  ScrollView contentSize change action
    public func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    //  ScrollView offset change action
    public func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
}

extension RefreshComponent /* KVO methods */ {
    
    fileprivate static var context = "RefreshKVOContext"
    fileprivate static let offsetKeyPath = "contentOffset"
    fileprivate static let contentSizeKeyPath = "contentSize"
    
    public func ignoreObserver(_ ignore: Bool = false) {
        if let scrollView = scrollView {
            scrollView.isScrollEnabled = !ignore
        }
        isIgnoreObserving = ignore
    }
    
    fileprivate func addObserver(_ view: UIView?) {
        if let scrollView = view as? UIScrollView, !isObservingScrollView {
            scrollView.addObserver(self, forKeyPath: RefreshComponent.offsetKeyPath, options: [.initial, .new], context: &RefreshComponent.context)
            scrollView.addObserver(self, forKeyPath: RefreshComponent.contentSizeKeyPath, options: [.initial, .new], context: &RefreshComponent.context)
            isObservingScrollView = true
        }
    }
    
    fileprivate func removeObserver() {
        if let scrollView = superview as? UIScrollView, isObservingScrollView {
            scrollView.removeObserver(self, forKeyPath: RefreshComponent.offsetKeyPath, context: &RefreshComponent.context)
            scrollView.removeObserver(self, forKeyPath: RefreshComponent.contentSizeKeyPath, context: &RefreshComponent.context)
            isObservingScrollView = false
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &RefreshComponent.context {
            guard isUserInteractionEnabled == true && isHidden == false else {
                return
            }
            if keyPath == RefreshComponent.contentSizeKeyPath {
                if isIgnoreObserving == false {
                    sizeChangeAction(object: object as AnyObject?, change: change)
                }
            } else if keyPath == RefreshComponent.offsetKeyPath {
                if isIgnoreObserving == false {
                    offsetChangeAction(object: object as AnyObject?, change: change)
                }
            }
        }
    }
    
}



open class RefreshAnimator: RefreshProtocol, RefreshAnimatorProtocol {
    // The view that called when component refresh, returns a custom view or self if 'self' is the customized views.
    open var view: UIView
    // Customized inset.
    open var insets: UIEdgeInsets
    // Refresh event is executed threshold required y offset, set a value greater than 0.0, the default is 60.0
    open var trigger: CGFloat = 60.0
    // Offset y refresh event executed by this parameter you can customize the animation to perform when you refresh the view of reservations height
    open var executeIncremental: CGFloat = 60.0
    // Current refresh state, default is .pullToRefresh
    open var state: RefreshViewState = .pullToRefresh
    
    public init() {
        view = UIView()
        insets = UIEdgeInsets.zero
    }
    
    open func refreshAnimationBegin(view: RefreshComponent) {
        /// Do nothing!
    }
    
    open func refreshAnimationWillEnd(view: RefreshComponent) {
        /// Do nothing!
    }
    
    open func refreshAnimationEnd(view: RefreshComponent) {
        /// Do nothing!
    }
    
    open func refresh(view: RefreshComponent, progressDidChange progress: CGFloat) {
        /// Do nothing!
    }
    
    open func refresh(view: RefreshComponent, stateDidChange state: RefreshViewState) {
        /// Do nothing!
    }
}



public enum RefreshViewState {
    case pullToRefresh
    case releaseToRefresh
    case refreshing
    case autoRefreshing
    case noMoreData
}

/**
 *  RefreshProtocol
 *  Animation event handling callback protocol
 *  You can customize the refresh or custom animation effects
 *  Mutating is to be able to modify or enum struct variable in the method - http://swifter.tips/protocol-mutation/ by ONEVCAT
 */
public protocol RefreshProtocol {
    
    /**
     Refresh operation begins execution method
     You can refresh your animation logic here, it will need to start the animation each time a refresh
    */
    mutating func refreshAnimationBegin(view: RefreshComponent)
    
    /**
     Refresh operation stop execution method
     Here you can reset your refresh control UI, such as a Stop UIImageView animations or some opened Timer refresh, etc., it will be executed once each time the need to end the animation
     */
    mutating func refreshAnimationEnd(view: RefreshComponent)
    
    /**
     Pulling status callback , progress is the percentage of the current offset with trigger, and avoid doing too many tasks in this process so as not to affect the fluency.
     */
    mutating func refresh(view: RefreshComponent, progressDidChange progress: CGFloat)
    
    mutating func refresh(view: RefreshComponent, stateDidChange state: RefreshViewState)
}


public protocol RefreshAnimatorProtocol {
    
    // The view that called when component refresh, returns a custom view or self if 'self' is the customized views.
    var view: UIView {get}
    
    // Customized inset.
    var insets: UIEdgeInsets {set get}
    
    // Refresh event is executed threshold required y offset, set a value greater than 0.0, the default is 60.0
    var trigger: CGFloat {set get}
    
    // Offset y refresh event executed by this parameter you can customize the animation to perform when you refresh the view of reservations height
    var executeIncremental: CGFloat {set get}
    
    // Current refresh state, default is .pullToRefresh
    var state: RefreshViewState {set get}
    
}

/**
 *  RefreshImpacter
 *  Support iPhone7/iPhone7 Plus or later feedback impact
 *  You can confirm the RefreshImpactProtocol
 */
fileprivate class RefreshImpacter {
    static private var impacter: AnyObject? = {
        if NSClassFromString("UIFeedbackGenerator") != nil {
            let generator = UIImpactFeedbackGenerator.init(style: .light)
            generator.prepare()
            return generator
        }
        return nil
    }()
    
    static public func impact() -> Void {
        if let impacter = impacter as? UIImpactFeedbackGenerator {
            impacter.impactOccurred()
        }
    }
}

public protocol RefreshImpactProtocol {}
public extension RefreshImpactProtocol {
    
    func impact() -> Void {
        RefreshImpacter.impact()
    }
    
}



open class RefreshFooterAnimator: UIView, RefreshProtocol, RefreshAnimatorProtocol {

    open var loadingMoreDescription: String = "Loading more"
    open var noMoreDataDescription: String  = ""
    open var loadingDescription: String     = "Loading..."

    open var view: UIView { return self }
    open var duration: TimeInterval = 0.3
    open var insets: UIEdgeInsets = UIEdgeInsets.zero
    open var trigger: CGFloat = 42.0
    open var executeIncremental: CGFloat = 42.0
    open var state: RefreshViewState = .pullToRefresh
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.init(white: 160.0 / 255.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView.init(style: .medium)
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = loadingMoreDescription
        addSubview(titleLabel)
        addSubview(indicatorView)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func refreshAnimationBegin(view: RefreshComponent) {
        indicatorView.startAnimating()
        titleLabel.text = loadingDescription
        indicatorView.isHidden = false
    }
    
    open func refreshAnimationEnd(view: RefreshComponent) {
        indicatorView.stopAnimating()
        titleLabel.text = loadingMoreDescription
        indicatorView.isHidden = true
    }
    
    open func refresh(view: RefreshComponent, progressDidChange progress: CGFloat) {
        // do nothing
    }
    
    open func refresh(view: RefreshComponent, stateDidChange state: RefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing, .autoRefreshing :
            titleLabel.text = loadingDescription
            break
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            break
        case .pullToRefresh:
            titleLabel.text = loadingMoreDescription
            break
        default:
            break
        }
        self.setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint.init(x: w / 2.0, y: h / 2.0 - 5.0)
        indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 18.0, y: titleLabel.center.y)
    }
}

