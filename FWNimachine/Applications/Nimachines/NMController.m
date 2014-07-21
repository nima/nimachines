
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
//  NMController.m
//  SOM
//
//  Created by Nima on 20/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import <Nimachine/NMCanvas.h>

//. Machines
#import <Nimachine/NMSOM.h>
#import <Nimachine/NMPerceptron.h>
#import <Nimachine/NMQLearn.h>

#import <Nimachine/NMCamera.h>

#import "NMUtilities.h"

#import "NMController.h"
#import "NMDataFileController.h"

@interface NMController();
- (void)populateDropDownMenu:(UInt8)tag;
@end

@implementation NMController

- (id)init {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (id)initWithCoder:(NSCoder *)dc {
  if(self = [super initWithCoder:dc]) {
  }
  return self;
}

#pragma mark -
#pragma Rendering

/*!
 @method     
 @abstract Awaken the Machine...
 @discussion 
 @tags MACHINE_DROPIN_POINT
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    glcontext = [self openGLContext];
    [glcontext makeCurrentContext];

    [gui_mainPanel setFloatingPanel:NO];
    
    [gui_openGLPanel setAlphaValue:0.00f];
    [gui_openGLPanel setFloatingPanel:NO];
    
    /*! @tags MACHINE_DROPIN_POINT */
    activeMachine = nil;
    [dataFileController setMachines:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NMPerceptron class], @"Perceptron",
      [NMSOM class], @"SOM",
      [NMQLearn class], @"QLearn",
      nil]
     ];
    [gui_machineTabs setDelegate:dataFileController];
    
    [[gui_machineTabs tabViewItemAtIndex:0] setIdentifier:@"Perceptron"];
    [gui_perceptron_box setBorderType:NSBezelBorder];
    [gui_perceptron_box setCornerRadius:5.00f];
    
    [[gui_machineTabs tabViewItemAtIndex:1] setIdentifier:@"SOM"];
    [gui_som_box setBorderType:NSBezelBorder];
    [gui_som_box setCornerRadius:5.00f];
    
    [[gui_machineTabs tabViewItemAtIndex:2] setIdentifier:@"QLearn"];
    [gui_qlnxt_box setBorderType:NSBezelBorder];
    [gui_qlnxt_box setCornerRadius:5.00f];
}

- (void)prepareOpenGL {
  [super prepareOpenGL];
  
  glEnable(GL_COLOR_MATERIAL);
  glLineWidth(2);
}

/*!
 @method     
 @abstract Inform the user about the machine's current state
 @discussion Via the UI, inform the user on each step, the state of the
 currently active machine.
 @tags MACHINE_DROPIN_POINT
*/
- (void)stepAnimation:(NSTimer *)t {
    if(activeMachine) {
        if([activeMachine class] == [NMPerceptron class]) {
            [gui_perceptron_error          setFloatValue:[perceptron averageError]];
            [gui_perceptron_error_q        setFloatValue:[perceptron averageError]];

            [gui_perceptron_learningRate   setFloatValue:[perceptron learningRate]];
            [gui_perceptron_learningRate_q setFloatValue:[perceptron learningRate]];

            [gui_perceptron_step           setDoubleValue:[perceptron stepCount]];
            [gui_perceptron_step_q         setDoubleValue:[perceptron stepCount]];

            [gui_perceptron_epoch          setDoubleValue:[perceptron epochCount]];
            [gui_perceptron_epoch_q        setDoubleValue:[perceptron epochCount]];
                        
        } else if([activeMachine class] == [NMSOM class]) {
            [gui_som_error             setFloatValue:[som averageError]];
            [gui_som_error_q           setFloatValue:[som averageError]];
            
            [gui_som_stepPhase1and2    setDoubleValue:[som stepCount]];
            [gui_som_stepPhase1and2_q  setDoubleValue:[som stepCount]];
            
            [gui_som_stepPhase3        setDoubleValue:[som stepCountP3]];
            [gui_som_stepPhase3_q      setDoubleValue:[som stepCountP3]];
            
            [gui_som_learningRate      setFloatValue:[som learningRate]];
            [gui_som_learningRate_q    setFloatValue:[som learningRate]];
            
            [gui_som_radius            setFloatValue:[som radius]];
            [gui_som_radius_q          setFloatValue:[som radius]];
            
            [gui_som_epoch             setIntValue:[som epochCount]];
            [gui_som_epoch_q           setIntValue:[som epochCount]];
        } else if([activeMachine class] == [NMQLearn class]) {
            [gui_qlnxt_step setIntValue:[activeMachine stepCount]];
            [gui_qlnxt_step_q setIntValue:[activeMachine stepCount]];
            
            [gui_qlnxt_learningRate setFloatValue:[activeMachine learningRate]];
            [gui_qlnxt_learningRate_q setFloatValue:[activeMachine learningRate]];
        }
        [self setNeedsDisplay:YES];
    }
}

#pragma mark -
#pragma mark Rendering

#import <GLUT/glut.h>


- (void)drawRect:(NSRect)r {
    /* FIXME: Crashed on EXC_BAD_ACCESS on close of application */
  if([gui_pause state] == NSOnState) {
    sleep(0.1);
    return;
  }

  /*! @tags MACHINE_DROPIN_POINT */
  if(activeMachine) {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    static float t = 0.000f;
    float u = 2*t*M_PI;
    float v = 4*t*M_PI;
    t += (t<1.000f)?TIMESTEP:-t;
    float x = RADIUS*sin(u)*cos(v);
    float y = RADIUS*sin(u)*sin(v);
    float z = RADIUS*cos(u);
    [camera setEyeWithX:x y:y z:z];
    
    if([activeMachine class] == [NMSOM class]) {
      [activeMachine epoch];
    } else if([activeMachine class] == [NMPerceptron class]) {
      static int i=0;
      if(i==-1 || i++ > 500) {
        [activeMachine epoch];
        i=-1;
      }
    } else if([activeMachine class] == [NMQLearn class]) {
      [activeMachine epoch];
    } else {
      FAIL_NOW;
    }
    [activeMachine render];
    [camera setLook:[activeMachine lookAtMe]];
    [camera execModelViewMatrix];
    [glcontext flushBuffer]; //. Swap between buffers in double bugger mode 
  }
}

#pragma mark -
#pragma mark IBAction

- (IBAction)awakenMachine:(id)sender {
    if([gui_control state] == NSOffState) {
        [gui_dataFileList setEnabled:YES];
        [gui_control setTitle:@"Start"];
        [activeMachine release];
        activeMachine = nil;
        //[gui_machineTabs setEnabled:YES];
        [gui_openGLPanel setAlphaValue:0.00f];
        [gui_som_latticeLength setEnabled:YES];
        [gui_som_dimensions setEnabled:YES];
        [gui_som_topology setEnabled:YES];
        [gui_pause setEnabled:NO];
    } else if([gui_control state] == NSOnState) {
        [gui_control setTitle:@"Stop"];
        //[gui_machineTabs setEnabled:NO];
        [gui_som_latticeLength setEnabled:NO];
        [gui_som_dimensions setEnabled:NO];
        [gui_som_topology setEnabled:NO];
        [gui_pause setEnabled:YES];
        [self populateDropDownMenu:[sender tag]];
        
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        [glcontext flushBuffer];
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        
        if(activeMachine == nil)
            [NSException raise:@"RunTimeError"
                        format: @"Active machine is `nil'"];

        [gui_openGLPanel setAlphaValue:1.00f];
        
        [camera execViewportMatrix];
        [activeMachine render];
    }
}

- (void)populateDropDownMenu:(UInt8)tag {
    NSString *dataFile = [[dataFileController selected] path];
    /*! @tags MACHINE_DROPIN_POINT */
    switch([dataFileController activeMachineId]) {
        int l, d;
        NMLatticeModeHyperCube t;
            
        case ID_PERCEPTRON:
            perceptron = [[NMPerceptron alloc] initWithDataFile:dataFile];
            activeMachine = perceptron;
            
            [perceptron epoch]; //. 1 introductory epoch for perceptron
            [camera setZoom:0.02f];
            
            [gui_openGLPanel                  setTitle:@"Rosenblat's Perceptron"];
            
            [gui_perceptron_step              setMinValue:0];
            [gui_perceptron_step              setMaxValue:[activeMachine stepLimit]];
            
            [gui_perceptron_error             setMinValue:0];
            [gui_perceptron_error             setMaxValue:1.00];
            
            [gui_perceptron_learningRate      setMinValue:0];
            [gui_perceptron_learningRate      setMaxValue:[activeMachine t0_learningRate]];
            
            [gui_perceptron_epoch             setMaxValue:[activeMachine stepLimit]/[activeMachine epochSize]];
            
            break;
        case ID_SOM:
            l = [[gui_som_latticeLength labelForSegment:[gui_som_latticeLength selectedSegment]] intValue];
            d = [gui_som_dimensions selectedSegment]+2;
            t = [gui_som_topology selectedSegment];
            som = [[NMSOM alloc] initWithDataFile:dataFile
                                       dimensions:d
                                    latticeLength:l
                                   andLatticeMode:t];
            activeMachine = som;
            
            [camera setZoom:0.02f];
            
            [gui_openGLPanel           setTitle:@"Kohonen's Self-Organizing Maps"];
            
            [gui_som_error             setMinValue:0];
            [gui_som_error             setMaxValue:10.00f];
            
            [gui_som_learningRate      setMinValue:0];
            [gui_som_learningRate      setMaxValue:[activeMachine t0_learningRate]];
            
            [gui_som_stepPhase1and2   setMinValue:0];
            [gui_som_stepPhase1and2   setMaxValue:[activeMachine stepLimit]];
            
            [gui_som_stepPhase3       setMinValue:0];
            [gui_som_stepPhase3       setMaxValue:[som stepLimitP3]];
            
            [gui_som_radius            setMinValue:0];
            [gui_som_radius            setMaxValue:[som t0_radius]];
            
            [som setVrp:[camera eye]];
            break;
        case ID_QLEARN:
            qlearn = [[NMQLearn alloc] initWithDataFile:dataFile];
            activeMachine = qlearn;
            [camera setZoom:0.02f];
            [gui_openGLPanel setTitle:@"QLearn"];
            
            [gui_qlnxt_step setMinValue:0];
            [gui_qlnxt_step setMaxValue:[activeMachine stepLimit]];
            
            [gui_qlnxt_learningRate setMinValue:0.0f];
            [gui_qlnxt_learningRate setMaxValue:[activeMachine t0_learningRate]];
            break;
        default:
            [NSException raise:@"InvalidMachineTagId"
                        format:@"No Machine with Tag ID %d", tag];
    }
}

- (IBAction)setFile:(id)sender {
  NSLog(@">>>%@<<<", [[sender selectedCell] objectValue]);
}

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




#pragma mark -
#pragma mark Windowing
@implementation NMController(Windowing)
- (BOOL)windowShouldClose:(id)sender{ //close box quits the app
  [NSApp terminate:self];
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self release]; // make sure to dealloc the controller to properly tear down the VideoOut 
}

/*
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)a {
  return YES;
}
*/

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)a {
  return NSRunStoppedResponse;
}
@end

/*
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
 #endif
 */

