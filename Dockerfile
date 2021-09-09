FROM bentoml/model-server:0.13.1-py38

# Based on https://github.com/bentoml/BentoML/blob/master/bentoml/saved_bundle/templates.py

ENV BENTOML_HOME=/home/bentoml/

RUN pip install git+https://github.com/withsmilo/BentoML.git@seperate_predict_with_healthz

WORKDIR /work/app

COPY entrypoint.sh start.sh ./

# Default port for BentoML Service
EXPOSE 5000

RUN chmod +x ./entrypoint.sh start.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./start.sh"]