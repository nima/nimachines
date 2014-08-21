class Node(object):
    '''Nodes can only join onto Links'''
    nid = 0

    #. The transfer function (phi):
    phi = None

    def __init__(self):
        self.nid = Node.nid
        Node.nid += 1

        self._target = False
        self._error = False

    def __repr__(self):
        ABSTRACT

    def set_error(self):
        t = self.get_target()
        o = self.get_output()
        dt = None
        if t is False: #. Hidden Layers (No official target)...
            #. As we can't calculate dt, we will estimate it, start by setting it to zero...
            #. This time we have no target so we have to do something else...
            dt = 0.00
            for l in self.get_links():
                #. Estimate the the error by borrowing it from the link's child node...
                e = l.get_child().get_error()

                #. Adjust the weight using this error...
                w  = l.get_weight()
                w += 1.0 * e * o
                l.set_weight(w)

                #. Add the weighted error to dt for each link...
                dt += 1.0 * w * e

        else: #. Output Nodes...
            dt = t - o

        self._error = dt * Node.d_phi(o)

    def set_target(self, value):
        self._target = float(value)

    def get_target(self):
        return self._target

    def get_output(self):
        ABSTRACT

    def get_type(self):
        ABSTRACT

    def get_links(self):
        return self.children.values()

    def get_children(self):
        '''
        This bypasses the intermediate link and returns the Node child of this
        Node
        '''
        r = [_.get_child() for _ in self.children.values()]
        if r: return r
        return None

    def get_error(self):
        assert self._error is not False
        return self._error

class Neuron(Node):
    def __init__(self):
        super(Neuron, self).__init__()

        #. These are child links-to-nodes, not nodes.
        self.parents = {}
        self.children = {}

        self._is_bias = False

    def __repr__(self):
        return "(%s %d:%2.3f)"%(self.get_type(), self.nid, self.get_output())

    def get_type(self):
        return self._is_bias and "bias" or "neuron"

    def get_output(self):
        '''
        Bias nodes return a signal of 1.00

            o = 1.00

        Other nodes return a signal that is equal to:

            o = phi(sum(w1x1, w2x2, ..., wNxN))

        '''
        o = 1.00

        if not self._is_bias:
            o = Node.phi(
                sum(map(
                    lambda l:l.get_weight() * l.get_input(),
                    self.parents.values()
                ))
            )

        return o

    def mk_bias(self):
        self._is_bias = True

class InputNode(Node):
    def __init__(self):
        super(InputNode, self).__init__()

        #. These are child links-to-nodes, not nodes.
        self.children = {}

        self._output = 0.00

    def __repr__(self):
        return "(%s %d:%2.3f)"%(self.get_type(), self.nid, self.get_output())

    def get_type(self):
        return "input"

    def get_output(self):
        return self._output

    def set_output(self, output):
        self._output = float(output)
