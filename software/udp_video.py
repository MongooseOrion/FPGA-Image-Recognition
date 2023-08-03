import socket
import numpy as np
import cv2

UDP_IP = "192.168.0.3"  # 监听所有可用的网络接口
UDP_PORT = 8080
BUFFER_SIZE = 2048

# 创建UDP套接字
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_socket.bind((UDP_IP, UDP_PORT))

# 用于保存已接收的图像数据
received_data = bytearray()

while True:
    # 接收数据
    data, addr = udp_socket.recvfrom(BUFFER_SIZE)
    
    # 添加接收到的数据到已接收的数据缓冲区
    received_data += data
    
    # 检查起始标识符
    start_marker = b"\xff\xd8\xff\xe0"
    start_pos = received_data.find(start_marker)
    
    if start_pos != -1:
        # 检查结束标识符
        end_marker = b"\xff\xd9"
        end_pos = received_data.find(end_marker, start_pos + len(start_marker))
        
        if end_pos != -1:
            # 截取图像数据
            image_data = received_data[start_pos:end_pos + len(end_marker)]
            
            # 解码图像数据
            try:
                image = np.frombuffer(image_data, dtype=np.uint8)
                image = cv2.imdecode(image, cv2.IMREAD_COLOR)
               
                # 显示图像
                cv2.imshow("Frame", image)
                
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