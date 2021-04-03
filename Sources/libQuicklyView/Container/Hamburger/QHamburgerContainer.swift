//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QHamburgerContainer : IQHamburgerContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self._contentContainer.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self._contentContainer.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self._contentContainer.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self._contentContainer.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self._contentContainer.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
    }
    public var contentContainer: IQHamburgerContentContainer {
        set(value) {
            guard self._contentContainer !== value else { return }
            if self.isPresented == true {
                self._contentContainer.prepareHide(interactive: false)
                self._contentContainer.finishHide(interactive: false)
            }
            self._contentContainer.parent = nil
            self._contentContainer = value
            self._contentContainer.parent = self
            self._layout.contentItem = QLayoutItem(view: self._contentContainer.view)
            if self.isPresented == true {
                self._contentContainer.prepareShow(interactive: false)
                self._contentContainer.finishShow(interactive: false)
            }
            self.didChangeInsets()
        }
        get { return self._contentContainer }
    }
    public var isShowedLeadingContainer: Bool {
        switch self._layout.state {
        case .leading: return true
        default: return false
        }
    }
    public var leadingContainer: IQHamburgerMenuContainer? {
        set(value) {
            guard self._leadingContainer !== value else { return }
            if let leadingContainer = self._leadingContainer {
                if self.isPresented == true {
                    switch self._layout.state {
                    case .leading:
                        leadingContainer.prepareHide(interactive: false)
                        leadingContainer.finishHide(interactive: false)
                    default:
                        break
                    }
                }
                leadingContainer.parent = nil
            }
            self._leadingContainer = value
            if let leadingContainer = self._leadingContainer {
                leadingContainer.parent = self
                self._layout.leadingItem = QLayoutItem(view: leadingContainer.view)
                self._layout.leadingSize = leadingContainer.hamburgerSize
                if self.isPresented == true {
                    switch self._layout.state {
                    case .leading:
                        leadingContainer.prepareShow(interactive: false)
                        leadingContainer.finishShow(interactive: false)
                    default:
                        break
                    }
                }
            }
            self.didChangeInsets()
        }
        get { return self._leadingContainer }
    }
    public var isShowedTrailingContainer: Bool {
        switch self._layout.state {
        case .trailing: return true
        default: return false
        }
    }
    public var trailingContainer: IQHamburgerMenuContainer? {
        set(value) {
            guard self._trailingContainer !== value else { return }
            if let trailingContainer = self._trailingContainer {
                if self.isPresented == true {
                    switch self._layout.state {
                    case .trailing:
                        trailingContainer.prepareHide(interactive: false)
                        trailingContainer.finishHide(interactive: false)
                    default:
                        break
                    }
                }
                trailingContainer.parent = nil
            }
            self._trailingContainer = value
            if let trailingContainer = self._trailingContainer {
                trailingContainer.parent = self
                self._layout.trailingItem = QLayoutItem(view: trailingContainer.view)
                self._layout.trailingSize = trailingContainer.hamburgerSize
                if self.isPresented == true {
                    switch self._layout.state {
                    case .trailing:
                        trailingContainer.prepareShow(interactive: false)
                        trailingContainer.finishShow(interactive: false)
                    default:
                        break
                    }
                }
            }
            self.didChangeInsets()
        }
        get { return self._trailingContainer }
    }
    public var animationVelocity: QFloat
    
    private var _layout: Layout
    private var _view: QCustomView
    #if os(iOS)
    private var _pressedGesture: IQTapGesture
    private var _interactiveGesture: IQPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveBeginState: Layout.State?
    private var _interactiveLeadingContainer: IQHamburgerMenuContainer?
    private var _interactiveTrailingContainer: IQHamburgerMenuContainer?
    #endif
    private var _contentContainer: IQHamburgerContentContainer
    private var _leadingContainer: IQHamburgerMenuContainer?
    private var _trailingContainer: IQHamburgerMenuContainer?
    
    public init(
        contentContainer: IQHamburgerContentContainer,
        leadingContainer: IQHamburgerMenuContainer? = nil,
        trailingContainer: IQHamburgerMenuContainer? = nil
    ) {
        self.isPresented = false
        #if os(iOS)
        self.animationVelocity = UIScreen.main.animationVelocity
        #endif
        self._layout = Layout(
            state: .idle,
            contentItem: QLayoutItem(view: contentContainer.view),
            leadingItem: leadingContainer.flatMap({ QLayoutItem(view: $0.view) }),
            leadingSize: leadingContainer?.hamburgerSize ?? 0,
            trailingItem: trailingContainer.flatMap({ QLayoutItem(view: $0.view) }),
            trailingSize: trailingContainer?.hamburgerSize ?? 0
        )
        #if os(iOS)
        self._pressedGesture = QTapGesture(name: "QHamburgerContainer-TapGesture")
        self._interactiveGesture = QPanGesture(name: "QHamburgerContainer-PanGesture")
        self._view = QCustomView(
            name: "QHamburgerContainer-RootView",
            gestures: [ self._pressedGesture, self._interactiveGesture ],
            layout: self._layout
        )
        #else
        self._view = QCustomView(
            layout: self._layout
        )
        #endif
        self._contentContainer = contentContainer
        self._leadingContainer = leadingContainer
        self._trailingContainer = trailingContainer
        self._init()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        return self.inheritedInsets
    }
    
    public func didChangeInsets() {
        self._leadingContainer?.didChangeInsets()
        self._contentContainer.didChangeInsets()
        self._trailingContainer?.didChangeInsets()
    }
    
    public func prepareShow(interactive: Bool) {
        self._contentContainer.prepareShow(interactive: interactive)
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.prepareShow(interactive: interactive)
        case .trailing: self._trailingContainer?.prepareShow(interactive: interactive)
        }
    }
    
    public func finishShow(interactive: Bool) {
        self._contentContainer.finishShow(interactive: interactive)
        self.isPresented = true
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.finishShow(interactive: interactive)
        case .trailing: self._trailingContainer?.finishShow(interactive: interactive)
        }
    }
    
    public func cancelShow(interactive: Bool) {
        self._contentContainer.cancelShow(interactive: interactive)
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.cancelShow(interactive: interactive)
        case .trailing: self._trailingContainer?.cancelShow(interactive: interactive)
        }
    }
    
    public func prepareHide(interactive: Bool) {
        self._contentContainer.prepareHide(interactive: interactive)
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.prepareHide(interactive: interactive)
        case .trailing: self._trailingContainer?.prepareHide(interactive: interactive)
        }
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._contentContainer.finishHide(interactive: interactive)
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.finishHide(interactive: interactive)
        case .trailing: self._trailingContainer?.finishHide(interactive: interactive)
        }
    }
    
    public func cancelHide(interactive: Bool) {
        self._contentContainer.cancelHide(interactive: interactive)
        switch self._layout.state {
        case .idle: break
        case .leading: self._leadingContainer?.cancelHide(interactive: interactive)
        case .trailing: self._trailingContainer?.cancelHide(interactive: interactive)
        }
    }
    
    public func showLeadingContainer(animated: Bool, completion: (() -> Void)?) {
        self._showLeadingContainer(interactive: false, animated: animated, completion: completion)
    }
    
    public func hideLeadingContainer(animated: Bool, completion: (() -> Void)?) {
        self._hideLeadingContainer(interactive: false, animated: animated, completion: completion)
    }
    
    public func showTrailingContainer(animated: Bool, completion: (() -> Void)?) {
        self._showTrailingContainer(interactive: false, animated: animated, completion: completion)
    }
    
    public func hideTrailingContainer(animated: Bool, completion: (() -> Void)?) {
        self._hideTrailingContainer(interactive: false, animated: animated, completion: completion)
    }
    
}

extension QHamburgerContainer : IQRootContentContainer {
}

private extension QHamburgerContainer {
    
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
            return available
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

private extension QHamburgerContainer.Layout {
    
    enum State {
        case idle
        case leading(progress: QFloat)
        case trailing(progress: QFloat)
    }
    
}

private extension QHamburgerContainer {
    
    func _init() {
        self._contentContainer.parent = self
        self._leadingContainer?.parent = self
        self._trailingContainer?.parent = self
        #if os(iOS)
        self._pressedGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture -> Bool in
            guard let view = gesture.view else { return false }
            return self._view.native.isChild(of: view, recursive: true)
        }).onShouldBegin({ [unowned self] in
            switch self._layout.state {
            case .idle: return false
            case .leading, .trailing: return self._pressedGesture.contains(in: self._contentContainer.view)
            }
        }).onTriggered({ [unowned self] in
            self._pressed()
        })
        self._interactiveGesture.onShouldBegin({ [unowned self] in
            guard self._leadingContainer != nil || self._trailingContainer != nil else { return false }
            guard self._contentContainer.shouldInteractive == true else { return false }
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
    
    func _showLeadingContainer(interactive: Bool, animated: Bool, completion: (() -> Void)?) {
        guard let leadingContainer = self._leadingContainer else {
            completion?()
            return
        }
        switch self._layout.state {
        case .idle:
            leadingContainer.prepareShow(interactive: interactive)
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
                        leadingContainer.finishShow(interactive: interactive)
                        completion?()
                    }
                )
            } else {
                self._layout.state = .leading(progress: 1)
                leadingContainer.finishShow(interactive: interactive)
                completion?()
            }
        case .leading:
            completion?()
            break
        case .trailing:
            self._hideTrailingContainer(interactive: interactive, animated: animated, completion: { [weak self] in
                self?._showLeadingContainer(interactive: interactive, animated: animated, completion: completion)
            })
        }
    }
    
    func _hideLeadingContainer(interactive: Bool, animated: Bool, completion: (() -> Void)?) {
        guard let leadingContainer = self._leadingContainer else {
            completion?()
            return
        }
        switch self._layout.state {
        case .leading:
            leadingContainer.prepareHide(interactive: interactive)
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
                        leadingContainer.finishHide(interactive: interactive)
                        completion?()
                    }
                )
            } else {
                self._layout.state = .idle
                leadingContainer.finishHide(interactive: interactive)
                completion?()
            }
        default:
            completion?()
            break
        }
    }
    
    func _showTrailingContainer(interactive: Bool, animated: Bool, completion: (() -> Void)?) {
        guard let trailingContainer = self._trailingContainer else {
            completion?()
            return
        }
        switch self._layout.state {
        case .idle:
            trailingContainer.prepareShow(interactive: interactive)
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
                        trailingContainer.finishShow(interactive: interactive)
                        completion?()
                    }
                )
            } else {
                self._layout.state = .trailing(progress: 1)
                trailingContainer.finishShow(interactive: interactive)
                completion?()
            }
        case .leading:
            self._hideLeadingContainer(interactive: interactive, animated: animated, completion: { [weak self] in
                self?._showTrailingContainer(interactive: interactive, animated: animated, completion: completion)
            })
        case .trailing:
            completion?()
            break
        }
    }
    
    func _hideTrailingContainer(interactive: Bool, animated: Bool, completion: (() -> Void)?) {
        guard let trailingContainer = self._trailingContainer else {
            completion?()
            return
        }
        switch self._layout.state {
        case .trailing:
            trailingContainer.prepareHide(interactive: interactive)
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
                        trailingContainer.finishHide(interactive: interactive)
                        completion?()
                    }
                )
            } else {
                self._layout.state = .idle
                trailingContainer.finishHide(interactive: interactive)
                completion?()
            }
        default:
            completion?()
            break
        }
    }
    
}

#if os(iOS)
    
private extension QHamburgerContainer {
    
    func _pressed() {
        switch self._layout.state {
        case .idle: break
        case .leading: self._hideLeadingContainer(interactive: true, animated: true, completion: nil)
        case .trailing: self._hideTrailingContainer(interactive: true, animated: true, completion: nil)
        }
    }
    
    func _beginInteractiveGesture() {
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self.view)
        self._interactiveBeginState = self._layout.state
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let beginState = self._interactiveBeginState else { return }
        let currentLocation = self._interactiveGesture.location(in: self.view)
        let deltaLocation = currentLocation - beginLocation
        switch beginState {
        case .idle:
            if deltaLocation.x > 0 && self._leadingContainer != nil {
                if self._interactiveLeadingContainer == nil {
                    self._leadingContainer!.prepareShow(interactive: true)
                    self._interactiveLeadingContainer = self._leadingContainer
                }
                let delta = min(deltaLocation.x, self._layout.leadingSize)
                let progress = delta / self._layout.leadingSize
                self._layout.state = .leading(progress: progress)
            } else if deltaLocation.x < 0 && self._trailingContainer != nil {
                if self._interactiveTrailingContainer == nil {
                    self._trailingContainer!.prepareShow(interactive: true)
                    self._interactiveTrailingContainer = self._trailingContainer
                }
                let delta = min(-deltaLocation.x, self._layout.trailingSize)
                let progress = delta / self._layout.trailingSize
                self._layout.state = .trailing(progress: progress)
            } else {
                self._layout.state = beginState
            }
        case .leading:
            if deltaLocation.x < 0 {
                if self._interactiveLeadingContainer == nil {
                    self._leadingContainer!.prepareHide(interactive: true)
                    self._interactiveLeadingContainer = self._leadingContainer
                }
                let delta = min(-deltaLocation.x, self._layout.leadingSize)
                let progress = delta / self._layout.leadingSize
                self._layout.state = .leading(progress: 1 - progress)
            } else {
                self._layout.state = beginState
            }
        case .trailing:
            if deltaLocation.x > 0 {
                if self._interactiveTrailingContainer == nil {
                    self._trailingContainer!.prepareHide(interactive: true)
                    self._interactiveTrailingContainer = self._trailingContainer
                }
                let delta = min(deltaLocation.x, self._layout.trailingSize)
                let progress = delta / self._layout.trailingSize
                self._layout.state = .trailing(progress: 1 - progress)
            } else {
                self._layout.state = beginState
            }
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let beginState = self._interactiveBeginState else { return }
        let currentLocation = self._interactiveGesture.location(in: self.view)
        let deltaLocation = currentLocation - beginLocation
        switch beginState {
        case .idle:
            if let leadingContainer = self._interactiveLeadingContainer, deltaLocation.x > 0 {
                let delta = min(deltaLocation.x, self._layout.leadingSize)
                if delta >= leadingContainer.hamburgerLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self._layout.leadingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1)
                            leadingContainer.finishShow(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self._layout.leadingSize / self.animationVelocity,
                        elapsed: (self._layout.leadingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            leadingContainer.cancelShow(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else if let trailingContainer = self._interactiveTrailingContainer, deltaLocation.x < 0 {
                let delta = min(-deltaLocation.x, self._layout.trailingSize)
                if delta >= trailingContainer.hamburgerLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self._layout.trailingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1)
                            trailingContainer.finishShow(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self._layout.trailingSize / self.animationVelocity,
                        elapsed: (self._layout.trailingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            trailingContainer.cancelShow(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else {
                self._layout.state = beginState
                self._resetInteractiveAnimation()
            }
        case .leading:
            if let leadingContainer = self._interactiveLeadingContainer, deltaLocation.x < 0 {
                let delta = min(-deltaLocation.x, self._layout.leadingSize)
                if delta >= leadingContainer.hamburgerLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self._layout.leadingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            leadingContainer.finishHide(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self._layout.leadingSize / self.animationVelocity,
                        elapsed: (self._layout.leadingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .leading(progress: 1)
                            leadingContainer.cancelHide(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                }
            } else {
                self._layout.state = beginState
                self._resetInteractiveAnimation()
            }
        case .trailing:
            if let trailingContainer = self._interactiveTrailingContainer, deltaLocation.x > 0 {
                let delta = min(deltaLocation.x, self._layout.trailingSize)
                if delta >= trailingContainer.hamburgerLimit && canceled == false {
                    QAnimation.default.run(
                        duration: self._layout.trailingSize / self.animationVelocity,
                        elapsed: delta / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1 - progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .idle
                            trailingContainer.finishHide(interactive: true)
                            self._resetInteractiveAnimation()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: self._layout.trailingSize / self.animationVelocity,
                        elapsed: (self._layout.trailingSize - delta) / self.animationVelocity,
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: progress)
                            self._layout.updateIfNeeded()
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self._layout.state = .trailing(progress: 1)
                            trailingContainer.cancelHide(interactive: true)
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
        self._interactiveLeadingContainer = nil
        self._interactiveTrailingContainer = nil
    }
    
}

#endif