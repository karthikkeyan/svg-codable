//
//  Service.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Combine
import Foundation

class ImageService: ObservableObject {
    lazy var objectWillChange = PassthroughSubject<Void, Never>()

    var result = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }

    func fetchImage() {
        DispatchQueue.global().async { [weak self] in
            do {
                let url = Bundle.main.url(forResource: "image", withExtension: "svg")!
                let data = try Data(contentsOf: url)

                let decoder = SVGDecoder()
                // decoder.isDebugMode = true
                let svg = try decoder.decode(data: data)

                let encoder = SVGEncoder()
                self?.result = encoder.encode(svg)
            } catch {
                print(error)
            }
        }
    }
}
