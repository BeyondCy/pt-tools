#!/usr/bin/env python 

'''
Split a binary file into parts to test them against AV detection

Split methods:

1. Split the file in even size blocks
2. Split in blocks incrementally larger by [blocksize]
3. Remove block n from every file

'''


import sys

# Split the file in even size blocks
def split1(filename):
	f = open(filename, 'rb')
	
	idx = 0
	for block in iter(lambda: f.read(blocksize), ''):
		out_f = open('out1/out_%04d' % idx, 'wb')
		out_f.write(block)
		idx += 1
		out_f.close()

	f.close()

	print '[*] %d files generated' % idx

# Split in block incrementally larger by [blocksize]
def split2(filename):
    f = open(filename, 'rb')

    current = ''
    idx = 0
    for block in iter(lambda: f.read(blocksize), ''):
        out_f = open('out2/out_%04d' % idx, 'wb')
        out_f.write(current + block)
        idx += 1
        out_f.close()
        current += block

    f.close()

    print '[*] %d files generated' % idx

# Split in binaries having the block i removed
def split3(filename):
	f = open(filename, 'rb')
	
	blocks = []	
	for block in iter(lambda: f.read(blocksize), ''):
		blocks.append(block)

	for idx in xrange(len(blocks)):
		out_f = open('out3/out_%04d' % idx, 'wb')
		blocks_before = "".join(blocks[:idx])
		blocks_after = "".join(blocks[idx + 1:])
		out_f.write(blocks_before + blocks_after)
		out_f.close()

	print '[*] %d files generated' % len(blocks)
	
if __name__=="__main__":	
	if len(sys.argv) != 4:
		print 'Usage: ./%s [method] [blocksize] [filename]' % (sys.argv[0])
		print 'Supported methods: \n'\
			'\t1. Split the file in even size blocks\n'\
			'\t2. Split in blocks incrementally larger by [blocksize]\n'\
			'\t3. Remove block n from every file\n'
			
		sys.exit()

	method = int(sys.argv[1])
	blocksize = int(sys.argv[2])	# in bytes
	filename = sys.argv[3]

	if method == 1:
		split1(filename)
	elif method == 2:
		split2(filename)
	elif method == 3:
		split3(filename)
	else:
		print '[-] Invalid split method!\n'
