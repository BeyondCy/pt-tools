#!/usr/bin/python

'''
	SMTP Send email
'''

import smtplib
import sys

def usage():
    print "Usage:\n ./send.pl [sender address] [dest address] [mail server] [verbose (0|1)]\n"
    sys.exit(1)
    
if (len(sys.argv) != 5) :
    usage()
    
sender = sys.argv[1]
server = sys.argv[3]
# must be a list!
target = [sys.argv[2]]  

if (sys.argv[4] == "1"):
	verbose = True
else:
	verbose = False

# Prepare actual message
subject = "Hello!"
data = "This message was sent with Python's smtplib."

message = (
	"From: %s\n"
	"To: %s\n"
	"Subject: %s\n"
	"Content-type: text/html\n"
	"\n"	# newline before message body
	"%s") % (sender, ", ".join(target), subject, data)

# Send the mail
try:
	smtp = smtplib.SMTP(server)
	smtp.set_debuglevel(verbose)
	smtp.helo('example.com')		
	smtp.sendmail(sender, target, message)
	print "Successfully sent!"
	smtp.quit()
except smtplib.SMTPException:
   print "Error: unable to send email"

