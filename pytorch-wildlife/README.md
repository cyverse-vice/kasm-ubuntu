# Pytorch-Wildlife

Per the [documentation](https://cameratraps.readthedocs.io/en/latest/): "PytorchWildlife is a collaborative deep learning framework developed for the conservation community. It offers pre-trained models tailored for animal detection and classification, making it easier for researchers, conservationists, and enthusiasts to harness the power of machine learning for wildlife monitoring and research." This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and use pytorch-wildlife. This image uses the 1.2.0 version.

# Instructions

## Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org:
```
docker pull harbor.cyverse.org/vice/kasm/pytorch-wildlife:1.2.0
```
2. Run the container:
```
docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/pytorch-wildlife:1.2.0
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the Kasm desktop.

## How to test Pytorch-wildlife

Cellprofiler provides some example image sets for testing purposes. To test the container using these examples:

1. Run the container (above)
2. In the container, run:
```
git clone https://github.com/microsoft/CameraTraps.git
cd CameraTraps
cd demo
# For the image demo
python image_demo.py
# For the video demo
python video_demo.py
# For the gradio app
python gradio_demo.py
```

## Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html).

Unless you plan on making changes to this container, you should use the existing launch button above.

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/pytorch-wildlife:1.2.0
```
Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---

Launch the Pytorch-wildlife Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/6d1982b2-ea54-11ef-b69f-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found on the pytorch-wildlife github: https://github.com/microsoft/CameraTraps/tree/main
