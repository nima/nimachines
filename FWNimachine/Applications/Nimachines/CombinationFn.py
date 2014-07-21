#
#  CombinationFn.py
#  SOM
#
#  Created by Nima on 17/11/08.
#  Copyright (c) 2008 Autonomy. All rights reserved.
#

from Foundation import *

################################################################################
#. The Combination Functions
#. Input:  Input-Vector, Weight-Vector
#. Output: Input-Scalar
class CombinationFn(NSObject):
  def __init__(self):
    pass

class Dot(CombinationFn):
  def __init__(self): super(Dot, self).__init__()
  def __call__(self, w, x): return dot(w, x)
  def d(self, x): return x
