import CommandLineKit
import PathKit
import Rainbow
import RainKit
import Foundation

/// 创建命令行
let cli = CommandLineKit.CommandLine()
/// 目标路径
let projectOption = StringOption(shortFlag: "p", longFlag: "project", helpMessage: "path to the project(目标路径)")
/// json 文件路径
let jsonPathOption = StringOption(shortFlag: "j", longFlag: "jsonPath", helpMessage: "the json file path to decode(json文件路径)")

/// 要生成的文件名&类名
public let fileNameOption = StringOption(shortFlag: "n", longFlag: "name", helpMessage: "the name of the decode model(要生成的文件名&类名)")

//// 文件扩展名
//let fileExtensionsOption = StringOption(shortFlag: "f",
//                                                 longFlag: "file-extensions",
//                                                 helpMessage: "file Extensions to decode, default is swift")
let originalNamingOption = BoolOption(shortFlag: "o", longFlag: "original-naming", helpMessage: " use the original json naming (是否使用原始的命名方式，默认使用转化成驼峰)")

let workspace = BoolOption(shortFlag: "w", longFlag: "workspace", helpMessage: "init json template file and the workspace of rain(初始化rain的Workspace)")

// 帮助
let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")
// 添加命令行参数
cli.addOptions([projectOption, fileNameOption, jsonPathOption, originalNamingOption, help, workspace])
cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error:
        str = s.red.bold
    case .optionFlag:
        str = s.green.underline
    case .optionHelp:
        str = s.blue
    default:
        str = s
    }
    return cli.defaultFormat(s: str, type: type)
}

// 解析输入的命令行
do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

// 如果有用户输入了help, 打印所有设定的参数
if help.value {
    cli.printUsage()
    exit(EX_OK)
}

if workspace.value {
    RainKit.initWorkspace()
    exit(EX_OK)
}

var workspaceJSONPath: String?
var workspaceProjectPath: String?
let paths = RainKit.getWorkspacePath()
if RainKit.isExistWorkspace(paths) {
    workspaceProjectPath = paths.0
    workspaceJSONPath = paths.1
}

let yamlConfi = Configuration.load()
// 目标路径
let project = projectOption.value ?? yamlConfi?.project ?? workspaceProjectPath ?? "."
guard let jsonPath = jsonPathOption.value ?? yamlConfi?.jsonPath ?? workspaceJSONPath else {
    print("json文件路径不能为空".red)
    exit(EX_NOINPUT)
}
guard let name = fileNameOption.value ?? yamlConfi?.name, !name.isEmpty else {
    print("model名称不能为空".red)
    exit(EX_NOINPUT)
}

// 文件扩展名
//let fileExtension = fileExtensionsOption.value ?? "swift"
let fileExtension = "swift"

let modelPath = project + "/\(name).\(fileExtension)"
let mode: ActionMode = jsonPath == workspaceJSONPath ? .workspace : .commandLine
var rainKit = RainKit(name: name, jsonFilePath: jsonPath, modelFilePath: modelPath, camelCased: !originalNamingOption.value, actionMode: mode)
rainKit.run()
print(">>>> ✨✨ Model Generate Success ✨✨ <<<<<".green)



