//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QSwipeCellView : IQSwipeCellView {
    
    public var parentLayout: IQLayout? {
        get { return self._view.parentLayout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var name: String {
        return self._view.name
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var isAppeared: Bool {
        return self._view.isAppeared
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public var shouldHighlighting: Bool {
        get { return self._view.shouldHighlighting }
    }
    public var isHighlighted: Bool {
        get { return self._view.isHighlighted }
    }
    public private(set) var shouldPressed: Bool
    public private(set) var contentView: IQView {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._layout.contentItem = QLayoutItem(view: self.contentView)
        }
    }
    public var isShowedLeadingView: Bool {
        switch self._layout.state {
        case .leading: return true
        default: return false
        }
    }
    public private(set) var leadingView: IQView? {
        didSet(oldValue) {
            guard self.leadingView !== oldValue else { return }
            if let view = self.leadingView {
                self._layout.leadingItem = QLayoutItem(view: view)
            } else {
                self._layout.leadingItem = nil
            }
        }
    }
    public private(set) var leadingSize: QFloat {
        set(value) { self._layout.leadingSize = value }
        get { return self._layout.leadingSize }
    }
    public private(set) var leadingLimit: QFloat
    public var isShowedTrailingView: Bool {
        switch self._layout.state {
        case .trailing: return true
        default: return false
        }
    }
    public private(set) var trailingView: IQView? {
        didSet(oldValue) {
            guard self.trailingView !== oldValue else { return }
            if let view = self.trailingView {
                self._layout.trailingItem = QLayoutItem(view: view)
            } else {
                self._layout.trailingItem = nil
            }
        }
    }
    public private(set) var trailingSize: QFloat {
        set(value) { self._layout.trailingSize = value }
        get { return self._layout.trailingSize }
    }
    public var trailingLimit: QFloat
    public var animationVelocity: QFloat
    public var color: QColor? {
        get { return self._view.color }
    }
    public var cornerRadius: QViewCornerRadius {
        get { return self._view.cornerRadius }
    }
    public var border: QViewBorder {
        get { return self._view.border }
    }
    public var shadow: QViewShadow? {
        get { return self._view.shadow }
    }
    public var alpha: QFloat {
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: IQCustomView
    #if os(iOS)
    private var _pressedGesture: IQTapGesture
    private var _interactiveGesture: IQPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveBeginState: Layout.State?
    #endif
    private var _onShowLeading: (() -> Void)?
    private var _onHideLeading: (() -> Void)?
    private var _onShowTrailing: (() -> Void)?
    private var _onHideTrailing: (() -> Void)?
    private var _onPressed: (() -> Void)?
    
    public init(
        name: String? = nil,
        shouldPressed: Bool = true,
        contentView: IQView,
        leadingView: IQView? = nil,
        leadingLimit: QFloat = 0,
        leadingSize: QFloat = 0,
        trailingView: IQView? = nil,
        trailingLimit: QFloat = 0,
        trailingSize: QFloat = 0,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        let name = name ?? String(describing: Self.self)
        self.shouldPressed = shouldPressed
        self.contentView = contentView
        self.leadingView = leadingView
        self.leadingLimit = leadingLimit > 0 ? leadingLimit : leadingSize / 2
        self.trailingView = trailingView
        self.trailingLimit = trailingLimit > 0 ? trailingLimit : trailingSize / 2
        #if os(iOS)
        self.animationVelocity = QFloat(UIScreen.main.bounds.width * 2)
        #endif
        self._layout = Layout(
            state: .idle,
            contentItem: QLayoutItem(view: contentView),
            leadingItem: leadingView.flatMap({ QLayoutItem(view: $0) }),
            leadingSize: leadingSize,
            trailingItem: trailingView.flatMap({ QLayoutItem(view: $0) }),
            trailingSize: trailingSize
        )
        #if os(iOS)
        self._pressedGesture = QTapGesture(name: "\(name)-TapGesture")
        self._interactiveGesture = QPanGesture(name: "\(name)-PanGesture")
        self._view = QCustomView(
            name: name,
            gestures: [ self._pressedGesture, self._interactiveGesture ],
            layout: self._layout,
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        #else
        self._view = QCustomView(
            name: name,
            layout: self._layout,
            shouldHighlighting: true,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        #endif
        self._init()
    }
    
    public func size(_ available: QSize) -> QSize {
        return self._view.size(available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    public func showLeadingView(animated: Bool, completion: (() -> Void)?) {
        switch self._layout.state {
        case .idle:
            if animated == true {
                QAnimation.default.run(
                    duration: self._layout.leadingSize / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .leading(progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .leading(progress: 1)
                        self._onShowLeading?()
                        completion?()
                    }
                )
            } else {
                self._layout.state = .leading(progress: 1)
                self._onShowLeading?()
                completion?()
            }
        case .leading:
            self._onShowLeading?()
            completion?()
            break
        case .trailing:
            self.hideTrailingView(animated: animated, completion: { [weak self] in
                self?.showLeadingView(animated: animated, completion: completion)
            })
        }
    }
    
    public func hideLeadingView(animated: Bool, completion: (() -> Void)?) {
        switch self._layout.state {
        case .leading:
            if animated == true {
                QAnimation.default.run(
                    duration: self._layout.leadingSize / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .leading(progress: 1 - progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .idle
                        self._onHideLeading?()
                        completion?()
                    }
                )
            } else {
                self._layout.state = .idle
                self._onHideLeading?()
                completion?()
            }
        default:
            completion?()
            self._onHideLeading?()
            break
        }
    }
    
    public func showTrailingView(animated: Bool, completion: (() -> Void)?) {
        switch self._layout.state {
        case .idle:
            if animated == true {
                QAnimation.default.run(
                    duration: self._layout.trailingSize / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .trailing(progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .trailing(progress: 1)
                        self._onShowTrailing?()
                        completion?()
                    }
                )
            } else {
                self._layout.state = .trailing(progress: 1)
                self._onShowTrailing?()
                completion?()
            }
        case .leading:
            self.hideLeadingView(animated: animated, completion: { [weak self] in
                self?.showTrailingView(animated: animated, completion: completion)
            })
        case .trailing:
            completion?()
            self._onShowTrailing?()
            break
        }
    }
    
    public func hideTrailingView(animated: Bool, completion: (() -> Void)?) {
        switch self._layout.state {
        case .trailing:
            if animated == true {
                QAnimation.default.run(
                    duration: self._layout.trailingSize / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .trailing(progress: 1 - progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .idle
                        self._onHideTrailing?()
                        completion?()
                    }
                )
            } else {
                self._layout.state = .idle
                self._onHideTrailing?()
                completion?()
            }
        default:
            completion?()
            self._onHideTrailing?()
            break
        }
    }
    
    public func triggeredChangeStyle(_ userIteraction: Bool) {
        self._view.triggeredChangeStyle(userIteraction)
    }
    
    @discardableResult
    public func shouldHighlighting(_ value: Bool) -> Self {
        self._view.shouldHighlighting(value)
        return self
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self._view.highlight(value)
        return self
    }
    
    @discardableResult
    public func shouldPressed(_ value: Bool) -> Self {
        self.shouldPressed = value
        return self
    }
    
    @discardableResult
    public func contentView(_ value: IQView) -> Self {
        self.contentView = value
        return self
    }
    
    @discardableResult
    public func leadingView(_ value: IQView?) -> Self {
        self.leadingView = value
        return self
    }
    
    @discardableResult
    public func leadingSize(_ value: QFloat) -> Self {
        self.leadingSize = value
        return self
    }
    
    @discardableResult
    public func leadingLimit(_ value: QFloat) -> Self {
        self.leadingLimit = value
        return self
    }
    
    @discardableResult
    public func trailingView(_ value: IQView?) -> Self {
        self.trailingView = value
        return self
    }
    
    @discardableResult
    public func trailingSize(_ value: QFloat) -> Self {
        self.trailingSize = value
        return self
    }
    
    @discardableResult
    public func trailingLimit(_ value: QFloat) -> Self {
        self.trailingLimit = value
        return self
    }
    
    @discardableResult
    public func animationVelocity(_ value: QFloat) -> Self {
        self.animationVelocity = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self._view.color(value)
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self._view.border(value)
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self._view.cornerRadius(value)
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self._view.shadow(value)
        return self
    }
    
    @discardableResult
    public func alpha(_ value: QFloat) -> Self {
        self._view.alpha(value)
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._view.onAppear(value)
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._view.onDisappear(value)
        return self
    }
    
    @discardableResult
    public func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self {
        self._view.onChangeStyle(value)
        return self
    }
    
    @discardableResult
    public func onShowLeading(_ value: (() -> Void)?) -> Self {
        self._onShowLeading = value
        return self
    }
    
    @discardableResult
    public func onHideLeading(_ value: (() -> Void)?) -> Self {
        self._onHideLeading = value
        return self
    }
    
    @discardableResult
    public func onShowTrailing(_ value: (() -> Void)?) -> Self {
        self._onShowTrailing = value
        return self
    }
    
    @discardableResult
    public func onHideTrailing(_ value: (() -> Void)?) -> Self {
        self._onHideTrailing = value
        return self
    }
    
    @discardableResult
    public func onPressed(_ value: (() -> Void)?) -> Self {
        self._onPressed = value
        return self
    }
    
}

private extension QSwipeCellView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var state: State {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var leadingItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var leadingSize: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var trailingItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var trailingSize: QFloat {
            didSet { self.setNeedUpdate() }
        }

        init(
            state: State,
            contentItem: QLayoutItem,
            leadingItem: QLayoutItem?,
            leadingSize: QFloat,
            trailingItem: QLayoutItem?,
            trailingSize: QFloat
        ) {
            self.state = state
            self.contentItem = contentItem
            self.leadingItem = leadingItem
            self.leadingSize = leadingSize
            self.trailingItem = trailingItem
            self.trailingSize = trailingSize
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            switch self.state {
            case .idle:
                self.contentItem.frame = bounds
            case .leading(let progress):
                if let leadingItem = self.leadingItem {
                    let contentBeginFrame = bounds
                    let contentEndedFrame = QRect(
                        x: bounds.origin.x + self.leadingSize,
                        y: bounds.origin.y,
                        width: bounds.size.width,
                        height: bounds.size.height
                    )
                    let leadingBeginFrame = QRect(
                        x: bounds.origin.x - self.leadingSize,
                        y: bounds.origin.y,
                        width: self.leadingSize,
                        height: bounds.size.height
                    )
                    let leadingEndedFrame = QRect(
                        x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: self.leadingSize,
                        height: bounds.size.height
                    )
                    self.contentItem.frame = contentBeginFrame.lerp(contentEndedFrame, progress: progress)
                    leadingItem.frame = leadingBeginFrame.lerp(leadingEndedFrame, progress: progress)
                } else {
                    self.contentItem.frame = bounds
                }
            case .trailing(let progress):
                if let trailingItem = self.trailingItem {
                    let contentBeginFrame = bounds
                    let contentEndedFrame = QRect(
                        x: bounds.origin.x - self.trailingSize,
                        y: bounds.origin.y,
                        width: bounds.size.width,
                        height: bounds.size.height
                    )
                    let trailingBeginFrame = QRect(
                        x: bounds.origin.x + bounds.size.width,
                        y: bounds.origin.y,
                        width: self.trailingSize,
                        height: bounds.size.height
                    )
                    let trailingEndedFrame = QRect(
                        x: (bounds.origin.x + bounds.size.width) - self.trailingSize,
                        y: bounds.origin.y,
                        width: self.trailingSize,
                        height: bounds.size.height
                    )
                    self.contentItem.frame = contentBeginFrame.lerp(contentEndedFrame, progress: progress)
                    trailingItem.frame = trailingBeginFrame.lerp(trailingEndedFrame, progress: progress)
                } else {
                    self.contentItem.frame = bounds
                }
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available)
            switch self.state {
            case .idle: break
            case .leading:
                guard let leadingItem = self.leadingItem else { break }
                let leadingSize = leadingItem.size(QSize(width: self.leadingSize, height: contentSize.height))
                return QSize(width: available.width, height: max(contentSize.height, leadingSize.height))
            case .trailing:
                guard let trailingItem = self.trailingItem else { break }
                let trailingSize = trailingItem.size(QSize(width: self.trailingSize, height: contentSize.height))
                return QSize(width: available.width, height: max(contentSize.height, trailingSize.height))
            }
            return QSize(width: available.width, height: contentSize.height)
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = [ self.contentItem ]
            switch self.state {
            case .leading where self.leadingItem != nil:
                items.insert(self.leadingItem!, at: 0)
            case .trailing where self.trailingItem != nil:
                items.insert(self.trailingItem!, at: 0)
            default:
                break
            }
            return items
        }
        
    }
    
}

private extension QSwipeCellView.Layout {
    
    enum State {
        case idle
        case leading(progress: QFloat)
        case trailing(progress: QFloat)
    }
    
}

private extension QSwipeCellView {
    
    func _init() {
        #if os(iOS)
        self._pressedGesture.onShouldBegin({ [unowned self] in
            guard self.shouldPressed == true else { return false }
            guard self._pressedGesture.contains(in: self.contentView) == true else { return false }
            return true
        }).onTriggered({ [unowned self] in
            self._pressed()
        })
        self._interactiveGesture.onShouldBegin({ [unowned self] in
            guard self.leadingView != nil || self.trailingView != nil else { return false }
            let translation = self._interactiveGesture.translation(in: self.contentView)
            guard abs(translation.x) >= abs(translation.y) else { return false }
            return true
        }).onBegin({ [unowned self] in
            self._beginInteractiveGesture()
        }).onChange({ [unowned self] in
            self._changeInteractiveGesture()
        }).onCancel({ [unowned self] in
            self._endInteractiveGesture(true)
        }).onEnd({ [unowned self] in
            self._endInteractiveGesture(false)
        })
        #endif
    }
    
    #if os(iOS)
    
    func _pressed() {
        switch self._layout.state {
        case .idle: self._onPressed?()
        case .leading: self.hideLeadingView(animated: true, completion: nil)
        case .trailing: self.hideTrailingView(animated: true, completion: nil)
        }
    }
    
    func _beginInteractiveGesture() {
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self)
        self._interactiveBeginState = self._layout.state
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let beginState = self._interactiveBeginState else { return }
        let currentLocation = self._interactiveGesture.location(in: self)
        let deltaLocation = currentLocation - beginLocation
        switch beginState {
        case .idle:
            if deltaLocation.x > 0 && self.leadingView != nil {
                let delta = min(deltaLocation.x, self.leadingSize)
                let progress = delta / self.leadingSize
                self._layout.state = .leading(progress: progress)
            } else if deltaLocation.x < 0 && self.trailingView != nil {
                let delta = min(-deltaLocation.x, self.trailingSize)
                let progress = delta / self.trailingSize
                self._layout.state = .trailing(progress: progress)
            } else {
                self._layout.state = beginState
            }
        case .leading:
            if deltaLocation.x < 0 {
                let delta = min(-deltaLocation.x, self.leadingSize)
                let progress = delta / self.leadingSize
                self._layout.state = .leading(progress: 1 - progress)
            } else {
                self._layout.state = beginState
            }
        case .trailing:
            if deltaLocation.x > 0 {
                let delta = min(deltaLocation.x, self.trailingSize)
                let progress = delta / self.trailingSize
                self._layout.state = .trailing(progress: 1 - progress)
            } else {
                self._layout.state = beginState
            }
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let beginState = self._interactiveBeginState else { return }
        let currentLocation = self._interactiveGesture.location(in: self)
        let deltaLocation = currentLocation - beginLocation
        switch beginState {
        case .idle:
            if deltaLocation.x > 0 && self.leadingView != nil {
                let delta = min(deltaLocation.x, self.leadingSize)
                if delta >= self.leadingLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self.leadingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1)
                            self._resetInteractiveAnimation()
                            self._onShowLeading?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self.leadingSize / self.animationVelocity,
                        elapsed: (self.leadingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else if deltaLocation.x < 0 && self.trailingView != nil {
                let delta = min(-deltaLocation.x, self.trailingSize)
                if delta >= self.trailingLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self.trailingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1)
                            self._resetInteractiveAnimation()
                            self._onShowTrailing?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self.trailingSize / self.animationVelocity,
                        elapsed: (self.trailingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else {
                self._layout.state = beginState
                self._resetInteractiveAnimation()
            }
        case .leading:
            if deltaLocation.x < 0 {
                let delta = min(-deltaLocation.x, self.leadingSize)
                if delta >= self.leadingLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self.leadingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            self._resetInteractiveAnimation()
                            self._onHideLeading?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self.leadingSize / self.animationVelocity,
                        elapsed: (self.leadingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1)
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else {
                self._layout.state = beginState
                self._resetInteractiveAnimation()
            }
        case .trailing:
            if deltaLocation.x > 0 && self.trailingView != nil {
                let delta = min(deltaLocation.x, self.trailingSize)
                if delta >= self.trailingLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self.trailingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            self._resetInteractiveAnimation()
                            self._onHideTrailing?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self.trailingSize / self.animationVelocity,
                        elapsed: (self.trailingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1)
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else {
                self._layout.state = beginState
                self._resetInteractiveAnimation()
            }
        }
    }

    func _resetInteractiveAnimation() {
        self._interactiveBeginState = nil
        self._interactiveBeginLocation = nil
    }
    
    #endif
    
}