
require 'xcodeproj'

#打开项目工程A.xcodeproj

project_path = ARGV[0]
jsonPath = ARGV[1]
modelPath = ARGV[2]
yamlPath = ARGV[3]

project = Xcodeproj::Project.open(project_path)

# 1、显示所有的target
project.targets.each do |target|
  puts target.name
end
target = project.targets.first

##找到要插入的group (参数中true表示如果找不到group，就创建一个group)

rainGroup = project.main_group.find_subpath(File.join("Rain"),false)
if !rainGroup.nil? then
    rainGroup.clear()
    rainGroup.remove_from_project
end

newRainGroup = project.main_group.find_subpath(File.join('Rain'), true)
newRainGroup.set_source_tree('SOURCE_ROOT')

#向group中增加文件引用
#'/Users/rainedAllNight/Desktop/RainTest/Rain'

file_ref1 = newRainGroup.new_reference(jsonPath)
file_ref2 = newRainGroup.new_reference(modelPath)
file_ref3 = newRainGroup.new_reference(yamlPath)

ret = target.add_file_references([file_ref1, file_ref2, file_ref3])

project.save

