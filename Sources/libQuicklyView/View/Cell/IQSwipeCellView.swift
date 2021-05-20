//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQSwipeCellView : IQCellView {
    
    var isShowedLeadingView: Bool { get }
    var leadingView: IQView? { get }
    var leadingSize: Float { get }
    var leadingLimit: Float { get }
    var isShowedTrailingView: Bool { get }
    var trailingView: IQView? { get }
    var trailingSize: Float { get }
    var trailingLimit: Float { get }
    var animationVelocity: Float { get }
    
    func showLeadingView(animated: Bool, completion: (() -> Void)?)
    func hideLeadingView(animated: Bool, completion: (() -> Void)?)
    
    func showTrailingView(animated: Bool, completion: (() -> Void)?)
    func hideTrailingView(animated: Bool, completion: (() -> Void)?)
    
    @discardableResult
    func leadingView(_ value: IQView?) -> Self
    
    @discardableResult
    func leadingSize(_ value: Float) -> Self
    
    @discardableResult
    func leadingLimit(_ value: Float) -> Self
    
    @discardableResult
    func trailingView(_ value: IQView?) -> Self
    
    @discardableResult
    func trailingSize(_ value: Float) -> Self
    
    @discardableResult
    func trailingLimit(_ value: Float) -> Self
    
    @discardableResult
    func animationVelocity(_ value: Float) -> Self
    
    @discardableResult
    func onShowLeading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onHideLeading(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onShowTrailing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onHideTrailing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onPressed(_ value: (() -> Void)?) -> Self
    
}

public extension IQSwipeCellView {
    
    func showLeadingView(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.showLeadingView(animated: animated, completion: completion)
    }
    
    func hideLeadingView(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.hideLeadingView(animated: animated, completion: completion)
    }
    
    func showTrailingView(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.showTrailingView(animated: animated, completion: completion)
    }
    
    func hideTrailingView(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.hideTrailingView(animated: animated, completion: completion)
    }
    
}
