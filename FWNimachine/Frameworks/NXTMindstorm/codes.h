
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

//. Created by Nima Talebi on 4/01/10.

typedef enum _NXTVendor {
    kNXTVendorUnknown     = 0x00,
    kNXTVendorLego        = 0x01,
    kNXTVendorHiTechnic   = 0x02,
    kNXTVendorMindSensors = 0x03
} NXTVendor;

/*!
 @enum
 @abstract   Generic debugging messaging priorities
 @discussion Each message in thin framework that is for debugging purposes
 should avoid making direct calls to NSLog, use this instead.
 @constant   FATAL Nothing should ever get to such areas.
 @constant   INFO
 @constant   ERROR
 @constant   DEBUG
 @seealso    dbg
*/
typedef enum _NXTLogPriority {
    kFATAL   = 1<<0,
    kINFO    = 1<<1,
    kERROR   = 1<<2,
    kMSG     = 1<<3,
    kDEBUG   = 1<<4,
    kALL     = (1<<5) - 1
} NXTLogPriority;

/*!
 @enum
 @abstract Operation Codes
 @discussion This is a list of command operations.  Commands typically control
 sensors or servos, or request information.
 */
typedef enum _NXTOpCode {
    kNXTStartProgram          = 0x00, /*!< Start Program Op Code */
    kNXTStopProgram           = 0x01, /*!< Stop Program Op Code */
    kNXTPlaySoundFile         = 0x02, /*!< Play Sound File Op Code */
    kNXTPlayTone              = 0x03, /*!< Play Tone Op Code */
    kNXTSetOutputState        = 0x04, /*!< Set Output State Op Code */
    kNXTSetInputMode          = 0x05, /*!< */
    kNXTGetOutputState        = 0x06, /*!< */
    kNXTGetInputValues        = 0x07, /*!< */
    kNXTResetScaledInputValue = 0x08, /*!< */
    kNXTMessageWrite          = 0x09, /*!< */
    kNXTResetMotorPosition    = 0x0A, /*!< */
    kNXTGetBatteryLevel       = 0x0B, /*!< */
    kNXTStopSoundPlayback     = 0x0C, /*!< */
    kNXTKeepAlive             = 0x0D, /*!< */
    kNXTLSGetStatus           = 0x0E, /*!< */
    kNXTLSWrite               = 0x0F, /*!< */
    kNXTLSRead                = 0x10, /*!< */
    kNXTGetCurrentProgramName = 0x11, /*!< */
    kNXTMessageRead           = 0x13  /*!< */
} NXTOpCode;

/*!
 @enum
 @abstract Message Codes
 @discussion These codes specify message type and specify if the command
 requires a return value or acknowledgement.
 */
typedef enum _NXTRetMode {
    kNXTRet   = 0x00, /*!< Command returns a value */
    kNXTNoRet = 0x80, /*!< Command does not return a value */
    kNXTSysOP = 0x01  /*!< Command is a system operation (USB only) */
} NXTRetMode;

/*!
 @enum
 @abstract Command Return Values
 @discussion Success and error codes returned by commands.
 */
typedef enum _NXTStatus {
    kNXTSuccess                 = 0x00, /*!< */
    kNXTPendingCommunication    = 0x20, /*!< */
    kNXTMailboxEmpty            = 0x40, /*!< */
    kNXTNoMoreHandles           = 0x81, /*!< */
    kNXTNoSpace                 = 0x82, /*!< */
    kNXTNoMoreFiles             = 0x83, /*!< */
    kNXTEndOfFileExpected       = 0x84, /*!< */
    kNXTEndOfFile               = 0x85, /*!< */
    kNXTNotALinearFile          = 0x86, /*!< */
    kNXTFileNotFound            = 0x87, /*!< */
    kNXTHandleAllReadyClosed    = 0x88, /*!< */
    kNXTNoLinearSpace           = 0x89, /*!< */
    kNXTUndefinedError          = 0x8A, /*!< */
    kNXTFileIsBusy              = 0x8B, /*!< */
    kNXTNoWriteBuffers          = 0x8C, /*!< */
    kNXTAppendNotPossible       = 0x8D, /*!< */
    kNXTFileIsFull              = 0x8E, /*!< */
    kNXTFileExists              = 0x8F, /*!< */
    kNXTModuleNotFound          = 0x90, /*!< */
    kNXTOutOfBoundary           = 0x91, /*!< */
    kNXTIllegalFileName         = 0x92, /*!< */
    kNXTIllegalHandle           = 0x93, /*!< */
    kNXTRequestFailed           = 0xBD, /*!< */
    kNXTUnknownOpCode           = 0xBE, /*!< */
    kNXTInsanePacket            = 0xBF, /*!< */
    kNXTOutOfRange              = 0xC0, /*!< */
    kNXTBusError                = 0xDD, /*!< */
    kNXTCommunicationOverflow   = 0xDE, /*!< */
    kNXTChanelInvalid           = 0xDF, /*!< */
    kNXTChanelBusy              = 0xE0, /*!< */
    kNXTNoActiveProgram         = 0xEC, /*!< */
    kNXTIllegalSize             = 0xED, /*!< */
    kNXTIllegalMailbox          = 0xEE, /*!< */
    kNXTInvalidField            = 0xEF, /*!< */
    kNXTBadInputOutput          = 0xF0, /*!< */
    kNXTInsufficientMemmory     = 0xFB, /*!< */
    kNXTBadArguments            = 0xFF  /*!< */
} NXTStatus;

typedef enum _NXTUSBOp {
    kNXT_SYS_OPEN_READ                = 0x80,
    kNXT_SYS_OPEN_WRITE               = 0x81,
    kNXT_SYS_READ                     = 0x82,
    kNXT_SYS_WRITE                    = 0x83,
    kNXT_SYS_CLOSE                    = 0x84,
    kNXT_SYS_DELETE                   = 0x85,
    kNXT_SYS_FIND_FIRST               = 0x86,
    kNXT_SYS_FIND_NEXT                = 0x87,
    kNXT_SYS_GET_FIRMWARE_VERSION     = 0x88,
    kNXT_SYS_OPEN_WRITE_LINEAR        = 0x89,
    kNXT_SYS_OPEN_READ_LINEAR         = 0x8A,
    kNXT_SYS_OPEN_WRITE_DATA          = 0x8B,
    kNXT_SYS_OPEN_APPEND_DATA         = 0x8C,
    kNXT_SYS_BOOT                     = 0x97,
    kNXT_SYS_SET_BRICK_NAME           = 0x98,
    kNXT_SYS_GET_DEVICE_INFO          = 0x9B,
    kNXT_SYS_DELETE_USER_FLASH        = 0xA0,
    kNXT_SYS_POLL_COMMAND_LENGTH      = 0xA1,
    kNXT_SYS_POLL_COMMAND             = 0xA2,
    kNXT_SYS_BLUETOOTH_FACTORY_RESET  = 0xA4
} NXTUSBOp;

#pragma mark -
#pragma mark Sensors

typedef enum _NXTSensorClass {
    kNXTSensorUnknown = 0x00,
    kNXTSensorDigital = 0x01,
    kNXTSensorAnalog  = 0x02
} NXTSensorClass;

/*!
 @enum
 @abstract Sensor Types
 @discussion Specify sensor type and operation.  The non-arbitrary sensor types
 defined here primarily affect scaling factors used to calculate the normalized
 sensor values, but some values have other side-effects.

 If you write to this property, also write a value of TRUE to the InvalidData
 property.

 Unlike the RCX firmware, no default sensor modules are associated with each
 sensor type.
*/
typedef enum _NXTSensorType {
    ////////////////////////////////////////////////////////////////////////////
    //. Non-Arbitrary Codes
    kNXTSensorNone          = 0x00, //. No sensor configured
    kNXTSensorTouch         = 0x01, //. NXT or RCX touch sensor
    kNXTSensorTemperature   = 0x02, //. RCX temperature sensor
    kNXTSensorReflection    = 0x03, //. RCX light sensor
    kNXTSensorAngle         = 0x04, //. RCX rotation sensor
    kNXTSensorLight         = 0x05, //. NXT light sensor with floodlight enabled
    kNXTSensorLightPassive  = 0x06, //. NXT light sensor with floodlight disabled
    kNXTSensorSound         = 0x07, //. NXT sound sensor with dB scaling
    kNXTSensorSoundAdjusted = 0x08, //. NXT sound sensor with dBA scaling
    kNXTSensorCustom        = 0x09, //. Custom (Unused)
    kNXTSensorLowSpeed      = 0x0A, //. I2C digital sensor
    kNXTSensorLowSpeed9V    = 0x0B, //. I2C digital sensor at 9V power
    kNXTSensorHighSpeed     = 0x0C, //. I2C digital high-speed sensor (Unused)

    ////////////////////////////////////////////////////////////////////////////
    //. Arbitrary Codes
    kNXTSensorGyroscope          = 0x11,

    //. Digital I2C Sensors...
    kNXTSensorUltrasonic         = 0x80,
    kNXTSensorAccelerometer      = 0x81,
    kNXTSensorAccelerometerMSv3  = 0x82,
    kNXTSensorCompass            = 0x83,
    kNXTSensorColor              = 0x84,
    kNXTSensorInfrared           = 0x85,
} NXTSensorType;

/*!
 @enum
 @abstract Port Specifiers
 @discussion These enums specify sensor or motor ports.
 */
typedef enum _NXTSensorPort {
    kNXTSensor1  = 0x00, /*!< Sensor Port 1 */
    kNXTSensor2  = 0x01, /*!< Sensor Port 2 */
    kNXTSensor3  = 0x02, /*!< Sensor Port 3 */
    kNXTSensor4  = 0x03, /*!< Sensor Port 4, the serial port */
} NXTSensorPort;


/*!
 @enum
 @abstract Sensor Modes
 @discussion These modes control sensor operation.
 */
typedef enum _NXTSensorMode {
    kNXTRawMode             = 0x00, /*!< */
    kNXTBooleanMode         = 0x20, /*!< */
    kNXTTransitionCntMode   = 0x40, /*!< */
    kNXTPeriodCounterMode   = 0x60, /*!< */
    kNXTPCTFullScaleMode    = 0x80, /*!< */
    kNXTCelciusMode         = 0xA0, /*!< */
    kNXTFahrenheitMode      = 0xC0, /*!< */
    kNXTAngleStepsMode      = 0xE0, /*!< */
    kNXTSlopeMask           = 0x1F, /*!< */
    kNXTModeMask            = 0xE0  /*!< */
} NXTSensorMode;

#pragma mark -
#pragma mark Actuators
typedef enum _NXTActuatorType {
    kNXTActuatorNone             = 0x80,
    kNXTActuatorLight            = 0x81,
    kNXTActuatorSound            = 0x82,
    kNXTActuatorInfrared         = 0x83,
    kNXTActuatorServo            = 0x90,
} NXTActuatorType;

/*!
 @enum
 @abstract Servo Run States
 @discussion These regulation modes alter the behavior of servos.
 */
typedef enum _NXTActuatorServoRunState {
    kNXTMotorRunStateIdle        = 0x00, /*!< */
    kNXTMotorRunStateRampUp      = 0x10, /*!< */
    kNXTMotorRunStateRunning     = 0x20, /*!< */
    kNXTMotorRunStateRampDown    = 0x40  /*!< */
} NXTActuatorServoRunState;

/*!
 @enum
 @abstract Port Specifiers
 @discussion These enums specify sensor or motor ports.
 */
typedef enum _NXTActuatorPort {
    kNXTMotorA   = 0x00, /*!< Motor Port A */
    kNXTMotorB   = 0x01, /*!< Motor Port B */
    kNXTMotorC   = 0x02, /*!< Motor Port C */
    kNXTMotorAll = 0xFF  /*!< All Motors */
} NXTActuatorPort;

/*!
 @enum
 @abstract Servo Modes
 @discussion These modes alter the behavior of servos.
 */
typedef enum _NXTActuatorServoMode{
    kNXTCoast     = 0x00, /*!< */
    kNXTMotorOn   = 0x01, /*!< */
    kNXTBrake     = 0x02, /*!< */
    kNXTRegulated = 0x04  /*!< */
} NXTActuatorServoMode;

/*!
 @enum
 @abstract Servo Regulation Modes
 @discussion These regulation modes alter the behavior of servos.
 */
typedef enum _NXTActuatorServoRegulationMode {
    kNXTRegulationModeIdle       = 0x00, /*!< */
    kNXTRegulationModeMotorSpeed = 0x01, /*!< */
    kNXTRegulationModeMotorSync  = 0x02  /*!< */
} NXTActuatorServoRegulationMode;


