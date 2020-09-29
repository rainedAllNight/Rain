# Rain

# What 

Rain is a simple command-line util to auto generate codable model  from json(一个根据json自动生成codable model的命令行工具)

--Write with Swift

# Install

```
> git clone https://github.com/rainedAllNight/Rain.git
> cd Rain
> ./install
```
You need  enter the password when prompted(get the permissions to add ruby file to **/usr/local/**)

# Usage

## Run with  "Workspace"

### Init workspace
Just navigate to your project folder, then:

```
> rain -w
```

It will init workspace of the rain, and there will be an additional directory named "Rain" for your project

You will see these files later

* source.json:  The json that you want to decode
* rain.yaml: the configuration file of the command unit (use command-line arguments first)
* xxx.swift: the  result model

### Usage

**Next time you just need to modify the source.json file and the rain.yaml configuration**

then navigate to your project folder, then: 

```
> rain
```
or 

```
> rain -n UserModel
```
**if you use command-line arguments, it will ignores the configuration with the same name in the workspace**

## Run with command line

Rain supports some arguments. You can find it by:

```
> rain --help

  -p, --project:
      path to the project(目标路径)
  -n, --name:
      the name of the decode model(要生成的文件名&类名)
  -j, --jsonPath:
      the json file path to decode(json文件路径)
  -o, --original-naming:
       use the original json naming (是否使用原始的命名方式，默认使用转化成驼峰)
  -h, --help:
      Prints a help message.
  -w, --workspace:
      init json template file and the workspace of rain(初始化rain的Workspace)

```

# Tips

You can create a custom Xcode behavious to open terminal quickly,  I've provided a shell script named "run_rain.sh",  you can use it to rain quickly.

please provide executable permissions for  "run_rain.sh" 

```
> chmod +x run_rain.sh

```




