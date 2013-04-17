#!/usr/bin/env python

'''
 Minimal web server to serve files
 ! No access controls implemented
'''

import SimpleHTTPServer
import SocketServer
import sys
import os

def usage():
    print "\tMinimal web server\n"
    print "\tUsage: python %s [port]" % sys.argv[0]
    exit(1)
    
def start_server(path, port):
	os.chdir(path)

	Handler = SimpleHTTPServer.SimpleHTTPRequestHandler

	httpd = SocketServer.TCPServer(("", port), Handler)

	print "Serving from %s at port %d" % (path, port)
	httpd.serve_forever()

if __name__ == "__main__":	
	if (len(sys.argv) != 3) :
		 usage()

	path = sys.argv[1]
	port = int(sys.argv[2])

	start_server(path, port)
