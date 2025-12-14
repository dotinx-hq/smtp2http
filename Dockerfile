FROM golang:1.14.4 as builder

ARG VERSION=dev
ARG BUILD_DATE
ARG VCS_REF

WORKDIR /go/src/build
COPY . .
RUN go mod vendor
ENV CGO_ENABLED=0
RUN GOOS=linux go build \
    -mod vendor \
    -a \
    -ldflags "-X main.Version=${VERSION} -X main.BuildDate=${BUILD_DATE} -X main.GitCommit=${VCS_REF}" \
    -o smtp2http .

FROM alpine:latest

ARG VERSION=dev
ARG BUILD_DATE
ARG VCS_REF

LABEL org.opencontainers.image.title="smtp2http" \
      org.opencontainers.image.description="SMTP server that forwards emails as HTTP webhooks" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/dotinx-hq/smtp2http"

WORKDIR /root/
COPY --from=builder /go/src/build/smtp2http /usr/bin/smtp2http
ENTRYPOINT ["smtp2http"]
