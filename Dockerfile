# Multi-Stage Build

FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o main .

FROM alpine:latest
WORKDIR /
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]



# Single Stage Build

# FROM golang:1.22-alpine
# WORKDIR /app
# COPY go.mod ./
# RUN go mod download
# COPY . .
# RUN go build -o main .
# EXPOSE 8080
# CMD ["./main"]
