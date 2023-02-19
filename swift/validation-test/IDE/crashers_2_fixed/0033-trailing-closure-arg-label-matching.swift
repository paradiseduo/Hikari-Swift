// RUN: %swift-ide-test -code-completion -source-filename %s -code-completion-token COMPLETE | %FileCheck %s

func foo() {
  _ = sink { items in }#^COMPLETE^#
}

func sink(receiveCompletion: (Int) -> Void, receiveValue: (Int) -> Void) { fatalError() }

// CHECK: Begin completions, 1 items
// CHECK-DAG: Pattern/Local/Flair[ArgLabels]:     {#receiveValue: (Int) -> Void {<#Int#> in|}#}[#(Int) -> Void#];
// CHECK: End completions
