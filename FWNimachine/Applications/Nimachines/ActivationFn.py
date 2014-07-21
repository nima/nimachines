#
#  ActivationFn.py
#  SOM
#
#  Created by Nima on 17/11/08.
#  Copyright (c) 2008 Autonomy. All rights reserved.
#

from Foundation import *

################################################################################
#. The Activation Functions
#. Input: Output-Scalar
#. Output: Quantized-Output-Scalar
class ActivationFn(NSObject):
  def __init__(self, eFn):
    self.errorFn = eFn

class Threshold(ActivationFn):
  def __init__(self, eFn): super(Threshold, self).__init__(eFn)
  def __call__(self, z): return sign(z)
  def e(self, t, z): return sign(t - z)

class Sigmoid(ActivationFn):
  def __init__(self, A, B, c, eFn):
    super(Sigmoid, self).__init__(eFn)
    self.A = A
    self.B = B
    self.c = c
    self.eFn = eFn
  def __call__(self, o): return self.A + self.B/(1 + exp(-self.c*o))
  def d(self, o):
    z = self(o)
    return self.c*(z - self.A)*(self.B - z + self.A)/self.B
  def e(self, t, o):
    z = self(o)
    return self.eFn(t, z)*self.d(t, o)
