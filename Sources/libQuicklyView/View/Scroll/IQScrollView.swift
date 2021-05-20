//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QScrollViewDirection : OptionSet {
    
    public typealias RawValue = UInt
    
    public var rawValue: UInt
    
    @inlinable
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var horizontal = QScrollViewDirection(rawValue: 0x01)
    public static var vertical = QScrollViewDirection(rawValue: 0x02)
    
}

public enum QScrollViewScrollAlignment {
    case leading
    case center
    case trailing
}

public protocol IQScrollView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var direction: QScrollViewDirection { get }
    var indicatorDirection: QScrollViewDirection { get }
    var contentInset: QInset { get }
    var contentOffset: QPoint { get }
    var contentSize: QSize { get }
    var contentLayout: IQLayout { get }
    var isScrolling: Bool { get }
    var isDecelerating: Bool { get }

    func contentOffset(with view: IQView, horizontal: QScrollViewScrollAlignment, vertical: QScrollViewScrollAlignment) -> QPoint?
    
    @discardableResult
    func direction(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func indicatorDirection(_ value: QScrollViewDirection) -> Self
    
    @discardableResult
    func contentInset(_ value: QInset) -> Self
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool) -> Self
    
    @discardableResult
    func contentLayout(_ value: IQLayout) -> Self
    
    @discardableResult
    func onBeginScrolling(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onScrolling(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndScrolling(_ value: ((_ decelerate: Bool) -> Void)?) -> Self
    
    @discardableResult
    func onBeginDecelerating(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndDecelerating(_ value: (() -> Void)?) -> Self
    
}

public extension IQScrollView {
    
    var estimatedContentOffset: QPoint {
        let size = self.bounds.size
        let contentOffset = self.contentOffset
        let contentSize = self.contentSize
        let contentInset = self.contentInset
        return QPoint(
            x: (contentInset.left + contentSize.width + contentInset.right) - (contentOffset.x + size.width),
            y: (contentInset.top + contentSize.height + contentInset.bottom) - (contentOffset.y + size.height)
        )
    }
    
    @discardableResult
    func contentOffset(_ value: QPoint, normalized: Bool = false) -> Self {
        return self.contentOffset(value, normalized: normalized)
    }
    
    func scrollToTop(animated: Bool = true, completion: (() -> Void)? = nil) {
        let contentInset = self.contentInset
        let beginContentOffset = self.contentOffset
        let endContentOffset = QPoint(x: -contentInset.left, y: -contentInset.top)
        let deltaContentOffset = abs(beginContentOffset.distance(to: endContentOffset))
        if animated == true && deltaContentOffset > 0 {
            let velocity = max(self.bounds.width, self.bounds.height)
            QAnimation.default.run(
                duration: TimeInterval(deltaContentOffset / velocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [unowned self] progress in
                    let contentOffset = beginContentOffset.lerp(endContentOffset, progress: progress)
                    self.contentOffset(contentOffset)
                },
                completion: {
                    completion?()
                }
            )
        } else {
            self.contentOffset(QPoint(x: -contentInset.left, y: -contentInset.top))
            completion?()
        }
    }
    
}
