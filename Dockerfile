FROM lsiobase/alpine:3.6
MAINTAINER Gonzalo Peci <davyjones@linuxserver.io>, sparklyballs

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
ENV LOCAL_NETWORK=
ENV OPENVPN_USERNAME=**None**
ENV OPENVPN_PASSWORD=**None**
ENV OPENVPN_PROVIDER=**None**
ENV OPENVPN_CONFIG=**None**
ENV PUID=999
ENV PGID=999

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

RUN mkdir -p /etc/openvpn

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libffi-dev \
	openssl-dev \
	py2-pip \
	python2-dev && \

# install runtime packages
 apk add --no-cache \
	ca-certificates \
	curl \
	openssl \
	p7zip \
	unrar \
	unzip \
	openvpn \
	dcron

RUN \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	deluge \
	dockerize

# install pip packages
 RUN \
  pip install --no-cache-dir -U \
	incremental \
	pip && \
  pip install --no-cache-dir -U \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface

# cleanup
RUN apk del --purge build-dependencies

RUN rm -rf /root/.cache

# Create user and group
RUN addgroup -S -g 2001 media
RUN usermod -d /config -u 1001 -G media -s /bin/nologin transmission

# add local files
COPY root/ /
COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/
COPY init/ /etc/init.d/
COPY /cron/root /etc/crontabs/root

RUN rc-update add openvpn-serv default
RUN rc-update add dcron default

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config /downloads