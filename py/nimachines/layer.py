from .node import InputNode, Neuron

class Layer:
    lid = 0
    def __init__(self, size, with_bias_node=True):
        self._lid = Layer.lid
        Layer.lid += 1

        self._size = size

        Node = self._lid > 0 and Neuron or InputNode
        self._nodes = [ Node() for i in range(size) ]

        if with_bias_node:
            n = Neuron()
            n.mk_bias()
            self._nodes.append(n)

    def __repr__(self):
        return "[%d { %s }]"%(self._lid, ", ".join([repr(_) for _ in self._nodes]))

    def set_sublayer(self, l):
        self._sublayer = l

    def get_nodes(self):
        return self._nodes

    def get_size(self):
        return self._size
