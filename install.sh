#!/bin/sh
swift package clean
swift build -c release
addFilePath="/usr/local/rain"
if [[ ! -x "$addFilePath" ]]; then
    sudo mkdir $addFilePath
    sudo chmod -R 777 $addFilePath
    cp ./add_file.rb $addFilePath
    chmod +x "${addFilePath}/add_file.rb"
fi

cp .build/release/Rain /usr/local/bin/rain



