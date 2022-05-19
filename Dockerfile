FROM golang:1.17.5-stretch

ARG coredns_version=1.8.6
ARG plugin_name=kubenodes
ARG plugin_repo=github.com/infobloxopen/kubenodes

RUN go mod download github.com/coredns/coredns@v${coredns_version}

WORKDIR $GOPATH/pkg/mod/github.com/coredns/coredns@v${coredns_version}
RUN go mod download

RUN sed -i "/kubernetes/i ${plugin_name}:${plugin_repo}" plugin.cfg
RUN go get ${plugin_repo}
RUN make coredns
RUN mv coredns /tmp/coredns

FROM scratch

COPY --from=0 /etc/ssl/certs /etc/ssl/certs
COPY --from=0 /tmp/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
