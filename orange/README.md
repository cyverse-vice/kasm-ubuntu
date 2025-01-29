# Orange

Orange is an open source software for machine learning and data visualiation. This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and run Orange. This image uses Orange version 3.38.0.

# Instructions

## Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org:
```
docker pull harbor.cyverse.org/vice/kasm/orange:3.38.0
```
2. Run the container:
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/orange:3.38.0
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the container. Orange will open automatically on Kasm.

## Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html).

Unless you plan on making changes to this container, you should use the existing launch button above.

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/orange:3.38.0
```
Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---

Launch the Label Studio Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/4e54dbd6-de76-11ef-b1f4-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found on the Orange website: https://orangedatamining.com/
