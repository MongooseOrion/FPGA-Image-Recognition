import threading
import socket
import numpy as np
import cv2
import time

# 共享数据
received_data = bytearray()

# 创建一个锁
lock = threading.Lock()

# 创建一个事件，用于通知线程退出
exit_event = threading.Event()

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

# 第二个函数，用于显示图像
def cv_imshow():
    global received_data
    start_marker = b"\xff\xd8"
    end_marker = b"\xff\xd9"
    i = 0
    start_time = 0
    end_time = 0
    fps = 0
    # 帧率显示数字大小等参数设置
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.5
    font_thickness = 1
    font_color = (255, 255, 255)  # 白色
    while not exit_event.is_set():
        #检查起始标识符
        # with lock:
        start_pos = received_data.find(start_marker)
        if start_pos != -1:
            while True:
                time.sleep(0.005)    #当检查到起始符后，要过一段时间结束符才会到来，暂停一小会防止程序卡死
                # 检查结束标识符
                with lock:
                    end_pos = received_data.find(end_marker, start_pos + len(start_marker))
                if end_pos != -1:
                    with lock:
                        image_data = received_data[start_pos:end_pos + len(end_marker)]
                        received_data = received_data[end_pos + len(end_marker):]  #清除已经显示信息
                    try:
                        image = np.frombuffer(image_data, dtype=np.uint8)
                        image = cv2.imdecode(image, cv2.IMREAD_COLOR)
                        height, width, channels = image.shape
                        resolution_str = f"Resolution: {width} x {height}"
                        #帧率计算，15帧计算一次，并在图片数据上添加帧率数据
                        if(i==1):
                            start_time = time.time()
                        elif (i==16):
                            i=0
                            end_time = time.time()
                            fps = 15/(end_time - start_time)     
                        cv2.putText(image, f'FPS: {fps:.2f}', (10, 30), font, font_scale, font_color, font_thickness)  
                        cv2.imshow(resolution_str, image)
                        i=i+1
                        key = cv2.waitKey(1)
                        if key == ord('q'):  # 按下 'q' 键退出
                            exit_event.set()
                    except Exception as e:
                        print(f"Failed to decode image: {e}")

                    break #跳出循环

# 创建两个线程，分别运行两个不同的函数
thread1 = threading.Thread(target=udp_receive_data)
thread2 = threading.Thread(target=cv_imshow)

# 启动线程
thread1.start()
thread2.start()



# 等待两个线程执行完毕
thread1.join()
thread2.join()

print("Main thread exiting.")
