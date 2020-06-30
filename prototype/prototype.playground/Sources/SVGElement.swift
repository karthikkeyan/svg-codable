import Foundation

public protocol SVGDecodable {
    var elementName: String { get }
    var attributes: [String: String] { get set }
    var value: String? { get set }
    var children: [SVGElement] { get set }
    var parent: SVGElement? { get set }
}

public extension SVGEncodable where Self: Group {
    var elementName: String { "g" }
}

public struct SVGEncoder {
    public var depth = 0
    
    public init() { }
    
    public func encode(_ element: SVGEncodable) -> String {
        return element.encode(self)
    }
    
    public var childrenEncoder: SVGEncoder {
        var encoder = self
        encoder.depth += 1
        return encoder
    }
}

public protocol SVGEncodable {
    func encode(_ encoder: SVGEncoder) -> String
}

public extension SVGEncodable where Self: SVGDecodable {
    func encode(_ encoder: SVGEncoder) -> String {
        let tabs = Array(repeating: "\t", count: encoder.depth).joined()
        let encodedAttributes = self.encodedAttributes
        var desc = parent == nil ? "" : "\n"
        
        desc += tabs + "<\(elementName)" + (encodedAttributes.isEmpty ? "" : " ") + encodedAttributes
        
        if children.isEmpty && value == nil {
            desc += "/>"
            return desc
        }
        
        desc += ">"

        if let value = value, !value.isEmpty {
            desc += "\n" + tabs + value
        }
        
        if !children.isEmpty {
            var encodedChildren = ""
            children.enumerated().forEach  {
                encodedChildren += $0.element.encode(encoder.childrenEncoder)
            }
            
            desc += encodedChildren
        }
        
        desc += "\n" + tabs + "</\(elementName)>"
        
        return desc
    }
    
    internal var encodedAttributes: String {
        return attributes.reduce("") {
            $0 + ($0.isEmpty ? "" :  " ") + $1.key + "=\"" + $1.value + "\""
        }
    }
}

public typealias SVGCodable = SVGEncodable & SVGDecodable

open class SVGElement: SVGCodable {
    open var attributes: [String: String] = [:]
    open var value: String?
    open var children: [SVGElement] = []
    
    public weak var parent: SVGElement?
    
    public var elementName: String { "element" }
    
    public init() { }
}

public class SVG: SVGElement {
    public static var empty: SVG {
        return SVG()
    }
    
    public override var elementName: String { "svg" }
    
    public override init() {
        super.init()
    }
}

public class Group: SVGElement {
    public override var elementName: String { "g" }
}

public class Path: SVGElement {
    public override var elementName: String { "path" }
}

public class Text: SVGElement {
    public override var elementName: String { "text" }
}

public class Definitions: SVGElement {
    public override var elementName: String { "defs" }
}

public class ClipPath: SVGElement {
    public override var elementName: String { "clipPath" }
}

public class LinearGradient: SVGElement {
    public override var elementName: String { "linearGradient" }
}

public class Stop: SVGElement {
    public override var elementName: String { "stop" }
}

public struct SVGElementFactory {
    enum Tag: String {
        case svg
        case group = "g"
        case path
        case text
        case definitions = "defs"
        case clipPath
        case linearGradient
        case stop
    }
    
    public init() { }
    
    public func elementForTagName(_ name: String) -> SVGElement? {
        guard let tag = Tag(rawValue: name) else {
            return nil
        }
        
        switch tag {
            case .svg:
                return SVG()
            case .group:
                return Group()
            case .path:
                return Path()
            case .text:
                return Text()
            case .definitions:
                return Definitions()
            case .clipPath:
                return ClipPath()
            case .linearGradient:
                return LinearGradient()
            case .stop:
                return Stop()
        }
    }
}
