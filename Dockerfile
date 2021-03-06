FROM ubuntu:18.04

MAINTAINER Alexandre DEVELY

LABEL vcs-type "git"
LABEL vcs-url  "https://github.com/abcdesktopio/oc.pulse.18.04/Dockerfile"
LABEL vcs-ref  "master"
LABEL release  "5"
LABEL version  "1.2"
LABEL architecture "x86_64"

# correct debconf: (TERM is not set, so the dialog frontend is not usable.)
ENV DEBCONF_FRONTEND noninteractive
ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y  --no-install-recommends \
        apt-utils                       \
        && apt-get clean

RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends\
        pulseaudio                      \
        pulseaudio-utils                \
	dbus				\
        && apt-get clean


# apt install iproute2 install ip command
# iputils-ping and vin can be removed
# RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y   --no-install-recommends     \
#         iproute2                                                                \
#        && apt-get clean

## DBUS SECTION
RUN 	mkdir -p /var/run/dbus 		&& \
	touch /var/lib/dbus/machine-id  && \
	chown -R $BUSER:$BUSER             \
                /var/run/dbus              \
                /var/lib/dbus              \
                /var/lib/dbus/machine-id

COPY etc/pulse /etc/pulse
RUN  chown -R $BUSER:$BUSER /etc/pulse 

# Next command use $BUSER context
ENV BUSER balloon
# RUN adduser --disabled-password --gecos '' $BUSER
# RUN id -u $BUSER &>/dev/null || 
RUN groupadd --gid 4096 $BUSER
RUN useradd --create-home --shell /bin/bash --uid 4096 -g $BUSER --groups sudo $BUSER
# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
# PASS=ballon
# Change password for user balloon
RUN echo "balloon:lmdpocpetit" | chpasswd $BUSER
# hack: be shure to own the home dir 
RUN chown -R $BUSER:$BUSER /home/$BUSER 	\
    && chown -R $BUSER:$BUSER /etc/pulse	\
    && echo `date` > /etc/build.date

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER balloon

CMD /docker-entrypoint.sh

# expose pulseaudio tcp port
EXPOSE 4714
