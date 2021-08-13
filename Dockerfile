FROM alpine:latest
ENV ISTIO_VERSION 1.10.4

RUN apk update && apk add curl bash coreutils jq ca-certificates openssl nginx

# Get Istio
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
RUN mv istio-${ISTIO_VERSION}/bin/istioctl /usr/bin && chmod +x /usr/bin/istioctl

# Get kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Add scripts for Istio
COPY scripts /usr/local/app/scripts/
RUN chmod +x /usr/local/app/scripts/init_kubeconfig.sh /usr/local/app/scripts/run.sh /usr/local/app/scripts/create_istio_system.sh /usr/local/app/scripts/uninstall_istio_system.sh /usr/local/app/scripts/get_grafana_dashboards.sh /usr/local/app/scripts/setup_release_mirror.sh /usr/local/app/scripts/generate_ssl.sh /usr/local/app/scripts/fetch_istio_releases.sh
RUN mkdir -p /usr/local/app/dashboards && /usr/local/app/scripts/get_grafana_dashboards.sh

# Add nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Get Istio tar for nginx
RUN mkdir -p /opt/istio-releases && /usr/local/app/scripts/fetch_istio_releases.sh /opt/istio-releases

ENTRYPOINT [ "/usr/local/app/scripts/run.sh" ]
