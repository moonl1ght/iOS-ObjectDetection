# iOS + YOLOv3

Introducing online object detection on iOS with YOLOv3-416 and YOLOv3-tiny convolutional neural network architecture.

### Convertation from Darknet to CoreML

First of all need to download YOLOv3 pretrained weights from [YOLO website](https://pjreddie.com/yolo/). Download both cfg and weights files.

Then load Darknet weights to Keras model using [Keras-YOLOv3](https://github.com/qqwweee/keras-yolo3) implementation.

After cloning above repo use this commend to load Darknet and save .h5:

```bash
python convert.py yolov3.cfg yolov3.weights model_data/yolo.h5
```

And finally to transform from .h5 keras model representation to CoreML format use code below:

```python
import coremltools

coreml_model = coremltools.converters.keras.convert(
    'yolo.h5',
    input_names='image',
    image_input_names='image',
    input_name_shape_dict={'image': [None, 416, 416, 3]},
    image_scale=1/255.)

coreml_model.license = 'Public Domain'
coreml_model.input_description['image'] = 'Input image'

coreml_model.save('yolo.mlmodel')
```


