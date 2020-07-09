//
//  SVGElement.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

open class SVGElement: SVGElementCodable {
    open var elementName: String
    open var value: String?
    open var attributes: [String: String] = [:]
    open var children: [SVGElement] = []
    
    public weak var parent: SVGElement?
    
    public init() {
        elementName = "SVGElement"
        value = nil
    }
    
    required public init(from decoderData: SVGDecoderData) {
        elementName = decoderData.elementName
        value = decoderData.value
        attributes = decoderData.attributes
    }
    
    var root: SVG {
        var current: SVGElement? = self
        while current?.parent != nil {
            current = current?.parent
        }
        
        guard let svg = current as? SVG else {
            assertionFailure("Root element of the SVG tree must of class typ SVG")
            return .empty
        }
        
        return svg
    }
}

public class SVG: SVGElement {
    public static var empty: SVG { SVG() }

    public lazy var definitions: Definitions? = {
        return children.first(where: { $0.elementName == "defs" }) as? Definitions
    }()
}

public class Group: SVGElement { }

public class Path: SVGElement { }

public class Text: SVGElement { }

public class ClipPath: SVGElement { }

public class LinearGradient: SVGElement { }

public class Stop: SVGElement { }

public class Definitions: SVGElement {
    private lazy var definitions: [String: SVGElement] = {
        var items: [String: SVGElement] = [:]

        let idKey = "id"
        for child in children {
            guard let id = child.attributes[idKey] else {
                continue
            }
            items[id] = child
        }
        return items
    }()

    public func elementForID(_ id: String) -> SVGElement? {
        return definitions[id]
    }
}
