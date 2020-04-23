FROM docker.io/golang:1-alpine as build

WORKDIR ${GOPATH}/src/contained-ganesha-test

ENV GO111MODULES=on

COPY go.mod go.sum .
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
ENV GOOS=${GOOS:-linux}
ENV GOARCH=${GOARCH:-amd64}
RUN go test -v -c -o bin/contained-ganesha-test ./...

FROM scratch
COPY --from=build /go/src/contained-ganesha-test/bin/contained-ganesha-test /contained-ganesha-test

ENTRYPOINT ["/contained-ganesha-test"]
CMD ["-test.v"]
