from . import *
from .link import Link
from .node import Node
from .layer import Layer
import pickle, os

'''
input signal; function signals
error signal; the signal generated at the output layer and back-propagated

hidden neurons; act as feature detectors
'''

class NeuralNetwork:
    trained = 0
    def __init__(self, datafile, topology, transfer_fn):

        self._datafile = "%s.nn" % datafile
        if (os.path.exists(self._datafile)):
            data = None
            with open(self._datafile, 'rb') as fH:
                data = pickle.load(fH)

            Node.phi              = data.phi
            NeuralNetwork.trained = data.trained

            self._input_layer  = data._input_layer
            self._datafile     = data._datafile
            self._hiddenLayers = data._hiddenLayers
            self._layers       = data._layers
            self._output_layer = data.self._output_layer

        else:
            Node.phi = transfer_fn

            #. The input layer...
            self._input_layer = Layer(topology[0])
            self._layers = [self._input_layer]

            #. The hidden layers...
            self._hiddenLayers = []
            for l in topology[1:-1]:
                self._hiddenLayers.append(Layer(l))
            self._layers.extend(self._hiddenLayers)

            #. The output layer...
            self._output_layer = Layer(topology[-1], False)
            self._layers.append(self._output_layer)

            #. Join the layers...
            for i in range(0, len(self._layers) - 1):
                self._layers[i].set_sublayer(self._layers[i+1])

            #. Connect all nodes in one layer to all the nodes of the next layer...
            for pL, cL in [[_ for _ in self._layers[i:i+2]] for i in range(0, len(self._layers)-1)]:
                for pN in pL.get_nodes():
                    for cN in cL.get_nodes():
                        Link(pN, cN)

    def __repr__(self):
        return '\n'.join([repr(l) for l in self._layers])

    def draw(self):
        def dfs(node, weight=None, indent=0):
            if weight:
                print("  "*indent, "\___W:%.5f___>>> %s"%(weight, node))
            else:
                print("  "*indent, "[I%d] >>> %s"%(node.id, node))
            links = node.getLinks()
            if links:
                for link in links:
                    dfs(link.getChild(), link.getWeight(), indent+1)
            else:
                print("")

        for iN in self._input_layer.get_nodes():
            dfs(iN)

    def train(self, inputs, outputs):
        '''Train a single example'''
        NeuralNetwork.trained += 1

        #. Set the Targets values on the Outputs Nodes...
        nodes = self._output_layer.get_nodes()
        assert len(outputs) == len(nodes)
        for i in range(len(outputs)):
            nodes[i].set_target(outputs[i])

        #. Set the Feed supply from the Input nodes (by setting their outputs)...
        nodes = self._input_layer.get_nodes()
        assert len(inputs) == len(nodes) - 1 #. `-1' for the bias node
        for i in range(len(inputs)):
            nodes[i].set_output(inputs[i])

        #. Back-Propagate from the Output Nodes back to the Input Nodes...
        #. We do this by making a deep copy of the layers array, and reversing it
        #. so that we end up with { OutputLayer, HiddenLayerN, ..., HiddenLayer0, InputLayer }
        nodes = self._output_layer.get_nodes()
        #. Starting at the Output layer now, we backprop the error...
        for l in reversed(self._layers):
            for n in l.get_nodes():
                n.set_error()

        return [n.get_error() for n in nodes]

    def trainer(self, data):
        '''Train an epoch of examples (an entire training set)'''
        return reduce(lambda x,y:sum((x,y)), [
            abs(sum(e)/len(e)) for e in map(lambda d:self.train(d[0], d[1]), data)
        ], 0)/len(data)

    def test(self, inputs):
        #. Inputs...
        assert len(inputs) == self._input_layer.get_size()
        nodes = self._input_layer.get_nodes()
        for i in range(len(inputs)):
            nodes[i].set_output(inputs[i])
        return [_.get_output() for _ in self._output_layer.get_nodes()]

    def dump(self, name=None):
        if name is None:
            name = self._datafile

        with open(name, 'wb') as fH:
            pickle.dump(self, fH)
