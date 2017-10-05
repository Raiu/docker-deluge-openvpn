FROM lsiobase/alpine:3.6
MAINTAINER Viktor Näslund <naslund.viktor@gmail.com>, Raiu

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
ENV LOCAL_NETWORK=
ENV OPENVPN_USERNAME=**None**
ENV OPENVPN_PASSWORD=**None**
ENV OPENVPN_PROVIDER=**None**
ENV OPENVPN_CONFIG=**None**
ENV PUID=999
ENV PGID=999

RUN mkdir -p /etc/openvpn

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config /downloads

# install build packages
RUN \
	apk add --no-cache --virtual=build-dependencies \
		g++ \
		gcc \
		libffi-dev \
		openssl-dev \
		libressl-dev \
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
		shadow \
		openvpn \
		dcron && \

	apk add --no-cache \
		--repository "http://nl.alpinelinux.org/alpine/edge/testing" \
		deluge && \

	apk add --no-cache \
		--repository "http://nl.alpinelinux.org/alpine/edge/main" \
		libressl2.5-libssl

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
RUN apk del --purge build-dependencies \
	rm -rf /root/.cache

# Create user and group
RUN addgroup -S -g 999 media && \
	adduser -SH -u 999 -G media -s /sbin/nologin -h /config deluge

# add local files
RUN rm /etc/init.d/openvpn
COPY etc/ /etc/
COPY openvpn/ /etc/openvpn/

RUN rc-update add openvpn-serv default
RUN rc-update add dcron default