# Dynamic BentoML

Self containing [BentoML](https://github.com/bentoml/BentoML) image, which can load model server on start.

* [Github repository](https://github.com/LeoVS09/dynamic-bentoml)
* [DockerHub repository](https://hub.docker.com/r/leovs09/dynamic-bentoml)

## What is BentoML?

BentoML is a flexible, high-performance framework for serving, managing, and deploying machine learning models.

* Supports multiple ML frameworks, including Tensorflow, PyTorch, Keras, XGBoost and [more](https://github.com/bentoml/BentoML#ml-frameworks)
* Cloud native deployment with Docker, Kubernetes, AWS, Azure and [many more](https://github.com/bentoml/BentoML#deployment-options)
* High-Performance online API serving and offline batch serving
* Web dashboards and APIs for model registry and deployment management

BentoML bridges the gap between Data Science and DevOps. By providing a standard interface for describing a prediction service, BentoML abstracts away how to run model inference efficiently and how model serving workloads can integrate with cloud infrastructures. [See how it works!](https://github.com/bentoml/BentoML#introduction)

## What is Dynamic BentoML?

Extendable Docker image of ML model server. Service build for load model server on start, persist it, and start server.

## Tags

Image tags of this repository mostly follow images of [BentoML project](https://hub.docker.com/r/bentoml/model-server/tags?page=1&ordering=last_updated). If some image from not exists, you can build and push by self, follow development guide.

* Simple CPU images examples: `latest`, `0.13.1-py38`, `0.13.1-py36`
* Thanks to [@withsmilo](https://github.com/withsmilo/BentoML/tree/seperate_predict_with_healthz) for fix health check [issue #1768](https://github.com/bentoml/BentoML/issues/1768) you can use image: `0.13.1-py38-health`

### Why Dynamic BentoML?

For what need Dynamic BentoML if simple BentoML already exists?

I faced simple problem, my **models too big to be saved as Docker image**. My kubernetes cluster have limitations for ephimeral storage, which not allow to load and start big Docker images. And also, save ML models as part of image is simple solution, but not good practice, because it force to copy models in multiple places, what increase storage and bandwith costs.

BentoML great framework, but it not allow in simple way load and update model artifacts from local registry, when new version is available.

**For solve this problem**, I created simple Docker image which receive `MODEL_NAME` and `YATAI_URL` enviroment variables and start BentoML server.

In simple terms it will just run `bentoml serve-gunicorn ${MODEL_NAME} --yatai-url=${YATAI_URL}`

For **decrease container size** you can use `BENTOML_HOME` for set where model services will be saved before serving, and add persistence volume in this folder. It also allow to share and cache models before starts, what decrease startup time.

**Warning:** Current solution not much decrease overall storage size, becuase you will need to use ML models registry and also packed model services registry ([Yatai Service](https://hub.docker.com/r/bentoml/yatai-service)). I hope someone will write general artifact adapter for BentoML which allow load new models on start.

## Requrements

* For run server need started and working [Yatai Service](https://docs.bentoml.org/en/latest/concepts.html#customizing-model-repository) as packed model registry.

### Example setup Yatai Service

You can check docs how to start [Yatai Service in docker](https://docs.bentoml.org/en/latest/concepts.html#customizing-model-repository) or in [Kubernetes with Helm](https://docs.bentoml.org/en/latest/guides/helm.html).

#### Docker Compose

There simple example how to start [Yatai Service](https://hub.docker.com/r/bentoml/yatai-service) with [PostgreSQL](https://hub.docker.com/_/postgres) as database and [Minio](https://hub.docker.com/r/minio/minio/) as artifacts storage.

```yaml
# docker-compose.yaml
version: "3.9"

services:

   yatai-service:
      image: bentoml/yatai-service:0.13.1
      ports:
         - 50051:50051 # GRPC port
         - 3000:3000 # UI port
      environment:
         - BENTOML_HOME=/bentoml
         - AWS_ACCESS_KEY_ID=minio
         - AWS_SECRET_ACCESS_KEY=minio123
         - AWS_DEFAULT_REGION=eu-central-1
      volumes:
         - ./data/registry/bentoml/:/bentoml/.
      command: --db-url=postgresql://postgres:examplepass@postgresdb:5432/bentomldb --s3-endpoint-url=http://minio:9000 --repo-base-url=s3://bentoml-models/
      depends_on: 
         - postgresdb
         - minio
      links:
         - postgresdb
         - minio

   postgresdb:
      image: postgres:13.4
      restart: always
      ports:
         - 5432:5432
      environment:
         - POSTGRES_PASSWORD=examplepass
         - POSTGRES_USER=postgres
         - PGDATA=/var/lib/postgresql/data
         - POSTGRES_DB=bentomldb
      volumes:
         - ./data/postgres/data:/var/lib/postgresql/data

   minio:
      image: quay.io/minio/minio
      entrypoint: sh
      command: -c 'mkdir -p /data/bentoml-models && /usr/bin/minio server /data --console-address ":9001"'
      expose:
         - "9000"
         - "9001"
      environment:
         MINIO_ROOT_USER: minio
         MINIO_ROOT_PASSWORD: minio123
      healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
         interval: 30s
         timeout: 20s
         retries: 3
      volumes:
         - ./data/minio/data:/data

```

## Usage

### Preapare your image

Firstly prepare, pack and push your model to [Yatai Service](https://hub.docker.com/r/bentoml/yatai-service).

* To prepare and pack folow [Getting Started guide from BentoML](https://docs.bentoml.org/en/latest/quickstart.html)
* To pack and push your model to [Yatai Service](https://hub.docker.com/r/bentoml/yatai-service) folow one of [this examples](https://docs.bentoml.org/en/latest/concepts.html#model-management).

In simple case you need only add yatai url when save

```python
# pack.py
# ...

# if service running locally
bento_svc.save(yatai_url="127.0.0.1:50051") 

# if running in example docker-compose
bento_svc.save(yatai_url="model-registry-manager:50051") 
```

### Start docker container

Start docker container service directly.

```bash
> docker run \
  -v ~/bentoml:/bentoml \
  -p 5000:5000 \
  -e SERVICE_NAME=IrisClassifier:latest \
  -e YATAI_URL=127.0.0.1:50051 \
  leovs09/dynamic-bentoml:latest
```

open <http://localhost:5000/> to see Swagger API page.

Send request to service

```bash
> curl -i \
  --header "Content-Type: application/json" \
  --request POST \
  --data '[[5.1, 3.5, 1.4, 0.2]]' \
  http://localhost:5000/predict
```

### Examples

For build your own image based on this, for example for add more libraries required for you model simply create your Dockerfile and build it.

Example Dockerfile

```Dockerfile
FROM leovs09/dynamic-bentoml:latest

COPY requirements.txt ./
RUN pip install -r requirements.txt
```

#### Example usage in docker compose

```yaml
# docker-compose.yaml

version: "3.9"

services:

   # add yatai service from example before
   # ...

   ml-model-service:
      image: leovs09/dynamic-bentoml:latest # or your image based on that
      ports:
         - 8904:8904
      volumes:
         - ./data/bentoml/:/bentoml/.
      environment:
         - BENTOML_PORT=8904
         - BENTOML_GUNICORN_WORKERS=1
         - BENTOML_HOME=/bentoml
         - YATAI_URL=yatai-service:50051
         - SERVICE_NAME=IrisClassifier:latest
      depends_on: 
         - yatai-service
      links:
         - yatai-service

```

## Configuration

Service configuration made through enviroment variables.

### Enviroment Variables

All listed in [cli docs](https://docs.bentoml.org/en/latest/cli.html#bentoml-serve-gunicorn) enviroment variables are available.

#### Required variables

* `SERVICE_NAME` - Name and version of [BentoML](https://github.com/bentoml/BentoML) service which need load. Example: `SERVICE_NAME=IrisClassifier:latest`
* `YATAI_URL` - Url of [Yatai Service](https://hub.docker.com/r/bentoml/yatai-service), from where model will be loaded. Example: `YATAI_URL=127.0.0.1:50051`

#### Optional variables

* `BENTOML_HOME` - Path where models will be saved before serving, can be used for target to persistence volume folder, default to `~/bentoml`. Example: `BENTOML_HOME=/bentoml`
* `BENTOML_PORT` - The port to listen on for the REST api server, default is `5000`. Example: `BENTOML_PORT=8904`
* BENTOML_GUNICORN_WORKERS - Number of workers will start for the gunicorn server. Example: `BENTOML_GUNICORN_WORKERS=1`

## Development

If you want extend or build your own image, folow next steps:

* Clone repository `git clone https://github.com/LeoVS09/dynamic-bentoml.git`
* Make your changes
* Update `Makefile` with new image name and tag
* Run `make` - it will build new docker image and push to docker hub
