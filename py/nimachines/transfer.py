import math

def sigmoid(x):
    '''
    The logistic function:

        s(x) = 1 / ( 1 + e^(-x) )

    This has the nice derivative of:

        d(s(x))/d(x) = s(x) . ( 1 - s(x) )
    '''
    return 1/(1 + math.pow(math.e, -x))
    #try:
    #except OverflowError:
    #    print('-x = %0.2f' % -x)
    #    raise

def d_sigmoid(sx):
    '''
    This has the nice derivative of:

        d(s(x))/d(x) = s(x) . ( 1 - s(x) )
    '''
    return sx * (1 - sx)

def hyperbolicTangent(x):
    return math.tanh(x)

def arcTangent(x):
    return math.atan(x)
