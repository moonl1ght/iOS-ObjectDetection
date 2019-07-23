import coremltools

print('saving coreml -----')

coreml_model = coremltools.converters.keras.convert(
    'yolo-tiny.h5',
    input_names='image',
    image_input_names='image',
    input_name_shape_dict={'image': [None, 416, 416, 3]},
    image_scale=1/255.)

coreml_model.author = 'Original paper: Joseph Redmon, Ali Farhadi'
coreml_model.license = 'Public Domain'
coreml_model.short_description = "The YOLO network from the paper 'YOLOv3：An Incremental Improvement' (2018)"
coreml_model.input_description['image'] = 'Input image'

print(coreml_model)
coreml_model.save('yolo-tiny.mlmodel')
# output_labels = []
# with open('coco_classes.txt') as f:
#   output_labels = [line.strip() for line in f.readlines()]
#   f.close()


# print(output_labels)
# print(len(output_labels))
# coreml_model = coremltools.converters.keras.convert('yolo-tiny.h5', input_names=['image'], output_names=['output'],
#   class_labels=output_labels, image_input_names='image', input_name_shape_dict={'image': [None, 416, 416, 3]})
# coreml_model.save("yolo-tiny.mlmodel")
# print('saving coreml -----')