# Given 64 features, calculate the associated spatial vector
# test vector format:
# [ ModeIn | LabelIn | ChannelsIn | ModeOut | LabelOut | HVOut ]
#     2         5         64*6         2		 5		  1000

import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 1000;
CHANNEL_WIDTH = 6;
LABEL_WIDTH = 5;
INPUT_CHANNELS = 64;
MODE_WIDTH = 2;

def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim-1,-1,-1)])

def gen_vector(ModeIn, LabelIn, ChannelsIn, ExpectedHV):
	vec = ''.join([bin(ModeIn,MODE_WIDTH), bin(LabelIn,LABEL_WIDTH)])
	vec = vec + ''.join([bin(ChannelsIn[i],CHANNEL_WIDTH) for i in range(INPUT_CHANNELS-1,-1,-1)])
	vec = vec + ''.join([bin(ModeIn,MODE_WIDTH), bin(LabelIn,LABEL_WIDTH)])
	vec = vec + HVbin(ExpectedHV)
	return vec

# get the item memory
iM_file = open('iM.txt','r')
iM = [];
for i in range(INPUT_CHANNELS):
	vec_string = iM_file.readline().rstrip();
	iM.append(2*((np.fromstring(vec_string,'u1') - ord('0')) - 0.5))

file = open('spatial_encoder_vectors.txt', 'w')

loops = 100
for i in range(loops):
	# generate random features
	feat = np.random.randint(2**CHANNEL_WIDTH, size=INPUT_CHANNELS)
	mode = np.random.randint(2**MODE_WIDTH,size=1)
	label = np.random.randint(2**LABEL_WIDTH,size=1)
	
	# loop through channels
	result = np.zeros(HV_DIMENSION)
	for ch in range(INPUT_CHANNELS):
		result = result + (iM[ch]*feat[ch])
	
	file.write(gen_vector(mode[0],label[0],feat,result) + '\n')
			




