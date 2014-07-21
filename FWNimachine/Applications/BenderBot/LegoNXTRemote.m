
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

/* $Id: LegoNXTRemote.m 17 2009-02-01 01:18:33Z querry43 $ */

/*! \file LegoNXTRemote.h
* This file implements a graphical interface for the LegoNXT Framework.
*
* \author Matt Harrington
* \date 01/04/09
*/

#import "LegoNXTRemote.h"

@interface LegoNXTRemote()
- (NXTSensorType)sensorModelAtPort:(UInt8)port;
- (NXTSensorType)sensorModelSelectedIn:(NSPopUpButton *)sensorSelector;
- (void)sendObjects:(id *)objSet message:(SEL)sel withArgument:(id)arg;
- (void)sendObjects:(id *)objSet message:(SEL)sel value:(UInt8)arg;
- (void)sendObjects:(id *)objSet setEnabled:(BOOL)arg;
@end

#pragma mark -
@implementation LegoNXTRemote

- (void)sendObjects:(id *)objSet message:(SEL)sel withArgument:(id)arg {
    NSMethodSignature *sig;
    NSInvocation *inv;
    id obj;
    int i = 0;
    while((obj = objSet[i++]) != NULL) {
        sig = [[obj class] instanceMethodSignatureForSelector:sel];
        assert(sig != nil);
        inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:obj];
        [inv setSelector:sel];
        [inv setArgument:&arg atIndex:2];
        [inv invoke];
    }
}

- (void)sendObjects:(id *)objSet setEnabled:(BOOL)arg {
    SEL sel = @selector(setEnabled:);
    [self sendObjects:objSet message:sel value:arg];
}

- (void)sendObjects:(id *)objSet message:(SEL)sel value:(UInt8)arg {
    NSMethodSignature *sig;
    NSInvocation *inv;
    id obj;
    int i = 0;
    while((obj = objSet[i++]) != NULL) {
        sig = [[obj class] instanceMethodSignatureForSelector:sel];
        assert(sig != nil);
        inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:obj];
        [inv setSelector:sel];
        [inv setArgument:&arg atIndex:2];
        [inv invoke];
    }
}


// enable all poll buttons
- (void)enableControls:(BOOL)enable {

    [self sendObjects:sensorPollIntervals setEnabled:enable];
    [self sendObjects:sensorPolls setEnabled:enable];
    [self sendObjects:sensorTypes setEnabled:enable];
    [self sendObjects:servoEnables setEnabled:enable];
    [self sendObjects:servoPolls setEnabled:enable];
    [servoPositionReset setEnabled:enable];

    if(!enable) {
        [self sendObjects:sensorPolls message:@selector(setTitle:) withArgument:@"poll"];
        [self sendObjects:servoPolls message:@selector(setTitle:) withArgument:@"poll"];
        [self sendObjects:servoEnables message:@selector(setState:) value:NSOffState];
        [self sendObjects:servoSpeeds message:@selector(setEnabled:) value:enable];
        [self sendObjects:servoSpeeds message:@selector(setIntValue:) value:0];

        for(int i=0; i<3; i++)
            isPollingServo[i] = NO;
    }
}

#pragma mark -
#pragma mark GUI Delegates

- (void)awakeFromNib {
    NSLog(@"awakened");
    NSLog(@" >>> %d vs %d <<<", sizeof(NXTVendor), sizeof(NXTLogPriority));

    [connectMessage setStringValue:[NSString stringWithFormat:@"Disconnected"]];

    memcpy(sensorPolls, ((NSButton *[CNT_SENSORS + 1]){
        sensorPoll1,
        sensorPoll2,
        sensorPoll3,
        sensorPoll4,
    NULL}), (CNT_SENSORS + 1) * sizeof(NSButton *));

    memcpy(sensorPollIntervals, ((NSSlider *[CNT_SENSORS + 1]){
        sensorPollInterval1,
        sensorPollInterval2,
        sensorPollInterval3,
        sensorPollInterval4,
    NULL}), (CNT_SENSORS + 1) * sizeof(NSButton *));

    memcpy(sensorTypes, ((NSButton *[CNT_SENSORS + 1]){
        sensorType1,
        sensorType2,
        sensorType3,
        sensorType4,
    NULL}), (CNT_SENSORS + 1) * sizeof(NSButton *));

    memcpy(sensorValues, ((NSTextField *[CNT_SENSORS + 1]){
        sensorValue1,
        sensorValue2,
        sensorValue3,
        sensorValue4,
    NULL}), (CNT_SENSORS + 1) * sizeof(NSButton *));
    
    memcpy(servoPolls, ((NSButton *[CNT_SERVOS + 1]){
        servoPollA,
        servoPollB,
        servoPollC,
    NULL}), (CNT_SERVOS + 1) * sizeof(NSButton *));
    
    memcpy(servoEnables, ((NSButton *[CNT_SERVOS + 1]){
        servoEnableA,
        servoEnableB,
        servoEnableC,
    NULL}), (CNT_SERVOS + 1) * sizeof(NSButton *));
    
    memcpy(servoPositions, ((NSTextField *[CNT_SERVOS + 1]){
        servoPositionA,
        servoPositionB,
        servoPositionC,
    NULL}), (CNT_SERVOS + 1) * sizeof(NSButton *));

    memcpy(servoSpeeds, ((NSSlider *[CNT_SERVOS + 1]){
        servoSpeedA,
        servoSpeedB,
        servoSpeedC,
    NULL}), (CNT_SERVOS + 1) * sizeof(NSButton *));
}

- (BOOL)windowShouldClose:(id)sender {
    [NSApp terminate:self];
    return true;
}

- (IBAction)doConnect:(id)sender {
    [connectMessage setStringValue:[NSString stringWithFormat:@"Connecting..."]];

    _nxt = [[NXTMindstorm alloc] init];
    if([_nxt connect:self]) {
        [sensorController setContent:[NXTSensor supported]];
        [connectMessage setStringValue:[NSString stringWithFormat:@"Connected"]];
    } else {
        [connectMessage setStringValue:
         [NSString stringWithFormat:@"Disconnected (Connection Failed)"]];
        [_nxt release];
    }
}

#pragma mark -
#pragma mark * Sensors
- (NXTSensorType)sensorModelSelectedIn:(NSPopUpButton *)sensorSelector {
    unsigned short i = [sensorSelector indexOfSelectedItem];
    id s = [[sensorController arrangedObjects] objectAtIndex:i];
    return [[s value] intValue];
}

- (NXTSensorType)sensorModelAtPort:(UInt8)port {
    NSPopUpButton *popup = sensorTypes[port];
    return [self sensorModelSelectedIn:popup];
}

- (void)switchPollingSensorOnPort:(UInt8)port
                   sensorSelector:(NSPopUpButton *)sensorSelector
                       pollButton:(NSButton *)pollButton {
    
    NXTSensor *sensor = sensors[port];
    NXTSensorType type = [self sensorModelSelectedIn:sensorSelector];

    BOOL create = NO;
    if(sensor && ([sensor type] != type)) {
        [sensor release];
        create = YES;
    } else if(sensor == kNXTSensorNone) {
        create = YES;
    }

    if(create) {
        switch(type) {
            case kNXTSensorLight:
            case kNXTSensorLightPassive:
                sensor = [[NXTSensorLight alloc] initWithType:type andPort:port];
                break;
            case kNXTSensorSound:
            case kNXTSensorSoundAdjusted:
                sensor = [[NXTSensorSound alloc] initWithType:type andPort:port];
                break;
            case kNXTSensorGyroscope:
                sensor = [[NXTSensorGyroscope alloc] initOnPort:port];
                break;
            case kNXTSensorTouch:
                sensor = [[NXTSensorTouch alloc] initOnPort:port];
                break;
            case kNXTSensorAccelerometer:
                sensor = [[NXTSensorAccelerometer alloc] initOnPort:port];
                break;
            case kNXTSensorCompass:
                sensor = [[NXTSensorCompass alloc] initOnPort:port];
                break;
            case kNXTSensorUltrasonic:
                sensor = [[NXTSensorUltrasonic alloc] initOnPort:port];
                break;
            default:
                [NSException raise:@"ERROR" format:@"505 - FIXME"];
                break;
        }
    }
    
    BOOL start = ![sensor polled];
    if(start) {
        float interval = [sensorPollIntervals[port] floatValue];
        sensors[port] = sensor;
        [_nxt attachSensor:sensor];
        [_nxt pollSensor:sensor atInterval:interval];
        [pollButton setTitle:@"Stop"];
        [sensorSelector setEnabled:NO];
    } else {
        [_nxt unpollSensorOnPort:port];
        [pollButton setTitle:@"Poll"];
        [sensorSelector setEnabled:YES];
    }
}

- (IBAction)doPollSensor:(id)sender {
    UInt8 tag = [sender tag];
    [self switchPollingSensorOnPort:(NXTSensorPort)tag
                     sensorSelector:sensorTypes[tag]
                         pollButton:sensorPolls[tag]];
}

- (IBAction)doPollIntervalSensor:(id)sender {
    UInt8 tag = [sender tag];
    NXTSensor *sensor = sensors[(NXTSensorPort)tag];
    [_nxt pollSensor:sensor atInterval:[sender floatValue]];
}

- (void)setSensorTextField:(NXTSensorPort)port value:(NSString *)value {
    [sensorValues[port] setStringValue:value];
}

#pragma mark -
#pragma mark * Servos
- (void)enableServo:(int)state
               port:(NXTSensorPort)port
       speedControl:(NSSlider *)servoSpeed {

    if(state == NSOnState)
        [servoSpeed setEnabled:YES];
    else {
        [servoSpeed setEnabled:NO];
        [servoSpeed setIntValue:0];
        [_nxt setOutputState:port
                       power:0
                        mode:kNXTCoast
              regulationMode:kNXTRegulationModeIdle
                   turnRatio:0
                    runState:kNXTMotorRunStateIdle
                  tachoLimit:0];
    }
}


- (void)startPollingServo:(BOOL)start
                servoPort:(UInt8)port
               pollButton:(NSButton *)pollButton {
    if(start) {
        [_nxt pollServo:port interval:1];
        [pollButton setTitle:@"Stop"];
    } else {
        [_nxt pollServo:port interval:0];
        [pollButton setTitle:@"Poll"];
    }
}

- (IBAction)enableServo:(id)sender {
    UInt8 tag = [sender tag];
    [self enableServo:[sender state]
                 port:tag
         speedControl:servoSpeeds[tag]];
}

- (IBAction)doChangeServoSpeed:(id)sender {
    UInt8 tag = [sender tag];
    int speed = [sender intValue];
    [_nxt moveServo:tag power:speed tacholimit:0];
}

- (IBAction)doPollServo:(id)sender {
    UInt8 tag = [sender tag];
    isPollingServo[tag] = !isPollingServo[tag];
    [self startPollingServo:isPollingServo[tag]
                  servoPort:tag
                 pollButton:servoPolls[tag]];
}

- (IBAction)doResetServoPosition:(id)sender {
    [_nxt resetMotorPosition:kNXTMotorA relative:YES];
    [_nxt resetMotorPosition:kNXTMotorB relative:YES];
    [_nxt resetMotorPosition:kNXTMotorC relative:YES];

    [servoPositionA setStringValue:@""];
    [servoPositionB setStringValue:@""];
    [servoPositionC setStringValue:@""];
}


#pragma mark -
#pragma mark NXT Delegates

// connected
- (void)NXTDiscovered:(NXTMindstorm *)nxt {
    [connectMessage setStringValue:[NSString stringWithFormat:@"Connected"]];
    [connectButton setEnabled:NO];
    [self enableControls:YES];

	[nxt playTone:523 duration:500];
    [nxt getBatteryLevel];
    [nxt pollKeepAlive];
}


// disconnected
- (void)NXTClosed:(NXTMindstorm *)nxt {
    [connectMessage setStringValue:[NSString stringWithFormat:@"Disconnected"]];
    [connectButton setEnabled:YES];

    [self enableControls:NO];
}


// NXT delegate methods
- (void)NXTError:(NXTMindstorm *)nxt code:(int)code {
    [connectMessage setIntValue:code];
}


// handle errors, special case ls pending communication
- (void)NXTOperationError:(NXTMindstorm *)nxt
                operation:(NXTOpCode)operation
                   status:(NXTStatus)status {
    // if communication is pending on the LS port, just keep polling
	if(operation == kNXTLSGetStatus && status == kNXTPendingCommunication)
		[nxt LSGetStatus:kNXTSensor4];
	else {
        dbg(
            "RC",
            kERROR,
            "Error: Are you reading too fast? <NXTOpCode:0x%x> <NXTStatus:0x%x>",
            operation,
            status
        );
    }
}


// if bytes are ready to read, read 'em
- (void)NXTLSGetStatus:(NXTMindstorm *)nxt
                   port:(NXTSensorPort)port
             bytesReady:(UInt8)bytesReady {

    NXTSensorType sensor = [self sensorModelAtPort:port];

    // XXX: problem here
    if(bytesReady > 0)
		[nxt LSRead:port sensor:sensor];
}

- (void)NXTBatteryLevel:(NXTMindstorm *)nxt batteryLevel:(UInt16)batteryLevel {
    [batteryLevelIndicator setIntValue:batteryLevel];
}

// read sensor values
- (void)NXTGetInputValues:(NXTMindstorm *)nxt
                     port:(NXTSensorPort)port
             isCalibrated:(BOOL)isCalibrated
                     type:(UInt8)type
                     mode:(UInt8)mode
                 rawValue:(UInt16)rawValue
          normalizedValue:(UInt16)normalizedValue
              scaledValue:(SInt16)scaledValue
          calibratedValue:(SInt16)calibratedValue {
    NSString *value = [NSString stringWithFormat:@"%d", scaledValue];
    [self setSensorTextField:port value:value];
}


// read the Ultrasonic/Accelerometer values
- (void)NXTLSRead:(NXTMindstorm *)nxt
           sensor:(NXTSensorType)type
             port:(NXTSensorPort)port
        bytesRead:(UInt8)bytesRead
             data:(NSData *)data {

    /* TODO: Note that we don't need the sensor type to be passed into this
     method as we can read it from the popup menu, but maybe allowing the
     underlying framework to know about it can be useful at some point, so will
     leave as is for now.

     NXTSensorType sensor2 = [self sensorModelSelectedInPort:port];

     assert(sensor == sensor2);
     */

    NSString *value;
    
    switch(type) {
        UInt16 d;
        SInt8 outbuf[6];
        case kNXTSensorNone:
            NSLog(@"No sensor here to read from!");
            return;
            break;
        case kNXTSensorAccelerometer:
            [data getBytes:outbuf length:6];
            SInt16 x = outbuf[0]; x <<= 2; x += outbuf[3]; float gX = x/200.f;
            SInt16 y = outbuf[1]; y <<= 2; y += outbuf[4]; float gY = y/200.f;
            SInt16 z = outbuf[2]; z <<= 2; z += outbuf[5]; float gZ = z/200.f;
            value = [NSString stringWithFormat:@"%+5.2fg, %+5.2fg, %+5.2fg", gX, gY, gZ ];
            break;
        case kNXTSensorAccelerometerMSv3:
            NSAssert(1==0, @"kNXTSensorAccelerometerMSv3: Not Implemented (Yet).");
            break;
        case kNXTSensorUltrasonic:
            [data getBytes:&d length:2];
            d = OSSwapLittleToHostInt16(d);
            if(d < 0xff)
                value = [NSString stringWithFormat:@"%hu", d];
            else
                value = [NSString stringWithFormat:@"--"];
            break;
        default:
            NSAssert(1==0, @"505: Internal Error - This device does not belong here.");
            break;
    }
    [self setSensorTextField:port value:value];
}

// read servo values
- (void) NXTGetOutputState:(NXTMindstorm *)nxt
                      port:(NXTSensorPort)port
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
    [servoPositions[port] setStringValue:value];
}

@end
