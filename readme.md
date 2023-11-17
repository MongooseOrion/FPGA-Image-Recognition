[*click here to translate in English*]()

# 基于 FPGA 的图像内目标识别系统

该项目是一个利用 FPGA 采集图像，然后将图像传输到电脑执行目标检测任务的系统。该系统采用 YoloV3 模型，利用 Keras-TensorFlow 运行，能够实现对 30 多个种类的物体进行准确识别的功能。数据处理任务需要在电脑端运行。为实现数据的稳恒传输，该系统利用 UDP 网络协议由 RJ45 网络接口将数据从板上路由至电脑端，并通过 OpenCV 和其他 Python 库实现图像数据解码。

系统的一般工作方式如下：首先，系统通过摄像头捕获实时图像，并将图像数据处理为 RGB565 和（或）YUV422 通用图像编码格式。接下来，经过硬逻辑模块的处理，通过 DDR 和 FIFO 等跨时钟缓存存储硬件，将图像数据传输给 HDMI 处理模块和 UDP 发送编码模块。然后，系统可将摄像头采集的图像通过 HDMI 显示在兼容的显示屏上，其中图像参数为 $1280 \times 720,\\ 60FPS$。同时，另一路图像数据通过 UDP 发送模块编码后传输给电脑，并通过电脑执行目标检测任务。

## 运行环境

  * Pango Design Suite Lite 2022.2
  * PGL50H-6FBG484 芯片部件编号
  * 开发平台：MES50HP

## 存储库结构

```
  |-- dataset                   // 数据集处理相关文件
  |-- document                  // 开发文档
    |-- constraint.md           // 硬件约束参考
  |-- FPGA                      // FPGA 工程文件，例如约束文件和比特流文件
  |-- RTL                       // RTL 代码
  |-- software                  // 相关程序代码
```

## 硬件侧
### 系统框图

该项目的主要硬件模块包括：摄像头模块（OV5640）、高速存取模块（DDR3）、显示模块（HDMI）和以太网 UDP 收发模块。

<div align = 'center'><img src = './document\pic\图片1.png' width='600'></div>

该系统包含两个 OV5640 摄像头。其中一个摄像头的配置为 YUV422 格式，流处理格式为 JPEG 2，分辨率为 $1280\times 720$，以 JPEG 2 模式进行配置能够生成具有固定数据长度的帧信息；另一个摄像头的配置为 RGB565 格式，流处理格式为视频流，分辨率为 $1280\times 720$。

YUV422 格式的视频信号在传输过程中，数据通过 UDP 模块拆分为元数据，以便通过网络接口传输到连接的 PC 端。PC 端接收到数据后，可以进行进一步的处理和分析。

另一路视频信号配置为 RGB565 格式，将 8 位的数据拼接为 16 位的 RGB565 数据，然后通过 DDR 缓存。最后，通过 HDMI 接口将存储在 DDR 缓存中的视频数据发送到连接的显示屏上进行实时显示。

## 软件侧
### 深度学习模型介绍

该项目采用的目标检测模型为 Yolov3。有关模型的更多细节，可访问作者存储库[在 Tensorflow2 上使用 yolov3 进行目标检测](https://github.com/MongooseOrion/tf2-keras-yolo3)了解，在本仓库中不再重新添加相关模型文件。

### 电脑端 UDP 接收程序设计

若要正常执行目标检测，你首先需要在 Windows 设置中将目标设备的 IP 地址修改为 `192.168.0.3`。

JPEG 的起始标识符应该是 $\\xff\\xd8\\xff\\xe0$。使用 find() 方法可查找起始标识符在 received_data 中的位置。如果找到了起始标识符，则继续检查结束标识符。

JPEG 的结束标识符应该是 $\\xff\\xd9$。使用 find() 方法可在 received_data 中查找结束标识符的位置。如果找到了结束标识符，则截取图像数据，将其存储在 image_data 中，然后调用 cv2 模块拼合图像。

## 训练数据集

该项目的目标数据集内包括有 1000 个训练视频及其对应的按帧记录的 JSON 标注文件。

<div align = 'center'><img src = './document\pic\屏幕截图 2023-08-03 162036.png' height='600'></div>

处理过程如下述所示：
  1. 为了能够使用 yolov3 模型训练，必须按照图片和对应 txt 文件的方式对数据集进行处理，于是调用 `opencv` 将所有视频切成单帧；
  2. 将标注文件（格式为 json）的 bbox 和目标种类信息按照：`path/to/img xmin,ymin,xmax,ymax,category_name0 xmin,ymin,xmax,ymax,category_name1 ...` 的格式以追加模式写入标注文件 `train.txt` 中；
  3. 将 `category_name` 保存在 `classes.txt` 中；
  4. 交叉比对，删去不含 bbox 信息的帧，也即没有被 json 文件记录的帧，经过比对，大约有 300 个视频或 20 万帧没有 bbox 信息；
  5. 由于原始 json 标注文件对于目标种类的索引都是从 0 开始，这也就是第二步中没有直接按索引号标识 `category_name` 的原因，在此步骤中将 `train.txt` 中每行的 `category_name` 按照 `classes.txt` 中的顺序替换为索引号；
  6. 打乱排序，准备训练。

有关处理数据集的源代码，请[点此](https://github.com/MongooseOrion/FPGA-Image-Recognition/blob/master/dataset/process.py)查看。

## 识别效果
为保证截图效果，设置了中断，因此程序状态显示为 “未响应”。

<div align = 'center'><img src = './document\pic\图片2.png' height='300'></div>
