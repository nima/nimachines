#
#  ErrorFn.py
#  SOM
#
#  Created by Nima on 17/11/08.
#  Copyright (c) 2008 Autonomy. All rights reserved.
#

from Foundation import *

################################################################################
#. The Error Functions
#. Input: Target-Scalar, Quantized-Output-Scalar
class ErrorFn(NSObject):
  def __init__(self):
    pass

class SumOfSquares(ErrorFn):
  def __init__(self): super(SumOfSquares, self).__init__()
  def __call__(self, t, z): return 0.5*(t - z)**2
  def d(self, t, z):  return (z - t)
