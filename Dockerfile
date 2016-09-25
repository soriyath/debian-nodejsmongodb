FROM soriyath/debian-swissfr
MAINTAINER Sumi Straessle

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
	&& echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN apt-get update -qq \
	&& apt-get install -y --fix-missing wget build-essential python mongodb-org=3.2.9 mongodb-org-server=3.2.9 mongodb-org-shell=3.2.9 mongodb-org-mongos=3.2.9 mongodb-org-tools=3.2.9

ADD mongodb.conf $ROOTFS/etc/mongodb.conf

# NODEJS 5.12.0
RUN	set -ex \
	&& apt-get update \
	&& apt-get install -y wget build-essential
WORKDIR /usr/local/src
RUN wget https://nodejs.org/dist/v5.12.0/node-v5.12.0.tar.gz \
	&& tar -xzvf node-v5.12.0.tar.gz && rm -f node-v5.12.0.tar.gz \
	&& cd node-v5.12.0 \
	&& ./configure \
	&& make -j $(cat /proc/cpuinfo | grep processor | wc -l)\
	&& make install

RUN apt-get clean \
	&& apt-get autoremove \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /srv/www
EXPOSE 27017 28017

# Supervisor config file
ADD mongodb.sv.conf /etc/supervisor/conf.d/mongodb.sv.conf

# default command
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
