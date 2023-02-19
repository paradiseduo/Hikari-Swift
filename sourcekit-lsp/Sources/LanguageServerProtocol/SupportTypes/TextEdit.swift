//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// Edit to a text document, replacing the contents of `range` with `text`.
public struct TextEdit: ResponseType, Hashable {

  /// The range of text to be replaced.
  @CustomCodable<PositionRange>
  public var range: Range<Position>

  /// The new text.
  public var newText: String

  public init(range: Range<Position>, newText: String) {
    self._range = CustomCodable<PositionRange>(wrappedValue: range)
    self.newText = newText
  }
}

extension TextEdit: LSPAnyCodable {
  public init?(fromLSPDictionary dictionary: [String : LSPAny]) {
    guard case .dictionary(let rangeDict) = dictionary[CodingKeys.range.stringValue],
          case .string(let newText) = dictionary[CodingKeys.newText.stringValue] else
    {
      return nil
    }
    guard let range = Range<Position>(fromLSPDictionary: rangeDict) else {
      return nil
    }
    self._range = CustomCodable<PositionRange>(wrappedValue: range)
    self.newText = newText
  }

  public func encodeToLSPAny() -> LSPAny {
    return .dictionary([
      CodingKeys.range.stringValue: range.encodeToLSPAny(),
      CodingKeys.newText.stringValue: .string(newText)
    ])
  }
}
