Based on YOLO impl in repo https://github.com/eriklindernoren/PyTorch-YOLOv3
and (https://github.com/eriklindernoren/PyTorch-YOLOv3)
Using onnx for converting pyTorch model to CoreML model (https://onnx.ai)

Convert to onnx
```
python3  -c "from models import *; convert_onnx('cfg/yolov3-tiny.cfg')"
```

Function convert_onnx:
```
import torch.onnx
from torch.autograd import Variable
def convert_onnx(cfg='cfg/yolov3-spp.cfg'):
    model = Darknet(cfg)
    input_shape = (3, 416, 416)
    dummy_input = Variable(torch.randn(1, *input_shape))
    torch.onnx.export(model, dummy_input, "yolov3-tiny.onnx")
```

```
python3 detect.py --image_folder data/samples/ --weights_path weights/yolov3-tiny.weights --model_def config/yolov3-tiny.cfg
```


