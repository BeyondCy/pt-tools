#!/usr/bin/python

# Get time from time daemon on port 37 
# http://en.wikipedia.org/wiki/Time_Protocol

import sys
import socket
import struct
import time

def usage():
    print " -- Query port 37 and get the time from a server --\n"
    print "Usage: python %s [server]" % sys.argv[0]
    exit(1)
    
if (len(sys.argv) != 2) :
    usage()
    
host = sys.argv[1]
port = 37

print "Connect to %s ..." % host
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))

data = s.recv(1024)

s.close()

# 32-bit unsigned integer, in network byte order (big endian)
seconds = struct.unpack(">I", data)[0]
print "%u seconds since 1 January 1900 - 00:00:00" % seconds

epoch_delta = 2208988800L # 1970-01-01 00:00:00
print "%u seconds since Unix epoch (1 January 1970 - 00:00:00)" % (seconds -epoch_delta)

print "Time on server is ", time.ctime(seconds - epoch_delta)
