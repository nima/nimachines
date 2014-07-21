
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

/*!
 @discussion This file defines the interface for Lego NXT Mindstorms(tm) brick
 and a delegate object for receiving actions from the brick. 
 @author Matt Harrington (Original Author who deserves all the credit)
 @author Nima Talebi
 */
#import <Cocoa/Cocoa.h>

#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>

#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

#import "codes.h"

#define CNT_SENSORS 4
#define CNT_SERVOS 3

#import "NXTSensors.h"
#import "NXTActuator.h"

#import "NXTAction.h"
#import "NXTState.h"

#pragma mark -

#ifndef NXT_LOG_PRIO
#define NXT_LOG_PRIO (kMSG|kERROR|kFATAL)
//#define NXT_LOG_PRIO (kDEBUG)
#endif

/*!
 @function
 @abstract   
 @discussion Each message in thin framework that is for debugging purposes
 should avoid making direct calls to NSLog, use this instead.
 @param      aN  Prepended tag to log message
 @param      dL  Tha priority of the log message
 @param      msg The message itself, whic can be in `printf' form with
 additional arguments supplied.
*/
void dbg(char *aN, NXTLogPriority dL, char *msg, ...);

#pragma mark -
/*!
 @header NXT
 @abstract NXT Object
 @discussion
*/
@interface NXTMindstorm:NSObject {
@private
    id delegate;

@protected
    BOOL connected;
    BOOL checkStatus;

    NSTimer *batteryLevelTimer;
    NSTimer *keepAliveTimer;

    NSMutableArray *lsGetStatusQueue;
    NSMutableArray *lsReadQueue;

    NSLock *lsGetStatusLock;
    NSLock *lsReadLock;

    IOBluetoothDevice *mBluetoothDevice;
    IOBluetoothRFCOMMChannel *mRFCOMMChannel;
    
    NXTSensor   *sensors[CNT_SENSORS];

    NXTActuator *actuators[CNT_SERVOS];
    NSTimer *motorTimers[CNT_SERVOS];
}

- (id)initWithDelegate:(id)dlg;
- (void)setDelegate:(id)dlg;

- (BOOL)isConnected;
- (void)alwaysCheckStatus:(BOOL)check;

#pragma mark -
#pragma mark NXT Commands

@property(readonly) NSDictionary *sensorIdDict;

/*! 
 @section NXT Commands
 @abstract NXT Low-level NXT commands
 @discussion Each command sends a single message to the brick.
*/
//@{

/*!
 @method
 @abstract   Start a Stored Program
 @discussion Starts a program stored on the brick.  Program names always end in
 `.rxe'.  For example, `Untitled-1.rxe'.
*/
- (void)startProgram:(NSString *)program;

/*!
 @method
 @abstract   Stop a Running Program
 @discussion Stops a program run by -startProgram:
*/
- (void)stopProgram;

/*!
 @method
 @abstract   Get Running Program Name
 @discussion Gets the name of a program run by startProgram:()program.
*/
- (void)getCurrentProgramName;

/*!
 @method
 @abstract   Play a Sound File
 @discussion Plays a sound file stored on the brick.  Sound file names always
 end in ".rso".  For example: "Woops.rso".
*/
- (void)playSoundFile:(NSString *)soundfile loop:(BOOL)loop;

/*!
 @method
 @abstract Play a Tone
 @discussion Plays a tone with a pitch and duration.
*/
- (void)playTone:(UInt16)tone duration:(UInt16)duration;

/*!
 @method
 @abstract Stop Sound Playback
 @discussion Stops playing sound files or tones.
*/
- (void)stopSoundPlayback;

/*!
 @method
 @abstract Servo Control.
 @discussion Set the output state of a servo.
 @param port Servo Port 
 @param power 100 to -100
 @param mode
 @param regulationMode
 @param turnRatio  
 @param runState 
 @param tachoLimit
*/
- (void)setOutputState:(NXTActuatorPort)port
                 power:(SInt8)power
                  mode:(UInt8)mode
        regulationMode:(UInt8)regulationMode
             turnRatio:(SInt8)turnRatio
              runState:(UInt8)runState
            tachoLimit:(UInt32)tachoLimit;

/*!
 @method
 @abstract Sensor Control.
 @discussion Change the mode of sensors.  Modes are specific to each type of
 sensor.
*/
- (void)setInputMode:(NXTSensorPort)port
                type:(NXTSensorType)type
                mode:(NXTSensorMode)mode;

/*!
 @method
 @abstract Get Servo Output State.
 @discussion Read servo parameters and state, including current position.
 Result is sent to delegate.
*/
- (void)getOutputState:(UInt8)port;

/*!
 @method
 @abstract Get Sensor Input Values.
 @discussion Read sensor paremeters and state, including raw and calibrated
 values.  Result is sent to delegate.
*/
- (void)getInputValues:(UInt8)port;

/*!
 @method
 @abstract Untested.  What does this do?  Does it work?
*/
- (void)resetInputScaledValue:(UInt8)port;

/*!
 @method
 @abstract Untested.  What does this do?  Does it work?
*/
- (void)messageWrite:(UInt8)inbox message:(void *)message size:(int)size;

/*!
 @method
 @abstract Untested.  What does this do?  Does it work?
*/
- (void)messageRead:(UInt8)remoteInbox
         localInbox:(UInt8)localInbox
             remove:(BOOL)remove;

/*!
 @method
 @abstract Untested.  What does this do?  Does it work?
*/
- (void)resetMotorPosition:(UInt8)port relative:(BOOL)relative;

/*!
 @method
 @abstract Read Battery Level.
 @discussion Gets the brick's battery level.  Result is sent to delegate.
*/
- (void)getBatteryLevel;

#pragma mark -
/*!
 @method
 @abstract Get Low-Speed Buffer Status.
 @discussion Use this to determine if the LS device has data to send.  When
 requesting data with LSWrite, use this method to determine when the data is
 ready.  This often results in a kNXTPendingCommunication error status, which
 only means the data is not yet ready.  

 The easiest way to work with this method is to call LSRead within the
 delegate's NXTLSGetStatus method.  To call LSGetStatus in loop when data is not
 ready, catch kNXTPendingCommunication in delegate's NXTOperationError method
 and re-call LSGetStatus.
*/
- (void)LSGetStatus:(UInt8)port;

/*!
 @method
 @abstract Write Data to Low-Speed Device.
 @discussion Writes data to the LS device.  Port must be kNXTSensor4.  Data
 length is liited to 16 bytes.  This is usually followed by -LSGetStatus:.
 */
- (void)LSWrite:(UInt8)port
       txLength:(UInt8)txLength
       rxLength:(UInt8)rxLength
         txData:(void *)txData;

/*!
 @method
 @abstract Read Data from Low-Speed Device.
 @discussion Reads 16 bytes of 0-padded data from a low-speed device.  This is
 usually called from the delegate's -NXTLSGetStatus method when bytesReady is
 greater than 0.  Take care to always read data when it is ready, as the buffer
 on the ultrasound sensor will overflow, resulting in a garbled message.
*/
//- (void)LSRead:(UInt8)port;
- (void)LSRead:(UInt8)port sensor:(NXTSensorType)type;
//@}




#pragma mark -
#pragma mark NXT Methods
/*!
 @name NXT Methods
 @abstract High-level NXT methods
 @discussion Methods consisting of several NXT commands.  Some of which set
 timers for polling or keep-alive.
*/
//@{

/*!
 @method
 @abstract Keep Brick From Powering Down.
 @discussion Reset's the brick's sleep timer, keeping it from shutting down to
 save power.
*/
- (void)keepAlive;

/*!
 @method
 @abstract Poll Keep Alive.
 @discussion Polls the brick with -keepAlive: regularly to keep it from
 suspending.
*/
- (void)pollKeepAlive;

/*!
 @method
 @abstract Poll Battery Level.
 @discussion Poll the brick's battery level.
*/
- (void)pollBatteryLevel:(NSTimeInterval)seconds;

/*!
 @method
 @abstract Stop all Polling Timers.
 @discussion Stops all scheduled timers, killing all polling.
*/
- (void)stopAllTimers;


#pragma mark Sensors
/*!
 @method
 @abstract Poll Sensor Values.
 @discussion Polls a sensor with -getInputValues: every interval.  This does not
 work for low-speed sensors, such as the ultrasound.
 Similar to -pollSensor, for the Ultrasound, this polls the ultrasound sensor at
 a regular interval.  Call -setupUltrasoundSensor: before using this method.
 Take care not to poll too frequently, as polling the ultrasound generates a lot
 of chatter and may overwhelm the brick.
 */
- (void)pollSensor:(NXTSensor *)sensor
        atInterval:(NSTimeInterval)sec;

/*!
 @method
 @abstract Attach a configured sensor object.
 @discussion If sound sensor is `adjusted', it will only hear sounds within the
 human-audible range.
 @discussion If light sensor is `active' it will also emit light (rather than
 just measuring it).
 @discussion The Ultrasound sensor can *only* be on kNXTSensor4.
 */
- (BOOL)attachSensor:(NXTSensor *)s;
- (void)unpollSensorOnPort:(NXTSensorPort)port;
- (BOOL)switchPollingSensorOnPort:(NXTSensorPort)p atInterval:(NSTimeInterval)freq;

#pragma mark Actuators
- (BOOL)attachActuator:(NXTActuator *)a;
- (BOOL)switchPollingActuatorOnPort:(NXTActuatorPort)p
                         atInterval:(NSTimeInterval)freq;
- (BOOL)setActuatorOnPort:(NXTActuatorPort)p toSpeed:(float)speed;
- (BOOL)resetActuatorOnPort:(NXTActuatorPort)p;
- (BOOL)performAction:(NXTAction *)a;

/*!
 @method
 @abstract Move a Servo.
 @discussion Move a servo at a given power to the set tacho limit.  If limit is
 0, move indefinately.
 */
- (void)moveServo:(NXTActuatorPort)port power:(SInt8)power tacholimit:(UInt32)tacholimit;

/*!
 @method
 @abstract Poll Servo Values.
 @discussion Polls a servo with -getOutputState: every interval.
 */
- (void)pollServo:(NXTActuatorPort)port interval:(NSTimeInterval)seconds;

/*!
 @method
 @abstract Stop All Servos.
 @discussion Set power to 0 on all servos.
 */
- (void)stopServos;
//@}

@end

#pragma mark -
#pragma mark NXT Bluetooth Delegate Methods
@interface NXTMindstorm(BluetoothDelegates)
- (BOOL)connect:(id)dlg;
- (void)close:(IOBluetoothDevice *)device;
- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel;
- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel
                           status:(IOReturn)error;
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength;
@end

/*! NXT Delegate Object. */
#pragma mark -
#pragma mark NXT's OWN Delegate Methods
//@{
@interface NSObject(NXTDelegate);
- (void)NXTDiscovered:(NXTMindstorm *)nxt;
- (void)NXTClosed:(NXTMindstorm *)nxt;

- (void)NXTError:(NXTMindstorm *)nxt code:(int)code;
- (void)NXTOperationError:(NXTMindstorm *)nxt
                operation:(NXTOpCode)operation
                   status:(NXTStatus)status;

- (void)NXTBatteryLevel:(NXTMindstorm *)nxt
           batteryLevel:(UInt16)batteryLevel;

- (void)NXTGetInputValues:(NXTMindstorm *)nxt
                     port:(NXTSensorPort)port
             isCalibrated:(BOOL)isCalibrated
                     type:(UInt8)type
                     mode:(UInt8)mode
                 rawValue:(UInt16)rawValue
          normalizedValue:(UInt16)normalizedValue
              scaledValue:(SInt16)scaledValue
          calibratedValue:(SInt16)calibratedValue;
- (void)NXTGetOutputState:(NXTMindstorm *)nxt
                     port:(NXTSensorPort)port
                    power:(SInt8)power
                     mode:(UInt8)mode
           regulationMode:(UInt8)regulationMode
                turnRatio:(SInt8)turnRatio
                 runState:(UInt8)runState
               tachoLimit:(UInt32)tachoLimit
               tachoCount:(SInt32)tachoCount
          blockTachoCount:(SInt32)blockTachoCount
            rotationCount:(SInt32)rotationCount;

- (void)NXTCommunicationError:(NXTMindstorm *)nxt code:(int)code;
- (void)NXTSleepTime:(NXTMindstorm *)nxt sleepTime:(UInt32)sleepTime;
- (void)NXTCurrentProgramName:(NXTMindstorm *)nxt
           currentProgramName:(NSString *)currentProgramName;

- (void)NXTLSRead:(NXTMindstorm *)nxt
           sensor:(NXTSensorType)type
             port:(NXTSensorPort)port
        bytesRead:(UInt8)bytesRead
             data:(NSData *)data;
- (void)NXTLSGetStatus:(NXTMindstorm *)nxt
                  port:(NXTSensorPort)port
            bytesReady:(UInt8)bytesReady;

- (void)NXTMessageRead:(NXTMindstorm *)nxt
               message:(NSData *)message
            localInbox:(UInt8)localInbox;

@end
//@}
