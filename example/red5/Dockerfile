FROM daocloud.io/library/centos:7
MAINTAINER DockerJian<Keith_me_please@163.com>

# replace sources
ADD 	CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
 
#	nmap-ncat.x86_64 :inlcues `nc` an arbitrary TCP and UDP connections and listens
#	xorg-x11-server-utils.x86_64: include xsetroot
#	xorg-x11-utils.x86_64: include xdpyinfo
#	before install pwgen..., we should extend epel first
RUN   yum update -y 
RUN   yum install -y \
	epel-release 

RUN   yum install -y \
	pwgen \
      curl \
	unzip \
	wget \	
	sudo \
	vim \
	net-tools \
	nmap-ncat \
	grep \ 
	xorg-x11-server-Xvfb \ 
	xorg-x11-server-utils \
	xorg-x11-utils \
	xorg-x11-fonts* \
	openbox \
	xfce4-terminal \
	x11vnc \
	python-setuptools && easy_install supervisor 
 
RUN 	yum install -y java-1.7.0-openjdk.x86_64 giflib-devel libjpeg-devel freetype-devel gcc-c++ make
   
RUN 	yum clean all

####################
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
#XMANAGER : we support openbox in centos
#VNC_PASSWORD : if value is "no", then use no password; otherwides use password
ENV BIN_UTILS="/usr/bin" \
    LOGS_DIR="/var/log/container" \
    WAIT_TIMEOUT="45s" \

    XMANAGER="openbox" \
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
 
COPY  conf/openbox/menu.xml /etc/xdg/openbox/
 
COPY  conf/supervisor/supervisord.conf /etc/supervisor/ 

EXPOSE 6080
####################

COPY  red5-server-1.0.7-M5.tar.gz Apache_OpenOffice_4.1.2_Linux_x86-64_install-rpm_zh-CN.tar.gz swftools-2013-04-09-1007.tar.gz /tmp/

RUN 	tar -xzvf /tmp/red5-server-1.0.7-M5.tar.gz -C /usr/local/ 

RUN	tar -xzvf /tmp/Apache_OpenOffice_4.1.2_Linux_x86-64_install-rpm_zh-CN.tar.gz -C /usr/local/ \
	&& rpm -ivh /usr/local/zh-CN/RPMS/*.rpm 
	
RUN	tar -xzvf /tmp/swftools-2013-04-09-1007.tar.gz -C /usr/local/  \
	&& cd /usr/local/swftools-2013-04-09-1007 \
	&& ./configure --prefix=/usr/local/swftools \
	&& make \
	&& make install \
	&& make clean \
	&& make distclean 

RUN 	rm -rdf /tmp/* /usr/local/zh-CN /usr/local/swftools-2013-04-09-1007	 
  
ENV	SWFTOOLS_HOME=/usr/local/swftools \
	PATH=$PATH:$SWFTOOLS_HOME/bin

EXPOSE  5080 1935 8100 

VOLUME  /usr/local/red5-server/webapps/

COPY	docker-entrypoint.sh /entrypoint.sh
RUN 	chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
