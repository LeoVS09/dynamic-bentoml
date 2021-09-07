#!/usr/bin/env bash


# Separatly pull model and then start solve case 
#  when server too long loading service without progress
#  and killing workers which cannot load service in given time.
echo "Loading model ${MODEL_NAME} from ${YATAI_URL}"
bentoml pull ${MODEL_NAME} --yatai-url=${YATAI_URL} --debug

echo "Starting BentoML server in production enviroment..."
bentoml serve-gunicorn ${MODEL_NAME}
