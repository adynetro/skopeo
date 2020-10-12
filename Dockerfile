
##############################################
# Stage 1 : Build go-init
##############################################
FROM openshift/origin-release:golang-1.12 AS go-init-builder
WORKDIR  /go/src/github.com/openshift/jenkins
COPY . .
WORKDIR  /go/src/github.com/openshift/jenkins/go-init
RUN go build . && cp go-init /usr/bin

##############################################
# Stage 2 : Build slave-base with go-init
##############################################
FROM quay.io/openshift/origin-cli

COPY --from=go-init-builder /usr/bin/go-init /usr/bin/go-init

ENV HOME=/home/jenkins \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-slave-skopeo-rhel7" \
      name="openshift3/jenkins-slave-skopeo-rhel7" \
      version="3.3" \
      architecture="x86_64" \
      release="4" \
      io.k8s.display-name="Jenkins Slave Skopeo" \
      io.k8s.description="The jenkins slave image has the skopeo tools on top of the jenkins slave base image." \
      io.openshift.tags="openshift,jenkins,slave,skopeo" \
      maintainer="alex@dorneean.ro"

USER root
# Install headless Java
RUN INSTALL_PKGS="bc gettext git java-11-openjdk-headless java-1.8.0-openjdk-headless lsof rsync tar unzip which zip bzip2 jq" && \
    yum install -y --setopt=tsflags=nodocs --disableplugin=subscription-manager $INSTALL_PKGS && \
    rpm -V  $INSTALL_PKGS && \
    yum clean all && \
    mkdir -p /home/jenkins && \
    chown -R 1001:0 /home/jenkins && \
    chmod -R g+w /home/jenkins && \
    chmod -R 775 /etc/alternatives && \
    chmod -R 775 /var/lib/alternatives && \
    chmod -R 775 /usr/lib/jvm && \
    chmod 775 /usr/bin && \
    chmod 775 /usr/lib/jvm-exports && \
    chmod 775 /usr/share/man/man1 && \
    mkdir -p /var/lib/origin && \
    chmod 775 /var/lib/origin && \    
    unlink /usr/bin/java && \
    unlink /usr/bin/jjs && \
    unlink /usr/bin/keytool && \
    unlink /usr/bin/pack200 && \
    unlink /usr/bin/rmid && \
    unlink /usr/bin/rmiregistry && \
    unlink /usr/bin/unpack200 && \
    unlink /usr/lib/jvm-exports/jre && \
    unlink /usr/share/man/man1/java.1.gz && \
    unlink /usr/share/man/man1/jjs.1.gz && \
    unlink /usr/share/man/man1/keytool.1.gz && \
    unlink /usr/share/man/man1/pack200.1.gz && \
    unlink /usr/share/man/man1/rmid.1.gz && \
    unlink /usr/share/man/man1/rmiregistry.1.gz && \
    unlink /usr/share/man/man1/unpack200.1.gz

# Copy the entrypoint
ADD contrib/bin/* /usr/local/bin/

ENV SKOPEO_BIN=https://github.com/sabre1041/ocp-support-resources/blob/master/skopeo/bin/skopeo?raw=true

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

<<<<<<< HEAD
=======
# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/bin/go-init", "-main", "/usr/local/bin/run-jnlp-client"]

##############################################
# End
##############################################
>>>>>>> 8f74e03bdad291b6af785427d1fe400f5c32091e
