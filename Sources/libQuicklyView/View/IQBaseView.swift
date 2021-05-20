//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBaseView : AnyObject {
    
    var name: String { get }
    var native: QNativeView { get }
    var isLoaded: Bool { get }
    var bounds: QRect { get }
    
    func size(_ available: QSize) -> QSize
    
    func disappear()
    
    func isChild(of view: IQView, recursive: Bool) -> Bool
    
    @discardableResult
    func onAppear(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onDisappear(_ value: (() -> Void)?) -> Self
    
}

public extension IQBaseView {
    
    var debugDescription: String {
        return "\(self.name)"
    }
    
    func isChild(of view: IQView, recursive: Bool) -> Bool {
        return self.native.isChild(of: view.native, recursive: recursive)
    }
    
}
