import random
import time

class Link:
    '''A Link joins two nodes'''
    lnid = 0
    def __init__(self, parent, child):
        '''A link has exactly 1 child, and 1 parent, both of them being of type Node'''
        random.seed(time.time())
        self._lnid = Link.lnid
        self._parent = parent
        self._child = child

        #. Set the initial weights to a very small random value...
        self._weight = 1.0
        if parent.get_type() != "bias":
            self._weight *= (random.random()-0.5)/100

        self._child.parents[parent] = self
        self._parent.children[child] = self

        Link.lnid += 1

    def __str__(self):
        return "(%d) %s === %.5f ===> %s"%(self._lnid, self._parent, self._weight, self._child)

    def get_parent(self):
        return self._parent

    def get_child(self):
        return self._child

    def set_weight(self, weight):
        self._weight = weight

    def get_weight(self):
        return self._weight

    def get_input(self):
        '''Input to this link is the output of the parent node'''
        return self._parent.get_output()

    def get_error(self):
        '''Error is the child node's error'''
        return self._child.get_error()
