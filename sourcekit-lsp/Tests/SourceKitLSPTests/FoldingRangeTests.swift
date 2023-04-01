//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import LanguageServerProtocol
import SKTestSupport
import XCTest

final class FoldingRangeTests: XCTestCase {

  typealias FoldingRangeCapabilities = TextDocumentClientCapabilities.FoldingRange

  func initializeWorkspace(withCapabilities capabilities: FoldingRangeCapabilities, testLoc: String) throws -> (SKTibsTestWorkspace, DocumentURI)? {
    var documentCapabilities = TextDocumentClientCapabilities()
    documentCapabilities.foldingRange = capabilities
    let capabilities = ClientCapabilities(workspace: nil, textDocument: documentCapabilities)
    guard let ws = try staticSourceKitTibsWorkspace(name: "FoldingRange",
                                                    clientCapabilities: capabilities) else { return nil }
    let loc = ws.testLoc(testLoc)
    try ws.openDocument(loc.url, language: .swift)
    return (ws, DocumentURI(loc.url))
  }

  func testPartialLineFolding() throws {
    var capabilities = FoldingRangeCapabilities()
    capabilities.lineFoldingOnly = false

    guard let (ws, uri) = try initializeWorkspace(withCapabilities: capabilities, testLoc: "fr:base") else { return }

    let request = FoldingRangeRequest(textDocument: TextDocumentIdentifier(uri))
    let ranges = try withExtendedLifetime(ws) { try ws.sk.sendSync(request) }

    XCTAssertEqual(ranges, [
      FoldingRange(startLine: 0, startUTF16Index: 0, endLine: 1, endUTF16Index: 18, kind: .comment),
      FoldingRange(startLine: 3, startUTF16Index: 0, endLine: 13, endUTF16Index: 2, kind: .comment),
      FoldingRange(startLine: 14, startUTF16Index: 10, endLine: 27, endUTF16Index: 0, kind: nil),
      FoldingRange(startLine: 15, startUTF16Index: 2, endLine: 17, endUTF16Index: 2, kind: .comment),
      FoldingRange(startLine: 17, startUTF16Index: 2, endLine: 19, endUTF16Index: 4, kind: .comment),
      FoldingRange(startLine: 22, startUTF16Index: 21, endLine: 25, endUTF16Index: 2, kind: nil),
      FoldingRange(startLine: 23, startUTF16Index: 23, endLine: 23, endUTF16Index: 30, kind: nil),
      FoldingRange(startLine: 26, startUTF16Index: 2, endLine: 26, endUTF16Index: 10, kind: .comment),
      FoldingRange(startLine: 29, startUTF16Index: 0, endLine: 31, endUTF16Index: 2, kind: .comment),
      FoldingRange(startLine: 33, startUTF16Index: 0, endLine: 35, endUTF16Index: 2, kind: .comment),
      FoldingRange(startLine: 37, startUTF16Index: 0, endLine: 37, endUTF16Index: 32, kind: .comment),
      FoldingRange(startLine: 39, startUTF16Index: 0, endLine: 39, endUTF16Index: 11, kind: .comment),
    ])
  }

  func testLineFoldingOnly() throws {
    var capabilities = FoldingRangeCapabilities()
    capabilities.lineFoldingOnly = true

    guard let (ws, uri) = try initializeWorkspace(withCapabilities: capabilities, testLoc: "fr:base") else { return }

    let request = FoldingRangeRequest(textDocument: TextDocumentIdentifier(uri))
    let ranges = try withExtendedLifetime(ws) { try ws.sk.sendSync(request) }

    XCTAssertEqual(ranges, [
      FoldingRange(startLine: 0, endLine: 1, kind: .comment),
      FoldingRange(startLine: 3, endLine: 13, kind: .comment),
      FoldingRange(startLine: 14, endLine: 27, kind: nil),
      FoldingRange(startLine: 15, endLine: 17, kind: .comment),
      FoldingRange(startLine: 17, endLine: 19, kind: .comment),
      FoldingRange(startLine: 22, endLine: 25, kind: nil),
      FoldingRange(startLine: 29, endLine: 31, kind: .comment),
      FoldingRange(startLine: 33, endLine: 35, kind: .comment),
    ])
  }

  func testRangeLimit() throws {

    func performTest(withRangeLimit limit: Int?, expecting expectedRanges: Int, line: Int = #line) throws {
      var capabilities = FoldingRangeCapabilities()
      capabilities.lineFoldingOnly = false
      capabilities.rangeLimit = limit
      guard let (ws, url) = try initializeWorkspace(withCapabilities: capabilities, testLoc: "fr:base") else { return }
      let request = FoldingRangeRequest(textDocument: TextDocumentIdentifier(url))
      let ranges = try withExtendedLifetime(ws) { try ws.sk.sendSync(request) }
      XCTAssertEqual(ranges?.count, expectedRanges, "Failed rangeLimit test at line \(line)")
    }

    try performTest(withRangeLimit: -100, expecting: 0)
    try performTest(withRangeLimit: 0, expecting: 0)
    try performTest(withRangeLimit: 4, expecting: 4)
    try performTest(withRangeLimit: 5000, expecting: 12)
    try performTest(withRangeLimit: nil, expecting: 12)
  }

  func testNoRanges() throws {
    let capabilities = FoldingRangeCapabilities()

    guard let (ws, url) = try initializeWorkspace(withCapabilities: capabilities, testLoc: "fr:empty") else { return }

    let request = FoldingRangeRequest(textDocument: TextDocumentIdentifier(url))
    let ranges = try withExtendedLifetime(ws) { try ws.sk.sendSync(request) }

    XCTAssertEqual(ranges?.count, 0)
  }

  func testDontReportDuplicateRangesRanges() throws {
    // In this file the range of the call to `print` and the range of the argument "/*fr:duplicateRanges*/" are the same.
    // Test that we only report the folding range once.
    let capabilities = FoldingRangeCapabilities()

    guard let (ws, url) = try initializeWorkspace(withCapabilities: capabilities, testLoc: "fr:duplicateRanges") else { return }

    let request = FoldingRangeRequest(textDocument: TextDocumentIdentifier(url))
    let ranges = try withExtendedLifetime(ws) { try ws.sk.sendSync(request) }

    let expected = [
      FoldingRange(startLine: 0, startUTF16Index: 12, endLine: 2, endUTF16Index: 0, kind: nil),
      FoldingRange(startLine: 1, startUTF16Index: 10, endLine: 1, endUTF16Index: 34, kind: nil),
    ]

    XCTAssertEqual(ranges, expected)
  }
}