//
//  YamlParser.swift
//  Rain
//
//  Created by rainedAllNight on 2020/9/29.
//

import Foundation
import Yams

public struct Configuration: Codable {
    public var name: String?
    
    public var jsonPath: String?
    
    public var project: String?
}

public extension Configuration {
     static func load() -> Configuration? {
        guard let data = FileManager.default.contents(atPath: yamlPath),
              let yaml = String(data: data, encoding: .utf8) else {return nil}
        do {
            let configuration = try YAMLDecoder().decode(self, from: yaml)
            return configuration
        } catch {
            return nil
        }
    }
}

extension Configuration {
    static func generateYaml() {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: yamlPath) else {return}
        let defaultYaml = """
                          # name: the model&file name
                          # jsonPath: default is source.json in the workspace
                          # project: default is the workspace path named "Rain"

                          name: RainTestModel
                          """
        fileManager.createFile(atPath: yamlPath, contents: defaultYaml.data(using: .utf8))
    }
    
    static var yamlPath: String {
        return "\(RainKit.getWorkspacePath().0)/rain.yaml"
    }
}
