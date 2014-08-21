#!/usr/bin/python3
#. Author: Nima Talebi <nima@it.net.au>
#. Date:  2008-05-09

import random
import time

random.seed(time.time())

#. Create the Neural Network machine
from nimachines.nn import NeuralNetwork
nn = NeuralNetwork('xor', [2,8,1])
#nn.draw()

#. Commence Training...
print('#'*80)

#. XOR Training Data
training = [
    [ [0,0], [0] ],
    [ [0,1], [1] ],
    [ [1,0], [1] ],
    [ [1,1], [0] ],
]

#. XOR Training
threshold = 0.00000001
mse = 1
while mse > threshold:
    mse = sum(
        [pow(e[0], 2) for e in map(lambda d:nn.train(*d), training)]
    ) / len(training)
    if(nn.trained % 500 == 0):
        print("%s; e:%9.8f, i:%ld" % (
            list(zip(
                [d[0] for d in training],
                [('%2.3f' % e[0]) for e in map(lambda d:nn.test(d[0]), training)]
            )), mse, nn.trained
        ))

print('#'*80)

#nn.draw()
