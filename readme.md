[*click here to translate in English*]()

# 基于 FPGA 的图像识别系统

该项目是一个基于开源 RISC-V 核心的目标识别系统，利用 Nuclei 提供的开源 RISC-V 核心，从源代码构建而成。该系统采用 TensorFlow Lite 框架，能够实现对 30 多个种类的物体进行准确的识别。

为了确保 TensorFlow Lite 及其检查点文件的正常工作，作者创建了 FreeRTOS 操作系统，并将该框架嵌入到上层操作系统中，以提供完整的功能和稳定性。

系统的一般工作方式如下：首先，系统通过摄像头捕获实时图像，并将图像加载到内存中。接下来，经过处理器的处理，系统会执行目标检测算法，利用先进的机器学习模型对图像中的物体进行识别和分类。最后，系统将处理后的图像通过 HDMI 接口显示在外部显示器上，使用户可以直观地观察到目标物体的识别结果。

## 运行环境

  * Pango Design Suite Lite 2022.2
  * PGL50H-6FBG484 芯片部件编号
  * 开发平台：MES50HP

## 存储库结构

```
  |-- dataset                   // 数据集
  |-- document                  // 开发文档
    |-- constraint.md           // 硬件约束参考
  |-- FPGA                      // FPGA 工程文件，例如约束文件
  |-- RTL                       // RTL 代码
  |-- software                  // 软件侧相关程序代码
```

## 硬件侧

在该项目中，采用开源处理器架构 RISC-V 作为中央处理核心。具体而言，该项目采用[蜂鸟（hbirdv2）](https://github.com/MongooseOrion/e203_hbirdv2) 处理器核心，挂载的外部模块包括：

  * DDR3
  * HDMI
  * 照相机 OV5640
  * SD Card

该系统可由照相机模块采集图像，经过 FPGA 处理后将目标详情通过 HDMI 传输图像。

### 系统框图

该项目的主要硬件模块包括：HBirdv2 SoC、摄像头模块（OV5640）、高速存取模块（DDR3）和显示模块（HDMI）。

<div align='center'><img src='.\document\pic\2023-05-30 173629.png' alt='' title='系统框图'></div>

根据需求，视觉系统挂载在外设总线的第 15 个端口（按照 RTL 的排序，名称为 `o15_icb`），地址为 0x1004_2000 - 0x1004_2FFF。

SoC 的存储资源包括 ITCM、DTCM 和 ROM。ITCM 的可配置地址区间为 0x8000_0000 - 0x8001_FFFF；DTCM 的可配置地址区间为 0x9000_0000 - 0x8001_FFFF；ROM 挂载在存储总线上，大小为 4KB，默认仅存储一条跳转指令，将直接跳至 ITCM 的起始地址位置并开始执行，其地址区间为0x0000_1000 - 0x0000_1FFF。

外部通信功能，例如 JTAG 调试功能（图中未标出）、UART 串行通信接口和 IIC 接口等均为 HBirdv2 SoC 默认挂载，因此可以方便地调用它们。有关该部分的更多内容，可见后续章节。

### 视觉模块

视觉系统由摄像头模块、DDR 模块和显示模块构成。通过将它们集成在一起，可以避免高速数据流使系统总线无响应的情况，尤其是 DDR 模块，对数据传输敏感度较高。紫光提供的 DDR IP 核使用 AXI4 Lite 总线，通过硬连接的方式，将视频采集和显示功能集成，减少了 SoC 系统外设总线协议间转换的工作量和全系统开销。

<div align='center'><img src='./document/pic\屏幕截图 2023-05-30 184917.png' alt='' title='视觉模块硬件框图'></div>

摄像头模块采取的是 OV5640，这是一款在嵌入式开发中较为流行的摄像头模组。从 RTL 代码上看，摄像头驱动模块有两个，可通过修改宏更改采集源，然后数据传入缓存池中，通过缓存控制器实现对 DDR 单元的访问，例如 CMOS 将视频数据传入 DDR 中，而通过总线，处理器单元能够读取这些数据。

数据缓冲池使用了名为 `DRM Based Simple Dual Port RAM` 的 IP 核，用于写缓冲（`wr_buf`）、读缓冲（`rd_buf`）。对于缓冲池控制器，是通过状态机的方式对不同的条件进行判断和处理，实现了对读取或写入数据的地址、长度和数据本身的控制，并生成相应的控制信号。模块中使用了一些辅助变量和寄存器来记录状态和计数器的值，例如 `cmd_cnt`、`write_en`、`axi_data_cnt` 等。这些变量用于管理写入操作的流程和状态转换。根据输入的使能信号和数据信息，生成对应的读取或写入数据信号和完成信号，并通过输出端口输出给其他模块使用。

同时，HDMI 输出控制模块将处理带有 bbox 的图像流，有关处理图像并在上层显示带有 bbox 的细节可见后续章节。

## SoC 和板上资源分析

HBird RISC-V SoC 提供了下述的外设接口：
  * GPIO，每组 32 通道，共两组
  * (Q)SPI，共三组
  * IIC，共两组
  * UART，共三组
  * PWM，16 路输出通道，共一组

这些接口是通过复用 `GPIO` 实现的。对于两组 I/O 接口 `GPIOA`、`GPIOB`，都可以配置为软件控制模式和 IOF 控制模式，在软件控制模式下，每个 I/O 接口都是未经定义的；在 IOF 控制模式下，某些 I/O 接口被设置为了特定的功能，例如 IIC 或 UART。

该项目采用的 FPGA 开发平台为紫光同创 MES50HP，其包含：
  * 8 个按钮，无开关，低电平有效
  * 8 个 LED 灯
  * 1 组 PMOD 扩展接口
  * 40 针扩展接口，34 路 I/O 有效

有关管脚约束的配置细节，可以查看 `./document/constraint.md`。

限于按键和 LED 资源有限，对于系统内的多个初始化或错误指示信号采取悬空处理，但这不影响系统的有效性或健壮性。

对于所有将用于连接硬件排针扩展接口的 GPIO 软路径，全部进行了三态连接处理，也即利用 `IOBUF` 配置输入输出接口的方向。然而对于 PDS 开发工具而言，其不支持原语配置，因此需要手动实现该配置。有关详情，可查看项目顶层文件 `./RTL/core/e203_system_top.v`。

## 软件侧

### 4.1 深度学习模型介绍

该项目采用的目标检测模型为 Yolov3。YOLOv3 是一种先进的目标检测算法，被广泛应用于计算机视觉领域。相比传统的目标检测算法，YOLOv3 以其快速、高效和准确的特点备受关注。

传统的目标检测算法通常将检测任务分为两个阶段：首先通过区域提取方法生成候选区域，然后使用分类器对候选区域进行分类和定位。而 YOLOv3 通过在单个神经网络中同时进行物体检测和定位，极大地提高了检测速度。它将图像分成网格，并在每个网格上预测多个边界框以及其对应的物体类别概率。这种端到端的检测方法不仅减少了复杂的流程，还提高了检测的准确性。

此外，YOLOv3 引入了 Anchor Boxes 的概念，通过预定义的一组锚框，模型可以更好地适应不同形状和比例的物体。同时，采用非极大值抑制算法来消除重叠较多的边界框，提高了检测结果的准确性。

为了减小开销，该项目采用 tiny 版本的 yolov3 进行训练，并生成关联的检查点文件。有关在 TensorFlow2.7 环境下训练 YOLOv3 模型的更多细节，可[点此](https://github.com/MongooseOrion/tf2-keras-yolo3)了解。

同时，为使目标检测能正常运行在基于 RISC-V 的硬件系统上，需要使用具有广泛兼容性的 TenorFlow-Lite 框架。TF Lite 的主要目标是提供快速、小巧且高效的机器学习推理解决方案。相比于标准的 TensorFlow 框架，TF Lite 经过了优化和精简，可以在移动设备和嵌入式设备上实现更高的性能和更低的内存占用。TF Lite 还提供了用于模型解析和推理的运行时库，以及用于开发和部署 TF Lite 模型的开发工具和集成库。适用于微控制器的 TensorFlow Lite 使用 C++ 11 编写而成，需要使用 32 位平台。

### 操作系统介绍

传统裸机程序是一个大的程序循环，例如 while 结构体，将所有事情看作一个任务，顺序执行代码，遇到中断发生则响应中断（可能发生中断嵌套），响应完中断后会继续之前被中断的任务。因此，仅仅有 TF Lite 模型文件是不够的，因为该模型并不能完美处理任务分配，例如中断。因此，为了满足实时性的要求，需要构建一个操作系统供 TF Lite 在上层运行。FreeRTOS 是一款迷你型实时操作系统内核，功能包括：任务管理、时间管理、信号量、消息队列、内存管理等功能，可基本满足较小系统的需要。

在 RTOS 中，将所有事情分成各个模块，每一个模块的内容看作一个任务，任务的执行顺序是灵活的，根据相应的调度算法管理任务的运行，灵活性比裸机程序强。

### 工作原理

FreeRTOS 中的调度算法分为时间片调度算法和抢占式调度，可在 FreeRTOS 的 `FreeRTOSConfig.h` 文件中配置寄存器 `configUSE_PREEMPTION` 和 `configUSE_TIME_SLICING` 实现。在此处，配置为时间片调度算法。

TensorFlow Lite for Microcontrollers 能够使用 Makefile 生成包含所有必要源文件的独立项目。目前支持的环境有 Keil、Make 和 Mbed。

利用 [TensorFlow Lite for Microcontrollers C++](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro) 库，就可以使用 C 源代码构建 TF-Lite 框架下的应用程序。例如：
  * `all_ops_resolver.h` 或 `micro_mutable_op_resolver.h` 可以用来提供解释器运行模型时所使用的运算。由于 `all_ops_resolver.h` 会拉取每一个可用的运算，因此它会占用大量内存。在生产应用中，应该仅使用 `micro_mutable_op_resolver.h` 拉取模型所需的运算。
  * `micro_error_reporter.h` 输出调试信息。
  * `micro_interpreter.h` 包含用于处理和运行模型的代码。



## 训练数据集

对于数据集，目标数据集内包括有 1000 个训练视频及其对应的按帧记录的标注文件。处理过程如下述所示：
  1. 为了能够使用 yolov3 模型训练，必须按照图片和对应 txt 文件的方式对数据集进行处理，于是调用 `opencv` 将所有视频切成单帧；
  2. 将标注文件（格式为 json）的 bbox 和目标种类信息按照：`path/to/img xmin,ymin,xmax,ymax,category_name0 xmin,ymin,xmax,ymax,category_name1 ...` 的格式以追加模式写入标注文件 `train.txt` 中；
  3. 将 `category_name` 保存在 `classes.txt` 中；
  4. 交叉比对，删去不含 bbox 信息的帧，也即没有被 json 文件记录的帧，经过比对，大约有 300 个视频或 20 万帧没有 bbox 信息；
  5. 由于原始 json 标注文件对于目标种类的索引都是从 0 开始，这也就是第二步中没有直接按索引号标识 `category_name` 的原因，在此步骤中将 `train.txt` 中每行的 `category_name` 按照 `classes.txt` 中的顺序替换为索引号；
  6. 打乱排序，准备训练。

有关处理数据集的源代码，请[点此](https://github.com/MongooseOrion/FPGA-Image-Recognition/blob/master/dataset/process.py)查看。
