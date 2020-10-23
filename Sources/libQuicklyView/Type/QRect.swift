//
//  libQuicklyView
//

import Foundation

public struct QRect : Hashable {
    
    public var origin: QPoint
    public var size: QSize
    
    @inlinable
    public init() {
        self.origin = QPoint()
        self.size = QSize()
    }
    
    @inlinable
    public init(
        x: QFloat,
        y: QFloat,
        width: QFloat,
        height: QFloat
    ) {
        self.origin = QPoint(x: x, y: y)
        self.size = QSize(width: width, height: height)
    }
    
    @inlinable
    public init(
        topLeft: QPoint,
        size: QSize
    ) {
        self.origin = topLeft
        self.size = size
    }
    
    @inlinable
    public init(
        top: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: top.x - (size.width / 2),
            y: top.y
        )
        self.size = size
    }
    
    @inlinable
    public init(
        topRight: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: topRight.x - size.width,
            y: topRight.y
        )
        self.size = size
    }
    
    @inlinable
    public init(
        left: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: left.x,
            y: left.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        center: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: center.x - (size.width / 2),
            y: center.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        right: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: right.x - size.width,
            y: right.y - (size.height / 2)
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottomLeft: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - size.height
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottom: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottom.x - (size.width / 2),
            y: bottom.y - size.height
        )
        self.size = size
    }
    
    @inlinable
    public init(
        bottomRight: QPoint,
        size: QSize
    ) {
        self.origin = QPoint(
            x: bottomRight.x - size.width,
            y: bottomRight.y - size.height
        )
        self.size = size
    }
    
}

public extension QRect {
    
    @inlinable
    var topLeft: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y
        )
    }
    
    
    @inlinable
    var top: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var topRight: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y
        )
    }
    
    
    @inlinable
    var left: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var center: QPoint {
        return QPoint(
            x: self.origin.x + (self.size.width / 2),
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var right: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y + (self.size.height / 2)
        )
    }
    
    
    @inlinable
    var bottomLeft: QPoint {
        return QPoint(
            x: self.origin.x,
            y: self.origin.y + self.size.height
        )
    }
    
    
    @inlinable
    var bottom: QPoint {
        return QPoint(
            x: self.origin.x + (self.size.width / 2),
            y: self.origin.y + self.size.height
        )
    }
    
    @inlinable
    var bottomRight: QPoint {
        return QPoint(
            x: self.origin.x + self.size.width,
            y: self.origin.y + self.size.height
        )
    }
    
}

public extension QRect {
    
    @inlinable
    func isContains(point: QPoint) -> Bool {
        guard self.origin.x <= point.x && self.origin.x + self.size.width >= point.x else { return false }
        guard self.origin.y <= point.y && self.origin.y + self.size.height >= point.y else { return false }
        return true
    }

    @inlinable
    func isContains(rect: QRect) -> Bool {
        guard self.origin.x <= rect.origin.x && self.origin.x + self.size.width >= rect.origin.x + rect.size.width else { return false }
        guard self.origin.y <= rect.origin.y && self.origin.y + self.size.height >= rect.origin.y + rect.size.height else { return false }
        return true
    }

    @inlinable
    func isIntersects(rect: QRect) -> Bool {
        guard self.origin.x <= rect.origin.x + rect.size.width && self.origin.x + self.size.width >= rect.origin.x else { return false }
        guard self.origin.y <= rect.origin.y + rect.size.height && self.origin.y + self.size.height >= rect.origin.y else { return false }
        return true
    }

    @inlinable
    func offset(x: QFloat, y: QFloat) -> QRect {
        return QRect(
            topLeft: self.origin - QPoint(x: x, y: y),
            size: self.size
        )
    }

    @inlinable
    func offset(point: QPoint) -> QRect {
        return QRect(
            topLeft: self.origin - point,
            size: self.size
        )
    }

    @inlinable
    func union(_ to: QRect) -> QRect {
        let minX = min(self.origin.x, to.origin.x)
        let minY = min(self.origin.y, to.origin.y)
        let maxX = max(self.origin.x + self.size.width, to.origin.x + to.size.width)
        let maxY = max(self.origin.y + self.size.height, to.origin.y + to.size.height)
        return QRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    @inlinable
    func lerp(_ to: QRect, progress: QFloat) -> QRect {
        return QRect(
            x: self.origin.x.lerp(to.origin.x, progress: progress),
            y: self.origin.y.lerp(to.origin.y, progress: progress),
            width: self.size.width.lerp(to.size.width, progress: progress),
            height: self.size.height.lerp(to.size.height, progress: progress)
        )
    }
    
    @inlinable
    func apply(inset: QInset) -> QRect {
        let size = self.size.apply(inset: inset)
        return QRect(
            x: self.origin.x + inset.left,
            y: self.origin.y + inset.top,
            width: size.width,
            height: size.height
        )
    }
    
    @inlinable
    func apply(width: QDimensionBehaviour, height: QDimensionBehaviour) -> QRect {
        return QRect(
            center: self.center,
            size: self.size.apply(width: width, height: height)
        )
    }
    
    @inlinable
    func split(left: QFloat) -> (left: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: left,
                height: self.size.height
            ),
            right: QRect(
                x: self.origin.x + left,
                y: self.origin.y,
                width: self.size.width - left,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(right: QFloat) -> (left: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width - right,
                height: self.size.height
            ),
            right: QRect(
                x: (self.origin.x + self.size.width) - right,
                y: self.origin.y,
                width: right,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(left: QFloat, right: QFloat) -> (left: QRect, middle: QRect, right: QRect) {
        return (
            left: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: left,
                height: self.size.height
            ),
            middle: QRect(
                x: self.origin.x + left,
                y: self.origin.y,
                width: self.size.width - (left + right),
                height: self.size.height
            ),
            right: QRect(
                x: (self.origin.x + self.size.width) - right,
                y: self.origin.y,
                width: right,
                height: self.size.height
            )
        )
    }
    
    @inlinable
    func split(top: QFloat) -> (top: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: top
            ),
            bottom: QRect(
                x: self.origin.x,
                y: self.origin.y + top,
                width: self.size.width,
                height: self.size.height - top
            )
        )
    }
    
    @inlinable
    func split(bottom: QFloat) -> (top: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: self.size.height - bottom
            ),
            bottom: QRect(
                x: self.origin.x,
                y: (self.origin.y + self.size.height) - bottom,
                width: self.size.width,
                height: bottom
            )
        )
    }
    
    @inlinable
    func split(top: QFloat, bottom: QFloat) -> (top: QRect, middle: QRect, bottom: QRect) {
        return (
            top: QRect(
                x: self.origin.x,
                y: self.origin.y,
                width: self.size.width,
                height: top
            ),
            middle: QRect(
                x: self.origin.x,
                y: self.origin.y + top,
                width: self.size.width,
                height: self.size.height - (top + bottom)
            ),
            bottom: QRect(
                x: self.origin.x,
                y: (self.origin.y + self.size.height) - bottom,
                width: self.size.width,
                height: bottom
            )
        )
    }
    
    @inlinable
    func aspectFit(size: QSize) -> QRect {
        let iw = floor(size.width)
        let ih = floor(size.height)
        let bw = floor(self.size.width)
        let bh = floor(self.size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw < fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        let rx = (bw - rw) / 2
        let ry = (bh - rh) / 2
        return QRect(
            x: self.origin.x + rx,
            y: self.origin.y + ry,
            width: rw,
            height: rh
        )
    }
    
    @inlinable
    func aspectFill(size: QSize) -> QRect {
        let iw = floor(size.width)
        let ih = floor(size.height)
        let bw = floor(self.size.width)
        let bh = floor(self.size.height)
        let fw = bw / iw
        let fh = bh / ih
        let sc = (fw > fh) ? fw : fh
        let rw = iw * sc
        let rh = ih * sc
        let rx = (bw - rw) / 2
        let ry = (bh - rh) / 2
        return QRect(
            x: self.origin.x + rx,
            y: self.origin.y + ry,
            width: rw,
            height: rh
        )
    }
    
}
