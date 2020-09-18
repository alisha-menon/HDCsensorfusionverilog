# Given a sequence of spatial vectors, determine the temporal encoding
# test vector format:
# [ ModeIn | LabelIn | HVIn | ModeOut | LabelOut | HVOut ]
#     2         5      1000      2		   5	   1000

import random
import os
import numpy as np

random.seed(os.urandom(32))

HV_DIMENSION = 1000
LABEL_WIDTH = 5
MODE_WIDTH = 2
NGRAM_Size = 5
max_bundle_cycles = 80
numtests = 822

def bin(x, width):
	if x < 0: x = (~x) + 1
	return ''.join([(x & (1 << i)) and '1' or '0' for i in range(width-1, -1, -1)])

def HVbin(hv):
	dim = len(hv)
	return ''.join(['1' if hv[i] > 0 else '0' for i in range(dim-1,-1,-1)])

def gen_vector(ModeIn, LabelIn, HVIn, ExpectedHV):
	vec = ''.join([bin(ModeIn,MODE_WIDTH), bin(LabelIn,LABEL_WIDTH)])
	temp = HVbin(HVIn)
	vec = vec + temp[::-1]
	vec = vec + ''.join([bin(ModeIn,MODE_WIDTH), bin(LabelIn,LABEL_WIDTH)])
	temp = HVbin(ExpectedHV)
	vec = vec + temp[::-1]
	return vec

def rightRotateby1 (lists): 
    output_list = np.zeros(HV_DIMENSION,dtype=int) 
    # Will add values from n to the new list 
    output_list[0] = lists[HV_DIMENSION-1]
    output_list[1:] = lists[0:HV_DIMENSION-1]    
    return output_list 

def bitwise_xor(x1, x2):
	(x1 != x2).sum()

# get the item memory to use as random inputs
#iM_file = open('iM.txt','r')
iM = []
for ch in range(numtests):
	iM.append(np.random.choice([0, 1], size=HV_DIMENSION))
#for i in range(INPUT_CHANNELS):
#	vec_string = iM_file.readline().rstrip();
#	iM.append(2*((np.fromstring(vec_string,'u1') - ord('0')) - 0.5))

file = open('temporal_encoder_vectors.txt', 'w')

# Predict mode
mode = 0
label = np.random.randint(2**LABEL_WIDTH,size=1)
ExpectedHV = np.zeros(HV_DIMENSION,dtype=int)
NGRAM0 = np.zeros(HV_DIMENSION,dtype=int)
NGRAM1 = np.zeros(HV_DIMENSION,dtype=int)
NGRAM2 = np.zeros(HV_DIMENSION,dtype=int)
NGRAM3 = np.zeros(HV_DIMENSION,dtype=int)
NGRAM4 = np.zeros(HV_DIMENSION,dtype=int)
loops = 64
for i in range(loops):
	# generate random features
	# mode = np.random.randint(2**MODE_WIDTH,size=1)
	# label = np.random.randint(2**LABEL_WIDTH,size=1)
	HVin = iM[i]
	# Calculate expected HV - should just be the NGRAM
	#print(type(HVin[0]))
	#print(type(ExpectedHV[0]))
	ExpectedHV = HVin
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM1)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM2)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM3)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM4)
	NGRAM4 = rightRotateby1(NGRAM3)
	NGRAM3 = rightRotateby1(NGRAM2)
	NGRAM2 = rightRotateby1(NGRAM1)
	NGRAM1 = rightRotateby1(HVin)
	file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n')
	
	
	

#need to define the connectivity matrix
#connectivity_matrix = np.zeros((max_bundle_cycles, HV_DIMENSION));
cm_file = open('conn_mat.txt', 'r')
raw = np.fromstring(cm_file.readline(),'u1') - ord('0')
connectivity_matrix = np.fliplr(raw.reshape(max_bundle_cycles, HV_DIMENSION))





# Train mode, then switch to predict mode, do for multiple labels
#ExpectedNGRAM = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM0 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM1 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM2 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM3 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM4 = np.zeros(HV_DIMENSION,dtype=int)
mode = 1
bundlecycles = 76
numlabels = 4
ngram_counter = 0
label = np.random.randint(2**LABEL_WIDTH,size=1)
for i in range(numlabels):
	# run the bundling in train mode for bundlecycles, then write the train mode and expected 
	row_select = 0
	bundled_vector = np.zeros(HV_DIMENSION,dtype=int)
	for i in range(bundlecycles):
		# calculate NGRAM
		mode = 1
		HVin = iM[i]
		#print(type(HVin[0]))
		#print(type(ExpectedHV[0]))
		ExpectedNGRAM = HVin
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM1)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM2)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM3)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM4)
		NGRAM4 = rightRotateby1(NGRAM3)
		NGRAM3 = rightRotateby1(NGRAM2)
		NGRAM2 = rightRotateby1(NGRAM1)
		NGRAM1 = rightRotateby1(HVin)
		# Bind NGRAMS
		#flippedbundled = bundled_vector
		#print(flippedbundled)
		#print("\n \n")
		# if (ngram_counter >= NGRAM_Size-1):
		# 	for loop_again in range(HV_DIMENSION):
		# 		if connectivity_matrix[row_select,loop_again] == 1:
		# 			#flip
		# 			if flippedbundled[loop_again] == 1:
		# 				flippedbundled[loop_again] = 0
		# 			else:
		# 				flippedbundled[loop_again] = 1
		# 	#print(flippedbundled)
		# 	#print("\n \n")
		# 	for loop_again in range(HV_DIMENSION):
		# 		if (flippedbundled[loop_again] + ExpectedNGRAM[loop_again] + bundled_vector[loop_again]) > 1.5:
		# 			bundled_vector[loop_again] = 1
		# 		else:
		# 			bundled_vector[loop_again] = 0
		# 	#print(bundled_vector)
		# 	#print("\n \n")
		# 	row_select = row_select + 1
		# 	ExpectedHV = bundled_vector
		if i>3:
			sim = np.bitwise_xor(bundled_vector, connectivity_matrix[row_select,:])
			maj = (bundled_vector + sim + ExpectedNGRAM)>1.5
			bundled_vector = maj.astype(int)
			row_select = row_select + 1
			ExpectedHV = bundled_vector
		#print(ExpectedHV)
		#print("\n \n")
		file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # put into train mode with Hvin input, give 76 inputs
		ngram_counter = ngram_counter + 1
	# switch to predict mode
	ngram_counter = 0
	mode = 0
	file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # put into inference mode 
	# change label for next training
	prev = label
	while prev == label:
		label = np.random.randint(2**LABEL_WIDTH,size=1)

# train mode, then switch labels
#ExpectedHV = np.zeros(HV_DIMENSION,dtype=int)
#ExpectedNGRAM = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM0 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM1 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM2 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM3 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM4 = np.zeros(HV_DIMENSION,dtype=int)
mode = 1
label = np.random.randint(2**LABEL_WIDTH,size=1)
bundlecycles = 76
numtests = 4
#bundled_vector = np.zeros(HV_DIMENSION,dtype=int)
for i in range(numtests):
	# run the bundling in train mode for bundlecycles, then write the train mode and expected 
	label = np.random.randint(2**LABEL_WIDTH,size=1)
	row_select = 0
	for i in range(bundlecycles):
		# calculate NGRAM
		mode = 1
		HVin = iM[i]
		ExpectedNGRAM = HVin
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM1)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM2)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM3)
		ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM4)
		NGRAM4 = rightRotateby1(NGRAM3)
		NGRAM3 = rightRotateby1(NGRAM2)
		NGRAM2 = rightRotateby1(NGRAM1)
		NGRAM1 = rightRotateby1(HVin)
		# Bind NGRAMS
		flippedbundled = bundled_vector
		for loop_again in range(0,HV_DIMENSION-1):
			if connectivity_matrix[row_select,loop_again] == 1:
				#flip
				if flippedbundled[loop_again] == 1:
					flippedbundled[loop_again] = 0
				else:
					flippedbundled[loop_again] = 1
		for loop_again in range(HV_DIMENSION):
			if (flippedbundled[loop_again] == 1 and ExpectedNGRAM[loop_again] == 1) or (flippedbundled[loop_again] == 1 and bundled_vector[loop_again] == 1) or (bundled_vector[loop_again] == 1 and ExpectedNGRAM[loop_again] == 1):
				bundled_vector[loop_again] = 1
			else:
				bundled_vector[loop_again] = 0
		row_select = row_select + 1
		ExpectedHV = bundled_vector
		file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # put into train mode with Hvin input, give 76 inputs
	#stay in training, switch label
	mode = 1
	prev = label
	while prev == label:
		label = np.random.randint(2**LABEL_WIDTH,size=1)
	file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # stay in training, switch label

# put into predict mode, then switch to train mode, change label, then predict mode
mode = 0
#ExpectedHV = np.zeros(HV_DIMENSION,dtype=int)
#ExpectedNGRAM = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM0 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM1 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM2 = np.zeros(HV_DIMENSION,dtype=int)
#GRAM3 = np.zeros(HV_DIMENSION,dtype=int)
#NGRAM4 = np.zeros(HV_DIMENSION,dtype=int)
#bundled_vector = np.zeros(HV_DIMENSION,dtype=int)
for i in range(loops):
	# generate random features
	# mode = np.random.randint(2**MODE_WIDTH,size=1)
	# label = np.random.randint(2**LABEL_WIDTH,size=1)
	label = np.random.randint(2**LABEL_WIDTH,size=1)
	HVin = iM[i]
	# Calculate expected HV - should just be the binded NGRAM
	ExpectedHV = HVin
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM1)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM2)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM3)
	ExpectedHV = np.bitwise_xor(ExpectedHV, NGRAM4)
	file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n')
	NGRAM4 = rightRotateby1(NGRAM3)
	NGRAM3 = rightRotateby1(NGRAM2)
	NGRAM2 = rightRotateby1(NGRAM1)
	NGRAM1 = rightRotateby1(HVin)
mode = 1
# run the bundling in train mode for bundlecycles, then writing the input and the mode
label = np.random.randint(2**LABEL_WIDTH,size=1)
row_select = 0
for i in range(bundlecycles):
	# calculate NGRAM
	mode = 1
	HVin = iM[i]
	ExpectedNGRAM = HVin
	ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM1)
	ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM2)
	ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM3)
	ExpectedNGRAM = np.bitwise_xor(ExpectedNGRAM, NGRAM4)
	NGRAM4 = rightRotateby1(NGRAM3)
	NGRAM3 = rightRotateby1(NGRAM2)
	NGRAM2 = rightRotateby1(NGRAM1)
	NGRAM1 = rightRotateby1(HVin)
	# Bind NGRAMS
	flippedbundled = bundled_vector
	for loop_again in range(0,HV_DIMENSION-1):
		if connectivity_matrix[row_select,loop_again] == 1:
			#flip
			if flippedbundled[loop_again] == 1:
				flippedbundled[loop_again] = 0
			else:
				flippedbundled[loop_again] = 1
	for loop_again in range(HV_DIMENSION):
		if (flippedbundled[loop_again] == 1 and ExpectedNGRAM[loop_again] == 1) or (flippedbundled[loop_again] == 1 and bundled_vector[loop_again] == 1) or (bundled_vector[loop_again] == 1 and ExpectedNGRAM[loop_again] == 1):
			bundled_vector[loop_again] = 1
		else:
			bundled_vector[loop_again] = 0
	row_select = row_select + 1
	ExpectedHV = bundled_vector
	file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # put into train mode with Hvin input, give 76 inputs
#stay in training, switch label
prev = label
while prev == label:
	label = np.random.randint(2**LABEL_WIDTH,size=1)
file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # keep in train mode, switch label
#switch back to predict mode
mode = 1
file.write(gen_vector(mode,label,HVin,ExpectedHV) + '\n') # switch to predict mode
