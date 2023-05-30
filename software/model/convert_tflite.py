import tensorflow as tf

# 加载模型
model = tf.keras.models.load_model('C:\\Users\\smn90\\repo\\FPGA-Image-Recognition\\software\\model\\tiny_yolo_weights.h5')

# 转换为 TFLite 模型
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# 保存为 TFLite 文件
with open('tiny_yolo_model.tflite', 'wb') as f:
    f.write(tflite_model)
