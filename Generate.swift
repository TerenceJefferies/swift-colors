import Foundation

struct RGB {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
}

func getDefinitions() throws -> [String: [String: String]] {
    let contents = try String(contentsOfFile: "definitions.json")
    let data = contents.data(using: .utf8)

    return try JSONDecoder().decode([String: [String: String]].self, from: data!)
}

func getRgb(hex: String) -> RGB {
    let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)

    if hexString.hasPrefix("#") {
        scanner.currentIndex = hex.index(after: hexString.startIndex)
    }

    var color: UInt64 = 0
    scanner.scanHexInt64(&color)

    let mask = 0x000000FF
    let redFull = Int(color >> 16) & mask
    let greenFull = Int(color >> 8) & mask
    let blueFull = Int(color) & mask

    let red   = CGFloat(redFull) / 255
    let green = CGFloat(greenFull) / 255
    let blue  = CGFloat(blueFull) / 255

    return RGB(red: red, green: green, blue: blue)
}

func makeCodeLines() -> [String] {
    var codeLines: [String] = []
    codeLines.append("// This file is auto-generated. Do not edit directly")
    codeLines.append("")
    codeLines.append("import Foundation")
    codeLines.append("import SwiftUI")
    codeLines.append("")
    codeLines.append("@available(iOS 13.0, watchOS 6.0, macOS 10.15, tvOS 13.0, *)")
    codeLines.append("public extension Color {")
    return codeLines
}

func makeDocLines() -> [String] {
    var docLines: [String] = []
    docLines.append("|Name|Color|")
    docLines.append("|---|---|")
    return docLines
}

func makeColorDeclarationLine(name: String, variant: String, rgb: RGB) -> String {
    var line = "    static var "
    line += name + variant + " = Color(red: "
    line += String(describing: rgb.red) + ", green: "
    line += String(describing: rgb.green) + ", blue: "
    line += String(describing: rgb.blue)
    line += ")"
    return line
}

func makeDocLine(name: String, variant: String, hex: String) -> String {
    return "|" + name + variant + "|" + "![a](https://via.placeholder.com/25/" +
    hex.replacingOccurrences(of: "#", with: "") + "/000000?text=+)" + "|"
}

var codeLines = makeCodeLines()
var docLines = makeDocLines()
let definitions = try getDefinitions()

for (colorName, variants) in definitions {
    for (variant, hex) in variants {
        let rgb = getRgb(hex: hex)
        codeLines.append(makeColorDeclarationLine(name: colorName, variant: variant, rgb: rgb))
        docLines.append(makeDocLine(name: colorName, variant: variant, hex: hex))
    }
}

codeLines.append("}")
codeLines.append("")

let code = codeLines.joined(separator: "\n")
try code.write(to:
                        URL(fileURLWithPath: "./Sources/Colors/Colors.swift"),
                       atomically: true,
                       encoding: String.Encoding.utf8
)

let template = try String(contentsOfFile: "template.md")
let table = docLines.joined(separator: "\n")
let docTable = template.replacingOccurrences(of: "[!]", with: table)
try docTable.write(to:
                        URL(fileURLWithPath: "./README.md"),
                       atomically: true,
                       encoding: String.Encoding.utf8
)
