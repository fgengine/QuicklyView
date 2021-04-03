//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QTextView {
    
    final class TextView : UILabel {
        
        override var frame: CGRect {
            didSet(oldValue) {
                guard let view = self._view, self.frame != oldValue else { return }
                self.update(cornerRadius: view.cornerRadius)
                self.updateShadowPath()
            }
        }
        override var debugDescription: String {
            guard let view = self._view else { return super.debugDescription }
            return view.debugDescription
        }
        
        private unowned var _view: QTextView?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
        
}

extension QTextView.TextView {
    
    func update(view: QTextView) {
        self._view = view
        self.update(text: view.text)
        self.update(textFont: view.textFont)
        self.update(textColor: view.textColor)
        self.update(alignment: view.alignment)
        self.update(lineBreak: view.lineBreak)
        self.update(numberOfLines: view.numberOfLines)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(text: String) {
        self.text = text
    }
    
    func update(textFont: QFont) {
        self.font = textFont.native
    }
    
    func update(textColor: QColor) {
        self.textColor = textColor.native
    }
    
    func update(alignment: QTextAlignment) {
        self.textAlignment = alignment.nsTextAlignment
    }
    
    func update(lineBreak: QTextLineBreak) {
        self.lineBreakMode = lineBreak.nsLineBreakMode
    }
    
    func update(numberOfLines: UInt) {
        self.numberOfLines = Int(numberOfLines)
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

extension QTextView.TextView : IQReusable {
    
    typealias Owner = QTextView
    typealias Content = QTextView.TextView

    static var reuseIdentificator: String {
        return "QTextView"
    }
    
    static func createReuse(owner: Owner) -> Content {
        return Content(frame: CGRect.zero)
    }
    
    static func configureReuse(owner: Owner, content: Content) {
        content.update(view: owner)
    }
    
    static func cleanupReuse(owner: Owner, content: Content) {
        content.cleanup()
    }
    
}

#endif
