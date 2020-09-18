import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 1000;
MAX_BUNDLE_CYCLES = 80;

def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim)])

def gen_vector(Reset, Enable, FirstHypervector, FeatureIn, HypervectorIn, ExpectedHV):
	return ''.join([Reset, Enable, FirstHypervector, bin(FeatureIn,CHANNEL_WIDTH), HVbin(HypervectorIn), HVbin(ExpectedHV)])

file = open('hv_man_vectors.txt', 'w')

# load the connectivity matrix
cm_file = open('conn_mat.txt', 'r')
raw = np.fromstring(cm_file.readline(),'u1') - ord('0')
cm = raw.reshape(MAX_BUNDLE_CYCLES, HV_DIMENSION)

loops = 100

for i in range(MAX_BUNDLE_CYCLES):
	hv_in = np.random.choice([-1, 1], size=HV_DIMENSION)
	man_in = -np.ones(MAX_BUNDLE_CYCLES)
	man_in[i] = 1
	hv_out = np.zeros(HV_DIMENSION)

	for j in range(HV_DIMENSION):
		if cm[i,j] > 0:
			hv_out[j] = -1*hv_in[j]
		else:
			hv_out[j] = hv_in[j]

	vector = ''.join([HVbin(hv_in), HVbin(man_in), HVbin(hv_out)])
	file.write(vector + '\n')

for i in range(loops):
	hv_in = np.random.choice([-1, 1], size=HV_DIMENSION)
	man_in = np.random.choice([-1, 1], size=MAX_BUNDLE_CYCLES)
	man_idx = np.where(man_in > 0)
	hv_out = np.zeros(HV_DIMENSION)

	for j in range(HV_DIMENSION):
		if np.sum(cm[man_idx,j]) > 0:
			hv_out[j] = -1*hv_in[j]
		else:
			hv_out[j] = hv_in[j]

	vector = ''.join([HVbin(hv_in), HVbin(man_in), HVbin(hv_out)])
	file.write(vector + '\n')

			




