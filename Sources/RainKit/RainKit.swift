//
//  File.swift
//  
//
//  Created by rainedAllNight on 2020/9/24.
//

import Foundation
import PathKit
import Rainbow

public enum ActionMode {
    case workspace
    case commandLine
}

public struct RainKit {
    /// 文件名
    public var name: String
    /// json file path
    public var jsonFilePath: String
    /// model file path, like ./Test.swift
    public var modelFilePath: String
    /// use camel-cased naming
    public var camelCased: Bool
    ///存储子model信息
    private var subModelDic = [String: Any]()
    ///存储codingKey的映射关系
    private var codingKeysMapping = [String: String]()
    private var codingDefines = ""
    private var actionMode: ActionMode
    
    // MARK: - Public
    
    public init(name: String,
                jsonFilePath: String,
                modelFilePath: String,
                camelCased: Bool,
                actionMode: ActionMode) {
        self.name = name
        self.jsonFilePath = jsonFilePath
        self.modelFilePath = modelFilePath
        self.camelCased = camelCased
        self.actionMode = actionMode
    }
    
    public mutating func run() {
        let swift = self.getDefine()
        let paths = RainKit.getWorkspacePath()
        let isExistWorkspace = RainKit.isExistWorkspace(paths)
        let useWorkspace = isExistWorkspace && actionMode == .workspace
        ///删除上一次生成的model.swift
        if useWorkspace {
            guard let children = try? Path(paths.0).children() else {return}
            children.forEach({
                if $0.extension == "swift" {
                    try? $0.delete()
                }
            })
        }
        FileManager.default.createFile(atPath: modelFilePath, contents: swift.data(using: .utf8))
        /// 将生成的文件加入到工程项目中
        if isExistWorkspace {
            RainKit.addWorkspaceToProject(paths.1,
                                          modelPath: modelFilePath,
                                          yamlPath: Configuration.yamlPath)
        }
    }
    
    // MARK: - Get code string
    
    /// json to dictionary
    /// - Returns: dictionary
    func getDictionaryValue() -> [String: Any]? {
        guard let json = try? Path(jsonFilePath).read(.utf8), !json.isEmpty, let data = json.data(using: .utf8) else {
            print("json数据错误")
            exit(EX_DATAERR)
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        } catch {
            print(json)
            print("json转换失败: \(error.localizedDescription)")
            exit(EX_DATAERR)
        }
    }
    
    /// 获取属性类型
    /// - Parameters:
    ///   - key: 对应的key
    ///   - value: 对应的value
    /// - Returns: 属性类型
    mutating func getPropertyType(_ key: String, value: Any) -> String? {
        if value is Int {
            return "Int"
        } else if value is Double {
            return "Double"
        } else if value is String {
            return "String"
        } else if value is [String] {
            return "[String]"
        } else if value is [Int] {
            return "[Int]"
        } else if value is [Double] {
            return "[Double]"
        } else if value is [String: Any] {
            subModelDic[key] = value
            return key.headUppercased
        } else if value is [Any] {
            subModelDic[key] = value
            return "[\(key.headUppercased)]"
        } else {
            return nil
        }
    }

    /// 获取属性定义
    /// - Parameter dic: 对应的dic
    /// - Returns:
    mutating func getPropertyDefine(_ dic: [String: Any]?) -> String {
        var propertyList = ""
        dic?.forEach({ (key, value) in
            let camelCaseKey = camelCased ? key.camelCase() : key
            guard let type = getPropertyType(camelCaseKey, value: value) else {return}
            propertyList += "   var \(camelCaseKey): \(type)\n"
            codingKeysMapping[key] = camelCaseKey
        })
        propertyList.removeLast()
        return propertyList
    }
    
    /// 获取嵌套结构的子model定义
    /// - Returns:
    mutating func getSubModelDefines() -> String {
        var subModel = ""
        let keys = subModelDic.keys
        subModelDic.forEach { (key, value) in
            ///字典
            if let dic = value as? [String: Any] {
                subModel += getStruct(key.headUppercased, dic: dic)
            } else if let array = value as? [[String: Any]] {
               ///数组
                subModel += getStruct(key.headUppercased, dic: array.first)
            }
        }
        keys.forEach({subModelDic.removeValue(forKey: $0)})
        return subModel
    }

    /// 获取单个struct
    /// - Parameters:
    ///   - structName: struct name
    ///   - property: 所有属性的定义
    /// - Returns:
    mutating func getStruct(_ structName: String, dic: [String: Any]?) -> String {
        let property = getPropertyDefine(dic)
        let `struct` = """
        struct \(structName) {
        \(property)
        }
        \n
        """
        let codabe = getCodabeDefine(structName, map: codingKeysMapping)
        codingKeysMapping.removeAll()
        codingDefines += codabe
        return `struct`
    }
    
    /// 获取整个model file 定义
    /// - Returns:
    mutating func getDefine() -> String {
        var main = "import Foundation\n\n" + getStruct(name, dic: getDictionaryValue())
        while !subModelDic.isEmpty {
            main += getSubModelDefines()
        }
        return main + codingDefines
    }
}

fileprivate extension RainKit {
    func getCodabeDefine(_ struct: String, map: [String: String]) -> String {
        return """
        extension \(`struct`): Codable {
            private enum CodingKeys: String, CodingKey {
        \(getCodingKeysMapping(map))
            }
        }
        \n
        """
    }
    
    private func getCodingKeysMapping(_ map: [String: String]) -> String {
        var mapping = map.reduce("") { (result, map) -> String in
            return result + """
                    case \(map.value) = "\(map.key)"\n
            """
        }
        mapping.removeLast()
        return mapping
    }
}

fileprivate extension String {
    func camelCase(with separator: Character = "_") -> String {
        let strings = self.split(separator: separator)
        return strings.reduce("") { (result, sub) -> String in
            if result.isEmpty {
                return String(sub)
            } else {
                return result + sub.capitalized
            }
        }
    }
    
    var headUppercased: String {
        guard !isEmpty else {return ""}
        let range = ...startIndex
        return replacingCharacters(in: range, with: self.first!.uppercased())
    }
}

public extension RainKit {
    static func initWorkspace() {
        let paths = getWorkspacePath()
        let folder = Path(paths.0)
        let json = paths.1
        if isExistWorkspace(paths) {
            try? folder.delete()
        }
        do {
            try folder.mkdir()
            let templateJSON = """
                                {
                                    "name": "rain",
                                    "version": "1.0",
                                    "authorAge": 6
                                }
                               """
            FileManager.default.createFile(atPath: json, contents: templateJSON.data(using: .utf8))
            addGitignore()
            Configuration.generateYaml()
            RainProcess.shell("rain", "-n", "RainTestModel")
            print(">>>> Init Workspace Success <<<<".green)

        } catch {
            print("初始化工作区失败\(error.localizedDescription)".red)
            exit(EX__BASE)
        }
    }
    
    static func getWorkspacePath() -> (String, String) {
        let currentPath = Path.current
        let folder = currentPath.string + "/Rain"
        let json = "\(folder)/source.json"
        return (folder, json)
    }
    
    static func isExistWorkspace(_ paths: (String, String)) -> Bool {
        return Path(paths.0).exists
    }
    
    static func addWorkspaceToProject(_ jsonPath: String,
                                      modelPath: String,
                                      yamlPath: String) {
        let project = getProjectPath()
        RainProcess.shell("ruby", "/usr/local/rain/add_file.rb", project.string, jsonPath, modelPath, yamlPath)
    }
    
    private static func getProjectPath() -> Path {
        let currentPath = Path.current
        guard let children = try? currentPath.children() else {
            print("路径下无内容，请检查路径是否正确".red)
            exit(EX__BASE)
        }
        var project: Path?
        if let xcodeproj = children.first(where: {$0.extension == "xcodeproj"}) {
            project = xcodeproj
        }
        guard let p = project, p.exists else {
            print("项目路径下无工程项目，请检查路径是否正确".red)
            exit(EX__BASE)
        }
        
        return p
    }
    
    private static func addGitignore() {
        let gitignorePath = "\(Path.current.string)/.gitignore"
        guard Path(gitignorePath).exists else {return}
        let gitignore = "Rain/"
        let gitignores = try? Path(gitignorePath).read(.utf8)
        guard let ignores = gitignores, !ignores.contains(gitignore) else {return}
        let fileHandle = FileHandle.init(forWritingAtPath: gitignorePath)
        fileHandle?.seekToEndOfFile()
        guard let data = "Rain/".data(using: .utf8) else {return}
        fileHandle?.write(data)
        fileHandle?.closeFile()
    }
}
