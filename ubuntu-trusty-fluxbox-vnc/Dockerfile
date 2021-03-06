FROM daocloud.io/library/ubuntu:trusty-20151028
MAINTAINER DockerJian<Keith_me_please@163.com>
 
# replace sources
ADD sources.list /etc/apt/sources.list

#	netcat-openbsd : inlcues `nc` an arbitrary TCP and UDP connections and listens
#	x11-xserver-utils : include xsetroot
#	x11-utils : include xdpyinfo

RUN  	apt-get update \
    	&& apt-get install -y \
	pwgen \
      curl \
	unzip \
	wget \	
	sudo \
	vim \
	net-tools \
	netcat-openbsd \
	grep \ 
	xvfb \ 
	fluxbox \
	x11-xserver-utils \
	x11-utils \
	x11vnc \
	supervisor 
  
RUN apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
  
########################################
# noVNC to expose VNC via an html page
########################################
# Download novnc/noVNC dated 2016-12-20 commit 558544364cf0d1f91d18b3a5768db8c8292f7ff6
# Download kanaka/websockify dated 2016-10-10 commit cb1508fa495bea4b333173705772c1997559ae4b
ENV NOVNC_SHA="558544364cf0d1f91d18b3a5768db8c8292f7ff6" \
    WEBSOCKIFY_SHA="cb1508fa495bea4b333173705772c1997559ae4b"
RUN wget -nv -O noVNC.zip \
        "https://github.com/novnc/noVNC/archive/${NOVNC_SHA}.zip" \
  	&& unzip -x noVNC.zip \
  	&& mv noVNC-${NOVNC_SHA} noVNC \
	&& rm noVNC.zip \
	&& wget -nv -O websockify.zip \
	  "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
	&& unzip -x websockify.zip \
	&& rm websockify.zip \
	&& mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify
 
#======
# Envs
#======
#DISP_N : Display number; see docker-entrypoint.sh for $DISPLAY
#XMANAGER : openbox|fluxbox
#VNC_PASSWORD : if value is "no", then use no password; otherwides use password
ENV BIN_UTILS="/usr/bin" \
    LOGS_DIR="/var/log/container" \
    WAIT_TIMEOUT="45s" \

    XMANAGER="fluxbox" \
    FLUXBOX_START_MAX_RETRIES=5 \

    WAIT_VNC_FOREGROUND_RETRY="7s" \
    VNC_STORE_PWD_FILE="/root/.vnc/passwd" \
    VNC_PORT="5900" \ 
    VNC_PASSWORD="" \ 
    NOVNC_PORT="6080" \ 
  
    DISP_N="-1" \ 
    MAX_DISPLAY_SEARCH=99 \
    WAIT_FOREGROUND_RETRY="2s" 


RUN 	mkdir -p /root/.vnc \ 
	&& mv noVNC /root/ 

COPY 	bin/* ${BIN_UTILS}/
RUN  	chmod u+x,g+x ${BIN_UTILS}/*
 
COPY  conf/fluxbox/init /root/.fluxbox/
 
COPY  conf/supervisor/supervisord.conf /etc/supervisor/ 

EXPOSE 6080

COPY	docker-entrypoint.sh /entrypoint.sh
RUN 	chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
