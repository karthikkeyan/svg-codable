//
//  SVG.swift
//  SVGCodable (iOS)
//
//  Created by Karthikkeyan Bala Sundaram on 7/13/20.
//

import Foundation

public class SVG: SVGElement {
    public static var empty: SVG { SVG() }

    public lazy var definitions: Definitions? = {
        children.first(where: { $0.elementName == "defs" }) as? Definitions
    }()
}
