//
//  RainProcess.swift
//  RainKit
//
//  Created by rainedAllNight on 2020/9/27.
//

import Foundation

public struct RainProcess {
    /***
     * 执行shell命令，返回输出结果
     */
    @discardableResult
    public static func shell(_ args: String...) -> String {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: .utf8)!
    //    return (process.terminationStatus, output)
        return output
    }

}
