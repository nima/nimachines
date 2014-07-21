
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
//  Node.m
//  SOM
//
//  Created by Nima on 18/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMNode.h"
#import "NMLattice.h"
#import "NMLink.h"

@interface NMNode()
- (void)setCenter:(NMPoint3)c;
@property(readwrite, assign) NSMutableArray *pLinks, *cLinks;
@property(readwrite, assign) unsigned int nid;
@end

@implementation NMNode
@synthesize pLinks, cLinks, nid;
@synthesize activity;

static unsigned int neuronId = 0;

//+ (id)allocWithZone:(NSZone *)zone { return nil; }

- (id)init {
    if(self = [super init]) {
        cLinks = [NSMutableArray new];
        pLinks = [NSMutableArray new];
        nid = neuronId++;
        NMPoint3 p = NMPoint3_ZERO;
        center = p;
    }
    return self;
}

- (id)initWithLattice:(NMLattice *)l position:(NMPoint3)p {
    if(self = [self init]) {
        lattice = l;
        positionVector = malloc([lattice dimensions]*sizeof(unsigned int));
        [self setCenter:p];
        needsDisplay = YES;
    }
    return self;
}

- (void)dealloc {
  free(positionVector);
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %d>", NSStringFromClass([self class]), nid];
  //return [NSString stringWithFormat:@"<Node: %dx%dx%d>", (unsigned int)center.x, (unsigned int)center.y, (unsigned int)center.z];
}

- (void)addPLink:(NMLink *)link {
  [link retain];
  [pLinks addObject:link];
}

- (unsigned int)inputs {
  return [pLinks count];
}

- (void)setActivity:(float)a {
  [self doesNotRecognizeSelector:_cmd];
}

- (NMNode **)inputNodes {
  static NMNode **inputNodes;
  if((!inputNodes) || sizeof(inputNodes) != [pLinks count]*sizeof(NMNode *)) { 
    inputNodes = realloc(inputNodes, [pLinks count]*sizeof(NMNode *));
    for(int i=0; i<[pLinks count]; i++)
      inputNodes[i] = [(NMLink *)[pLinks objectAtIndex:i] parent];
  }
  return inputNodes;
}

- (void)addCLink:(NMLink *)link {
  [link retain];
  [cLinks addObject:link];
}

- (void)render {
  needsDisplay = YES;
}

- (void)setCenter:(NMPoint3)c {
    positionVector[0] = c.x;
    positionVector[1] = c.y;  
    positionVector[2] = c.z;
    center = c;
}  

#define FAIL_NOW assert(1==0)
- (unsigned int *)positionVector {
    if(positionVector != NULL)
        return positionVector;
    FAIL_NOW;
}

- (NSString *)type { return @"abstract"; }

@end
