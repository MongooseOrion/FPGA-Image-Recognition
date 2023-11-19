import socket
import numpy as np
import cv2
import sys
import argparse
from yolo import YOLO
from PIL import Image
import os
import sys
import time

import settings

UDP_IP = "192.168.0.3"  # 监听所有可用的网络接口
UDP_PORT = 8080
BUFFER_SIZE = 2764800

# 创建UDP套接字
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_socket.bind((UDP_IP, UDP_PORT))

# 用于保存已接收的图像数据
received_data = bytearray()

# 期望的图像尺寸
expected_image_size = 1280 * 720 * 3

# 加载YOLOv3模型
model_path = settings.DEFAULT_MODEL_PATH  # 根据实际路径修改
yolo = YOLO(model_path=model_path)

# 创建视频编写器
if os.path.exists('model_data/video.avi'):
    os.remove('model_data/video.avi')
output_path = 'model_data/video.avi' 
fourcc = cv2.VideoWriter_fourcc(*'XVID')
output_video = cv2.VideoWriter(output_path, fourcc, 20.0, (1280, 720))

# 帧数显示
start_time = time.time()
frame_count = 0

while True:
    # 接收数据
    data, addr = udp_socket.recvfrom(BUFFER_SIZE)
    
    # 添加接收到的数据到已接收的数据缓冲区
    received_data += data
    
    # 检查起始标识符
    #start_marker = b"\xff\xd8\xff\xe0"
    start_marker = b"\xff\xd8"
    start_pos = received_data.find(start_marker)
    
    if start_pos != -1:
        # 检查结束标识符
        #end_marker = b"\xff\xd9"
        end_marker = b"\xff\xd9"
        end_pos = received_data.find(end_marker, start_pos + len(start_marker))
        
        if end_pos != -1:
            
            data_length = end_pos - start_pos
            if data_length < 345600:
                # 继续接收数据，直到达到指定长度
                while data_length < 345600:
                    additional_data, _ = udp_socket.recvfrom(BUFFER_SIZE)
                    received_data += additional_data
                    data_length = len(received_data) - start_pos

                    # 检查是否出现新的结束符
                    new_end_pos = received_data.find(end_marker, end_pos + len(end_marker))
                    if new_end_pos != -1:
                        # 更新结束符位置
                        end_pos = new_end_pos
                        data_length = end_pos - start_pos

            # 截取图像数据
            image_data = received_data[start_pos:end_pos + len(end_marker)]
            
            try:
                # 解码图像数据
                image = np.frombuffer(image_data, dtype=np.uint8)
                image = cv2.imdecode(image, cv2.IMREAD_UNCHANGED)
                
                # 填充破损的图像数据为全零数据
                if len(image.shape) == 3 and image.shape[2] != 3:
                    filled_data = np.zeros((image.shape[0], image.shape[1], 3), dtype=np.uint8)
                    filled_data[:image.shape[0], :image.shape[1], :image.shape[2]] = image
                    image = filled_data

                # 执行目标检测
                detected_image = yolo.detect_image(Image.fromarray(image))
                
                # 将检测结果转换为OpenCV图像格式
                result_image = np.array(detected_image)
                #result_final = cv2.cvtColor(np.array(result_image), cv2.COLOR_BGR2RGB)
                
                # 裁剪画面
                result_height = result_image.shape[0]
                result_width = result_image.shape[1]

                crop_height = int(result_height * 0.99)  # 要裁剪的高度（例如保留顶部25%的画面）
                crop_left = int(result_width * 0.01)  
                crop_right = int(result_width * 0.99)
                result_image = result_image[:crop_height, crop_left:crop_right, :]
                
                # 将结果写入视频流
                output_video.write(result_image)

                # 在每一帧处理之后增加帧数计数
                frame_count += 1
                # 计算经过的时间
                elapsed_time = time.time() - start_time
                # 计算实时 FPS 值
                fps = (frame_count / elapsed_time)*3
                # 在图像的左上角绘制 FPS 值
                cv2.putText(result_image, f"FPS: {fps:.2f}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 1)
                
                # 显示图像
                cv2.imshow("Frame", result_image)
                
                # 清除已显示的图像数据
                received_data = received_data[end_pos + len(end_marker):]
            
            except Exception as e:
                print(f"Failed to decode image: {e}")
        
        else:
            # 未找到结束标识符，继续接收数据
            continue
    
    # 按下 'q' 键退出循环
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# 清理资源
udp_socket.close()
cv2.destroyAllWindows()