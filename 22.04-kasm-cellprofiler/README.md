# Cellprofiler

Cellprofiler is a open source software for measuring and analyzing cell images. This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and run Cellprofiler (including Cellpose & the RunCellpose plugin) with GPU capabilities. This image uses Cellprofiler version 4.2.8 and Cellpose version 2.2.3.

# Instructions

## Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org:
```
docker pull harbor.cyverse.org/vice/kasm/cellprofiler:22.04-4.2.8-gpu
```
2. Run the container:
```
docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/cellprofiler:22.04-4.2.8-gpu
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the Kasm desktop.

4. Open a terminal and run `cellprofiler` to open the cellprofiler GUI.

## How to test Cellprofiler/Cellpose

Cellprofiler provides some example image sets for testing purposes. To test the container using these examples:

1. Run the container (above)
2. In the container, visit https://cellprofiler.org/examples
3. Download any of the example image sets to the container and unzip the folder
4. Open cellprofiler
5. Go to Edit > Browse for image folder > Navigate to the desired folder and click "open"
6. Click the "+" next to "Adjust modules:" and add the `RunCellpose` module
7. On the right-hand side, change "Run CellPose in docker or local python environment" to Python, change "Use GPU" to Yes, and select the correct input image.
8. Click "Start Test Mode", and "Run" to test!

## Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html).

Unless you plan on making changes to this container, you should use the existing launch button above.

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/cellprofiler:22.04-4.2.8-gpu
```
Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---

Launch the Cellprofiler Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/566e3660-e974-11ef-be46-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found on the Cellprofiler website: https://cellprofiler.org/
