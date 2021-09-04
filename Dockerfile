FROM bentoml/model-server:0.13.1-py36

# Based on https://github.com/bentoml/BentoML/blob/master/bentoml/saved_bundle/templates.py

ENV BENTOML_HOME=/home/bentoml/

WORKDIR /home/app

COPY start.sh ./
RUN chmod +x ./start.sh

ARG UID=1034
ARG GID=1034
RUN groupadd -g $GID -o bentoml && useradd -m -u $UID -g $GID -o -r bentoml

# Default port for BentoML Service
EXPOSE 5000

USER bentoml

CMD ["./start.sh"]