[*click here to translate in English*]()

# 基于 FPGA 的图像识别系统

该项目旨在利用 FPGA 构建一个能够识别图像中的物体名称的系统。

## 运行环境

  * Pango Design Suite Lite 2022.2
  * PGL50H-6FBG484 芯片部件编号
  * 开发平台：MES50HP

## 仓库结构

```
  |-- dataset                   // 数据集
  |-- document                  // 开发文档
    |-- connect_relate.md       // 自定义模块连接关系说明
    |-- constraint.md           // 硬件约束参考
  |-- FPGA                      // FPGA 工程文件，例如约束文件
  |-- RTL                       // RTL 代码
  |-- software                  // 软件侧相关程序代码
```

## 硬件侧

在该项目中，我们采用广受好评的开源处理器架构 RISC-V 作为中央处理核心。具体而言，该项目采用一个[无剑 100]() 处理器核心，挂载的模块包括：
  * DDR3
  * HDMI
  * 照相机 OV5640

## 软件侧

我们采用 YOLOv3 进行自定义训练，并转译为 TensorFlow-Lite 架构以便在微处理器上运行。