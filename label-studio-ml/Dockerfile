FROM gabebarros/kasm-ubuntu:20.04-gpu

USER kasm-user

WORKDIR /home/kasm-user/Desktop

# install labelstudio
RUN pip install -U label-studio

# install ML backend
RUN git clone https://github.com/HumanSignal/label-studio-ml-backend.git && \
cd label-studio-ml-backend && pip install -e .

# install base requirements
RUN pip install gunicorn==22.0.0

#install specific reqs
RUN pip install cython megatron-core
 
RUN pip install ultralytics==8.3.91 tqdm torchmetrics==1.4.2 transformers datasets==2.18.0 accelerate==0.28.0 easyocr==1.7.1 boto3==1.28.58 opencv-python-headless==4.9.0.80 scipy flair==0.15 gliner==0.2.16 olefile==0.47 segment-anything==1.0 pytesseract==0.3.10 openai==1.58.1 tenacity==8.2.2 openmim==0.3.9 mmcv==2.1.0 numpy~=1.26 nemo-toolkit==1.23.0 huggingface-hub==0.23.5 werkzeug==3.0.6 label_studio_converter onnxruntime onnx rq==1.10.1 timm==0.4.12 scikit-learn pillow~=10.3 spacy~=3.6 ibm-watsonx-ai presto-python-client pydantic>=1.10.0 langchain==0.1.8 langchain_ibm==0.1.0 label_studio_sdk==1.0.10 mmdet sam2

RUN pip install hydra-core nemo-toolkit[all]

USER root

# install segment-anything-2
ENV PIP_CACHE_DIR=/.cache
RUN git clone --depth 1 --branch main --single-branch https://github.com/facebookresearch/sam2.git
WORKDIR sam2
RUN --mount=type=cache,target=${PIP_CACHE_DIR},sharing=locked \
    pip3 install -e .
RUN cd checkpoints && ./download_ckpts.sh
RUN mv checkpoints ~/Desktop

# Set env variable to bypass login
ENV VNCOPTIONS=-disableBasicAuth

EXPOSE 6901
EXPOSE 80

USER root

# remove SSL requirement
RUN sed -i 's/-sslOnly//g' /dockerstartup/vnc_startup.sh

# set env variables for GPU access
ENV PYTORCH_NVML_BASED_CUDA_CHECK=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# copy over start script
COPY start.sh /home/kasm-user
RUN chmod a+rwx /home/kasm-user/start.sh

# copy over other necessary files
COPY instructions.txt /home/kasm-user
COPY open_instructions.desktop /etc/xdg/autostart/ 

# set right permissions
RUN chmod -R a+rw /home/kasm-user/.cache

RUN cp -r ~/Desktop/checkpoints ~/.

# Set user to kasm-user
USER kasm-user

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
