
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
//  NXTAction.m
//  Nimachines
//
//  Created by Nima Talebi on 2/07/09.
//  Copyright 2009 Autonomy. All rights reserved.
//

#import "NXTAction.h"

@implementation NXTAction

@synthesize power, actionId, actuator, actuators;

+ (id)actionWithActuator:(NXTActuator *)a power:(float)p name:(NSString *)n desc:(NSString *)d {
  NSParameterAssert(a!=nil);
  return [[[self alloc] initWithActuator:a power:p name:n desc:d] autorelease];
}

+ (id)actionWithActuators:(NSArray *)a power:(float)p name:(NSString *)n desc:(NSString *)d {
  NSParameterAssert(a!=nil);
  NXTAction *action = [[[self alloc] initWithActuator:[a objectAtIndex:0] power:p name:n desc:d] autorelease];
  for(int i=1; i<[a count]; i++)
    [action addActuator:[a objectAtIndex:i]];
  return action;
}

- (id)initWithActuator:(NXTActuator *)a power:(float)p name:(NSString *)n desc:(NSString *)d {
  NSParameterAssert(a!=nil);
  if(self = [super init]) {
    actuator = a;
    power = p;
    name = n;
    desc = d;
  }
  return self;
}

- (void)addActuator:(NXTActuator *)a {
  if(!actuators) {
    actuators = [NSMutableArray new];
    [actuators addObject:actuator];
  }
  [actuators addObject:a];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<Action:[Actuator:%@, Power:%0.5f, Name:%@", actuator, power, name];
}

- (void)dealloc {
  if(actuators) {
    for(int i=0; i<[actuators count]; i++)
      [[actuators objectAtIndex:i] release];
    actuators = nil;
  } else {
    [actuator release];
  }
  [super dealloc];
}

@end
