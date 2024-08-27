FROM golang:latest AS awg
COPY . /awg
WORKDIR /awg
RUN go mod download && \
    go mod verify && \
    go build -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v -o /usr/bin

FROM alpine:3.15 AS awg-tools
ARG AWGTOOLS_RELEASE="1.0.20231215"
RUN apk --no-cache add linux-headers build-base git bash && \
    git clone https://github.com/NOXCIS/amneziawg-tools.git && \
    #wget https://github.com/amnezia-vpn/amnezia-wg-tools/archive/refs/tags/v${AWGTOOLS_RELEASE}.zip && \
    #unzip v${AWGTOOLS_RELEASE}.zip && \
    cd amneziawg-tools/src && \
    make -e LDFLAGS=-static && \
    make install

FROM alpine:3.15
RUN apk --no-cache add iproute2 bash
COPY --from=awg /usr/bin/amnezia-wg /usr/bin/wireguard-go
COPY --from=awg-tools /usr/bin/wg /usr/bin/wg-quick /usr/bin/
