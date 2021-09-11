#!/usr/bin/env bash

# Check is service exists in the environment
if bentoml get ${SERVICE_NAME} --print-location
then echo "Service exists locally"
else 
    echo "Service not found"
    echo "Loading service ${SERVICE_NAME} from ${YATAI_URL}"
    # Separatly pull model for solve case 
    #  when server too long loading service without progress
    #  and killing workers which cannot load service in given time.
    bentoml pull ${SERVICE_NAME} --yatai-url=${YATAI_URL} --debug
fi

echo "Starting BentoML server in production enviroment..."
bentoml serve-gunicorn ${SERVICE_NAME}
