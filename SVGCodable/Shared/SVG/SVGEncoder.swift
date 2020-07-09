//
//  SVGEncoder.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

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
