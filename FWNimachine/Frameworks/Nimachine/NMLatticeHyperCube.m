
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
//  LatticeHyperCube.m
//  SOM
//
//  Created by Nima on 18/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMLatticeHyperCube.h"
#import "NMPoint3.h"
#import "NMNeuron.h"
#import "NMInputNode.h"
#import "NMLink.h"

@interface NMLatticeHyperCube()
- (void)mallocNeuronsStandard;
- (void)mallocNeuronsClosePacked;
@end

@implementation NMLatticeHyperCube

- (id)initWithTopology:(NSUInteger *)arch inputs:(UInt8)i {
    if(self = [super init]) {
        inputs = i;
        
        //NSLog(@"sideLengths:%d %d %d %d %d", arch[0], arch[1], arch[2], arch[3], arch[4]);
        architecture = arch;
        mode = arch[0];
        dimensions = arch[1];
        
        sideLengths = ((NSUInteger*)arch+2);
        //sideLengths = malloc(dimensions*sizeof(NSUInteger));
        //memcpy(sideLengths, ((NSUInteger*)arch+2), dimensions*sizeof(NSUInteger));
        
        for(int i=0; i<dimensions; i++)
            radius += powf(sideLengths[i], 2);
        radius = sqrtf(radius)/2.0f;
        
        //. Create space for neurons...
        int _ = 1;
        for(int i=0; i<dimensions; i++)
            _ *= arch[i+2];
        neuronList = malloc(_*sizeof(NMNeuron *));
        
        //. Create the Lattice...
        if(mode == NMStandard)
            [self mallocNeuronsStandard];
        else if(mode == NMClosePacked)
            [self mallocNeuronsClosePacked];
        else
            [NSException raise:@"InvalidNMLatticeModeHyperCube"
                        format:@"No such NMLatticeModeHyperCube of value `%d'", mode];  
        
        
        //. Create the Input Nodes...
        inputNodes = malloc(inputs*sizeof(NMInputNode *));
        for(int i=0; i<inputs; i++)
            inputNodes[i] = [NMInputNode new];
        
        //. Connect the input nodes to the lattice nodes...
        for(int i=0; i<sideLengths[0]; i++)
            for(int j=0; j<sideLengths[1]; j++)
                for(int k=0; k<sideLengths[2]; k++)
                    for(int l=0; l<inputs; l++)
                        [NMLink joinParent:inputNodes[l] toChild:neurons[i][j][k]];
        
        assert(size==_);
    }
    return self;
}

- (void)mallocNeuronsStandard {
    NSLog(@"Initializing Standard HyperCube Lattice");
    NMNeuron *n;
    neurons = malloc(sideLengths[0]*sizeof(NMNeuron ***));
    for(int i=0; i<sideLengths[0]; i++) {
        neurons[i] = malloc(sideLengths[1]*sizeof(NMNeuron **));
        for(int j=0; j<sideLengths[1]; j++) {
            neurons[i][j] = malloc(sideLengths[2]*sizeof(NMNeuron *));
            for(int k=0; k<sideLengths[2]; k++) {
                NMPoint3 nP = NMPoint3$initWithXYZ(i, j, k);
                n = [[NMNeuron alloc] initWithLattice:self position:nP];
                neurons[i][j][k] = neuronList[size] = n;
                size++;
            }
        }
    }
}

- (void)mallocNeuronsClosePacked {
    NSLog(@"Initializing Close-Packed HyperCube Lattice");
    NMNeuron *n;
    neurons = malloc(sideLengths[0]*sizeof(NMNeuron ***));
    float iO, jO, kO, M;
    iO = sqrt(3)/2;
    jO = kO = 0.25f;
    M = 1.0;
    for(int i=0; i<sideLengths[0]; i++) {
        neurons[i] = malloc(sideLengths[1]*sizeof(NMNeuron **));
        for(int j=0; j<sideLengths[1]; j++) {
            neurons[i][j] = malloc(sideLengths[2]*sizeof(NMNeuron *));
            for(int k=0; k<sideLengths[2]; k++) {
                NMPoint3 nP = NMPoint3$initWithXYZ(M*(i*iO), M*(j+jO), M*(k+kO));
                n = [[NMNeuron alloc] initWithLattice:self position:nP];
                neurons[i][j][k] = neuronList[size] = n;
                size++;
            }
            kO = -kO;
        }
        jO = -jO;
    }
}

- (void)dealloc {
    NSLog(@"Destroying the %d Neurons...", size);
    NMNode *n;
    for(int i=0; i<sideLengths[0]; i++) {
        for(int j=0; j<sideLengths[1]; j++) {
            for(int k=0; k<sideLengths[2]; k++) {
                n = neurons[i][j][k];
                neurons[i][j][k] = nil;
                neuronList[size] = NULL;
                free(n);
            }
            free(neurons[i][j]);
        }
        free(neurons[i]);
    }
    free(neurons);
    free(neuronList);
    
    for(int i=0; i<inputs; i++)
        [inputNodes[i] release];
    
    free(inputNodes);
    free(architecture);
    
    [super dealloc];
}

- (NMNeuron *)neuronWithId:(unsigned int)nID {
    return neuronList[nID];
    /*
     int lev = (nID/sideLengths[0]/sideLengths[1]);
     int row = (nID/sideLengths[1]%sideLengths[2]);
     int col = (nID%sideLengths[2]);
     //NSLog(@"%@ --> %d, %d, %d", neurons[lev][row][col], lev, row, col);
     return neurons[lev][row][col];
     */
}

- (float)distanceBetweenNode:(NMNeuron *)n1 andNode:(NMNeuron *)n2 {
    unsigned int *p1 = [n1 positionVector];
    unsigned int *p2 = [n2 positionVector];
    float sumOfSquares = 0.0f;
    for(int i=0; i<dimensions; i++)
        sumOfSquares += powl(p2[i] - p1[i], 2);
    return sqrtf(sumOfSquares);
}

@end
