# DeepLabCut

DeepLabCut is an open source Python package for animal pose estimation. This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and run DeepLabCut. This image uses DLC version 3.0 with a PyTorch backend.

## Instructions

### Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org:
```
docker pull harbor.cyverse.org/vice/kasm/deeplabcut:gpu-2412
```
2. Run the container:
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/deeplabcut:gpu-2412
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the container.
4. In Kasm, open a terminal and activate the DEEPLABCUT conda environment:
```
conda activate DEEPLABCUT
```
5. Finally, launch DLC with:
```
python -m deeplabcut
```

For more information on GPU use, go here: https://kasmweb.com/docs/latest/how_to/gpu.html

### Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html).

Unless you plan on making changes to this container, you should use the existing launch button above.

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/deeplabcut:gpu-2412
```
Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---

Launch the Label Studio Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/fb187ac2-448d-11ef-8675-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found on the official DeepLabCut github: https://github.com/DeepLabCut/DeepLabCut