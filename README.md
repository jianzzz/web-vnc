web-vnc

visit url: http://ip:6080/vnc_auto.html

password: 
if you set VNC_PASSWORD="no" in Dockerfile, then use no password;   
if you set VNC_PASSWORD="" in Dockerfile, then we generate random password in start-vnc.sh,   
otherwise we use the VNC_PASSWORD value as password;   
we export the password, you can see it's value by environment variable VNC_PASSWORD;

1、ubuntu-trusty-fluxbox-vnc
xvfb: x-server
fluxbox: window manager
x11vnc: vnc server
novnc: web vnc agent
 
2、ubuntu-trusty-openbox-vnc
xvfb: x-server
openbox: window manager
x11vnc: vnc server
novnc: web vnc agent

3、centos-7-openbox-vnc
xvfb: x-server
openbox: window manager
x11vnc: vnc server
novnc: web vnc agent


As you can see, I always run supervisor after xvfb、openbox、x11vnc、novnc. And I can see the program's result when I run 'docker logs XXX'.  
  
But something different in example/mysql, because its based-image use ENTRYPOINT and CMD in its Dockerfile to start mysqld,and I move this work to supervisor.  
However, I do not directly use ENTRYPOINT["supervisord"], why?  
------>I may run a mysql container named 'test', and run another mysql container who link to 'test' and use `/bin/bash -c "..."` in `docker run` command. Cause I use ENTRYPOINT["supervisord"] in Dockerfile, such `docker run` arguments will be regarded as supervisor's input-argument, and then cause problem.  
------>So I run supervisor in shell file, and entrypoint this file.

Another problem is that I use `wait "${SUPERVISOR_PID}"` to tells bash to wait until child processes have exited.   
If we want `/bin/bash -c "..."` takes effect, we should run `exec "$@"` before `wait "${SUPERVISOR_PID}"`, see example/mysql/docker/entrypoint.sh.  

You can see the difference in Dockerfile、docker-entrypoint.sh、supervisord.conf.

