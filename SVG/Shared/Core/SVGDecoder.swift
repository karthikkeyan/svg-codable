//
//  SVGDecoder.swift
//  SVGCodable
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import Foundation

public class SVGDecoder: NSObject, XMLParserDelegate {
    private lazy var iterationStack = SVGElementStack()
    private lazy var elementFactory = SVGElementFactory()
    private lazy var root: SVG = .empty
    private var foundCharacters: String?
    private var parser: SVGParser?

    public var isDebugMode: Bool = false

    public func decode(data: Data) throws -> SVG {
        iterationStack.clear()
        foundCharacters = nil
        root = .empty

        parser = SVGParser(data: data)
        parser?.delegate = self

        guard let isParsed = parser?.parse(), isParsed else {
            throw parser?.parserError ?? SVGDecodingError.decodeFailed
        }

        return root
    }

    public func parser(_: XMLParser,
                       didStartElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?,
                       attributes attributeDict: [String: String] = [:]) {
        let decoderData = SVGDecoderData(elementName: elementName,
                                         namespaceURI: namespaceURI,
                                         qualifiedName: qName,
                                         value: nil,
                                         attributes: attributeDict)
        guard let element = elementFactory.elementForData(decoderData) else {
            throwError(.invalidElement)
            return
        }

        if let svg = element as? SVG {
            if iterationStack.isEmpty {
                root = svg
            } else {
                throwError(.invalidDocument)
                return
            }
        }

        let parent = iterationStack.peek()
        parent?.children.append(element)

        element.parent = parent
        iterationStack.push(element)

        if isDebugMode {
            let attributes = attributeDict.reduce("") {
                $0 + ($0.isEmpty ? "" : " ") + $1.key + "=" + $1.value
            }
            print("\n<\(elementName)\(attributes.isEmpty ? "" : " ")\(attributes)>")
        }

        foundCharacters = nil
    }

    public func parser(_: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI _: String?,
                       qualifiedName _: String?) {
        let trimmed = foundCharacters?.trimmingCharacters(in: .whitespacesAndNewlines)
        iterationStack.pop()?.value = trimmed

        foundCharacters = nil

        if isDebugMode {
            if let _trimmed = trimmed, !_trimmed.isEmpty {
                print(_trimmed)
            }
            print("</" + elementName + ">", "\n")
        }
    }

    public func parser(_: XMLParser,
                       foundCharacters string: String) {
        if foundCharacters == nil {
            foundCharacters = ""
        }

        foundCharacters?.append(string)
    }

    private func throwError(_ error: SVGDecodingError) {
        parser?.decodingError = error
        parser?.abortParsing()
    }
}

private struct SVGElementStack {
    private var storage: [SVGElement] = []

    var isEmpty: Bool {
        return storage.isEmpty
    }

    var count: Int {
        return storage.count
    }

    mutating func push(_ element: SVGElement) {
        storage.append(element)
    }

    @discardableResult
    mutating func pop() -> SVGElement? {
        return storage.removeLast()
    }

    func peek() -> SVGElement? {
        return storage.last
    }

    mutating func clear() {
        storage = []
    }
}
