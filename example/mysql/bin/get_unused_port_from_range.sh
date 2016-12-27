#!/usr/bin/env python

import sys
import socket
import random

from_port = int(sys.argv[1])
to_port = int(sys.argv[2])

ports = list(range(from_port, to_port))
random.shuffle(ports)

for port in ports:
    # print("Trying port %s" % port)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(('', port))
    except:
        # print("Port %s is used" % port)
        continue
    addr = s.getsockname()
    print(addr[1])
    s.close()
    break

if port == to_port:
    raise Exception("Port range %s - %s not available to bind" % (from_port, to_port))
