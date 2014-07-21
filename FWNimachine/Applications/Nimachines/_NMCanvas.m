
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
//  SOMCanvas.m
//  SOM
//
//  Created by Nima on 23/09/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMCanvas.h"

#import <GLUT/glut.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#import "SOM.h"
#import "Camera.h"
#import "Vector3.h"

#pragma mark -
@implementation NMCanvas(SOM)

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)c andDataFile:(NSString *)dF {
  self = [super initWithCoder:c andDataFile:dF];
  return self;
}

#pragma mark -
#pragma mark Windowing and Application Handling

- (BOOL)windowShouldClose:(id)sender{ //close box quits the app
  [NSApp terminate:self];
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self release]; // make sure to dealloc the controller to properly tear down the VideoOut
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)a {
  return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)a {
  return NSRunStoppedResponse;
}

#pragma mark -
#pragma mark Animation

- (void)awakeFromNib {
  [super awakeFromNib];
  glcontext = [self openGLContext];
  [glcontext makeCurrentContext];
  
  //. The SOM...
  som = [[SOM alloc] initWithData:INPUT_DATA_SOM];
  [self addObject:som];
  [som setVrp:[camera eye]];
  
  [camera execViewportMatrix];
  
  [gui_zoom setFloatValue:[gui_zoom minValue] + 0.02f*([gui_zoom maxValue]-[gui_zoom minValue])];
  [gui_stepCount        setMaxValue:[som tN_stepCount]];
  [gui_stepCount        setMinValue:0];
  [gui_stepConvCount    setMaxValue:[som tN_stepConvCount]];
  [gui_stepConvCount    setMinValue:0];
  [gui_radius            setMaxValue:[som t0_radius]];
  [gui_radius            setMinValue:0];
  [gui_learningRate      setMaxValue:[som t0_learningRate]];
  [gui_learningRate      setMinValue:0];
  
  [self setZoom:gui_zoom];
}

- (void)prepareOpenGL {
  [super prepareOpenGL];
  [gui_ambientLight setFloatValue:0.0f];
}

- (void)stepAnimation:(NSTimer *)t {
  
  [gui_stepCount        setDoubleValue:[som stepCount]];
  [gui_stepCount_q      setDoubleValue:[som stepCount]];
  [gui_stepConvCount    setDoubleValue:[som stepConvCount]];
  [gui_stepConvCount_q  setDoubleValue:[som stepConvCount]];
  [gui_learningRate      setFloatValue:[som learningRate]];
  [gui_learningRate_q    setFloatValue:[som learningRate]];
  [gui_radius            setFloatValue:[som radius]];
  [gui_radius_q          setFloatValue:[som radius]];
  
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Rendering



- (void)drawRect:(NSRect)r {
  [som epoch];
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  
  /******************************* CAMERA *************************************/
#if ANTIALIASING > 0
  Vector3 jitter;
  glClear(GL_ACCUM_BUFFER_BIT);
  
  for(int i=0; i<ANTIALIASING; i++) {
    jitter = Vector3$initWithXYZOnly(
                                     (0.5-randf)/.5f,
                                     (0.5-randf)/.5f,
                                     0
                                     );
    [camera slideWithVector:jitter];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glColor3d(0.3, 0.8, 0.1);
    glCallList(teapot);
    glAccum(GL_ACCUM, 1.0f/(float)ANTIALIASING);
  }
  
  [som render];
  glAccum(GL_RETURN, 1.0);
#else
  Vector3 v1 = Vector3$initWithXYZOnly(camera.eye->z, 0, -camera.eye->x);
  Vector3 v2 = Vector3$initWithXYZOnly(camera.eye->y, -camera.eye->x, 0);
  Vector3 v3 = Vector3$add(v1, v2);
  if(Vector3$scalar(v3)) {
    v3 = Vector3$normalize(v3);
    [camera moveEyeWithVector:v3];
  }
  [som render];
#endif
  [camera execModelViewMatrix];
  
  /******************************* OBJECTS ************************************/
  /*
   for(int i=0; i<[objects count]; i++)
   [[objects objectAtIndex:i] render];
   */
  
  //[som render];
  //[self reshape];
  
  //glutSwapBuffers();
  [glcontext flushBuffer]; //. Swap between buffers in double bugger mode 
  //glFlush();
  /*
   The function glFlush waits until commands are submitted but does not wait for
   the commands to finish executing. The function glFinish waits for the
   submitted commands to complete executing. 
   */
}

#pragma mark -
#pragma mark IBAction

- (IBAction)setAmbience:(id)sender {
  lightAmbient[3] = 1.0;
  lightAmbient[0] = lightAmbient[1] = lightAmbient[2] = [gui_ambientLight floatValue];
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lightAmbient);
}

- (IBAction)setZoom:(id)sender {
  double x = [sender doubleValue];
  double m = [sender maxValue];
  [camera setZoom: x/sqrt(1+pow(0.9*m-x, 2))];
}

@end







//
//  PerceptronCanvas.m
//  SOM
//
//  Created by Nima on 17/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "Canvas.h"
#import "PerceptronCanvas.h"

#import <GLUT/glut.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#import "Perceptron.h"
#import "Camera.h"
#import "Vector3.h"

#pragma mark -
@implementation NMCanvas(Perceptron)

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)c andDataFile:(NSString *)dF {
  self = [super initWithCoder:c andDataFile:dF];
  return self;
}

#pragma mark -
#pragma mark Animation

- (void)awakeFromNib {
  [super awakeFromNib];
  glcontext = [self openGLContext];
  [glcontext makeCurrentContext];
  //[glcontext setView:[SOMCanvas new]];
  
  //. The Perceptron...
  perceptron = [[Perceptron alloc] initWithData:dataFile];
  [self addObject:perceptron];
  [camera setLook:[perceptron center]];
  [camera execViewportMatrix];
  
  [gui_zoom         setFloatValue:[gui_zoom minValue] + 0.02f*([gui_zoom maxValue]-[gui_zoom minValue])];
  [gui_stepCount   setMaxValue:[perceptron tN_stepCount]];
  [gui_stepCount   setMinValue:0];
  [gui_learningRate setMaxValue:[perceptron t0_learningRate]];
  [gui_learningRate setMinValue:0];
  
  [self setZoom:gui_zoom];
}

- (void)prepareOpenGL {
  [super prepareOpenGL];
  [gui_ambientLight setFloatValue:0.0f];
  
  glEnable(GL_COLOR_MATERIAL);
  glLineWidth(2);
  [perceptron epoch];
}

- (void)stepAnimation:(NSTimer *)t {
  [gui_stepCount     setDoubleValue:[perceptron stepCount]];
  [gui_stepCount_q   setDoubleValue:[perceptron stepCount]];
  [gui_learningRate   setFloatValue:[perceptron learningRate]];
  [gui_learningRate_q setFloatValue:[perceptron learningRate]];
  
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Rendering

- (void)drawRect:(NSRect)r {
  static int i=0;
  if(i==-1 || i++ > 1000) {
    [perceptron epoch];
    i=-1;
  }
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  
  /******************************* CAMERA *************************************/
  /**/
  Vector3 v1 = Vector3$initWithXYZOnly(camera.eye->z, 0, -camera.eye->x);
  Vector3 v2 = Vector3$initWithXYZOnly(camera.eye->y, -camera.eye->x, 0);
  Vector3 v3 = Vector3$add(v1, v2);
  if(Vector3$scalar(v3)) {
    v3 = Vector3$normalize(v3);
    [camera moveEyeWithVector:v3];
  }
  /**/
  [perceptron render];
  [camera execModelViewMatrix];
  
  [glcontext flushBuffer]; //. Swap between buffers in double bugger mode 
}

#pragma mark -
#pragma mark IBAction

- (IBAction)setAmbience:(id)sender {
  lightAmbient[3] = 1.0;
  lightAmbient[0] = lightAmbient[1] = lightAmbient[2] = [gui_ambientLight floatValue];
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lightAmbient);
}

- (IBAction)setZoom:(id)sender {
  double x = [sender doubleValue];
  double m = [sender maxValue];
  [camera setZoom: x/sqrt(1+pow(0.9*m-x, 2))];
}

@end

