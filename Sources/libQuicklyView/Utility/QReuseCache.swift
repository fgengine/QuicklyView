//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQReusable {
    
    associatedtype Owner
    associatedtype Content
    
    static var reuseIdentificator: String { get }
    
    static func createReuse(owner: Owner) -> Content
    static func configureReuse(owner: Owner, content: Content)
    static func cleanupReuse(owner: Owner, content: Content)
    
}

public final class QReuseCache {
    
    public static let shared: QReuseCache = QReuseCache()
    
    private var _items: [String : [Any]]
    
    fileprivate init() {
        self._items = [:]
    }
    
    public func set< Reusable: IQReusable >(_ reusable: Reusable.Type, owner: Reusable.Owner, content: Reusable.Content) {
        let identificator = reusable.reuseIdentificator
        if let items = self._items[identificator] {
            self._items[identificator] = items + [ content ]
        } else {
            self._items[identificator] = [ content ]
        }
        reusable.cleanupReuse(owner: owner, content: content)
    }
    
    public func get< Reusable: IQReusable >(_ reusable: Reusable.Type, owner: Reusable.Owner) -> Reusable.Content {
        let identificator = Reusable.reuseIdentificator
        let item: Reusable.Content
        if let items = self._items[identificator] {
            if let lastItem = items.last as? Reusable.Content {
                self._items[identificator] = items.dropLast()
                item = lastItem
            } else {
                item = reusable.createReuse(owner: owner)
            }
        } else {
            item = reusable.createReuse(owner: owner)
        }
        reusable.configureReuse(owner: owner, content: item)
        return item
    }
    
    public func reset(count: UInt? = nil) {
        if let count = count {
            for item in self._items {
                guard item.value.count > count else { continue }
                self._items[item.key] = Array(item.value.prefix(Int(count)))
            }
        } else {
            self._items = [:]
        }
    }
    
}
