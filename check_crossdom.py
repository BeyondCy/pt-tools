#!/usr/bin/python
import urllib2
import sys

'''
	Check crossdomain files which accept all hosts
'''

fname = "crossdomain.xml"

hosts_file = open('hosts.txt', 'r')

for line in hosts_file:
    host = line.strip()
    
    print "Trying host: %s" % (host)
    try:
        response = urllib2.urlopen("http://" + host + "/" + fname, timeout = 2 )
    except Exception, e:
        print "\t" , e
        continue
    
    print "crossdomain found on %s" % (host)
    cross_dom = response.read()
    
    if "domain=\"*\"" in cross_dom:
        print "[+] Accept all found on host: %s" % (host)

hosts_file.close()
