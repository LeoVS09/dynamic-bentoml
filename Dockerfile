FROM bentoml/model-server:0.13.1-py36

# Based on https://github.com/bentoml/BentoML/blob/master/bentoml/saved_bundle/templates.py

ENV BENTOML_HOME=/home/bentoml/

WORKDIR /work/app

COPY entrypoint.sh start.sh ./

# Default port for BentoML Service
EXPOSE 5000

RUN chmod +x ./entrypoint.sh start.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./start.sh"]