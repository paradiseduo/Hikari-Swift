// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -typecheck -enable-library-evolution -target %target-cpu-apple-macosx12.0 -emit-module-interface-path %t/Library.swiftinterface -module-name Library %s

// REQUIRES: concurrency
// REQUIRES: OS=macosx

@available(macOS 11.0, *)
@_nonSendable
public struct X { }

@_nonSendable
public struct Y { }

@available(macOS 11.0, *)
extension X {
  @available(macOS 12.0, *)
  @_nonSendable
  public struct A { }

  @_nonSendable
  public struct B { }
}

// RUN: %FileCheck %s <%t/Library.swiftinterface
// CHECK: @available(macOS 11.0, *)
// CHECK-NEXT: public struct X

// CHECK: @available(macOS, unavailable, introduced: 11.0)
// CHECK-NEXT: @available(*, unavailable)
// CHECK-NEXT: extension Library.X{{( )?}}: @unchecked Swift.Sendable {

// CHECK: @available(*, unavailable)
// CHECK-NEXT: extension Library.Y{{( )?}}: @unchecked Swift.Sendable {

// CHECK: @available(macOS, unavailable, introduced: 12.0)
// CHECK-NEXT: @available(*, unavailable)
// CHECK-NEXT: extension Library.X.A{{( )?}}: @unchecked Swift.Sendable {

// CHECK: @available(macOS, unavailable, introduced: 11.0)
// CHECK-NEXT: @available(*, unavailable)
// CHECK-NEXT: extension Library.X.B{{( )?}}: @unchecked Swift.Sendable {

// RUN: %target-swift-frontend -typecheck -enable-library-evolution -target %target-cpu-apple-macosx12.0 -emit-module-interface-path %t/Library.swiftinterface -DLIBRARY -module-name Library %s -module-interface-preserve-types-as-written
// RUN: %FileCheck %s <%t/Library.swiftinterface
