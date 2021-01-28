//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QGradientView {
    
    final class GradientView : UIView {
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        override class var layerClass: AnyClass {
            return CAGradientLayer.self
        }
        
        private unowned var _view: QGradientView?
        private var _layer: CAGradientLayer {
            return super.layer as! CAGradientLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QGradientView.GradientView {
    
    func update(view: QGradientView) {
        self._view = view
        self.update(fill: view.fill)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(fill: QGradientViewFill) {
        switch fill.mode {
        case .axial: self._layer.type = .axial
        case .radial: self._layer.type = .radial
        }
        self._layer.colors = fill.points.compactMap({ return $0.color.cgColor })
        self._layer.locations = fill.points.compactMap({ return NSNumber(value: $0.location) })
        self._layer.startPoint = fill.start.cgPoint
        self._layer.endPoint = fill.end.cgPoint
    }
    
}

extension QGradientView.GradientView : IQReusable {
    
    typealias View = QGradientView
    typealias Item = QGradientView.GradientView

    static var reuseIdentificator: String {
        return "QGradientView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(frame: CGRect.zero)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.update(view: view)
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif