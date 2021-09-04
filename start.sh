#!/usr/bin/env bash

# serve-gunicorn is serve for production enviroment

bentoml serve-gunicorn ${MODEL_NAME} --yatai-url=${YATAI_URL}
