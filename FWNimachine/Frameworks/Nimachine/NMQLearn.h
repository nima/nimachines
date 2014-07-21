
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
//  QLearn.h
//  Nimachines
//
//  Created by Nima Talebi on 10/06/09.
//  Copyright 2009 Autonomy. All rights reserved.
//

#define ID_QLEARN 3000

#import <Cocoa/Cocoa.h>
//#include <ode/ode.h> //. sudo port install ode
#import <NXTMindstorm/NXTMindstorm.h>

#import "NMMachine.h"

#define NXT_QL_GRAVITY -9.80665       //. The Gravity of our World
#define NXT_QL_CFM -0.00001           //. Constraint Force Mixing
#define NXT_QL_STEPSIZE 20            //. Timestep in Milli-Seconds

#define MAX_CONTACTS 0

@class NMMindstormNXT, NMQMemory, NXTState, NXTAction;

#ifdef ODE_ENABLED
#pragma mark ODE_API
enum { oCube, oSphere, oComplex, objsCount };
dWorldID world;
dReal contactPoints[20][3];
dJointGroupID contactGroup;

typedef struct _NXTObject {
  dBodyID body;
  dMass mass;
  dGeomID geom;
  void *name;
} NXTObject;
#endif

@interface NMQLearn:NMMachine {
  //////////////////////////////////////////////////////////////////////////////
  //. Q-Learning...
  NXTMindstorm        *_nxt;
  NMQMemory           *qMem;

  NXTActuator         *actServo1;
  NXTActuator         *actServo2;
  NXTSensor           *snsAcc;
  
  NXTState            *state;
  NXTState            *stateGoal; //. -1 Means UNSET
  NXTState            *stateTerm; //. -1 Means UNSET
  NXTAction           *doNothing; 

  BOOL                randEnabled;
  BOOL                connected; //. Are we connected to the NXT Brick?
  
  float               tau;

  NSArray             *states;
  NSArray             *actions;
    
  NSMutableDictionary *rewards; //. Immediate Rewards
  NSMutableDictionary *qValues;
  NSMutableDictionary *transitions;
  
  //. Statistics...
  int statRandom;
  int statGreedy;
  NSMutableDictionary *statCrashes;
  
  //. Special Counters...
  int counterTSLC; //. Time Since Last Crash
  
#ifdef ODE_ENABLED
  //////////////////////////////////////////////////////////////////////////////
  //. ODE & OpenGL
  const dReal *realP;
  dSpaceID space;
  NXTObject objs[objsCount];
  dReal masses[objsCount];
  dGeomID plane;
  dTriMeshDataID triMesh; 
#endif
}

- (SInt8)getQValueFromState:(NXTState *)s action:(NXTAction *)a;
- (void)setReward:(int)r forState:(NXTState *)s action:(NXTAction *)a;
- (void)setReward:(int)r forState:(NXTState *)s;
- (void)setReward:(int)r forAction:(NXTAction *)a;
- (void)setGoalState:(NXTState *)sG;
- (void)setTermState:(NXTState *)sT;
- (void)performAction:(NXTAction *)a;
- (BOOL)hasTerminated;
#ifdef ODE_ENABLED
- (void)drawObject:(NXTObject)obj;
#endif
- (BOOL)discoverState;

@property(readwrite, assign) BOOL randEnabled;
@property(readonly) NXTState *state;

@end
