#
#  Perceptron.py
#  SOM
#
#  Created by Nima on 17/11/08.
#  Copyright (c) 2008 Autonomy. All rights reserved.
#

from Foundation import *

class Perceptron(NSObject):
  seed(time())

  def __init__(self, lR, data):
    super(NSObject, self).__init__()

    self.w = array([random()/1, random()/1, random()/1]);

    self.lR = lR
    self.inputs  = []
    self.targets = []
    for x in data.keys():
      self.inputs.append(array([1]+list(x)))  #. The supplied input signal tuple
      self.targets.append(data[x])

    #self.fn = Threshold()
    self.errorFn = SumOfSquares()
    self.activationFn = Sigmoid(-1, 2, 1, self.errorFn)
    self.combinationFn = Dot()

    converged = 0
    sweep = 0
    while converged < len(self.inputs):
      converged = 0
      sweep += 1
      #. sweep...
      for i in range(len(self.inputs)):
        #. epoch...
        x = self.inputs[i]                  #. The supplied input signal tuple
        t = self.targets[i]                 #. The target value
        o = self.combinationFn(self.w, x)   #. The output (activity) of the neuron pre-activation-fn
        z = self.activationFn(o)            #. The output (activity) of the neuron post-activation-fn
        E = self.errorFn(t, z)
        dE = self.activationFn.d(o)*self.errorFn.d(t, z)*self.combinationFn.d(x)
        self.w -= self.lR * dE
        if sweep % 1000 == 0:
          print "target", t, "output", z, "E", E, "dE", dE, "w", self.w, "x", x

  def dump(self):
    print "0 = %.2f + %.2f*x1 + %.2f*x2"%(tuple(self.w))
    print "0 = %.2f + %.2f*x + %.2f*y"%(tuple(self.w))