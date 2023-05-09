
import tensorflow as tf
 
keras_model = tf.keras_models.load_model("./yolo.h5")
converter = tf.lite.TFLiteConverter.from_keras_model(keras_model)
tflite_model = converter.convert()
 
open("./yolo.tflite","wb").write(tflite_model)