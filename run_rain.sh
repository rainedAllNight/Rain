#!/bin/sh

path=""
if [ -n "$XcodeProjectPath" ]; then
    path=$XcodeProjectPath
else
    path=$XcodeWorkspacePath
fi
# 执行 AppleScript 打开 Terminal 进行 rain
osascript <<EOF
    tell application "Terminal"
        activate
        do script with command "cd \"$path\"/..;rain"
    end tell
EOF









