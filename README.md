#setup
Run on local machine: `cargo run`

Build docker container: `docker build -t docker-rts .`
Run container localy: `docker run -p 8080:8080 docker-rts`


# Google Cloud
This project does not necessarily need to be uploaded to google cloud, but here are the push instructions to a properly configured google cloud
### Setup
gcloud auth configure-docker
### Push a specific version
docker tag [SOURCE_IMAGE] gcr.io/[PROJECT-ID]/[IMAGE]
docker push gcr.io/[PROJECT-ID]/[IMAGE]
