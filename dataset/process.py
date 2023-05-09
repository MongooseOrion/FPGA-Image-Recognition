import cv2
import os
import sys
import json

# 把视频所有帧分离
def save_img():
    video_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\'
    videos = os.listdir(video_path)
    
    for video_name in videos:
        file_name = video_name.split('.')[0]
        folder_name = os.path.join(video_path, file_name)
        os.makedirs(folder_name, exist_ok=True)

        # 读入视频文件
        vc = cv2.VideoCapture(video_path + video_name) 
        c = 0
        print(file_name)
        rval = vc.isOpened()
        print(rval)
        
        # 循环读取视频帧
        while rval: 
            rval, frame = vc.read()
            pic_path = folder_name + '\\'
            if rval:
                c_fill = str(c).zfill(6)
                # 存储为图像,保存名为视频名_帧数.jpg
                cv2.imwrite(pic_path + file_name + '_' + c_fill + '.jpg', frame)  
                cv2.waitKey(1)
            else:
                break
            c = c + 1
        
        vc.release()
        print('save_success')
        print(folder_name)
        '''
        # 中断
        ans = input('input anything: ')
        if ans=='1':
            sys.exit()
'''

# 重命名每帧图片名称
def rename():
    img_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\ILSVRC2015_train_00005003'
    new_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\ILSVRC2015_train_00005003_new'
    if not os.path.exists(new_path):
        os.makedirs(new_path)
    imgname = os.listdir(img_path)
    n = len(imgname)
    images = os.listdir(new_path)
    imgname.sort(key=lambda x: int(x[:-4]))
    count = len(images)
    i = count

    for img in imgname:
        if img.endswith('.jpg'):
            oldname = os.path.join(os.path.abspath(img_path), img)
            nname = str(i)
            nname = nname.zfill(6)
            newname = os.path.join(os.path.abspath(new_path), nname + '.jpg')

            try:
                os.rename(oldname, newname)
                print("rename %s to %s ..." % (oldname, newname))
                i = i + 1
            except:
                continue

    print("total %d to rename & converted %d files" % (n, i))

# 格式化 Json 文件
def fm_js():        
    json_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train\\'
    json_file = os.listdir(json_path)
    video_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\'
    videos = os.listdir(video_path)

    for json_name in json_file:
        json_file_path = os.path.join(json_path, json_name)
        
        with open(json_file_path, 'r') as f:
            data = json.load(f)
        
        img_folder_name = data['video_id']
        # 检查 json 文件中的 video_id 是否存在有视频
        #if img_folder_name in videos:

        list_object=[]
        for item in data['subject/objects']:
            list_object.append(item['category'])
            
        with open('train.txt','a') as train:
            num = 0
            for item in data['trajectories']:
                for r in range(len(item)):
                    bbox_obj = item[r]          # 按顺序取出每帧的 bbox
                        
                    tid = bbox_obj['tid']
                    xmin = bbox_obj['bbox']['xmin']
                    ymin = bbox_obj['bbox']['ymin']
                    xmax = bbox_obj['bbox']['xmax']
                    ymax = bbox_obj['bbox']['ymax']
                    obj = list_object[tid]
                        
                    # 把图片的绝对路径打印
                    num_temp = str(num).zfill(6)
                    img_path = video_path + img_folder_name + '\\' + img_folder_name + '_' + num_temp + '.jpg'
                    if r == 0:
                        train.write(img_path +' '+str(xmin)+','+str(ymin)+','+str(xmax)+','+str(ymax)+ ',' + str(obj)+' ')
                    else:
                        train.write(str(xmin)+','+str(ymin)+','+str(xmax)+','+str(ymax) + ',' + str(obj)+' ')
                        
                    if r==len(item)-1:
                        train.write('\n')

                num = num + 1

    # 中断
    
    ans = input('input anything: ')
    if ans=='1':
        sys.exit()
    

save_img()
#rename()
#fm_js()