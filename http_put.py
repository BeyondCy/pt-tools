#!/usr/bin/python

'''
http://pydoc.org/2.4.1/httplib.html
'''

import httplib
import sys

def usage():
    print " -- Upload files to an HTTP server suporting the PUT method --\n"
    print "Usage: python %s [address] [port] [url path] [file]" % sys.argv[0]
    print ("\taddress  - http server address\n"
          "\tport      - http server port\n"
          "\turl_path  - URL where file will be uploaded\n"
          "\tfile      - local file to be uploaded\n")
    print "E.g. python %s 192.168.11.203 80 /remte_file local_file.txt" % sys.argv[0]
    exit(1)
    
if (len(sys.argv) != 5) :
    usage()

srv_name    = sys.argv[1]
srv_port    = sys.argv[2]
url_path    = sys.argv[3]
file_name   = sys.argv[4]
f           = open(file_name, 'r')
    
connection =  httplib.HTTPConnection(srv_name + ":" + srv_port)
body_content = f.read()
connection.request('PUT', url_path, body_content)
response = connection.getresponse()

print "Status: %s" % str(response.status)
print "Message: %s" % response.reason
print "Headers:"
for h in response.getheaders():
    print h
print "Body:"    
print response.read()
