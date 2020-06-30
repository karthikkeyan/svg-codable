import Foundation

public protocol SVGElement {
    func applyAttributes(_ attributes: [String: String])
}

public struct SVG: SVGElement {
    func applyAttributes(_ attributes: [String: String]) {
        
    }
}

public struct SVGElementFactory {
    public func elementForTagName(_ name: String) {
        print(name)
    }
}
