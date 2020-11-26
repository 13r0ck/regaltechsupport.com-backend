# 1: Build the exe
FROM rust:1.42 as builder
WORKDIR /usr/src

# 1a: Prepare for static linking
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y musl-tools && \
    rustup override set nightly && \
    rustup target add x86_64-unknown-linux-musl

# 1b: Download and compile Rust dependencies (and store as a separate Docker layer)
RUN USER=root cargo new myprogram
WORKDIR /usr/src/myprogram
COPY Cargo.toml Cargo.lock ./
RUN rustup override set nightly
RUN cargo install --target x86_64-unknown-linux-musl --path .

# 1c: Build the exe using the actual source code
COPY src ./src
RUN rustup override set nightly
RUN mkdir /compile-path
RUN cargo install --target x86_64-unknown-linux-musl --path .
RUN cargo build --release
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after it has been declared, those changes will be discarded. Thus:
RUN cp ./target/x86_64-unknown-linux-musl/release/docker-rts /compile-path/docker-rts
RUN echo $(ls ./target/x86_64-unknown-linux-musl/release)
RUN echo $(ls /compile-path -a)
VOLUME /compile-path

# 2: Copy the exe and extra files ("static") to an empty Docker image
#
# // This docker container works with `FROM scratch` to save on image size, though using google cloud run requires that the port be $PORT
# // as seen in `CMD ROCKET_PORT=$PORT`, but I have not figured out how to either compile rocket in a way or to add an enironment variable
# // to a scratch image. Hopefully I will figure that out eventually
#FROM scratch
FROM alpine:latest
COPY --from=builder /compile-path/docker-rts ./docker-rts
COPY static/ ./static/
USER 1000
CMD ROCKET_PORT=$PORT ./docker-rts
