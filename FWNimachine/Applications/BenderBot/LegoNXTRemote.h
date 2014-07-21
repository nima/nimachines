
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

/* $Id: LegoNXTRemote.h 17 2009-02-01 01:18:33Z querry43 $ */

/*! \file LegoNXTRemote.h
* This file describes a graphical interface for the LegoNXT Framework.
*
* \author Matt Harrington
* \date 01/04/09
*/

#import <Cocoa/Cocoa.h>
#import <NXTMindstorm/NXTMindstorm.h>

@interface LegoNXTRemote:NSObject {
    NXTMindstorm *_nxt;
    
    IBOutlet NSLevelIndicator *batteryLevelIndicator;
    IBOutlet NSTextField *connectMessage;
    IBOutlet NSButton *connectButton;

    
    
    NSButton *sensorPolls[CNT_SENSORS + 1];
    IBOutlet NSButton *sensorPoll1;
    IBOutlet NSButton *sensorPoll2;
    IBOutlet NSButton *sensorPoll3;
    IBOutlet NSButton *sensorPoll4;
    
    NSSlider *sensorPollIntervals[CNT_SENSORS + 1];
    IBOutlet NSSlider *sensorPollInterval1;
    IBOutlet NSSlider *sensorPollInterval2;
    IBOutlet NSSlider *sensorPollInterval3;
    IBOutlet NSSlider *sensorPollInterval4;
    
    NSPopUpButton *sensorTypes[CNT_SENSORS + 1];
    IBOutlet NSPopUpButton *sensorType1;
    IBOutlet NSPopUpButton *sensorType2;
    IBOutlet NSPopUpButton *sensorType3;
    IBOutlet NSPopUpButton *sensorType4;

    NSDictionary *sensorz;
	IBOutlet NSDictionaryController *sensorController;
    NXTSensor *sensors[CNT_SENSORS];

    NSTextField *sensorValues[CNT_SENSORS + 1];
    IBOutlet NSTextField *sensorValue1;
    IBOutlet NSTextField *sensorValue2;
    IBOutlet NSTextField *sensorValue3;
    IBOutlet NSTextField *sensorValue4;

    
    
    BOOL isPollingServo[CNT_SERVOS];

    NSButton *servoEnables[CNT_SERVOS + 1];
    IBOutlet NSButton *servoEnableA;
    IBOutlet NSButton *servoEnableB;
    IBOutlet NSButton *servoEnableC;
    
    IBOutlet NSButton *servoPositionReset;

    NSButton *servoPolls[CNT_SERVOS + 1];
    IBOutlet NSButton *servoPollA;
    IBOutlet NSButton *servoPollB;
    IBOutlet NSButton *servoPollC;
    
    NSTextField *servoPositions[CNT_SERVOS + 1];
    IBOutlet NSTextField *servoPositionA;
    IBOutlet NSTextField *servoPositionB;
    IBOutlet NSTextField *servoPositionC;
    
    NSSlider *servoSpeeds[CNT_SERVOS + 1];
    IBOutlet NSSlider *servoSpeedA;
    IBOutlet NSSlider *servoSpeedB;
    IBOutlet NSSlider *servoSpeedC;
}

- (IBAction)doConnect:(id)sender;

- (IBAction)doPollSensor:(id)sender;
- (IBAction)doPollIntervalSensor:(id)sender;

- (IBAction)doPollServo:(id)sender;
- (IBAction)enableServo:(id)sender;
- (IBAction)doChangeServoSpeed:(id)sender;
- (IBAction)doResetServoPosition:(id)sender;

@end
