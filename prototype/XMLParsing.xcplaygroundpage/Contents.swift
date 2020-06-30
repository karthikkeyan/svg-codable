//: [Previous](@previous)

import Foundation

class ParserDelegate: NSObject, XMLParserDelegate {
    
    var foundCharacters: String? = nil
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let attributes = attributeDict.reduce("") {
            $0 + ($0.isEmpty ? "" :  ", ") + $1.key + "=" + $1.value
        }
        print("\n\(elementName)\(attributes.isEmpty ? "" : ": ")\(attributes)")
        
        foundCharacters = nil
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let foundCharacters = foundCharacters {
            let trimmed = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                print(trimmed)
            }
            print(elementName, "\n")
        }

        foundCharacters = nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if foundCharacters == nil {
            foundCharacters = ""
        }

        foundCharacters?.append(string)
    }
}

let delegate = ParserDelegate()
let url = Bundle.main.url(forResource: "image", withExtension: "svg")!
let parser = XMLParser(contentsOf: url)
parser?.delegate = delegate
parser?.parse()
