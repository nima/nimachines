
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
//  Neuron.m
//  SOM
//
//  Created by Nima on 18/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMNeuron.h"
#import "NMLink.h"
#import "NMMath.h"
#import <GLUT/glut.h>

@interface NMNeuron()
- (void)resetMaterial;
@end

@implementation NMNeuron

- (id)initWithLattice:(NMLattice *)l position:(NMPoint3)p {
  if(self = [super initWithLattice:l position:p]) {
    alpha = 0.00f;
  }
  return self;
}

- (void)dealloc {
  free(weightVector);
  free(activityVector);
  [super dealloc];
}

- (NSString *)description {
  float *w = [self weightVector];
  return [NSString stringWithFormat:@"<%@: %d w:[%.4f, %.4f, %.4f]>",
          NSStringFromClass([self class]), nid,
          w[0], w[1], w[2]
  ];
}

- (void)resetMaterial {
  glEnable(GL_COLOR_MATERIAL);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
  float ambient_light[] = {0.4f, 0.4f, 0.4f, 1.0f};
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient_light);
  glColorMaterial(GL_FRONT_AND_BACK,  GL_AMBIENT_AND_DIFFUSE);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,   matDiff);
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT,   matAmbi);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR,  matSpec);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, matShin);
  glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION,  matEmis);
  matEmis[0] = 0.1; matEmis[1] = 0.1; matEmis[2] = 0.1; matEmis[3] = 1.0; 
}

- (void)setActivity:(float)a {
  [self doesNotRecognizeSelector:_cmd];
}

- (float *)weightVector {
  int size = [pLinks count];
  if(!weightVector) {
    weightVector = malloc(size*sizeof(float));
    //. Create the weightVector and initialize to small random numbers...
    //for(int i=0; i<size; i++)
    //  [[pLinks objectAtIndex:i] setWeight:(randf-0.5)];
  }
  for(int i=0; i<size; i++)
    weightVector[i] = [[pLinks objectAtIndex:i] weight];
  return weightVector;
}

- (float *)activityVector {
  int size = [pLinks count];
  if(!activityVector)
    activityVector = malloc(size*sizeof(float));
  for(int i=0; i<size; i++) {
    NMNode *n = [(NMLink *)[pLinks objectAtIndex:i] parent];
    activityVector[i] = [n activity];
    //NSLog(@"Node: %@, activity:%f", n, [n activity]);
  }
  return activityVector;
}

- (void)upAlpha:(GLfloat)da {
  if(_alpha >= ALPHA_SHIFT) return;
  _alpha = min(ALPHA_SHIFT, _alpha+da);
  alpha = exp(-powf(_alpha-ALPHA_SHIFT, 2)/ALPHA_FATNESS);
}

- (void)renderWithEnergy:(float)e {
  energy += e;
  [self render];
}

- (void)render {
  //if(alpha < ALPHA_SHIFT-ALPHA_FATNESS/2) return;
  if(!prepared) {
    [self resetMaterial];
    //glNewList(display, GL_COMPILE_AND_EXECUTE);
    //glutSolidCube(display);
    //glEndList();
    prepared = YES;
  }
  float *w = [self weightVector];
  glPushMatrix();
    glScalef(alpha*12, alpha*12, alpha*12);
    glColor4f(w[0], w[1], w[2], alpha);
    glRotated(128*energy, w[0], w[1], w[2]);
    glutSolidCube(1);
    //glutSolidSphere(1, 8, 8);
  glPopMatrix();
}  

@end
