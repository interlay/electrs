FROM bitnami/minideb:buster as builder

ENV DEBIAN_FRONTEND=noninteractive
ARG PROFILE=release

RUN apt-get update && \
    apt-get install -y cmake pkg-config libssl-dev git clang curl

ARG TOOLCHAIN=nightly-2020-10-01

ENV PATH="/root/.cargo/bin:${PATH}"

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup toolchain install ${TOOLCHAIN} && \
    rustup target add wasm32-unknown-unknown --toolchain ${TOOLCHAIN} && \
    rustup default ${TOOLCHAIN}

WORKDIR /electrs
COPY . .
RUN cargo build --release

FROM bitnami/minideb:buster

COPY --from=builder /electrs/target/release/electrs /usr/local/bin/

CMD ["/usr/local/bin/electrs"]
