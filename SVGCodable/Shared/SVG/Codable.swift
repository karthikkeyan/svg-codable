//
//  Codable.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

public typealias SVGElementCodable = SVGEncodable & SVGDecodable

// MARK: - SVGDecodable

public struct SVGDecoderData {
    public let elementName: String
    public let namespaceURI: String?
    public let qualifiedName: String?
    public let value: String?
    public let attributes: [String: String]
}

public protocol SVGDecodable {
    init(from decoderData: SVGDecoderData)
}

// MARK: - SVGEncodable

public protocol SVGEncodable {
    func encode(_ encoder: SVGEncoder) -> String
}

public extension SVGEncodable where Self: SVGElement {
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
