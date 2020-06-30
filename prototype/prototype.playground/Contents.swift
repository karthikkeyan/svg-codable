//: [Previous](@previous)

import Foundation

struct Stack {
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

public enum SVGDecodingError: Error {
    case decodeFailed
    case invalidElement
    case invalidDocument
}

class SVGParser: XMLParser {
    var decodingError: SVGDecodingError?
    
    override var parserError: Error? {
        if let error = super.parserError {
            return error
        }
        
        if let error = decodingError {
            return error
        }
        
        return nil
    }
}

public class SVGDecoder: NSObject, XMLParserDelegate {
    private lazy var iterationStack = Stack()
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
    
    public func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        guard let element = elementFactory.elementForTagName(elementName) else {
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
        element.attributes = attributeDict
        iterationStack.push(element)
        
        if isDebugMode {
            let attributes = attributeDict.reduce("") {
                $0 + ($0.isEmpty ? "" :  " ") + $1.key + "=" + $1.value
            }
            print("\n<\(elementName)\(attributes.isEmpty ? "" : " ")\(attributes)>")
        }
        
        foundCharacters = nil
    }
    
    public func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
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
    
    public func parser(_ parser: XMLParser,
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

let decoder = SVGDecoder()
// decoder.isDebugMode = true
let url = Bundle.main.url(forResource: "image", withExtension: "svg")!
let data = try! Data(contentsOf: url)

do {
    let svg = try decoder.decode(data: data)
    
    let encoder = SVGEncoder()
    print(encoder.encode(svg))
} catch {
    print(error)
}
