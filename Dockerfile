# syntax=docker/dockerfile:1

FROM golang:1.22.3-alpine3.18 as builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/opa-nginx
RUN echo "nobody:x:65534:65534:nobody:/nonexistent:/bin/nope" > passwd

FROM scratch

COPY --from=builder /bin/opa-nginx /bin/opa-nginx
COPY --from=builder /app/passwd /etc/passwd
USER nobody
ENV OPA_URL=https://127.0.0.1:8181
ENTRYPOINT ["/bin/opa-nginx"]
CMD ["serve"]