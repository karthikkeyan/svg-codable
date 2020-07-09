//
//  SVGParser.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

public enum SVGDecodingError: Error {
    case decodeFailed
    case invalidElement
    case invalidDocument
}

public class SVGParser: XMLParser {
    public var decodingError: SVGDecodingError?
    
    public override var parserError: Error? {
        if let error = super.parserError {
            return error
        }
        
        if let error = decodingError {
            return error
        }
        
        return nil
    }
}
