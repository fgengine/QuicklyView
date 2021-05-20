//
//  libQuicklyView
//

#if os(OSX)

import AppKit

public typealias QNativeView = NSView

public extension NSView {
    
    func isChild(of view: NSView, recursive: Bool) -> Bool {
        for subview in self.subviews {
            if subview === view {
                return true
            } else if recursive == true {
                if subview.isChild(of: view, recursive: recursive) == true {
                    return true
                }
            }
            
        }
        return false
    }

}

#endif
