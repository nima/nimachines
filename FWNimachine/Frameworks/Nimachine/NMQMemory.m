
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
//  NXTQMemory.m
//  Nimachines
//
//  Created by Nima Talebi on 2/07/09.
//  Copyright 2009 Autonomy. All rights reserved.
//

#import <NXTMindstorm/NXTMindstorm.h>
#import <NXTMindstorm/NXTState.h>

#import "NMQMemory.h"

@implementation NXTQMemory

+ (NSNumber *)stateActionIdFromStateId:(UInt8)sI actionId:(UInt8)aI {
  UInt16 sAID = (sI<<8)+aI;
  NSNumber *nSAID = [NSNumber numberWithUnsignedShort:sAID];
  dbg("NXTQL-Memory", kDEBUG, "sAID: %d << 8 + %d = %d --> %s", sI, aI, sAID, [[nSAID stringValue] UTF8String]);
  return nSAID;
}

- (id)initWithStates:(NSArray *)s actions:(NSArray *)a {
  if(self = [super init]) {
    states = s;
    [states retain];
    actions = a;
    [actions retain];
    
    //qTable = [[NSMutableDictionary alloc] initWithCapacity:[states count]*[actions count]];
    qTable = [NSMutableDictionary new];
    qValueMax = -INT16_MAX;
    NSNumber *sAID;
    for(UInt8 sI=0; sI<[states count]; sI++)
      for(UInt8 aI=0; aI<[actions count]; aI++) {
        sAID = [NXTQMemory stateActionIdFromStateId:sI actionId:aI];
        [qTable setObject:[[NSNumber alloc] initWithInt:0] forKey:sAID];
      }
  }
  return self;
}

- (NSNumber *)stateActionIdFromState:(NXTState *)s action:(NXTAction *)a {
  UInt8 sI = [states indexOfObject:s];
  UInt8 aI = [actions indexOfObject:a];
  return [NXTQMemory stateActionIdFromStateId:sI actionId:aI];
}

- (NSNumber *)maxQValueFromState:(NXTState *)s {
  UInt8 sI = [s stateId];
  NSNumber *maxQValue = [NSNumber numberWithInt:0];
  NSNumber *sAID;
  for(UInt8 aI=0; aI<[actions count]; aI++) {
    sAID = [NXTQMemory stateActionIdFromStateId:sI actionId:aI];
    if([[qTable objectForKey:sAID] isGreaterThan:maxQValue])
      maxQValue = [qTable objectForKey:sAID];
  }
  return maxQValue;
}

- (void)setQValue:(float)qV forSAID:(NSNumber *)sAID {
  NSParameterAssert(sAID!=nil);
  [qTable setObject:[NSNumber numberWithFloat:qV] forKey:sAID];
}

- (NXTAction *)nextRandomAction {
  return [actions objectAtIndex:random()%[actions count]];
}

- (NXTAction *)nextBestActionFromState:(NXTState *)s {
  UInt8 sI = [s stateId];
  UInt8 maxI = 0;
  NSNumber *maxQValue = [NSNumber numberWithInt:0];
  NSNumber *sAID;
  UInt8 aICount = [actions count];
  for(UInt8 aI=0; aI<aICount; aI++) {
    sAID = [NXTQMemory stateActionIdFromStateId:sI actionId:aI];
    if([[qTable objectForKey:sAID] isGreaterThan:maxQValue]) {
      maxQValue = [qTable objectForKey:sAID];
      maxI = aI;
    }
  }
  return [actions objectAtIndex:maxI];
}

@end
