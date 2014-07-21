
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
//  QLearn.m
//  Nimachines
//
//  Created by Nima Talebi on 10/06/09.
//  Copyright 2009 Autonomy. All rights reserved.
//

//. <32-bit State Id> ++ <32-bit Action Id>

#import <GLUT/glut.h>

#import "NMQLearn.h"
#import "NMQMemory.h"

#import <NXTMindstorm/NXTMindstorm.h>
#import <NXTMindstorm/NXTState.h>
#import <NXTMindstorm/NXTAction.h>

@implementation NMQLearn

@synthesize state;
@synthesize randEnabled;

#ifdef ODE_ENABLED
void collisionHandler(void *data, dGeomID o1, dGeomID o2) {  
  static int contactPointsCount = 0;

	// Since here there is just one space, we don't check for geometry type:
	// they are not spaces
	dContactGeom contacts[MAX_CONTACTS];
	// Check for collisions
	int collisions = dCollide(o1, o2, MAX_CONTACTS, contacts, sizeof(dContactGeom));
	NSLog(@"%d collision points\n", collisions);
  
	// Save contact points
	for(int i=0; i < collisions; ++i) {
		dGeomID g1 = contacts[i].g1, g2 = contacts[i].g2;
    
		if(g1 == g2)
			continue;
    
		float *pos = contacts[i].pos;
		NSLog(@"Copoint %d: %f %f %f\n", i, pos[0], pos[1], pos[2]);
    
		contactPoints[contactPointsCount][0] = pos[0];
		contactPoints[contactPointsCount][1] = pos[1];
		contactPoints[contactPointsCount][2] = pos[2];
		contactPointsCount++;
    
		char *o1Name = dGeomGetData(g1);
		char *o2Name = dGeomGetData(g2);
    /*
		const dReal *o1Pos = dGeomGetPosition(g1);
		const dReal *o2Pos = dGeomGetPosition(g2);
    */
		NSLog(@"Collision between %s (%x) and %s (%x)\n", o1Name, g1, o2Name, g2);
	}
}
#endif

#ifdef ODE_ENABLED
void nearCallback(void *data, dGeomID o1, dGeomID o2) {
	dBodyID body1 = dGeomGetBody(o1);
	dBodyID body2 = dGeomGetBody(o2);
  
	dContact contact[MAX_CONTACTS];
  
	for(int i=0; i<MAX_CONTACTS; i++) {
		contact[i].surface.mode = dContactBounce; // Bouncy surface
		contact[i].surface.bounce = 0.5;
		contact[i].surface.mu = 100.0; // Friction
	}
  
	int collisions = dCollide(o1, o2, MAX_CONTACTS, &contact[0].geom, sizeof(dContact));
	if(collisions) {
		for(int i=0; i<collisions; ++i) {
			dJointID c = dJointCreateContact(world, contactGroup, (const dContact *)&(contact[i]));
			dJointAttach(c, body1, body2);
		}
	}
}
#endif

+ (int)machineId { return ID_QLEARN; }
+ (NSString *)dataSubDir { return [NSString stringWithString:@"qlearn.d"]; }

- (id)init { return nil; }
- (id)initWithDataFile:(NSString *)tDF {
  if(self = [super initWithDataFile:tDF]) {

#ifdef ODE_ENABLED
      srandom(time(0));

    /**************************************************************************/
    /*** GUI ***/

    //. The World...
    world = dWorldCreate();
    assert(world);
    dWorldSetGravity(world, 0.0, NXT_QL_GRAVITY, 0.0);
    //dWorldSetCFM(world, NXT_QL_CFM);
    //. auto disable bodies after some time or steps to speed up simulation
    dWorldSetAutoDisableFlag(world, 1);

    //. Space...
    //self->space = dHashSpaceCreate(0);
    self->space = dSimpleSpaceCreate(0);
    assert(self->space);

    //. Bodies...
    masses[0] = 1.0;
    masses[1] = 2.0;
    masses[2] = 4.0;
    for(int i=0; i<objsCount; ++i) {
      //. Body...
      self->objs[i].body = dBodyCreate(world);
      assert(self->objs[i].body);
      //. Create a mass with the distribution of a sphere
      dMassSetSphereTotal(&objs[i].mass, masses[i], 15.0);
      //. Apply the mass to the cube
      dBodySetMass(objs[i].body, &objs[i].mass);
      //. Translate the body somewhere
      dBodySetPosition(objs[i].body, (i - 1)*160.0, 0.0, 0.0);
      //. Set a starting speed
      dBodySetLinearVel(objs[i].body, (i - 1)*-15.0, 0.0, 0.0);

      //. Geom...
      self->objs[i].geom = dCreateSphere(self->space, 5*((i / 3.0) + 1.0));
      assert(self->objs[i].geom);
      dGeomSetData(objs[i].geom, "Plane");
      dGeomSetBody(objs[i].geom, objs[i].body);
    }

    //. Tri Mesh...
    const unsigned int indexes[6] = {2, 1, 0, 3, 2, 0};
    const dVector3 triVert[4] = {
      { 10.0,  0.0,  10.0},
      {-10.0,  0.0,  10.0},
      {-10.0,  0.0, -10.0},
      { 10.0,  0.0, -10.0}
    };
    self->triMesh = dGeomTriMeshDataCreate();
    assert(self->triMesh);
    dGeomTriMeshDataBuildSimple(triMesh, (dReal *)triVert, 4, indexes, 6);

    self->plane = dCreateTriMesh(space, triMesh, NULL, NULL, NULL);
    assert(self->plane);
    dGeomSetBody(plane, 0);
    dGeomSetData(plane, "Plane");
    dGeomSetPosition(plane, 0.0, -10.0, 0.0);
#endif

    /**************************************************************************/
    /*** NXT ***/
    randEnabled     = YES;
    stepLimit       = 6000;
    t0_learningRate = 0.99999f;
    tN_learningRate = 0.00001f;
    learningRate    = t0_learningRate;
    tau             = exp(-1.0f / (stepLimit/(log(t0_learningRate) - log(tN_learningRate))));

    counterTSLC     = 0; //. Time Since Last Crash
    statRandom      = 0;
    statGreedy      = 0;
    statCrashes     = [NSMutableDictionary new];
    rewards         = [NSMutableDictionary new]; //. Immediate Rewards
    qValues         = [NSMutableDictionary new];
    transitions     = [NSMutableDictionary new];
    stateGoal       = nil;
    stateTerm       = nil;

    connected       = NO;
    _nxt            = [NXTMindstorm new];
    NSAssert([_nxt connect:self], @"Premature Failure in Connecting to the NXT Brick Device");
    NSAssert([_nxt respondsToSelector: @selector(attachActuator:)], @"_nxt does not respond to -attachActuator:");
  }
  return self;
}

- (void)dealloc {
#ifdef ODE_ENABLED
  //. TODO: dJointGroupEmpty();
  for(int i=0; i<objsCount; ++i)
    dBodyDestroy(self->objs[i].body);
  dWorldDestroy(world);
  dCloseODE();
#endif

  [qMem dealloc];
  [snsAcc dealloc];
  [actServo1 dealloc];
  [actServo2 dealloc];
  [_nxt dealloc];

  [super dealloc];
}

#ifdef ODE_ENABLED
- (void)drawObject:(NXTObject)obj {
  int t = dGeomGetClass(obj.geom); // Doesn't work
  switch(t) {
    case dSphereClass:
    case dBoxClass:
    case dTriMeshClass: {
      float rad = dGeomSphereGetRadius(obj.geom);
      GLUquadric *q = gluNewQuadric();
      glPushMatrix();
      glColor3d(0.8f, 0.8f, 0.4f);
      glScaled(10, 10, 10);
      glutSolidSphere(3, 16, 16);
      gluSphere(q, rad, 8, 8);
      glPopMatrix();
      break;
    }
    default:
      dbg("NXTQL", kFATAL, "UNKNOWN OBJECT CLASS!");
  }
}
#endif

- (void)render {
  return;

  glPushMatrix();

  /*
  glTranslatef(sceneTraX, sceneTraY, -20);
  glRotatef(sceneRotX, 1.0, 0.0, 0.0);
  glRotatef(sceneRotY, 0.0, 1.0, 0.0);
  */

  glPushMatrix();
    glColor3d(0.8f, 0.2f, 0.2f);
    glTranslatef(0, -100, 0);
    glutSolidSphere(10, 16, 16);
  glPopMatrix();

  //registerTime();
  /*
  registerTime();
  dWorldQuickStep(world, stepSize);
  drawThings();
  if (savedTime() + nextUpdate > actualTime())
    wait(savedTime() + nextUpdate - actualTime());
  */

//  glTranslatef(sceneTraX, sceneTraY, -20.0);
//  glRotatef(sceneRotX, 1.0, 0.0, 0.0);
//  glRotatef(sceneRotY, 0.0, 1.0, 0.0);

#ifdef ODE_ENABLED

  for(unsigned short i=0; i<objsCount; ++i) {
    glPushMatrix();
      glColor3d(0.9, 0.0, 0.0);
      self->realP = dBodyGetPosition(self->objs[i].body);
      glTranslatef(self->realP[0], self->realP[1], self->realP[2]);
      [self drawObject:self->objs[i]];
    glPopMatrix();
  }

  //. Set center for camera to stare at...
  const dReal *r = dBodyGetPosition(self->objs[1].body);
  center.x = r[0];
  center.y = r[1];
  center.z = r[2];

  //. Draw plane
	dVector3 v1, v2, v3;
	glPushMatrix();
    glColor3f(0.8, 0.5, 0.3);
    realP = dGeomGetPosition(plane);
    glTranslatef(realP[0], realP[1], realP[2]);
    glBegin(GL_TRIANGLES);
      for(int i=0; i<2; ++i) {
        dGeomTriMeshGetTriangle(plane, i, &v1, &v2, &v3);
        //NSLog(@"%i %f %f %f", i, v1, v2, v3);
        //dGeomSetPosition(plane, 0, -100, 0);
        glVertex3fv((const GLfloat *)v1);
        glVertex3fv((const GLfloat *)v2);
        glVertex3fv((const GLfloat *)v3);
      }
    glEnd();
	glPopMatrix();

  //dWorldQuickStep(world, NXT_QL_STEPSIZE/1000.0);
  dWorldStep(world, NXT_QL_STEPSIZE/1000.0);

  //dJointGroupEmpty(contactGroup);
  glPopMatrix();

  dSpaceCollide(space, self, &nearCallback);
  dWorldStep(world, 0.001f);
  //dJointGroupEmpty(contactGroup);
#endif
}

- (void)setReward:(int)r forState:(NXTState *)s {
  /* Reward associated for attaining the particular state */
  NSNumber *sAID;
  for(int aI=0; aI<[actions count]; aI++) {
    sAID = [qMem stateActionIdFromState:s action:[actions objectAtIndex:aI]];
    NSParameterAssert(sAID!=nil);
    [rewards setObject:[NSNumber numberWithInt:r] forKey:sAID];
  }
}

- (void)setReward:(int)r forAction:(NXTAction *)a {
  NSNumber *sAID;
  for(int sI=0; sI<[states count]; sI++) {
    sAID = [qMem stateActionIdFromState:[states objectAtIndex:sI] action:a];
    NSParameterAssert(sAID!=nil);
    [rewards setObject:[NSNumber numberWithInt:r] forKey:sAID];
  }
}

- (void)setReward:(int)r forState:(NXTState *)s action:(NXTAction *)a {
  NSNumber *sAID = [qMem stateActionIdFromState:s action:a];
  NSParameterAssert(sAID!=nil);
  [rewards setObject:[NSNumber numberWithInt:r] forKey:sAID];
}

- (SInt8)getQValueFromState:(NXTState *)s action:(NXTAction *)a {
  NSNumber *sAID = [qMem stateActionIdFromState:s action:a];
  return [[qValues objectForKey:sAID] intValue];
}

- (void)setGoalState:(NXTState *)sG {
  stateGoal = sG;
}

- (void)setTermState:(NXTState *)sT {
  stateTerm = sT;
}

- (BOOL)hasTerminated {
  return state == stateTerm;
}

/*!
 @method     
 @abstract   Discover the state of the robot
 @discussion The robot makes calls to this each tic to determine what state it
 is in, in order to decide what action to take next.  It does so by
 communicating with the sensors (via its state data-members).
*/
- (BOOL)discoverState {
    state = nil;
    NXTState *s;
    for(int sI=0; sI<[states count]; sI++) {
        s = [states objectAtIndex:sI];
        if([s isActive]) {
            state = s;
            NSParameterAssert(state);
            return TRUE;
        }
    }
    dbg("NM:QLearn", kINFO, "Failed to discover state of robot.");
    return FALSE;
}  

/*!
 @method     
 @abstract The smallest timestep unit of a machine
 @discussion The steps of this (QLearning) machine is not called form epoch,
 rather `-NXTGetInputValues:'
*/
- (void)step {
    if(state != nil) {
        
        NSParameterAssert(state);
        
        NXTState *lastState = [NXTState stateFromState:state];
        NXTAction *nextAction = doNothing;
        NSNumber *sAID;
        float reward, rewardImmediate, rewardDiscounted;
        
        if(![self hasTerminated]) {
            if((state == nil) || (randEnabled && ((float)random()/UINT32_MAX) <= learningRate)) {
                statRandom++;
                learningRate *= tau;
                dbg("NXT:[QLearn state]", kINFO, "Performing random action...");
                dbg("NXT:[QLearn state]", kINFO, "Learning rate reduced to %f, step %d (of total learning step %d)", learningRate, stepCount, stepLimit);
                nextAction = [qMem nextRandomAction];
            } else {
                statGreedy++;
                nextAction = [qMem nextBestActionFromState:lastState];
                dbg("NXT:[QLearn state]", kINFO, "Performing calculated action...");
            }
            sAID = [qMem stateActionIdFromState:state action:nextAction];
            rewardImmediate = [[rewards objectForKey:sAID] floatValue];
            rewardDiscounted = learningRate * [[qMem maxQValueFromState:state] floatValue];
            reward = rewardImmediate + rewardDiscounted;
            [qMem setQValue:reward forSAID:sAID];
        }
        //. TODO: Add this when ready...
        [self performAction:nextAction];
        stepCount++;
    } else {
        dbg(
            "NXT:[QLearn state]",
            kERROR,
            "Robot failed to determine state (%d)!",
            [snsAcc reading]
        );
        [self discoverState];
    }
}

- (void)performAction:(NXTAction *)a {
  NSParameterAssert(a!=nil);
  [_nxt performAction:a];
}

- (void)epoch {
    if(connected) {
        if(state == nil)
            dbg("NXT:[QLearn epoch]", kERROR, "Robot failed to determine state (%d)!", [snsAcc reading]);
    } else {
        dbg("NXT:[QLearn epoch]", kINFO, "Skip a epoch...");
    }
}

#pragma mark -
#pragma mark NXT Delegates

/*!
 @abstract Connected
*/
- (void)NXTDiscovered:(NXTMindstorm *)nxt {
    dbg("NXTQL-Delegate", kINFO, "NXT Connected!");
    
    connected = [nxt isConnected];
    NSAssert(connected, @"SHOULD NEVER GET HERE");
    
    actServo1 = [[NXTActuator alloc] initWithType:kNXTActuatorServo andPort:kNXTMotorB];   
    actServo2 = [[NXTActuator alloc] initWithType:kNXTActuatorServo andPort:kNXTMotorC];   
    dbg("NXTQL-Delegate", kINFO, "Actuator:%s", [[actServo1 description] UTF8String]);
    dbg("NXTQL-Delegate", kINFO, "Actuator:%s", [[actServo2 description] UTF8String]);
    [_nxt attachActuator:actServo1];
    [_nxt attachActuator:actServo2];
    
    snsAcc = [[NXTSensor alloc] initWithType:kNXTSensorAccelerometer andPort:kNXTSensor3];
    dbg("NXTQL-Delegate", kINFO, "Sensor:%s", [[snsAcc description] UTF8String]);
    [_nxt attachSensor:snsAcc];
    
    [nxt stopServos];
    [nxt resetMotorPosition:kNXTMotorAll relative:NO];
    
    NSArray *actuators = [[NSArray alloc] initWithObjects:actServo1, actServo2, nil];
    
    //. 120 max power
    actions = [[NSArray alloc] initWithObjects:
               [NXTAction actionWithActuators:actuators power:+75.0 name:@">>>>>" desc:@"Hard Acceleration"],
               [NXTAction actionWithActuators:actuators power:+45.0 name:@">>>" desc:@"Moderate Acceleration"],
               [NXTAction actionWithActuators:actuators power:+25.0 name:@">>" desc:@"Soft Acceleration"],
               [NXTAction actionWithActuators:actuators power:+15.0 name:@">" desc:@"Low Acceleration"],
               [NXTAction actionWithActuators:actuators power:  0.0 name:@"0" desc:@"No Acceleration"],
               [NXTAction actionWithActuators:actuators power:-15.0 name:@"<" desc:@"Low Deceleration"],
               [NXTAction actionWithActuators:actuators power:-25.0 name:@"<<" desc:@"Soft Deceleration"],
               [NXTAction actionWithActuators:actuators power:-45.0 name:@"<<<" desc:@"Moderate Deceleration"],
               [NXTAction actionWithActuators:actuators power:-75.0 name:@"<<<<<" desc:@"Hard Deceleration"],
               nil];
   /*
   states = [[NSArray alloc] initWithObjects:
            [NXTState stateWithSensor:snsAcc name:@"(((" desc:@"Falling Rightwards" tone:500        min:634 max:UINT16_MAX],
            [NXTState stateWithSensor:snsAcc name:@"((" desc:@"Heavily Leaning Rightwards" tone:500 min:610 max:633],
            [NXTState stateWithSensor:snsAcc name:@"(" desc:@"Leaning Rightwards" tone:700          min:586 max:609],
            [NXTState stateWithSensor:snsAcc name:@"|" desc:@"Perfectly Balanced" tone:900          min:581 max:585],
            [NXTState stateWithSensor:snsAcc name:@")" desc:@"Leaning Leftwards" tone:800           min:557 max:580],
            [NXTState stateWithSensor:snsAcc name:@"))" desc:@"Heavily Leaning Leftwards" tone:700  min:533 max:556],
            [NXTState stateWithSensor:snsAcc name:@")))" desc:@"Falling Leftwards" tone:600         min:500 max:532],
            [NXTState stateWithSensor:snsAcc name:@"-" desc:@"Fallen" tone:200                      min:0   max:500],
            nil];
    */
    states = [[NSArray alloc] initWithObjects:
              [NXTState stateWithSensor:snsAcc name:@"(((" desc:@"Falling Rightwards"           
                                   tone:500 min:-99 max:-31],
              [NXTState stateWithSensor:snsAcc name:@"((" desc:@"Heavily Leaning Rightwards"
                                   tone:500 min:-31 max:-21],
              [NXTState stateWithSensor:snsAcc name:@"(" desc:@"Leaning Rightwards"
                                   tone:700 min:-20 max:-11],
              [NXTState stateWithSensor:snsAcc name:@"|" desc:@"Perfectly Balanced"
                                   tone:900 min:-10 max:+10],
              [NXTState stateWithSensor:snsAcc name:@")" desc:@"Leaning Leftwards"
                                   tone:800 min:+11 max:+20],
              [NXTState stateWithSensor:snsAcc name:@"))" desc:@"Heavily Leaning Leftwards"
                                   tone:700 min:+21 max:+30],
              [NXTState stateWithSensor:snsAcc name:@")))" desc:@"Falling Leftwards"
                                   tone:600 min:+31 max:+99],
              [NXTState stateWithSensor:snsAcc name:@"-" desc:@"Fallen"
                                   tone:200 min:+100 max:+500],
              nil];
    
    [self setTermState:[states lastObject]];
    doNothing = [actions objectAtIndex:5];
    
    qMem = [[NXTQMemory alloc] initWithStates:states actions:actions];
    [self setReward:1000 forState:[states objectAtIndex:3]];
    
	[nxt playTone:523 duration:500];
    [nxt getBatteryLevel];
    [nxt pollKeepAlive];
}

/*!
 @abstract Disconnected
 */
- (void)NXTClosed:(NXTMindstorm *)nxt {
  dbg("NXTQL-Delegate", kINFO, "Disconnected!");
}

- (void)NXTError:(NXTMindstorm *)nxt code:(int)code {
  dbg("NXTQL-Delegate", kERROR, "Error Code: %d", code);
}

/*!
 @abstract Handle errors, special case ls pending communication
 */
- (void)NXTOperationError:(NXTMindstorm *)nxt operation:(UInt8)operation status:(UInt8)status {
  //. If communication is pending on the LS port, just keep polling
	if(operation == kNXTLSGetStatus && status == kNXTPendingCommunication)
		[nxt LSGetStatus:kNXTSensor4];
	else
    dbg("NXTQL-Delegate", kERROR, "Operation=0x%x Status=0x%x", operation, status);
}


/*!
 @abstract if bytes are ready to read, read 'em
 */
- (void)NXTLSGetStatus:(NXTMindstorm *)nxt port:(UInt8)port bytesReady:(UInt8)bytesReady {
    dbg("NXTQL-Delegate", kINFO, "%d bytes ready on port %d.", bytesReady, port);
	
    if(bytesReady > 0)
		[nxt LSRead:port sensor:kNXTSensorAccelerometer];
}

/*!
 @abstract Read battery level
 */
- (void)NXTBatteryLevel:(NXTMindstorm *)nxt batteryLevel:(UInt16)batteryLevel {
    dbg("NXTQL-Delegate", kINFO, "Battery level is %d", batteryLevel);
}

/*!
 @abstract Read accelerometer sensor value
 */
- (void)NXTLSRead:(NXTMindstorm *)nxt
           sensor:(NXTSensorType)type
             port:(UInt8)port
        bytesRead:(UInt8)bytesRead
             data:(NSData*)data {
    SInt8 outbuf[6];
    [data getBytes:outbuf length:6];
    SInt16 x = outbuf[0]; x <<= 2; x += outbuf[3]; float gX = x/200.f;
    SInt16 y = outbuf[1]; y <<= 2; y += outbuf[4]; float gY = y/200.f;
    SInt16 z = outbuf[2]; z <<= 2; z += outbuf[5]; float gZ = z/200.f;
    
    [snsAcc setReading:z/2]; //. centi-G's - and we only care about this axis for now.
    [nxt playTone:100 * gZ duration:1000];
    [self step];
}

/*!
 @abstract Read senrvo value
 */
- (void) NXTGetOutputState:(NXTMindstorm *)nxt
                      port:(UInt8)port
                     power:(SInt8)power
                      mode:(UInt8)mode
            regulationMode:(UInt8)regulationMode
                 turnRatio:(SInt8)turnRatio
                  runState:(UInt8)runState
                tachoLimit:(UInt32)tachoLimit
                tachoCount:(SInt32)tachoCount
           blockTachoCount:(SInt32)blockTachoCount
             rotationCount:(SInt32)rotationCount {
    NSString *value = [NSString stringWithFormat:@"%d", blockTachoCount];  
    dbg("NXTQL-Delegate", kDEBUG, "Value %s on port %d.", [value UTF8String], port);
}

@end
