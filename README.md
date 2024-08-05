# Seam Carving with YOLOv5 Integration

This project combines object detection using YOLOv5 with seam carving for intelligent image retargeting. The aim is to resize images while preserving important content, especially objects of interest identified by the YOLO model.

## Idea

The primary idea is to integrate object detection into the seam carving process to prioritize and protect key elements in an image during resizing. The project involves two main components:

1. **Object Detection with YOLOv5**:
   - YOLOv5, a state-of-the-art object detection model, is used to detect and mark objects within images.
   - The output includes bounding boxes around detected objects, which inform the subsequent seam carving process.

2. **Seam Carving in MATLAB**:
   - Seam carving is an advanced image processing technique used to resize images by removing seams (paths of least importance) without distorting the overall content.
   - In this implementation, MATLAB is used to process the images and apply seam carving.
   - The process uses several importance maps: dmap, smap, and gmap, along with YOLO's output, to determine the areas of the image that are critical and should be preserved.

### Importance Maps

- **Dmap (Dynamic Map)**: Reflects dynamic content in the image, highlighting moving or important parts.
- **Smap (Saliency Map)**: Identifies salient features in the image, focusing on visually prominent regions.
- **Gmap (Gradient Map)**: Highlights edges and significant textures in the image.

By assigning different weights to these maps and the YOLO detection output, the seam carving algorithm can prioritize which parts of the image to keep intact, thus avoiding distortion of important content such as faces or objects.

## Application

This technique is particularly useful in applications where automatic image resizing is required, such as responsive web design, mobile app development, and content-aware image editing.

