# Label Studio ML Backend

Per the official documentation: "The Label Studio ML backend is an SDK that lets you wrap your machine learning code and turn it into a web server. The web server can be connected to a running Label Studio instance to automate labeling tasks." This directory contains everything needed to launch a [Kasm workspace](https://kasmweb.com/) through docker and run DeepLabCut. This image uses label studio version 1.15.0

We currently offer the following models:
-bert_classifier
-easyocr
-flair
-gliner
-huggingface_llm
-huggingface_ner
-interactive_substring_matching
-langchain_search_agent
-llm_interactive
-nemo_asr
-segment_anything_2_image
-sklearn_text_classifier
-tesseract
-yolo


# Instructions

## Run the container locally or on a Virtual Machine

1. Pull the image from harbor.cyverse.org:
```
docker pull harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-ML
```
2. Run the container:
```
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-ML
```
3. Open a web browser and visit http://localhost:6901 or http://127.0.0.1:6901 to access the container.
4. In Kasm, open a terminal and change directories to the parent directory
```
cd ..
```
5. Finally, launch labelstudio with your chosen model with:
```
./start.sh [name_of_model]
```

## Build your own Docker container and deploy on CyVerse VICE

This container is intended to run on the CyVerse data science workbench, called [VICE](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/index.html).

Unless you plan on making changes to this container, you should use the existing launch button above.

###### Developer notes

To build your own container with a Dockerfile and additional dependencies, pull the pre-built image from CyVerse private/public [Harbor Registry](https://harbor.cyverse.org).

```
FROM harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-ML
```
Follow the instructions in the [VICE manual for integrating your own tools and apps](https://cyverse-visual-interactive-computing-environment.readthedocs-hosted.com/en/latest/developer_guide/building.html).

---

Launch the Label Studio Container in CyVerse Discovery Environment: <a href="https://de.cyverse.org/apps/de/184c82f4-d8fa-11ef-88e4-008cfa5ae621/launch" target="_blank"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a>

More information can be found on the official DeepLabCut github: https://github.com/HumanSignal/label-studio-ml-backend
