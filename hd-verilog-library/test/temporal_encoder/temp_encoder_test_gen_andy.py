import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 1000
LABEL_WIDTH = 5
MODE_WIDTH = 2
NGRAM_Size = 5
max_bundle_cycles = 80

def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim-1,-1,-1)])

def gen_vector(mode,label,hv):
	return ''.join([bin(mode,MODE_WIDTH), bin(label,LABEL_WIDTH), HVbin(hv)])

# get inputs
ex_file = open('example_vectors.txt','r')
ex = []
for i in range(380):
	vec_string = ex_file.readline().rstrip();
	ex.append(np.fromstring(vec_string,'u1') - ord('0'))

vector_file = open('andy_vectors.txt', 'w')
output_file = open('andy_outputs.txt', 'w')
debug_file = open('debug_outputs.txt', 'w')

count = 0

# Predict mode
mode = 0
label = np.random.randint(2**LABEL_WIDTH,size=1)
S0 = np.zeros(HV_DIMENSION,dtype=int)
S1 = np.zeros(HV_DIMENSION,dtype=int)
S2 = np.zeros(HV_DIMENSION,dtype=int)
S3 = np.zeros(HV_DIMENSION,dtype=int)
S4 = np.zeros(HV_DIMENSION,dtype=int)
loops = 76
for i in range(loops):
	S4 = np.roll(S3,-1)
	S3 = np.roll(S2,-1)
	S2 = np.roll(S1,-1)
	S1 = np.roll(S0,-1)
	S0 = ex[count]+0
	NGRAM = np.bitwise_xor(S0, S1)
	NGRAM = np.bitwise_xor(NGRAM, S2)
	NGRAM = np.bitwise_xor(NGRAM, S3)
	NGRAM = np.bitwise_xor(NGRAM, S4)
	
	vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
	output_file.write(gen_vector(mode,label,NGRAM) + '\n')
	debug_file.write(gen_vector(mode,label,NGRAM) + '\n')

	count = count + 1

# Train mode
cm_file = open('conn_mat.txt', 'r')
raw = np.fromstring(cm_file.readline(),'u1') - ord('0')
connectivity_matrix = np.fliplr(raw.reshape(max_bundle_cycles, HV_DIMENSION))
# connectivity_matrix = raw.reshape(max_bundle_cycles, HV_DIMENSION)

bundlecycles = (76,7,19,50)
gestures = (10,20,6,12)
for tests in range(4):
	mode = 1
	label = gestures[tests]
	conn_idx = 0
	bundle = np.zeros(HV_DIMENSION,dtype=int)
	for i in range(bundlecycles[tests]):
		S4 = np.roll(S3,-1)
		S3 = np.roll(S2,-1)
		S2 = np.roll(S1,-1)
		S1 = np.roll(S0,-1)
		S0 = ex[count]+0
		NGRAM = np.bitwise_xor(S0, S1)
		NGRAM = np.bitwise_xor(NGRAM, S2)
		NGRAM = np.bitwise_xor(NGRAM, S3)
		NGRAM = np.bitwise_xor(NGRAM, S4)

		if i>3:
			sim = np.bitwise_xor(bundle, connectivity_matrix[conn_idx,:])
			maj = (bundle + sim + NGRAM)>1.5
			bundle = maj.astype(int)
			conn_idx = conn_idx + 1

		vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
		debug_file.write(gen_vector(mode,label,bundle) + '\n')
		count = count + 1

	# vector_file.write(gen_vector(0,label,ex[count]) + '\n')
	# output_file.write(gen_vector(1,label,bundle) + '\n')
	# debug_file.write(gen_vector(1,label,bundle) + '\n')
	# count = count+1
	
	mode = 0
	loops = 5
	for i in range(loops):
		S4 = np.roll(S3,-1)
		S3 = np.roll(S2,-1)
		S2 = np.roll(S1,-1)
		S1 = np.roll(S0,-1)
		S0 = ex[count]+0
		NGRAM = np.bitwise_xor(S0, S1)
		NGRAM = np.bitwise_xor(NGRAM, S2)
		NGRAM = np.bitwise_xor(NGRAM, S3)
		NGRAM = np.bitwise_xor(NGRAM, S4)
		
		vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
		if i==0:
			output_file.write(gen_vector(1,label,bundle) + '\n')
			debug_file.write(gen_vector(1,label,bundle) + '\n')
		output_file.write(gen_vector(mode,label,NGRAM) + '\n')
		debug_file.write(gen_vector(mode,label,NGRAM) + '\n')

		count = count + 1

# Train mode with changing labels
gestures = (1,2,3)
mode = 1

label = gestures[0]
conn_idx = 0
bundle = np.zeros(HV_DIMENSION,dtype=int)
for i in range(10):
	S4 = np.roll(S3,-1)
	S3 = np.roll(S2,-1)
	S2 = np.roll(S1,-1)
	S1 = np.roll(S0,-1)
	S0 = ex[count]+0
	NGRAM = np.bitwise_xor(S0, S1)
	NGRAM = np.bitwise_xor(NGRAM, S2)
	NGRAM = np.bitwise_xor(NGRAM, S3)
	NGRAM = np.bitwise_xor(NGRAM, S4)

	if i>3:
		sim = np.bitwise_xor(bundle, connectivity_matrix[conn_idx,:])
		maj = (bundle + sim + NGRAM)>1.5
		bundle = maj.astype(int)
		conn_idx = conn_idx + 1
	vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
	debug_file.write(gen_vector(mode,label,bundle) + '\n')
	count = count + 1

prevlabel = label
label = gestures[1]

conn_idx = 0
for i in range(10):
	S4 = np.roll(S3,-1)
	S3 = np.roll(S2,-1)
	S2 = np.roll(S1,-1)
	S1 = np.roll(S0,-1)
	S0 = ex[count]+0
	NGRAM = np.bitwise_xor(S0, S1)
	NGRAM = np.bitwise_xor(NGRAM, S2)
	NGRAM = np.bitwise_xor(NGRAM, S3)
	NGRAM = np.bitwise_xor(NGRAM, S4)

	if i>3:
		sim = np.bitwise_xor(bundle, connectivity_matrix[conn_idx,:])
		maj = (bundle + sim + NGRAM)>1.5
		bundle = maj.astype(int)
		conn_idx = conn_idx + 1
	vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
	debug_file.write(gen_vector(mode,label,bundle) + '\n')
	count = count + 1
	if i==0:
		output_file.write(gen_vector(mode,prevlabel,bundle) + '\n')


prevlabel = label
label = gestures[2]

conn_idx = 0
for i in range(10):
	S4 = np.roll(S3,-1)
	S3 = np.roll(S2,-1)
	S2 = np.roll(S1,-1)
	S1 = np.roll(S0,-1)
	S0 = ex[count]+0
	NGRAM = np.bitwise_xor(S0, S1)
	NGRAM = np.bitwise_xor(NGRAM, S2)
	NGRAM = np.bitwise_xor(NGRAM, S3)
	NGRAM = np.bitwise_xor(NGRAM, S4)

	if i>3:
		sim = np.bitwise_xor(bundle, connectivity_matrix[conn_idx,:])
		maj = (bundle + sim + NGRAM)>1.5
		bundle = maj.astype(int)
		conn_idx = conn_idx + 1
	vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
	debug_file.write(gen_vector(mode,label,bundle) + '\n')
	count = count + 1
	if i==0:
		output_file.write(gen_vector(mode,prevlabel,bundle) + '\n')

mode = 0
loops = 5
for i in range(loops):
	S4 = np.roll(S3,-1)
	S3 = np.roll(S2,-1)
	S2 = np.roll(S1,-1)
	S1 = np.roll(S0,-1)
	S0 = ex[count]+0
	NGRAM = np.bitwise_xor(S0, S1)
	NGRAM = np.bitwise_xor(NGRAM, S2)
	NGRAM = np.bitwise_xor(NGRAM, S3)
	NGRAM = np.bitwise_xor(NGRAM, S4)
	
	vector_file.write(gen_vector(mode,label,ex[count]) + '\n')
	if i==0:
			output_file.write(gen_vector(1,label,bundle) + '\n')
			debug_file.write(gen_vector(1,label,bundle) + '\n')
	output_file.write(gen_vector(mode,label,NGRAM) + '\n')
	debug_file.write(gen_vector(mode,label,NGRAM) + '\n')

	count = count + 1


