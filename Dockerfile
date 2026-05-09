# syntax=docker/dockerfile:1.7

FROM golang:1.25-alpine AS builder

WORKDIR /src

RUN apk add --no-cache ca-certificates git

COPY go.mod go.sum ./
RUN go mod download

COPY cmd ./cmd
COPY internal ./internal

RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/zai2api ./cmd

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S zai2api \
    && adduser -S -G zai2api zai2api

WORKDIR /app

COPY --from=builder /out/zai2api /usr/local/bin/zai2api

ENV PORT=8000

EXPOSE 8000

USER zai2api

ENTRYPOINT ["zai2api"]
