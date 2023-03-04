import Foundation
import yyjson

/// AnandaModel can be created from AnandaJSON
public protocol AnandaModel {
    /// AnandaValueExtractor
    static var valueExtractor: AnandaValueExtractor { get }

    init(json: AnandaJSON)
}

extension AnandaModel {
    /// By default use DefaultAnandaValueExtractor as AnandaValueExtractor
    public static var valueExtractor: AnandaValueExtractor {
        DefaultAnandaValueExtractor()
    }

    /// Initialize with `jsonData`
    public init(jsonData: Data) {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
        }

        if let doc {
            self.init(
                json: .init(
                    pointer: yyjson_doc_get_root(doc),
                    valueExtractor: Self.valueExtractor
                )
            )

            yyjson_doc_free(doc)
        } else {
            assertionFailure("Should not be here!")
            self.init(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }

    /// Initialize with `jsonString`, `encoding` default to `.utf8`
    public init(jsonString: String, encoding: String.Encoding = .utf8) {
        if let jsonData = jsonString.data(using: encoding) {
            self.init(jsonData: jsonData)
        } else {
            assertionFailure("Should not be here!")
            self.init(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}
