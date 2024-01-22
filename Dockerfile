FROM alpine

ARG ARCH

# Ignore to update versions here
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG KUBECTL_VERSION=1.29.1
ARG VALS_VERSION=0.28.1
ARG KUBECONFORM_VERSION=0.6.4

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash openssh-client


# Install kubectl
RUN . /envfile && echo $ARCH && \
    curl -sLO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install jq
RUN apk add --update --no-cache jq yq

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install vals
RUN . /envfile && echo $ARCH && \
    curl -L https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${ARCH}.tar.gz -o -| tar xz -C /usr/bin/ && \
    chmod +x /usr/bin/vals

# Install kubeconform
RUN . /envfile && echo $ARCH && \
    curl -L https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-${ARCH}.tar.gz -o - | tar xz -C /usr/bin/ && \
    chmod +x /usr/bin/kubeconform

WORKDIR /apps
