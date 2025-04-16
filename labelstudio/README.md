# Label Studio

Label Studio is an open source data labeling platform. This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and run Label Studio. 

# Instructions

## Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org: 
```
docker pull harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-startup
```
2. Run the container: 
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-startup
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the container. Once the container is run, please allow for about 10-20 seconds as label studio launches.
4. Once launched, login with your label studio username and password

## Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html). 

Unless you plan on making changes to this container, you should use the existing launch button above. 

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-startup
```

Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---


Image is hosted on Dockerhub: https://hub.docker.com/repository/docker/gabebarros/kasm-labelstudio/general

Launch the Label Studio Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/184c82f4-d8fa-11ef-88e4-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found at the Label Studio website: https://labelstud.io/

