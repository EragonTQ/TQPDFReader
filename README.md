###更新  0.0.7 添加事件外部回调，方便外部埋点上报



# TQPDFReader  一个私有库，用于打开pdf 文件
## 支持网络文件和本地文件



# pod lib lint xxx.podSpec

## 对第三方头文件的引用，必须用引号，而不能用<> 
## 
## 校验失败，可以采用 pod lib lint xxx.podSpec --verbose 获取错误详情

本地依赖
 #pod 'PDFReader', :path => './PDFReader'


# pod repo push TQRepo TQPDFReader.podSpec 
### 会对podSpec 里面的source 指定的源代码文件进行编译校验，如果采用的是：git 的是对远程仓库里面的校验
### 如果采用的是：path  是对本地的校验，注意区分，否则本地修改再多的发现都对校验结果没有影响的
### 校验通过后，cocopods 会将xxx.podSpec 文件在本地的仓库TQRepo 里面创建对应的版本号文件夹，并将TQPDFReader.podSpec 复制进去；最后会推送到TQRepo对应的远程仓库里面
