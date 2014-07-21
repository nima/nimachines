
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
//  Perceptron.m
//  SOM
//
//  Created by Nima on 17/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import <GLUT/glut.h>

#import "NMPerceptron.h"
#import "NMSigmoid.h"
#import "NMSumOfSquares.h"
#import "NMDotAdder.h"
#import "NMLink.h"
#import "NMNeuron.h"
#import "NMInputNode.h"
#import "NMNode.h"
#import "NMBias.h"
#import "NMMath.h"

@implementation NMPerceptron

#define lround(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

@synthesize activationFn, errorFn, combinationFn;

+ (int)machineId {
    return ID_PERCEPTRON;
}

+ (NSString *)dataSubDir {
    return [NSString stringWithString:@"perceptron.d"];
}

- (id)init {
    return nil;
}

- (id)initWithDataFile:(NSString *)tDF {
    if(self = [super initWithDataFile:tDF]) {
        perceptron = [NMNeuron new];
        bias = [NMBias new];
        [NMLink joinParent:bias toChild:perceptron];
        
        [self addInputs:trainingVectorDimension-1];
        
        hyperplanes = [NSMutableArray new];

        learningRate = T0_LEARNING_RATE;
        activationFn = [NMSigmoid new];
        errorFn = [NMSumOfSquares new];
        combinationFn = [[NMDotAdder alloc] initWitDimension:trainingVectorDimension];
        stepLimit = ITERATIONS;

        float x, y, z;
        for(int i=0; i<epochSize; i++) {
            x += trainingData[i][0];
            y += trainingData[i][1];
            if(trainingVectorDimension == 4)
                z += trainingData[i][2];
            dualValues[i] = 0;
        }
        center.x = x/epochSize;
        center.y = y/epochSize;
        center.z = z/epochSize;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)addInputs:(unsigned int)count; {
  for(int i=0; i<count; i++)
    [NMLink joinParent:[NMInputNode new] toChild:perceptron];
}

- (NSString *)description {
    NSMutableString *s = [NSMutableString new];
    for(int i=0; i<[perceptron inputs]; i++)
        [s appendFormat:@"[Perceptron: %@]", [[perceptron pLinks] objectAtIndex:i]];
    
    return [s autorelease];
}

- (void)render {
    int targetIndex = trainingVectorDimension - 1;

    int maxAlpha = 1;
    for(int i=0; i<epochSize; i++)
        maxAlpha = max(dualValues[i], maxAlpha);

    for(int i=0; i<epochSize; i++) {
        float dualColor = dualValues[i]/maxAlpha;
        if(trainingData[i][targetIndex] < 0)
            glColor3d(1.0f, dualColor, dualColor);
        else
            glColor3d(dualColor, dualColor, 1.0f);
        glPushMatrix();
        if(trainingVectorDimension == 4) /* 3D */
            glTranslatef(
                ZOOM*trainingData[i][0],
                ZOOM*trainingData[i][1],
                ZOOM*trainingData[i][2]
            );
        else if(trainingVectorDimension == 3) /* 2D */
            glTranslatef(
                ZOOM*trainingData[i][0],
                ZOOM*trainingData[i][1],
                0.0f
            );
        glutSolidSphere(3, 16, 16);
        glPopMatrix();
    }
    
    
    glColor4d(1.0f, 0.9f, 0.1f, trainingVectorDimension == 4?0.6f:1.0f);
    
    NSArray *h;
    NMPoint3 p;
    int points;
    for(int i=0; i<[hyperplanes count]; i++) {
        if(trainingVectorDimension == 3) { /* 2D */
            points = 2;
            glBegin(GL_LINES);
        } else if(trainingVectorDimension == 4) { /* 3D */
            points = 4;
            glBegin(GL_POLYGON);
        }
        
        h = [hyperplanes objectAtIndex:i];
        for(int j=0; j<points; j++) {
            NMPoint3WithNSValue([h objectAtIndex:j], &p);
            glVertex3f(ZOOM*p.x, ZOOM*p.y, ZOOM*p.z);
        }
        glEnd();
    }
}

- (void)epoch {
    //. Separating Hyperplane...
    float *w, x, y, z;
    NSArray *h;
    
    for(int i=0; i<[hyperplanes count]; i++) {
        h = [hyperplanes objectAtIndex:i];
        [h release];
    }
    [hyperplanes removeAllObjects];
    
    for(int i=0; i<epochSize; i++) {
        [self step]; //. Also sets the error for that step.
        errors[i%epochSize] = error;
        w = [perceptron weightVector];
        if(trainingVectorDimension == 3) {
            x = -10; y=-(w[0]+w[1]*x)/w[2]; z = 0.0f;
            NMPoint3 p1 = NMPoint3$initWithXYZ(x, y, z);
            x = +10; y=-(w[0]+w[1]*x)/w[2]; z = 0.0f;
            NMPoint3 p2 = NMPoint3$initWithXYZ(x, y, z);
            h = [[NSArray alloc] initWithObjects:
                NSValueWithPoint3(&p1),
                NSValueWithPoint3(&p2),
                nil
            ];
        } else if(trainingVectorDimension == 4) {
            x = -10; y = -10; z=-(w[0]+w[1]*x+w[2]*y)/w[3];
            NMPoint3 p1 = NMPoint3$initWithXYZ(x, y, z);
            x = -10; y = +10; z=-(w[0]+w[1]*x+w[2]*y)/w[3];
            NMPoint3 p2 = NMPoint3$initWithXYZ(x, y, z);
            x = +10; y = +10; z=-(w[0]+w[1]*x+w[2]*y)/w[3];
            NMPoint3 p3 = NMPoint3$initWithXYZ(x, y, z);
            x = +10; y = -10; z=-(w[0]+w[1]*x+w[2]*y)/w[3];
            NMPoint3 p4 = NMPoint3$initWithXYZ(x, y, z);
            h = [[NSArray alloc] initWithObjects:
                NSValueWithPoint3(&p1),
                NSValueWithPoint3(&p2),
                NSValueWithPoint3(&p3),
                NSValueWithPoint3(&p4),
                nil
            ];
        }

        [hyperplanes addObject:h];

        averageError = average(epochSize, errors);
    }
    epochCount++;
}

- (void)step {
    if(!valid)
        if([[perceptron pLinks] count] && bias && activationFn && errorFn && combinationFn)
            valid = YES;
        else return;

    int step = stepCount%epochSize;
    NMLink *l;
    id iN;
    float *x, *w, o, z, t, e;
    float dE, de_dz, dz_do, do_dw;
    
    //. Initialize new input vectors for this training set...
    for(int i=1; i<[perceptron inputs]; i++) { //. i=0 is Bias
        l = [[perceptron pLinks] objectAtIndex:i];
        iN = [l parent];
        
        [iN setActivity:trainingData[step][i-1]];
    }
    
    x = [perceptron activityVector];
    w = [perceptron weightVector];
    o = [combinationFn fnWithW:w andX:x];
    z = [activationFn fnWithO:o];
    t = trainingData[stepCount%epochSize][[perceptron inputs]-1]; //. i=Last is class
    e += [errorFn fnWithT:t andZ:z];
    for(int i=0; i<[perceptron inputs]; i++) {
        de_dz = [errorFn dfnWithT:t andZ:z];
        dz_do = [activationFn dfnWithO:o];
        do_dw = x[i];
        dE = -learningRate * de_dz * dz_do * do_dw;

        l = [[perceptron pLinks] objectAtIndex:i];
        [l adjustWeight:dE];        
    }
    error = e/[perceptron inputs];

    long classified = lround((t + 1)/2 - z);
    if(classified != 0)
        dualValues[step]++;    

    stepCount++;
}

@end
