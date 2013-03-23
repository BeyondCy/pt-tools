#!/usr/bin/python

import httplib
import mimetypes
import sys

def post_multipart(host, selector, headers, filename):
    content_type, body = encode_multipart_formdata(filename)

    h = httplib.HTTPConnection(host)
    headers['Content-Type'] = content_type
    headers['Content-length'] = str(len(body))

    h.request('POST', selector, body, headers)
    res = h.getresponse()
    return res.status, res.reason, res.read()


def encode_multipart_formdata(filename):
    BOUNDARY = '----------------------------B0und4rY$$!'
    CRLF = '\r\n'
    L = []

    L.append('--' + BOUNDARY)
    L.append('Content-Disposition: form-data; name="Filename"')
    L.append('')
    L.append("X.jpg")

    L.append('--' + BOUNDARY)
    L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % ('Filedata', "X.jpg"))
    L.append('Content-Type: %s' % 'application/octet-stream')
    L.append('')
    L.append(open(filename).read())
    
    L.append('--' + BOUNDARY + '--')    
    L.append('Content-Disposition: form-data; name="%s"' % "Upload")
    L.append('')
    L.append('Submit Query')

    L.append('--' + BOUNDARY + '--')
    L.append('')

    body = CRLF.join(L)
    content_type = 'multipart/form-data; boundary=%s' % BOUNDARY

    return content_type, body

if __name__=="__main__":
    selector = "/a/b/c HTTP/1.1"
    headers =  {
        "Host" : "A.B.C.D", 
 			# ...
    }

    (status, reason, message) = post_multipart(headers[host], selector, headers, "X.jpg")
    print status
    print reason
    print message
