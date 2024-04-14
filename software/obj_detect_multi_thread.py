''' ======================================================================
* Copyright (c) 2023, MongooseOrion.
* All rights reserved.
*
* The following code snippet may contain portions that are derived from
* OPEN-SOURCE communities, and these portions will be licensed with: 
*
* <NULL>
*
* If there is no OPEN-SOURCE licenses are listed, it indicates none of
* content in this Code document is sourced from OPEN-SOURCE communities. 
*
* In this case, the document is protected by copyright, and any use of
* all or part of its content by individuals, organizations, or companies
* without authorization is prohibited, unless the project repository
* associated with this document has added relevant OPEN-SOURCE licenses
* by github.com/MongooseOrion. 
*
* Please make sure using the content of this document in accordance with 
* the respective OPEN-SOURCE licenses. 
* 
* THIS CODE IS PROVIDED BY https://github.com/MongooseOrion. 
* FILE ENCODER TYPE: UTF-8
* ========================================================================
'''
# 使用 yolo 对 UDP 传输的图像数据进行目标检测，多线程
import threading
import socket
import numpy as np
import cv2
from datetime import datetime
import json
import tensorflow as tf
import keyboard
from yolo import YOLO
from PIL import Image
import os
import sys
import time
import settings


# 共享数据
received_data = bytearray()

# 创建一个锁
lock = threading.Lock()

lock2 = threading.Lock()

# 创建一个事件，用于通知线程退出
exit_event = threading.Event() 

new_frame_event = threading.Event()


# 第一个函数，用于不停的接收数据
def udp_receive_data():
    global received_data
    UDP_IP = "192.168.0.3"  # 监听所有可用的网络接口
    UDP_PORT = 8080
    BUFFER_SIZE = 10240
    # 创建UDP套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.bind((UDP_IP, UDP_PORT))
    while not exit_event.is_set():
        # 接收数据 在使用共享数据之前先获取锁
        data, addr = udp_socket.recvfrom(BUFFER_SIZE)
        with lock:
            received_data += data
        # 在使用完共享数据后释放锁

#第二个函数，用来保存图像数据
def image_data_saved():
    global received_data
    global image
    start_marker = b"\xff\xd8"
    end_marker = b"\xff\xd9"

    while not exit_event.is_set(): 
        #检查起始标识符 
        start_pos = received_data.find(start_marker)
        if start_pos != -1:
            while True:
                time.sleep(0.001)    #当检查到起始符后，要过一段时间结束符才会到来，暂停一小会防止程序卡死
                # 检查结束标识符
                #with lock:
                end_pos = received_data.find(end_marker, start_pos + len(start_marker))
                if end_pos != -1:
                    with lock:
                        image_data = received_data[start_pos:end_pos + len(end_marker)]
                        received_data = received_data[end_pos + len(end_marker):]  #清除已经显示信息
                    try:
                        image1 = np.frombuffer(image_data, dtype=np.uint8)
                        with lock2:
                            image = cv2.imdecode(image1, cv2.IMREAD_COLOR)
                        new_frame_event.set()

                    except Exception as e:
                        print(f"Failed to decode image: {e}")

                    break #跳出循环


# 第三个函数，用于处理图像
def cv_imshow():
    global image
    global capture_target_frame_count
    i = 0
    start_time = 0
    end_time = 0
    fps = 0
    # 帧率显示数字大小等参数设置
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.5
    font_thickness = 1
    font_color = (255, 255, 255)  # 白色

    print("处理部分启动")
    image2=0

    capture_target_frame_count = 0

    # 加载YOLOv3模型
    model_path = settings.DEFAULT_MODEL_PATH  # 根据实际路径修改
    yolo = YOLO(model_path=model_path)
    

    while not exit_event.is_set():
            new_frame_event.wait() #等待新的一帧数据，防止重复识别，该模型识别的时间一般小于<0.02s，而接收到的图像为30帧（约0.03s）
            with lock2:
                image2 = image.copy()
            new_frame_event.clear() # 重置事件，等待下一帧数据
            image3 = image2.copy()
            # 进行模型推断
            time1=time.time()
            outputs = yolo.detect_image(Image.fromarray(image2))
            print(str(time.time()-time1))
            # 将检测结果转换为OpenCV图像格式
            result_image = np.array(outputs)
            if(i==1):
                start_time = time.time()
            elif (i==16):
                i=0
                end_time = time.time()
                fps = 15/(end_time - start_time)            #取15帧的平均帧率
            cv2.putText(result_image, f'FPS: {fps:.2f}', (10, 30), font, font_scale, font_color, font_thickness) 
            i=i+1
            # 显示结果
            cv2.imshow('yolo_v3', result_image)
            key = cv2.waitKey(1)

            if key == ord('q'):  # 按下 'q' 键退出
                exit_event.set()



# 创建三个线程，分别运行两个不同的函数
thread1 = threading.Thread(target=udp_receive_data)
thread2 = threading.Thread(target=cv_imshow)
thread3 = threading.Thread(target=image_data_saved)

# 启动线程

thread1.start()
thread3.start()
print("延迟8s等待模型加载模型")
time.sleep(8)

thread2.start()


# 等待两个线程执行完毕
thread1.join()
thread2.join()
thread3.join()

print("Main thread exiting.")
