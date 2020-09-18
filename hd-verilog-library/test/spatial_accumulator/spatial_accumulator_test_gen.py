# sum 64 random vectors with random feature values and check result
# test vector format:
#[ Reset | Enable | FirstHypervector |   FeatureIn   | HypervectorIn |  ExpectedHV  ]
#    1        1             1          CHANNEL_WIDTH    HV_DIMENSION   HV_DIMENSION

import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 10;
CHANNEL_WIDTH = 6;
INPUT_CHANNELS = 64;

def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim-1,-1,-1)])

def gen_vector(Reset, Enable, FirstHypervector, FeatureIn, HypervectorIn, ExpectedHV):
	return ''.join([Reset, Enable, FirstHypervector, bin(FeatureIn,CHANNEL_WIDTH), HVbin(HypervectorIn), HVbin(ExpectedHV)])

file = open('spatial_accumulator_vectors.txt', 'w')

# strobe reset
file.write(gen_vector('0','0','0',0,np.zeros(HV_DIMENSION), np.zeros(HV_DIMENSION)) + '\n')
file.write(gen_vector('1','0','0',0,np.zeros(HV_DIMENSION), np.zeros(HV_DIMENSION)) + '\n')
file.write(gen_vector('0','0','0',0,np.zeros(HV_DIMENSION), np.zeros(HV_DIMENSION)) + '\n')

# hv = np.random.choice([-1.0, 1.0], size=HV_DIMENSION)
# print(hv)
# out = HVbin(hv)
# print(out) 

loops = 1
result = np.zeros(HV_DIMENSION)
for i in range(loops):
	# generate 64 random hypervectors
	iM = []
	for ch in range(INPUT_CHANNELS):
		iM.append(np.random.choice([-1.0, 1.0], size=HV_DIMENSION))

	# generate random features
	feat = np.random.randint(2**CHANNEL_WIDTH, size=INPUT_CHANNELS)

	# loop through channels
	for ch in range(INPUT_CHANNELS):
		if ch == 0:
			result = iM[ch]*feat[ch]
			file.write(gen_vector('0','1','1',feat[ch],iM[ch],result) + '\n')
			
		else:
			result = result + (iM[ch]*feat[ch])
			file.write(gen_vector('0','1','0',feat[ch],iM[ch],result) + '\n')
			




