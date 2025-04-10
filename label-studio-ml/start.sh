#!/bin/bash

# Start ML backend in the background
label-studio-ml start Desktop/label-studio-ml-backend/label_studio_ml/examples/$1 &

# Start the Label Studio frontend
label-studio --host http://localhost:8080
