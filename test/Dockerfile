FROM docker.io/golang:1-alpine as build

WORKDIR ${GOPATH}/src/sut

ENV GO111MODULES=on

COPY go.mod go.sum .
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
ENV GOOS=${GOOS:-linux}
ENV GOARCH=${GOARCH:-amd64}
RUN go test -v -c -o bin/contained-ganesha-test ./...

FROM docker.io/alpine:3
COPY --from=build /go/src/sut/bin/contained-ganesha-test /usr/local/bin/contained-ganesha-test

ENTRYPOINT ["/usr/local/bin/contained-ganesha-test"]
CMD ["-test.v"]
