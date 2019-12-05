FROM alpine:3.10

RUN apk add --no-cache ca-certificates git bash curl jq

ARG HELM_VERSION=v3.0.0
ARG HELM_LOCATION="https://get.helm.sh"
ARG HELM_FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG HELM_SHA256="10e1fdcca263062b1d7b2cb93a924be1ef3dd6c381263d8151dd1a20a3d8c0dc"
RUN wget ${HELM_LOCATION}/${HELM_FILENAME} && \
    echo Verifying ${HELM_FILENAME}... && \
    sha256sum ${HELM_FILENAME} | grep -q "${HELM_SHA256}" && \
    echo Extracting ${HELM_FILENAME}... && \
    tar zxvf ${HELM_FILENAME} && mv /linux-amd64/helm /usr/local/bin/ && \
    rm ${HELM_FILENAME} && rm -r /linux-amd64

# https://github.com/roboll/helmfile/releases/download/v0.94.1/helmfile_linux_amd64
ARG HELMFILE_VERSION=v0.94.1
ARG HELMFILE_LOCATION="https://github.com/roboll/helmfile/releases/download"
ARG HELMFILE_FILENAME="helmfile_linux_amd64"
ARG HELMFILE_SHA256="eb058263f8279e1d0e9bb0c530db549615bb22fdb39c86c8696616c0e6b5beac"
RUN wget ${HELMFILE_LOCATION}/${HELMFILE_VERSION}/${HELMFILE_FILENAME} && \
    echo Verifying ${HELMFILE_FILENAME}... && \
    sha256sum ${HELMFILE_FILENAME} | grep -q "${HELMFILE_SHA256}" && \
    mv ${HELMFILE_FILENAME} /usr/local/bin/helmfile && \
    chmod +x /usr/local/bin/helmfile

# using the install documentation found at https://kubernetes.io/docs/tasks/tools/install-kubectl/
# for now but in a future version of alpine (in the testing version at the time of writing)
# we should be able to install using apk add.
ENV KUBECTL_VERSION="v1.15.3"
ENV KUBECTL_SHA256="6e805054a1fb2280abb53f75b57a1b92bf9c66ffe0d2cdcd46e81b079d93c322"
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sha256sum kubectl | grep ${KUBECTL_SHA256} && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

ENV HELM_HOME=/etc/helm
ENV XDG_CACHE_HOME=${HELM_HOME}/.cache/helm \
    XDG_CONFIG_HOME=${HELM_HOME}/.config/helm \
    XDG_DATA_HOME=${HELM_HOME}/.local/share/helm

RUN mkdir -p ${HELM_HOME} ${XDG_CACHE_HOME} ${XDG_CONFIG_HOME} ${XDG_DATA_HOME} && \
    chmod -R 0777 ${HELM_HOME} && \
    helm plugin install https://github.com/databus23/helm-diff --version v3.0.0-rc.7 && \
    helm plugin install https://github.com/futuresimple/helm-secrets && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git && \
    helm plugin install https://github.com/aslafy-z/helm-git.git

ENV HELMFILE_HELM3="1"

CMD ["/usr/local/bin/helmfile"]