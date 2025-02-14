# Image detection instructions

# Importing libraries
First, we'll start by importing the necessary libraries and modules.
```
import numpy as np
from PIL import Image
import torch
from torch.utils.data import DataLoader
from PytorchWildlife.models import detection as pw_detection
from PytorchWildlife.data import transforms as pw_trans
from PytorchWildlife.data import datasets as pw_data
from PytorchWildlife import utils as pw_utils
```
# Setting GPU

If you are using a GPU for this exercise, please specify which GPU to use for the computations. By default, GPU number 0 is used. Adjust this as per your setup. You don?t need to run this cell if you are using a CPU.
```
torch.cuda.set_device(0) # Only use if you are running on GPU.
```

# Model Initialization
We will initialize the MegaDetectorV5 model for image detection. This model is designed for detecting animals in images.
```
DEVICE = "cuda"  # Use "cuda" if GPU is available "cpu" if no GPU is available
detection_model = pw_detection.MegaDetectorV5(device=DEVICE, pretrained=True)
```

# Single Image Detection
We will first perform detection on a single image. Make sure to verify that you have the image in the specified path.
```
tgt_img_path = "./demo_data/imgs/10050028_0.JPG"
img = np.array(Image.open(tgt_img_path).convert("RGB"))
transform = pw_trans.MegaDetector_v5_Transform(target_size=detection_model.IMAGE_SIZE,
                                               stride=detection_model.STRIDE)
results = detection_model.single_image_detection(transform(img), img.shape, tgt_img_path)
pw_utils.save_detection_images(results, "./demo_output")
```

# Batch Image Detection
Next, we?ll demonstrate how to process multiple images in batches. This is useful when you have a large number of images and want to process them efficiently.

```
tgt_folder_path = "./demo_data/imgs"
dataset = pw_data.DetectionImageFolder(
    tgt_folder_path,
    transform=pw_trans.MegaDetector_v5_Transform(target_size=detection_model.IMAGE_SIZE,
                                                 stride=detection_model.STRIDE)
)
loader = DataLoader(dataset, batch_size=32, shuffle=False,
                    pin_memory=True, num_workers=8, drop_last=False)
results = detection_model.batch_image_detection(loader)
```
# Output Results
PytorchWildlife allows to output detection results in multiple formats. Here are the examples:

1. Annotated Images:
This will output the images with bounding boxes drawn around the detected animals. The images will be saved in the specified output directory.

`pw_utils.save_detection_images(results, "batch_output")`

2. Cropped Images:
This will output the cropped images of the detected animals. The cropping is done around the detection bounding box, The images will be saved in the specified output directory.

`pw_utils.save_crop_images(results, "crop_output")`

3. JSON Format:
This will output the detection results in JSON format. The JSON file will be saved in the specified output directory.

```
pw_utils.save_detection_json(results, "./batch_output.json",
                             categories=detection_model.CLASS_NAMES)
```
