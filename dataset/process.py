import cv2
import os
import sys
import json
import shutil

# 把视频所有帧分离为图片
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

        #list_object=[]
        dic_object={}
        for item in data['subject/objects']:
            #list_object.append(item['category'])
            dic_object[str(item['tid'])] = item['category']
            
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
                    #obj=list_object[tid]
                    obj = dic_object.get(str(tid))
                        
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
        '''
        ans = input('input anything: ')
        if ans=='1':
            sys.exit()
    '''
        
# 将图片文件搬运到另一个文件夹
def move():
    folder_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\'
    folder_list = os.listdir(folder_path)

    for folder in folder_list:
        try:
            img_path = os.path.join(folder_path,folder)
            for img in os.listdir(img_path):
                src_path = os.path.join(img_path,img)
                dst_path = os.path.join(folder_path,img)
                shutil.move(src_path,dst_path)
        except:
            continue

        #中断
        '''
        ans = input('input anything: ')
        if ans=='1':
            sys.exit()
'''


# 交叉比对图片是否都有对应的标注文件，有的放一个文件夹，没有的放另一个文件夹
def verify():
    img_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\'
    txt_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train_new.txt'
    new_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\new_folder'
    
    with open(txt_path,'r') as f:
        for line in f:
            # 获取文件路径
            file_path = line.split()[0]
            #print(file_path)
            # 检查文件是否存在
            if os.path.isfile(file_path):
                shutil.move(file_path,new_path)
            else:
                with open('train_failed.txt','a') as fail:
                    fail.write(line)
'''
            ans = input('input anything: ')
            if ans=='1':
                sys.exit()
'''
                
# 修改 txt 内容
def modify():
    txt_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train.txt'

    with open(txt_path, 'r') as f:
        lines = f.readlines()
        new_lines = []
        for line in lines:
            new_line = line[:58] + line[84:]
            new_lines.append(new_line)

    with open('train_new.txt', 'w') as f:
        f.writelines(new_lines)


# 统计 txt 的所有目标类别，并替换名称为索引号
def categary():
    file_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train_new_1.txt'
    task_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train_new_2.txt'

    obj_list = []
    with open(file_path, 'r') as f:
        for line in f:
            line_list = line.split()
            # 以逗号作为标识符检测有几个 bbox
            for item in line_list:
                if len(item.split(',')) > 1:
                    obj = item.split(',')[-1]
                    if obj not in obj_list:
                        obj_list.append(obj)

    with open('categary.txt','w') as f:
        for obj in obj_list:
            f.write(obj + '\n')

    with open(task_path, 'r+') as f:
        lines = f.readlines()
        f.seek(0)  # 将文件指针移回文件开头

        for line in lines:
            line = line.strip()
            items = line.split()
            new_items = []
            new_path_list = []

            for item in items:
                if len(item.split(',')) > 1:
                    category = item.split(',')[-1]
                    index = obj_list.index(category)
                    new_items.append(item.replace(str(category), str(index)))
                else:
                    new_path_list.append(item)

            new_line = ' '.join(new_path_list) + ' ' + ' '.join(new_items) + '\n'
            f.write(new_line)

        f.truncate()  # 截断文件，删除多余内容


# 令 txt 的标识与图片一一对应，去除没有 bbox 的帧信息 
def txt_veri():
    file_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\train_new_2.txt'
    pic_path = 'C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\dataset\\video\\'

    with open(file_path, 'r') as f, open('temp.txt', 'w') as temp:
        for line in f:
            line_list = line.split()
            path = line_list[0]
            if os.path.isfile(path):
                temp.write(line)
            else:
                pass





#save_img()
#rename()
#fm_js()
#move()
#verify()
#modify()
#categary()
txt_veri()