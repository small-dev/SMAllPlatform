FROM jolielang/jolie-docker-deployer
MAINTAINER Saverio Giallorenzo <saverio.giallorenzo@gmail.com>
RUN echo Europe/Rome | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
COPY launcher.sh launcher.sh
COPY public public
COPY jsutils.js jsutils.js
COPY reportDelayUtils.ol reportDelayUtils.ol
COPY busEtaAddress.iol busEtaAddress.iol
COPY reportDelay.ol main.ol