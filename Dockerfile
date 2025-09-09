# Step 1: Build stage
FROM golang:1.24.7-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o cubeflow ./cmd

# Step 2: Runtime stage
FROM alpine:3.18

LABEL org.opencontainers.image.source="https://github.com/MTC0D3/cubeflow"
LABEL org.opencontainers.image.version="1.0.0"

ENV TZ=Asia/Jakarta

RUN apk --no-cache add tzdata ca-certificates postgresql-client \
    && apk upgrade --no-cache

ARG USER_ID=10001
ARG GROUP_ID=10001
RUN addgroup -g $GROUP_ID app && adduser -D -u $USER_ID -G app app

COPY --from=builder /app/cubeflow /home/app/cubeflow
RUN chown -R app:app /home/app/cubeflow

USER app
WORKDIR /home/app
ENTRYPOINT ["./cubeflow"]