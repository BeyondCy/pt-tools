'''
	Decode simple CAPTCHAs. 
	Tested on Windows XP, using python 2.7, pytesser and PIL
	Tested on Ubuntu 12.10, with Tesseract Engine v3.02 and Pytesser
	(Should work on Linux as long as tesseract executable is in $PATH)
	
	pytesser:
		http://code.google.com/p/pytesser
	Python Image Library:
		http://www.pythonware.com/products/pil/
'''

import sys
import os

from PIL import Image
from pytesser import *

images = [
    'captcha_1.png',
    'captcha_2.png',
    'captcha_3.png',
    'captcha_4.png',
    'captcha_5.png'
    ]

for image in images:
    # Convert from PNG to GIF
    # http://nadiana.com/pil-tips-converting-png-gif
    im = Image.open(image)
    im = im.convert('RGB').convert('P', palette=Image.ADAPTIVE)
    im.save(image + '.gif')

    im_gif = Image.open(image + '.gif')
    im_gif.save(image + '.tif')

    # Perform OCR using pytesser library on TIF image    
    tif_img = Image.open(image + '.tif')
    print "Extracted from TIF: " , image_to_string(tif_img).strip()
    
    # Try to extract text also from PNG
    text = image_file_to_string(image, graceful_errors=True)
    print "Extracted from PNG: %s\n" % text.strip()

