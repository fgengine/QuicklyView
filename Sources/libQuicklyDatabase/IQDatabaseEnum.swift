//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public protocol IQDatabaseEnum {
    
    associatedtype RealValue
    
    var realValue: Self.RealValue { get }
    
    init(realValue: Self.RealValue)
    
}
