FROM ubuntu:trusty
MAINTAINER rberrelleza@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Use https://download.jitsi.org/unstable/ for unstable
ARG REPOSITORY="https://download.jitsi.org/jitsi/debian"

# Latest stable as of 5/17
ARG JITSI="1.0.2098-1"
ARG VIDEOBRIDGE="953-1"
ARG JICOFO="1.0-357-1"
ARG JITSIMEET="1.0.1967-1"

RUN apt-get update -y && \
  apt-get install -y software-properties-common && \
  add-apt-repository ppa:openjdk-r/ppa && \
  apt-get update && \
  apt-get install -y wget openjdk-8-jre nginx prosody luarocks default-jre-headless

RUN  cd /tmp && \
  wget ${REPOSITORY}/jitsi-videobridge_${VIDEOBRIDGE}_amd64.deb && \
  dpkg -i jitsi-videobridge_${VIDEOBRIDGE}_amd64.deb && \
  wget ${REPOSITORY}/jicofo_${JICOFO}_amd64.deb && \
  dpkg -i jicofo_${JICOFO}_amd64.deb && \
  wget ${REPOSITORY}/jitsi-meet-prosody_${JITSIMEET}_all.deb && \
  dpkg -i jitsi-meet-prosody_${JITSIMEET}_all.deb && \
  wget ${REPOSITORY}/jitsi-meet-web_${JITSIMEET}_all.deb && \
  dpkg -i jitsi-meet-web_${JITSIMEET}_all.deb && \
  wget ${REPOSITORY}/jitsi-meet-web-config_${JITSIMEET}_all.deb && \
  dpkg -i jitsi-meet-web-config_${JITSIMEET}_all.deb && \
  wget ${REPOSITORY}/jitsi-meet_${JITSI}_all.deb && \
  dpkg -i jitsi-meet_${JITSI}_all.deb


RUN apt-get clean && \
  mkdir /root/samples && \
  mkdir /var/run/prosody && \
  chown prosody /var/run/prosody && \
  touch /root/.first-boot && \
  mkdir /keys && \
  mkdir /recordings

EXPOSE 80 443
EXPOSE 10000-20000/udp

COPY config /root/samples
COPY run.sh run.sh

ENV DOMAIN jitsi.example.com
ENV YOURSECRET1 jitsi
ENV YOURSECRET2 jitsi
ENV YOURSECRET3 jitsi

VOLUME /keys
VOLUME /recordings

ENTRYPOINT ./run.sh

