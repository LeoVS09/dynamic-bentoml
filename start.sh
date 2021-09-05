#!/usr/bin/env bash

# Start BentoML server in production enviroment

bentoml serve-gunicorn ${MODEL_NAME} --yatai-url=${YATAI_URL}
