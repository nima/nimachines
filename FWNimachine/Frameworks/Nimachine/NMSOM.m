
/*. ******* coding:utf-8 AUTOHEADER START v1.2 *******
 *. vim: fileencoding=utf-8 syntax=c sw=4 ts=4 et
 *. Copyrights:
 *.
 *.     © 2007-2009 Matt Harrington (Author of LegoNXTRemove @ code.google.com)
 *.     © 2007-2010 Nima Talebi <nima@autonomy.net.au>
 *.     © 2010      Remy "Psycho" Demarest <Psy|@#cocoa@irc.freenode.org>
 *.
 *. License:
 *.
 *.     MIT - The @PKG packages is available under the terms of
 *.     the MIT license.
 *.
 *. Homepage:
 *.
 *.     Original: http://code.google.com/p/legonxtremote/
 *.     Mutation: http://ai.autonomy.net.au/wiki/Project/Framework/Nimachine
 *.
 *. This file is part of the Nimachine Suite.
 *.
 *.     Nimachine is free software: you can redistribute it and/or modify
 *.     it under the terms of the GNU General Public License as published by
 *.     the Free Software Foundation, either version 3 of the License, or
 *.     (at your option) any later version.
 *.
 *.     Nimachine is distributed in the hope that it will be useful,
 *.     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *.     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *.     GNU General Public License for more details.
 *.
 *.     You should have received a copy of the GNU General Public License
 *.     along with Nimachine.  If not, see <http://www.gnu.org/licenses/>.
 *.
 *. THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 *. WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 *. MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
 *. EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 *. INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *. LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 *. OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *. LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *. NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *. EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *.
 *. ADAPTED M. STONE & T. PARKER DISCLAIMER: THIS SOFTWARE COULD RESULT IN
 *. INJURY AND/OR DEATH, AND AS SUCH, IT SHOULD NOT BE BUILT, INSTALLED OR USED BY
 *. ANYONE.
 *. ******* AUTOHEADER END v1.2 ******* */

//
//  SOM.m
//  SOM
//
//  Created by Nima on 18/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import <GLUT/glut.h>
#import "NMSOM.h"
#import "NMInputNode.h"
#import "NMNeuron.h"
#import "NMLattice.h"
#import "NMPoint3.h"
#import "NMMath.h"
#import "NMLink.h"

@interface NMSOM()
void quickSortNeuronRenderOrder(NMNeuron **neurons, int array_size, NMPoint3 *vrp);
void q_sort(NMNeuron **neurons, int left, int right, NMPoint3 *vrp);
- (void)normalizeTrainingData;
@end

@implementation NMSOM
@synthesize radius, t0_radius, stepCountP3, stepLimitP3;

+ (int)machineId { return ID_SOM; }
+ (NSString *)dataSubDir { return [NSString stringWithString:@"som.d"]; }

- (id)initWithDataFile:(NSString *)tDF
            dimensions:(unsigned short)d
         latticeLength:(int)l
        andLatticeMode:(NMLatticeModeHyperCube)m {
    if(self = [super initWithDataFile:tDF]) {
        [self normalizeTrainingData];
        
        //. We do 3D Lattice anyway, just set last sideLength to 1 instead of l
        NSUInteger _[] = {m, 3, l, l, d==3?l:1};
        int s = (_[1]+2)*sizeof(NSUInteger);
        topology = malloc(s);
        memcpy(topology, _, s);
        
        NSLog(@"Creating the hypercube lattice...");
        lattice = [[NMLatticeHyperCube alloc] initWithTopology:topology inputs:4];
        
        radius = T0_RADIUS?T0_RADIUS:[lattice radius];
        stepCount = 0;
        decay_tau1 = ITERATIONS/log(radius/TN_RADIUS);
        decay_tau2 = ITERATIONS/(log(T0_LEARNING_RATE) - log(TN_LEARNING_RATE));
        learningRate = T0_LEARNING_RATE;
        
        t0_learningRate = learningRate;
        t0_radius = radius;
        stepLimit = ITERATIONS;
        stepLimitP3 = [lattice size]*CONV_FACTOR;
        
        neurons = [lattice neuronList];
    }
    
    return self;
}

- (void)dealloc {
  //free(topology); --> now Lattice's responsibility.
  [super dealloc];
}

- (void)normalizeTrainingData {
  return;
  //. Find the Maximums...
  float *maximums = malloc(trainingVectorDimension*sizeof(float));
  float *minimums = malloc(trainingVectorDimension*sizeof(float));
  for(int i=0; i<epochSize; i++)
    for(int j=0; j<trainingVectorDimension; j++)
      if(trainingData[i][j] > maximums[j])
        maximums[j] = trainingData[i][j];
      else if(trainingData[i][j] < maximums[j])
        minimums[j] = trainingData[i][j];

  //. Normalize...
  for(int i=0; i<epochSize; i++)
    for(int j=0; j<trainingVectorDimension; j++)
      trainingData[i][j] = trainingData[i][j]-minimums[j]/(maximums[j]-minimums[j]);
}

- (void)render {
  /*
  static int displayList;
  if(displayList) glCallList(displayList);
  else {
    displayList = glGenLists(1);
    glNewList(displayList, GL_COMPILE_AND_EXECUTE);
    glEndList();
  }
  */
  //quickSortNeuronRenderOrder(neurons, [lattice size], vrp);
  static float jitter = 0.0f;
  NMNeuron *neuron;
  glPushMatrix();
  glTranslated(
    -(float)topology[4]*MARGIN/2,
    -(float)topology[3]*MARGIN/2,
    -(float)topology[2]*MARGIN/2
  );
  NMPoint3 nC; //. Neuron Center
  jitter += 0.02f;
  float d;

  /*
  NSMutableArray *_ = [NSMutableArray arrayWithCapacity:[lattice size]];
  NSMutableArray *__ = [NSMutableArray arrayWithCapacity:[lattice size]];
  for(int n=0; n<[lattice size]; n++)
    [_ addObject: neurons[n]];
  
  for(int n=0; n<[lattice size]; n++) {
    neuron = [_ objectAtIndex:random()%[_ count]];
    [_ removeObject:neuron];
    [__ addObject:neuron];
  }
  */
  
  for(int n=[lattice size]-1; n>=0; n--) {
    //neuron = [lattice neuronWithId:n];
    neuron = neurons[n];
    //neuron = [__ objectAtIndex:n];
    nC = [neuron center];
    d = NMPoint3$distanceBetween([lattice center], nC);
    glPushMatrix();
      glTranslatef((MARGIN)*nC.x,
                   (MARGIN)*nC.y,
                   (MARGIN)*nC.z);
      /*
      glTranslatef(((1+breath(jitter)/16.0f)*MARGIN)*nC.x,
                   ((1+breath(jitter)/64.0f)*MARGIN)*nC.y,
                   ((1+breath(jitter)/16.0f)*MARGIN)*nC.z);
      */
      [neuron renderWithEnergy:learningRate];
    glPopMatrix();
  }
  glPopMatrix();
}


void quickSortNeuronRenderOrder(NMNeuron **neurons, int array_size, NMPoint3 *vrp) {
  q_sort(neurons, 0, array_size-1, vrp);
}

void q_sort(NMNeuron **neurons, int left, int right, NMPoint3 *vrp) {
  unsigned int l_hold, r_hold, pivot;

  l_hold = left;
  r_hold = right;
  pivot = left;
  
  while(left < right) {
    while((NMPoint3$distanceBetween(*vrp, [neurons[right] center]) >= NMPoint3$distanceBetween(*vrp, [neurons[pivot] center])) && (left < right))
      right--;
    if(left != right) {
      neurons[left] = neurons[right];
      left++;
    }
    while((NMPoint3$distanceBetween(*vrp, [neurons[left] center]) <= NMPoint3$distanceBetween(*vrp, [neurons[pivot] center])) && (left < right))
      left++;
    if(left != right) {
      neurons[right] = neurons[left];
      right--;
    }
  }
  neurons[left] = neurons[pivot];
  pivot = left;
  left = l_hold;
  right = r_hold;
  if (left < pivot)
    q_sort(neurons, left, pivot-1, vrp);
  if (right > pivot)
    q_sort(neurons, pivot+1, right, vrp);
}


- (void)epoch {
  int _ = stepCount+stepCountP3;
  epochCount = _/epochSize;
  float *x = trainingData[_%epochSize];
  float *w;
  float eD;
  NMNeuron *bmu = nil;
  NMNeuron *neuron = nil;
  NMLink *link;
  
  ////////////////////////////////////////////////////////////////////////////
  //. Competitive Process...

  //NSLog(@"----------------------------------------------------------------");
  float minimum = 1000000000;
  for(int n=0; n<[lattice size]; n++) {
    neuron = [lattice neuronWithId:n];
    w = [neuron weightVector];
    //NSLog(@"<%f, %f, %f, %f>", w[0], w[1], w[2], w[3]);
    eD = squaredDistance([neuron inputs], x, w);
    //NSLog(@"eD:%.4f, min:%.4f", eD, minimum);
    if(eD < minimum) {
      minimum = eD;
      bmu = neuron;
      //NSLog(@">>> n:%d, %@: %f", n, neuron, minimum);
    }
  }
  //NSLog(@"<%f, %f, %f, %f>", x[0], x[1], x[2], x[3]);
  w = [bmu weightVector];
  errors[_%epochSize] = squaredDistance([neuron inputs], x, w);
  averageError = average(epochSize, errors);

  //NSLog(@"BMU: %@", bmu);

  ////////////////////////////////////////////////////////////////////////////
  //. Cooperative Process...
  
  if(stepCount < ITERATIONS) { /* Ordering Phase */
    if(radius <= TN_RADIUS) NSLog(@"Ordering Phase Complete");
    radius *= exp(-1.0f/decay_tau1);
    
    if(learningRate <= TN_LEARNING_RATE) NSLog(@"Ordering Phase Complete");
    learningRate *= exp(-1.0f/decay_tau2);
  }
  
  for(int n=0; n<[lattice size]; n++) {
    neuron = [lattice neuronWithId:n];
    float eD = [lattice distanceBetweenNode:bmu andNode:neuron];
    float eq97 = exp(-powf(eD, 2.0f)/(2.0f*powf(radius, 2.0f)));
    float *w = [neuron weightVector];
    for(int i=0; i<[lattice inputs]; i++) {
      link = [[neuron pLinks] objectAtIndex:i];
      [link setWeight:(w[i] + T0_LEARNING_RATE * eq97 * (x[i] - w[i]))];
    }
    [neuron upAlpha:eq97];
  }
  
  if(stepCount < ITERATIONS) /* Ordering Phase */ stepCount++;
  else /* Convervence Phase */ stepCountP3++;
}

@end
