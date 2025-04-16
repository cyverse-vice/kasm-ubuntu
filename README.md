# kasm-ubuntu
### Ubuntu Desktops running KASM VNC

[Kasm](https://kasmweb.com/) is a container streaming platform that allows access to full desktop workspaces in a cloud/containerized environment.

### How to run
Each of the apps has specific directions on how to run them, and what to do once they are ran. These are located in the respective directories for each app. However, the general format is the following:
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/<image_name>:<tag> 
```
Then open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the app.

For apps that utilize GPUS, use the `--gpus all` flag when running. for example:
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/<image_name>:<tag>
```

### Available apps
We currently offer the following Kasm apps:

* [20.04-gpu](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/20.04-gpu): Ubuntu 20.04 with GPU capabilities.
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:22.04-gpu
```

* [Cellprofiler](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/22.04-kasm-cellprofiler): [Cellprofiler](https://cellprofiler.org/) running on Kasm. Once the container has been ran, open a terminal and type `cellprofiler` to start the GUI.
```
docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/cellprofiler:22.04-4.2.8-gpu
```

* [22.04](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/22.04): Basic Ubuntu version 22.04
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:22.04
```

* DeepLabCut: [Deeplabcut](https://www.mackenziemathislab.org/deeplabcut) running on Kasm. Once the container is ran, open a terminal and type `conda activate DEEPLABCUT` followed by `python -m deeplabcut` to open Deeplabcut.
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/deeplabcut:gpu-2412
```

* [ImageJ](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/ImageJ-22.04)

* [Duckdb](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/duckdb)

* [iland](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/iland)


* [LabelStudio](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/labelstudio): Data labeling platform [Label Studio](https://labelstud.io/) running on Kasm. Label studio will open on its own once the container is ran.
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-startup
```

* [LabelStudio-ML](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/label-studio-ml): Label Studio with an ML backend. Note that not all models are available in the app. Once the app is ran, there will be additional directions, and a list of the models that are available.
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-ML
```

* [Orange](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/orange): [Orange](https://orangedatamining.com/) machine learning software. Orange will open on its own once the container is ran.
```
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/orange:3.38.0
```

* [Pytorch-Wildlife](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/pytorch-wildlife): [Pytorch-Wildlife](https://microsoft.github.io/CameraTraps/INSTALLATION.html) is a data labeling software for animal detection. Once the app is ran, there will be additional directions.
```
docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/pytorch-wildlife:1.2.0
```

* [qgis-22.04](https://github.com/cyverse-vice/kasm-ubuntu/tree/main/qgis-22.04)

See the directories for the individual apps for more information on each one.
