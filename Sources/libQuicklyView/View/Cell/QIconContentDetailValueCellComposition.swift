//
//  libQuicklyView
//

import Foundation

public struct QIconContentDetailValueCellComposition< BackgroundView: IQView, IconView: IQView, ContentView: IQView, DetailView: IQView, ValueView: IQView > : IQCellComposition {
    
    public private(set) var backgroundView: BackgroundView?
    public var iconInset: QInset {
        set(value) {
            self._layout.iconInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.iconInset }
    }
    public private(set) var iconView: IconView
    public var contentInset: QInset {
        set(value) {
            self._layout.contentInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.contentInset }
    }
    public private(set) var contentView: ContentView
    public var detailInset: QInset {
        set(value) {
            self._layout.detailInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.detailInset }
    }
    public private(set) var detailView: DetailView
    public var valueInset: QInset {
        set(value) {
            self._layout.valueInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.valueInset }
    }
    public private(set) var valueView: ValueView
    public var layout: IQDynamicLayout {
        return self._layout
    }
    public var isOpaque: Bool {
        return self.backgroundView == nil
    }
    
    private var _layout: Layout
    
    public init(
        backgroundView: BackgroundView? = nil,
        iconInset: QInset,
        iconView: IconView,
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
        detailView: DetailView,
        valueInset: QInset,
        valueView: ValueView
    ) {
        self.backgroundView = backgroundView
        self.iconView = iconView
        self.contentView = contentView
        self.detailView = detailView
        self.valueView = valueView
        self._layout = Layout(
            backgroundItem: backgroundView.flatMap({ QLayoutItem(view: $0) }),
            iconInset: iconInset,
            iconItem: QLayoutItem(view: iconView),
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView),
            detailInset: contentInset,
            detailItem: QLayoutItem(view: detailView),
            valueInset: iconInset,
            valueItem: QLayoutItem(view: valueView)
        )
    }
    
}

extension QIconContentDetailValueCellComposition {
    
    class Layout : IQDynamicLayout {
        
        var delegate: IQLayoutDelegate?
        var parentView: IQView?
        var backgroundItem: IQLayoutItem?
        var iconInset: QInset
        var iconItem: IQLayoutItem
        var contentInset: QInset
        var contentItem: IQLayoutItem
        var detailInset: QInset
        var detailItem: IQLayoutItem
        var valueInset: QInset
        var valueItem: IQLayoutItem
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let item = self.backgroundItem {
                items.append(item)
            }
            items.append(contentsOf: [
                self.iconItem,
                self.contentItem,
                self.detailItem,
                self.valueItem
            ])
            return items
        }
        var size: QSize

        init(
            backgroundItem: IQLayoutItem?,
            iconInset: QInset,
            iconItem: IQLayoutItem,
            contentInset: QInset,
            contentItem: IQLayoutItem,
            detailInset: QInset,
            detailItem: IQLayoutItem,
            valueInset: QInset,
            valueItem: IQLayoutItem
        ) {
            self.backgroundItem = backgroundItem
            self.iconInset = iconInset
            self.iconItem = iconItem
            self.contentInset = contentInset
            self.contentItem = contentItem
            self.detailInset = detailInset
            self.detailItem = detailItem
            self.valueInset = valueInset
            self.valueItem = valueItem
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                if let item = self.backgroundItem {
                    item.frame = bounds
                }
                let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
                let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
                let iconContentValue = bounds.split(
                    left: self.iconInset.left + iconSize.width + self.iconInset.right,
                    right: self.valueInset.left + valueSize.width + self.valueInset.right
                )
                let contentSize = self.contentItem.size(iconContentValue.middle.size.apply(inset: self.contentInset))
                let contentDetail = iconContentValue.middle.split(
                    top: self.contentInset.top + contentSize.height + self.contentInset.bottom
                )
                self.iconItem.frame = iconContentValue.left.apply(inset: self.iconInset)
                self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
                self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
                self.valueItem.frame = iconContentValue.right.apply(inset: self.valueInset)
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            let iconSize = self.iconItem.size(available.apply(inset: self.iconInset))
            let iconBounds = iconSize.apply(inset: -self.iconInset)
            let valueSize = self.iconItem.size(available.apply(inset: self.valueInset))
            let valueBounds = valueSize.apply(inset: -self.valueInset)
            let contentAvailable = QSize(
                width: available.width - (iconBounds.width + valueBounds.width),
                height: available.height
            )
            let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
            let detailBounds = detailSize.apply(inset: -self.detailInset)
            return QSize(
                width: iconBounds.width + max(contentBounds.width, detailBounds.width) + valueBounds.width,
                height: max(iconBounds.height, contentBounds.height + detailBounds.height, valueBounds.height)
            )
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
        func insert(item: IQLayoutItem, at index: UInt) {
        }
        
        func delete(item: IQLayoutItem) {
        }
        
    }
    
}
