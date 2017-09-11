FROM node:8.4.0-wheezy
MAINTAINER Jakob Engdahl <jakobengdahl@gmail.com>

RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

WORKDIR /usr/src/node-red

COPY package.json /usr/src/node-red/
RUN npm install

# User configuration directory volume
VOLUME ["/data"]
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json

# Add Telldus repository
RUN mkdir -p /etc/apt/sources.list.d/
RUN echo "deb-src http://download.telldus.com/debian/ stable main" >> /etc/apt/sources.list.d/telldus.list
RUN curl -sSL http://download.telldus.se/debian/telldus-public.key | apt-key add -

# Install dependencies. Compile and install telldusd
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get build-dep -y telldus-core
RUN apt-get install -y cmake libconfuse-dev libftdi-dev help2man
RUN apt-get --compile source telldus-core
RUN dpkg --install *.deb

COPY tellstick.conf /etc/tellstick.conf
RUN npm install node-red-contrib-tellstick

# Install and configure Supervisor
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Specify health check for Docker
HEALTHCHECK CMD curl --fail http://localhost:1880 || exit 1
