#if canImport(Glibc)
	import Glibc
#else
	import Darwin.C
#endif

let cwd = getcwd(nil, Int(PATH_MAX))
defer { free(cwd) }
let workingDirectory = String(validatingUTF8: cwd!)!
let values = [workingDirectory] + Array(CommandLine.arguments.dropFirst())
print(values.map({ "\"\($0)\"" }).joined(separator: " "))