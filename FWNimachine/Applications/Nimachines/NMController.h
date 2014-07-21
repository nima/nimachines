
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
//  NMController.h
//  SOM
//
//  Created by Nima on 20/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

/* Psy| says...

 CGFloat is either float or double depending on your architecture, you should
 thus remove the f when you define values like that : 0.0f
 
 Don't dynamically allocate for structs (Point3). 
   
*/
#import <Cocoa/Cocoa.h>

#define TIMESTEP 0.001f
#define RADIUS   300

#define TAG_DIMENSIONS 5000

@class NMCanvas, NMDataFileController;
@class NMMachine, NMPerceptron, NMSOM, NMQLearn;

@interface NMController:NMCanvas {  
  NSString *trainingDataFile;
  IBOutlet NSSlider *gui_ambientLight, *gui_zoom;

  NMMachine *activeMachine;
  IBOutlet NSPanel *gui_mainPanel;
  IBOutlet NSPanel *gui_openGLPanel;
  IBOutlet NSTabView *gui_machineTabs;
  IBOutlet NSPopUpButton *gui_dataFileList;
  IBOutlet NSButton *gui_control, *gui_pause;
  IBOutlet NMDataFileController *dataFileController;

  NMPerceptron *perceptron;
  IBOutlet NSBox *gui_perceptron_box;
  IBOutlet NSLevelIndicator *gui_perceptron_step;
  IBOutlet NSLevelIndicator *gui_perceptron_epoch;
  IBOutlet NSLevelIndicator *gui_perceptron_error;
  IBOutlet NSLevelIndicator *gui_perceptron_learningRate;
  IBOutlet NSTextField *gui_perceptron_step_q;
  IBOutlet NSTextField *gui_perceptron_epoch_q;
  IBOutlet NSTextField *gui_perceptron_error_q;
  IBOutlet NSTextField *gui_perceptron_learningRate_q;  
  IBOutlet NSMatrix *gui_dimensions;
  
  NMSOM *som;
  IBOutlet NSBox *gui_som_box;
  IBOutlet NSLevelIndicator *gui_som_stepPhase1and2;
  IBOutlet NSLevelIndicator *gui_som_stepPhase3;
  IBOutlet NSLevelIndicator *gui_som_epoch;
  IBOutlet NSLevelIndicator *gui_som_learningRate;
  IBOutlet NSLevelIndicator *gui_som_radius;
  IBOutlet NSLevelIndicator *gui_som_error;
  IBOutlet NSTextField *gui_som_stepPhase1and2_q, *gui_som_stepPhase3_q;
  IBOutlet NSTextField *gui_som_radius_q, *gui_som_learningRate_q;  
  IBOutlet NSTextField *gui_som_epoch_q;
  IBOutlet NSTextField *gui_som_error_q;
  IBOutlet NSSegmentedControl *gui_som_latticeLength, *gui_som_dimensions, *gui_som_topology;

  NMQLearn *qlearn;
  IBOutlet NSBox *gui_qlnxt_box;
  IBOutlet NSLevelIndicator *gui_qlnxt_battery;
  IBOutlet NSLevelIndicator *gui_qlnxt_connection;
  IBOutlet NSLevelIndicator *gui_qlnxt_step;
  IBOutlet NSLevelIndicator *gui_qlnxt_learningRate;
  IBOutlet NSTextField *gui_qlnxt_step_q;
  IBOutlet NSTextField *gui_qlnxt_learningRate_q;
}

- (id)initWithCoder:(NSCoder *)dc;

- (IBAction)awakenMachine:(id)sender;

- (IBAction)setFile:(id)sender;
- (IBAction)setAmbience:(id)sender;
- (IBAction)setZoom:(id)sender;
@end
