
FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7


# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-slave-skopeo-rhel7" \
      name="openshift3/jenkins-slave-skopeo-rhel7" \
      version="3.3" \
      architecture="x86_64" \
      release="4" \
      io.k8s.display-name="Jenkins Slave Skopeo" \
      io.k8s.description="The jenkins slave image has the skopeo tools on top of the jenkins slave base image." \
      io.openshift.tags="openshift,jenkins,slave,skopeo"

USER root

ENV SKOPEO_BIN=https://github.com/sabre1041/ocp-support-resources/blob/master/skopeo/bin/skopeo?raw=true

USER root

ARG OC_VERSION=4.5

RUN curl -sLo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v$(echo $OC_VERSION | cut -d'.' -f 1)/clients/oc/$OC_VERSION/linux/oc.tar.gz && \
    tar xzvf /tmp/oc.tar.gz -C /usr/local/bin/ && \
    rm -rf /tmp/oc.tar.gz

COPY /policy.json /etc/containers/

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME && \
    curl -L -o /usr/bin/skopeo $SKOPEO_BIN && \
    chown -R 1001:0 /etc/containers && \
    chmod -R g+rw /etc/containers

