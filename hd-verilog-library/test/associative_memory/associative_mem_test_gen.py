import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 1000
LABEL_WIDTH = 5
MODE_WIDTH = 2 
CLASSES = 21

MODE_PREDICT = '00'
MODE_TRAIN = '01'
MODE_UPDATE = '11'

def HammingSearch(query, AM):
	label = 0
	dist = HV_DIMENSION
	for e in range(len(AM)):
		test = AM[e] + 0;
		temp = sum(test != query)
		if temp < dist:
			dist = temp
			label = e
	return label, dist


def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim-1,-1,-1)])

file_vectors = open('associative_mem_vectors.txt', 'w')
file_predictions = open('associative_mem_correct_predictions.txt', 'w')

file_merge = open('merge_bits.txt','r')
vec_string = file_merge.readline().rstrip();
merge_bits = np.flip(np.fromstring(vec_string,'u1') - ord('0'),axis=0)

loops = 1
for i in range(loops):
	# generate the AM vectors and train
	AM = []
	for c in range(CLASSES):
		AM.append(np.random.choice([0, 1], size=HV_DIMENSION))
		file_vectors.write(MODE_TRAIN + bin(c,LABEL_WIDTH) + HVbin(AM[c]) + '\n')

	# predict with the same vectors
	for c in range(CLASSES):
		file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(AM[c]) + '\n')
		file_predictions.write('Label: %d \t Distance: %d \n' % (c, 0))

	# predict with modifications of each of the actual vectors
	for c in range(CLASSES):
		idx = np.random.permutation(HV_DIMENSION)
		for d in range(10,301,10):
			vec = AM[c] + 0
			# print(vec)
			vec[idx[0:d]] = -1*(vec[idx[0:d]] - 0.5) + 0.5
			file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(vec) + '\n')
			file_predictions.write('Label: %d \t Distance: %d \n' % HammingSearch(vec, AM))

	# predict with random vectors
	for c in range(100):
		vec = np.random.choice([0, 1], size=HV_DIMENSION)
		file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(vec) + '\n')
		file_predictions.write('Label: %d \t Distance: %d \n' % HammingSearch(vec, AM))

	# update with similar vectors
	AM_update = []
	for c in range (CLASSES):
		sim = AM[c] + 0
		idx = np.random.permutation(HV_DIMENSION)
		sim[idx[0:200]] = -1*(sim[idx[0:200]] - 0.5) + 0.5
		file_vectors.write(MODE_UPDATE + bin(c,LABEL_WIDTH) + HVbin(sim) + '\n')

		for element in range(HV_DIMENSION):
			if merge_bits[element]:
				AM[c][element] =sim[element] + 0

	# predict with the same vectors
	for c in range(CLASSES):
		file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(AM[c]) + '\n')
		file_predictions.write('Label: %d \t Distance: %d \n' % (c, 0))

	# predict with modifications of each of the actual vectors
	for c in range(CLASSES):
		idx = np.random.permutation(HV_DIMENSION)
		for d in range(10,301,10):
			vec = AM[c] + 0
			# print(vec)
			vec[idx[0:d]] = -1*(vec[idx[0:d]] - 0.5) + 0.5
			file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(vec) + '\n')
			file_predictions.write('Label: %d \t Distance: %d \n' % HammingSearch(vec, AM))

	# predict with random vectors
	for c in range(100):
		vec = np.random.choice([0, 1], size=HV_DIMENSION)
		file_vectors.write(MODE_PREDICT + bin(0,LABEL_WIDTH) + HVbin(vec) + '\n')
		file_predictions.write('Label: %d \t Distance: %d \n' % HammingSearch(vec, AM))




	
			




