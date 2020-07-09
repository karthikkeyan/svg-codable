//
//  SVGElementFactory.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

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
    
    public func elementForData(_ decoderData: SVGDecoderData) -> SVGElement? {
        guard let tag = Tag(rawValue: decoderData.elementName) else {
            return nil
        }
        
        switch tag {
            case .svg:
                return SVG(from: decoderData)
            case .group:
                return Group(from: decoderData)
            case .path:
                return Path(from: decoderData)
            case .text:
                return Text(from: decoderData)
            case .definitions:
                return Definitions(from: decoderData)
            case .clipPath:
                return ClipPath(from: decoderData)
            case .linearGradient:
                return LinearGradient(from: decoderData)
            case .stop:
                return Stop(from: decoderData)
        }
    }
}
