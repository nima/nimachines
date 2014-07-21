
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

/* $Id: LegoNXT.m 11 2009-01-05 01:26:25Z querry43 $ */

/*! \file LegoNXT.m
 * This file implements the interface for Lego NXT Mindstorms(tm).
 *
 * \author Matt Harrington
 * \date 01/04/09
 */

#import "NXTMindstorm.h"
#import "NSMutableQueue.h"

#import <CoreServices/CoreServices.h>
#import <Foundation/NSData.h>

#pragma mark -

void dbg(char *aN, NXTLogPriority dL, char *msg, ...) {
    if(dL&NXT_LOG_PRIO) {
        char buffer[1<<10];
        va_list argp;
        va_start(argp, msg);
        vsprintf(buffer, msg, argp);
        va_end(argp);
        NSLog(@"%16s[0x%02x]: %s", aN, dL, buffer);
    }
}


#pragma mark -
#pragma mark NXT Private Method Prototypes

@interface NXTMindstorm()
/*!
 @method
 @abstract Send message to the NXT Brick
*/
- (UInt8)doReturn;
+ (void)dumpMessage:(const void *)message
             length:(int)length
             prefix:(NSString *)prefix;
+ (void)dumpMessage:(NSData *)message prefix:(NSString *)prefix;

/*!
 @deprecated by -sendMessage:
*/
- (void)sendMessage:(void *)message length:(UInt8)length;

- (void)sendMessage:(id <NXTMessage>)message;

- (void)doPollSensorWithTimer:(NSTimer *)theTimer;
- (void)doKeepAlivePoll:(NSTimer *)theTimer;
- (void)doBatteryPoll:(NSTimer *)theTimer;
- (void)doServoPoll:(NSTimer *)theTimer;
- (void)checkSensorPort:(UInt8)port;
- (void)pushLsGetStatusQueue:(UInt8)port;
- (UInt8)popLsGetStatusQueue;
- (void)pushLsReadQueue:(UInt8)port;
- (UInt8)popLsReadQueue;
- (void)clearPortQueues;

@property(readwrite, retain) id delegate;

@end

#pragma mark -
#pragma mark NXT

@implementation NXTMindstorm

@synthesize delegate;

#pragma mark NXT Private Method Implementation

- (UInt8)doReturn{
    return checkStatus ? kNXTRet : kNXTNoRet;
}

+ (void)dumpMessage:(const void *)message
             length:(int)length
             prefix:(NSString *)prefix {
    NSString *s;
    NSString *hexMessage = [NSString string];
    for(int i=0; i<length; i++) {
        s = [NSString stringWithFormat:@"%.2p, ", *((unsigned char *)message+i)];
        hexMessage = [hexMessage stringByAppendingString:s];
    }
    dbg("libNXT", kMSG, "%s:%s", [prefix UTF8String], [hexMessage UTF8String]);
}

+ (void)dumpMessage:(NSData *)message prefix:(NSString *)prefix {
    [NXTMindstorm dumpMessage:[message bytes]
                       length:[message length]
                       prefix:prefix];
}


- (void)doPollSensorWithTimer:(NSTimer *)theTimer {
    UInt8 port = *((UInt8*) [[theTimer userInfo] bytes]);
    NXTSensor *sensor = sensors[port];
    NXTSensorType type = [sensor type];
    NXTSensorClass cls = [sensor cls];

    dbg(
        "[NXTMindstorm -sendMessage:length:]",
        kDEBUG,
        "Polling sensor 0x%02x on port %d",
        type,
        port
    );


    char txData[] = { [sensor i2CAddr], [sensor rxAddr] };
    UInt8 txLength = 2;
    UInt8 rxLength;

    switch(cls) {
        case kNXTSensorDigital:
            /*!
             @abstract Get Ultrasound reading.
             @discussion Fetches a single ultrasound reading.  If you are using
             continuous mode, byte offset will always be 0 (i.e., register
             address will be the base 0x42).  Be sure to call the method
             -setupSensor:onPort: before reaching this code.
             */
            [self pushLsGetStatusQueue:port];
            rxLength= [sensor rxLength];
            [self LSWrite:port txLength:txLength rxLength:rxLength txData:txData];
            [self LSGetStatus:port];
            break;
        case kNXTSensorAnalog:
            [self getInputValues:port];
            break;
        default:
            dbg("NXT", kINFO, "NOT IMPLEMENTED");
            break;
    }
}

- (void)getAccelerationByte:(UInt8)port byte:(UInt8)byte {
    if(byte < 8) {
    }
}


- (void)doKeepAlivePoll:(NSTimer *)theTimer {
    [self keepAlive];
}

- (void)doBatteryPoll:(NSTimer *)theTimer {
    [self getBatteryLevel];
}

- (void)doServoPoll:(NSTimer *)theTimer {
    UInt8 port = *((UInt8*) [[theTimer userInfo] bytes]);
    [self getOutputState:port];
}

- (void)checkSensorPort:(UInt8)port {
    if(port > kNXTSensor4)
        dbg("libNXT", kERROR, "`pollSensor': Unknown sensor port %d", port);
}


- (void)pushLsGetStatusQueue:(UInt8)port {
    [lsGetStatusLock lock];
    [lsGetStatusQueue pushObject:[NSNumber numberWithUnsignedShort:port]];
    [lsGetStatusLock unlock];
}

- (UInt8)popLsGetStatusQueue {
    [lsGetStatusLock lock];
    id object = [lsGetStatusQueue popObject];
    [lsGetStatusLock unlock];
    return [object unsignedShortValue];
}

- (void)pushLsReadQueue:(UInt8)port {
    [lsReadLock lock];
    [lsReadQueue pushObject:[NSNumber numberWithUnsignedShort:port]];
    [lsReadLock unlock];
}

- (UInt8)popLsReadQueue {
    [lsReadLock lock];
    id object = [lsReadQueue popObject];
    [lsReadLock unlock];
    return [object unsignedShortValue];
}

- (void)clearPortQueues {
    [lsReadLock lock];
    [lsReadQueue removeAllObjects];
    [lsReadLock unlock];

    [lsGetStatusLock lock];
    [lsGetStatusQueue removeAllObjects];
    [lsGetStatusLock unlock];
}



#pragma mark -
#pragma mark NXT Public Method Implementation
@synthesize sensorIdDict;

#pragma mark Constructors & Destructors
- (id)init {
    if(self = [super init]) {
        connected = NO;
        checkStatus = NO;
        lsGetStatusQueue = [NSMutableArray new];
        lsReadQueue = [NSMutableArray new];
        lsGetStatusLock = [NSLock new];
        lsReadLock = [NSLock new];
    }
    return self;
}

- (id)initWithDelegate:(id)dlg {
    if(self = [NXTMindstorm init])
        [self setDelegate:dlg];
    return self;
}

- (void)dealloc {
    [self stopServos];

    for(int i=0; i<CNT_SENSORS; i++)
        if(sensors[i])
            [sensors[i] release];
    
    [lsGetStatusQueue release];
    [lsReadQueue release];
    [lsGetStatusLock release];
    [lsReadLock release];

    [super dealloc];
}

#pragma mark Bluetooth Connection Delegates

- (void)close:(IOBluetoothDevice*)device {
    connected = NO;

    for(int i=0; i<CNT_SENSORS; i++)
        [sensors[i] invalidateTimer];

    [self clearPortQueues];

    if(mBluetoothDevice == device) {
        IOReturn error = [mBluetoothDevice closeConnection];
        if(error != kIOReturnSuccess) {
            dbg(
                "libNXT",
                kERROR,
                "Failed to close the device connection with error %08lx.",
                (UInt32)error
            );
            if([delegate respondsToSelector:@selector(NXTCommunicationError:code:)]) {
                [delegate NXTCommunicationError:self code:error];
                dbg(
                    "libNXT",
                    kDEBUG,
                    "@selector responds to NXTCommunicationError:code:"
                );
            } else {
                dbg(
                    "libNXT",
                    kDEBUG,
                    "@selector does NOT respond to NXTCommunicationError:code:"
                );
            }
        }

        [mBluetoothDevice release];
    }
}

/*!
 @abstract
 @discussion From NXTMailController
 @param deviceSelector - The device selector will provide UI to the end user to
 find a remote device
 @param rfcommChannelID - To connect we need a device to connect and an RFCOMM
 channel ID to open on the device.
 @seealso -rfcommChannelOpenComplete:
 */
- (BOOL)connect:(id)dlg {
    IOBluetoothDeviceSelectorController	*deviceSelector;
    IOBluetoothSDPUUID                  *sppServiceUUID;
    NSArray                             *deviceArray;
    IOBluetoothDevice                   *device;
    IOBluetoothSDPServiceRecord         *sppServiceRecord;
	UInt8                               rfcommChannelID;
    
    [self setDelegate:dlg];
    
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];	
	if(deviceSelector == nil) {
		dbg(
            "[NXTMindstorm -connect:]",
            kERROR,
            "Unable to allocate IOBluetoothDeviceSelectorController."
        );
		return FALSE;
	}
    
	sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
	[deviceSelector addAllowedUUID:sppServiceUUID];
	if([deviceSelector runModal] != kIOBluetoothUISuccess) {
		dbg(
            "[NXTMindstorm -connect:]",
            kINFO,
            "User has cancelled the device selection."
        );
		return FALSE;
	}
    
	deviceArray = [deviceSelector getResults];	
	if((deviceArray == nil) || ([deviceArray count] == 0)) {
		dbg(
            "[NXTMindstorm -connect:]",
            kFATAL,
            "No selected device.  This should never happen."
        );
		return FALSE;
	}
    
	device = [deviceArray objectAtIndex:0];
	sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
	if(sppServiceRecord == nil) {
		dbg(
            "[NXTMindstorm -connect:]",
            kFATAL,
            "No SPP service in selected device; This should never happen since the selector forces the user to select only devices with spp."
        );
		return FALSE;
	}
    
	if([sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess) {
		dbg(
            "[NXTMindstorm -connect:]",
            kFATAL,
            "No SPP service in selected device; This should never happen; a SPP service must have an rfcomm channel id."
        );
		return FALSE;
	}
	
    dbg(
        "[NXTMindstorm -connect:]",
        kINFO,
        "Attempting to connect to NXT..."
    );
	/*!
     Open asyncronously the rfcomm channel when all the open sequence is
     completed my implementation of "rfcommChannelOpenComplete:" will be called.
     */
	if(([device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess) && (mRFCOMMChannel != nil)) {
        /*!
         Something went bad (looking at the error codes I can also say what, but for
         the moment let's not dwell on those details). If the device connection is
         left open close it and return an error...
         */
		dbg("[NXTMindstorm -connect:]", kERROR, "Open sequence failed.");
		[self close:device];
		return FALSE;
	} else {
		dbg("[NXTMindstorm -connect:]", kINFO, "Open sequence initiating...");
    }
	
	mBluetoothDevice = device;
	[mBluetoothDevice retain];
	[mRFCOMMChannel retain];
    
	return TRUE;
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel {
    dbg("[NXTMindstorm -rfcommChannelClosed:]", kINFO, "Channel Closed");
    [self performSelector:@selector(close:) withObject:mBluetoothDevice afterDelay:1.0];
    [self stopAllTimers];
    [delegate NXTClosed:self];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error {
    dbg(
        "[NXTMindstorm -rfcommChannelOpenComplete:status:]",
        kINFO,
        "Channel Opening Completed"
    );
    connected = YES;

    [delegate NXTDiscovered:self];

    if(error != kIOReturnSuccess) {
		dbg(
            "[NXTMindstorm -rfcommChannelOpenComplete:status:]",
            kERROR,
            "Failed to open the RFCOMM channel with error %08lx.",
            (UInt32)error
        );
        if([delegate respondsToSelector:@selector(NXTCommunicationError:code:)]) {
            dbg(
                "[NXTMindstorm -rfcommChannelOpenComplete:status:]",
                kDEBUG,
                "@selector responds to NXTOperationError:operation:status:"
            );
            [delegate NXTCommunicationError:self code:error];
        } else {
            dbg(
                "[NXTMindstorm -rfcommChannelOpenComplete:status:]",
                kDEBUG,
                "@selector does NOT respond to NXTOperationError:operation:status:"
            );
        }
		[self rfcommChannelClosed:rfcommChannel];
	}
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength {
    [NXTMindstorm dumpMessage:dataPointer length:dataLength prefix:@"<<< "];

    int i = 0;
    while(i < dataLength) {
        UInt16 messageLength = 0;
        NXTOpCode opCode = 0;
        NXTStatus status = 0;

        //. get the command length
        memcpy(&messageLength, dataPointer+i, 2);
        messageLength = OSSwapLittleToHostInt16(messageLength);
        i += 2;

        //. read the opcode and status
        memcpy(&opCode, dataPointer+i+1, 1);
        memcpy(&status, dataPointer+i+2, 1);
        i += 3;
		
        //. report error status
        if(status != kNXTSuccess && [delegate respondsToSelector:@selector(NXTOperationError:operation:status:)]) {
            dbg(
                "libNXT",
                kDEBUG,
                "@selector responds to NXTOperationError:operation:status:"
            );
            [delegate NXTOperationError:self operation:opCode status:status];
        } else {
            dbg(
                "libNXT",
                kDEBUG,
                "@selector does NOT respond to NXTOperationError:operation:status:"
            );

            if(opCode == kNXTGetOutputState) {
                UInt8 port;
                SInt8 power;
                UInt8 mode;
                UInt8 regulationMode;
                SInt8 turnRatio;
                UInt8 runState;
                UInt32 tachoLimit;
                SInt32 tachoCount;
                SInt32 blockTachoCount;
                SInt32 rotationCount;

                memcpy(&port,            dataPointer+i+0,  1); // 3
                memcpy(&power,           dataPointer+i+1,  1); // 4
                memcpy(&mode,            dataPointer+i+2,  1); // 5
                memcpy(&regulationMode,  dataPointer+i+3,  1); // 6
                memcpy(&turnRatio,       dataPointer+i+4,  1); // 7
                memcpy(&runState,        dataPointer+i+5,  1); // 8
                memcpy(&tachoLimit,      dataPointer+i+6,  4); // 9
                memcpy(&tachoCount,      dataPointer+i+10, 4); // 13
                memcpy(&blockTachoCount, dataPointer+i+14, 4); // 17
                memcpy(&rotationCount,   dataPointer+i+18, 4); // 21
                i += 21;

                tachoLimit      = OSSwapLittleToHostInt32(tachoLimit);
                tachoCount      = OSSwapLittleToHostInt32(tachoCount);
                blockTachoCount = OSSwapLittleToHostInt32(blockTachoCount);
                rotationCount   = OSSwapLittleToHostInt32(rotationCount);

                if([delegate respondsToSelector:@selector(NXTGetOutputState:port:power:mode:regulationMode:turnRatio:runState:tachoLimit:tachoCount:blockTachoCount:rotationCount:)]) {
                    dbg(
                        "libNXT",
                        kDEBUG,
                        "@selector responds to NXTGetOutputState:port:power:mode:regulationMode:turnRatio:runState:tachoLimit:tachoCount:blockTachoCount:rotationCount:"
                    );
                    [delegate NXTGetOutputState:self
                                            port:port
                                           power:power
                                            mode:mode
                                  regulationMode:regulationMode
                                       turnRatio:turnRatio
                                        runState:runState
                                      tachoLimit:tachoLimit
                                      tachoCount:tachoCount
                                 blockTachoCount:blockTachoCount
                                   rotationCount:rotationCount];
                } else {
                    dbg(
                        "libNXT",
                        kINFO,
                        "@selector does NOT respond to NXTGetOutputState:port:power:mode:regulationMode:turnRatio:runState:tachoLimit:tachoCount:blockTachoCount:rotationCount:"
                    );
                }
            } else if(opCode == kNXTGetInputValues) {
                UInt8  port;
                UInt8  valid;
                UInt8  isCalibrated;
                UInt8  sensorType;
                SInt8  sensorMode;
                UInt16 rawValue;
                UInt16 normalizedValue;
                SInt16 scaledValue;
                SInt16 calibratedValue;

                memcpy(&port,               dataPointer+i+0,  1); // 3
                memcpy(&valid,              dataPointer+i+1,  1); // 4
                memcpy(&isCalibrated,       dataPointer+i+2,  1); // 5
                memcpy(&sensorType,         dataPointer+i+3,  1); // 6
                memcpy(&sensorMode,         dataPointer+i+4,  1); // 7
                memcpy(&rawValue,           dataPointer+i+5,  2); // 8
                memcpy(&normalizedValue,    dataPointer+i+7,  2); // 10
                memcpy(&scaledValue,        dataPointer+i+9,  2); // 12
                memcpy(&calibratedValue,    dataPointer+i+11, 2); // 14
                i += 12;

                rawValue        = OSSwapLittleToHostInt16(rawValue);
                normalizedValue = OSSwapLittleToHostInt16(normalizedValue);
                scaledValue     = OSSwapLittleToHostInt16(scaledValue);
                calibratedValue = OSSwapLittleToHostInt16(calibratedValue);

                if(valid && [delegate respondsToSelector:@selector(NXTGetInputValues:port:isCalibrated:type:mode:rawValue:normalizedValue:scaledValue:calibratedValue:)]) {
                    [delegate NXTGetInputValues:self
                                            port:port
                                    isCalibrated:isCalibrated
                                            type:sensorType
                                            mode:sensorMode
                                        rawValue:rawValue
                                 normalizedValue:normalizedValue
                                     scaledValue:scaledValue
                                 calibratedValue:scaledValue];
                    dbg("libNXT", kDEBUG, "@selector responds to NXTGetInputValues:port:isCalibrated:type:mode:rawValue:normalizedValue:scaledValue:calibratedValue:");
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTGetInputValues:port:isCalibrated:type:mode:rawValue:normalizedValue:scaledValue:calibratedValue:");
                }
            } else if(opCode == kNXTGetBatteryLevel) {
                UInt16 batteryLevel;

                memcpy(&batteryLevel, dataPointer+i+0, 2); // 3
                i += 2;

                batteryLevel = OSSwapLittleToHostInt16(batteryLevel);

                if([delegate respondsToSelector:@selector(NXTBatteryLevel:batteryLevel:)]) {
                    dbg("libNXT", kDEBUG, "@selector responds to NXTBatteryLevel:batteryLevel:");
                    [delegate NXTBatteryLevel:self batteryLevel:batteryLevel];
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTBatteryLevel:batteryLevel:");
                }
            } else if(opCode == kNXTKeepAlive) {
                UInt32 sleepTime;

                memcpy(&sleepTime, dataPointer+i+0, 4); // 3
                i += 4;

                sleepTime = OSSwapLittleToHostInt32(sleepTime);

                if([delegate respondsToSelector:@selector(NXTSleepTime:sleepTime:)]) {
                    dbg("libNXT", kDEBUG, "@selector responds to NXTSleepTime:sleepTime:");
                    [delegate NXTSleepTime:self sleepTime:sleepTime];
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTSleepTime:sleepTime:");
                }
            } else if(opCode == kNXTLSGetStatus) /*! LSGetStatus often returns the kNXTPendingCommunication error status */ {
                UInt8 bytesReady;

                memcpy(&bytesReady, dataPointer+i+0, 1); // 3
                i += 1;
                if([delegate respondsToSelector:@selector(NXTLSGetStatus:port:bytesReady:)]) {
                    dbg("libNXT", kDEBUG, "@selector responds to NXTLSGetStatus:port:bytesReady:");
                    [delegate NXTLSGetStatus:self
                                         port:[self popLsGetStatusQueue]
                                   bytesReady:bytesReady];
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTLSGetStatus:port:bytesReady:");
                }
            } else if(opCode == kNXTLSRead) {
                UInt8 bytesRead;
                NSData *data;

                memcpy(&bytesRead, dataPointer+i+0, 1); // 3

                data = [[NSData dataWithBytes:(dataPointer+i+1) length:16] retain];
                i += 17;
				
                if([delegate respondsToSelector:@selector(NXTLSRead:sensor:port:bytesRead:data:)]) {
                    dbg(
                        "libNXT",
                        kDEBUG,
                        "@selector responds to NXTLSRead:sensor:port:bytesRead:data:"
                    );

                    UInt8 p = [self popLsReadQueue];
                    UInt8 s = [self popLsReadQueue];
                    dbg(
                        "libNXT",
                        kDEBUG,
                        ">>> Lib => <s:0x%02x> <p:0x%02x> <<<", s, p
                    );
                    
                    [delegate NXTLSRead:self
                                  sensor:s
                                    port:p
                               bytesRead:bytesRead
                                    data:data];
                } else {
                    dbg(
                        "libNXT",
                        kDEBUG,
                        "@selector does NOT respond to NXTLSRead:sensor:port:bytesRead:data:"
                    );
                }
            } else if (opCode == kNXTGetCurrentProgramName) {
                NSString *currentProgramName = [[NSString stringWithCString:(dataPointer+i) encoding:NSASCIIStringEncoding] retain]; // 3-22
                i += 20;
				
                if([delegate respondsToSelector:@selector(NXTCurrentProgramName:currentProgramName:)]) {
                    dbg("libNXT", kDEBUG, "@selector responds to NXTCurrentProgramName:currentProgramName:");
                    [delegate NXTCurrentProgramName:self currentProgramName:currentProgramName];
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTCurrentProgramName:currentProgramName:");
                }
            } else if(opCode == kNXTMessageRead) {
                UInt8 localInbox;
                UInt8 messageSize;
                NSData *message;

                memcpy(&localInbox, dataPointer+i+0, 1); // 3
                memcpy(&messageSize, dataPointer+i+1, 1); // 4
                message = [NSData dataWithBytes:dataPointer+i+2
                                         length:messageSize-1];
                i += 61;

                if([delegate respondsToSelector:@selector(NXTMessageRead:message:localInbox:)]) {
                    dbg("libNXT", kDEBUG, "@selector responds to NXTMessageRead:message:localInbox:");
                    [delegate NXTMessageRead:self message:message localInbox:localInbox];
                } else {
                    dbg("libNXT", kINFO, "@selector does NOT respond to NXTMessageRead:message:localInbox:");
                }
            }
        }
    }
}

#pragma mark NXT Hardware Inteface
/*!
 @deprecated by -sendMessage:
*/
- (void)sendMessage:(void *)message length:(UInt8)length {
    /*! @var fullMessage maximum message size (64) + size (2) */
    char fullMessage[66];
    
    fullMessage[0] = length;
    fullMessage[1] = 0;
    memcpy(fullMessage+2, message, length);
    
    [NXTMindstorm dumpMessage:fullMessage length:length+2 prefix:@">>> "];
    [mRFCOMMChannel writeSync:fullMessage length:length+2];
}

- (void)sendMessage:(id <NXTMessage>)message {
    UInt8 payload[66];
    NSUInteger length = [message length];
    payload[0] = length;
    payload[1] = 0x00;

    const UInt8 *_payload = [message payload];
    memcpy(&payload[2], _payload, length);

    dbg("libXXX", kMSG, "||| %s", [[message description] UTF8String]);
    [NXTMindstorm dumpMessage:payload length:length+2 prefix:@">>> "];
    [mRFCOMMChannel writeSync:(char *)payload length:length+2];
}

/*
- (void)sendMsgInit:(NXTMsgInit)message {
    UInt8 length = 5;
    
    char fullMessage[66];
    
    fullMessage[0] = length;
    fullMessage[1] = 0;
    /*!
     @discussion No need for the labourious initial method as we have defined
     our enums to be of size UInt8 explicitely, otherwise, the default sets
     them to 1 byte each, equivalent to a UInt32, and the size of our NXTMsgInit
     struct would be 20 rather than 5.
     The other solution is to pass `-fshort-enums', but this method is much
     better - self-documenting and explicit.
     
    fullMessage[2] = message.ret_mode;
    fullMessage[3] = message.op_code;
    fullMessage[4] = message.sns_port;
    fullMessage[5] = message.sns_type;
    fullMessage[6] = message.sns_mode;
    * /
    memcpy(fullMessage+2, (char *)&message, length);
    
    [NXTMindstorm dumpMessage:fullMessage length:length+2 prefix:@">>> "];
    [mRFCOMMChannel writeSync:fullMessage length:length+2];
}
*/
- (void)startProgram:(NSString *)program {
    char message[22] = {
        [self doReturn],
        kNXTStartProgram
    };

    [program getCString:(message+2)
              maxLength:20
               encoding:NSASCIIStringEncoding];
    message[21] = '\0';

    //. send the message
    [self sendMessage:message length:22];
}


- (void)stopProgram {
    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTStopProgram
    };

    //. send the message
    [self sendMessage:message length:2];
}

- (void)getCurrentProgramName {
    char message[] = {
        kNXTRet,
        kNXTGetCurrentProgramName
    };

    //. send the message
    [self sendMessage:message length:2];
}

- (void)playSoundFile:(NSString *)soundfile loop:(BOOL)loop {
    char message[23] = {
        [self doReturn],
        kNXTPlaySoundFile,
        (loop ? 1 : 0)
    };

    [soundfile getCString:(message+3) maxLength:20 encoding:NSASCIIStringEncoding];
	
    //. send the message
    [self sendMessage:message length:23];
}

- (void)playTone:(UInt16)tone duration:(UInt16)duration {
    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTPlayTone,
        (tone & 0x00ff),
        (tone & 0xff00) >> 8,
        (duration & 0x00ff),
        (duration & 0xff00) >> 8
    };

    //. send the message
    [self sendMessage:message length:6];
}

- (void)stopSoundPlayback {
    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTStopSoundPlayback
    };

    //. send the message
    [self sendMessage:message length:2];
}

- (void)setOutputState:(NXTActuatorPort)port
                 power:(SInt8)power
                  mode:(UInt8)mode
        regulationMode:(UInt8)regulationMode
             turnRatio:(SInt8)turnRatio
              runState:(UInt8)runState
            tachoLimit:(UInt32)tachoLimit {
    NXT_ASSERT_MOTOR_PORT(port);

    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTSetOutputState,
        port,
        power,
        mode,
        regulationMode,
        turnRatio,
        runState,
        (tachoLimit & 0x000000ff),
        (tachoLimit & 0x0000ff00) >> 8,
        (tachoLimit & 0x00ff0000) >> 16,
        (tachoLimit & 0xff000000) >> 24
    };

    //. send the message
    [self sendMessage:message length:12];
}

- (void)setInputMode:(NXTSensorPort)port
                type:(NXTSensorType)type
                mode:(NXTSensorMode)mode {
    NXT_ASSERT_SENSOR_PORT(port);

    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTSetInputMode,
        port,
        type,
        mode
    };

    //. send the message
    [self sendMessage:message length:5];
}

- (void)getOutputState:(UInt8)port {
    NXT_ASSERT_SENSOR_PORT(port);

    char message[] = {
        kNXTRet,
        kNXTGetOutputState,
        port
    };

    //. send the message
    [self sendMessage:message length:3];
}

- (void)getInputValues:(UInt8)port {
    NXT_ASSERT_SENSOR_PORT(port);

    //. construct the message
    char message[] = {
        kNXTRet,
        kNXTGetInputValues,
        port
    };

    //. send the message
    [self sendMessage:message length:3];
}

- (void)resetInputScaledValue:(UInt8)port {
    NXT_ASSERT_SENSOR_PORT(port);

    //. construct the message
    char message[] = {
        [self doReturn],
        kNXTResetScaledInputValue,
        port
    };

    //. send the message
    [self sendMessage:message length:3];
}

- (void)messageWrite:(UInt8)inbox message:(void*)message size:(int)size {
    char _message[size+4];

    _message[0] = [self doReturn];
    _message[1] = kNXTMessageWrite;
    _message[2] = inbox;
    _message[3] = size;

    memcpy(_message+4, message, size);

    [self sendMessage:_message length:size+4];
}


- (void)messageRead:(UInt8)remoteInbox
         localInbox:(UInt8)localInbox
             remove:(BOOL)remove {
    char message[] = {
        kNXTRet,
        kNXTMessageRead,
        remoteInbox,
        localInbox,
        (remove ? 1 : 0)
    };

    [self sendMessage:message length:5];
}


- (void)resetMotorPosition:(UInt8)port relative:(BOOL)relative {
    char message[] = {
        [self doReturn],
        kNXTResetMotorPosition,
        port,
        (relative ? 1 : 0)
    };

    [self sendMessage:message length:4];
}


- (void)getBatteryLevel {
    char message[] = {
        kNXTRet,
        kNXTGetBatteryLevel
    };

    [self sendMessage:message length:2];
}

#pragma mark -
#pragma mark * HardwareInterface:LS*
- (void)LSGetStatus:(UInt8)port {
    NXT_ASSERT_SENSOR_PORT(port);

    char message[] = {
        kNXTRet,
        kNXTLSGetStatus,
        port
    };

    [self sendMessage:message length:3];
}

- (void)LSWrite:(UInt8)port
       txLength:(UInt8)txLength
       rxLength:(UInt8)rxLength
         txData:(void *)txData {
    NXT_ASSERT_SENSOR_PORT(port);
    char message[5+txLength];

    message[0] = kNXTRet; //. Command returns a value
    message[1] = kNXTLSWrite;
    message[2] = port;
    message[3] = txLength;
    message[4] = rxLength;

    memcpy(message+5, txData, txLength);

    [self sendMessage:message length:(5+txLength)];
}
- (void)LSWriteToSensor:(NXTSensor *)sensor message:(NXTMessageInit1 *)msg {
    NXTSensorPort port = [sensor port];
    NXT_ASSERT_SENSOR_PORT(port);

    UInt8 txLength = [msg length];
    char message[5+txLength];
    
    message[0] = kNXTRet; //. Command returns a value
    message[1] = kNXTLSWrite;
    message[2] = port;
    message[3] = txLength;
    message[4] = [msg rxLength];

    memcpy(message+5, [msg payload], txLength);
    
    [self sendMessage:message length:(5+txLength)];
}



- (void)LSRead:(UInt8)port sensor:(NXTSensorType)sensor {
    NXT_ASSERT_SENSOR_PORT(port);

    char message[] = {
        kNXTRet,
        kNXTLSRead,
        port
    };

    dbg(
        "libNXT",
        kDEBUG,
        ">>> Lib(READ) => <s:0x%02x> <p:0x%02x> <<<", sensor, port
    );

    [self pushLsReadQueue:port];
    [self pushLsReadQueue:sensor];
    [self sendMessage:message length:3];
}




#pragma mark -
#pragma mark High-Level NXT Interfaces

- (void)keepAlive {
    char message[] = {
        [self doReturn],
        kNXTKeepAlive
    };

    [self sendMessage:message length:2];
}

- (void)pollKeepAlive {
    if(keepAliveTimer == nil)
        keepAliveTimer = [
            [NSTimer scheduledTimerWithTimeInterval:60
                                             target:self
                                           selector:@selector(doKeepAlivePoll:)
                                           userInfo:nil
                                            repeats:YES
            ]
        retain];
}

- (void)pollBatteryLevel:(NSTimeInterval)seconds {
    if(batteryLevelTimer != nil) {
        [batteryLevelTimer invalidate];
        batteryLevelTimer = nil;
    }

    if(seconds > 0)
        batteryLevelTimer = [
            [NSTimer scheduledTimerWithTimeInterval:seconds
                                             target:self
                                           selector:@selector(doBatteryPoll:)
                                           userInfo:nil
                                            repeats:YES
            ]
        retain];
}

- (void)stopAllTimers {
    int i;

    for(i=0; i<4; i++)
        [self unpollSensorOnPort:i];
    for(i=0; i<3; i++)
        [self pollServo:i interval:0];

    if(keepAliveTimer != nil) {
        [keepAliveTimer invalidate];
        keepAliveTimer = nil;
    }

    [self pollBatteryLevel:0];
}




- (BOOL)isConnected {
    return connected;
}

- (void)setDelegate:(id)dlg {
    delegate = dlg;
}

- (void)alwaysCheckStatus:(BOOL)check {
    checkStatus = check;
}



#pragma mark Actuators
- (BOOL)attachActuator:(NXTActuator *)a {
    BOOL success = YES;
    NXTActuatorPort p = [a port];
    NXTActuatorType m = [a type];
    
    dbg(
        "NXT:[Mindstorm attachActuator:]",
        kINFO, "Attaching Actuator %s to port %d",
        [[a description] UTF8String],
        p
        );
    
    switch(m) {
        case kNXTActuatorServo:
            actuators[p] = a;
            [self setOutputState:p
                           power:0
                            mode:kNXTCoast
                  regulationMode:kNXTRegulationModeIdle
                       turnRatio:0
                        runState:kNXTMotorRunStateIdle
                      tachoLimit:0];
            break;
        case kNXTActuatorNone:
            actuators[p] = a;
            break;
        default:
            dbg("NXTNXT", kERROR, "`attachActuator': unknown actuator type");
            success = NO;
            break;
    }
    return success;
}

- (BOOL)resetActuatorOnPort:(NXTActuatorPort)port {
    BOOL success = NO;
    switch(port) {
        case kNXTMotorA:
        case kNXTMotorB:
        case kNXTMotorC:
        case kNXTMotorAll:
            [self resetMotorPosition:port relative:YES];
            success = YES;
            break;
    }
    return success;
}

- (BOOL)performAction:(NXTAction *)a {
    BOOL success = FALSE;
    
    dbg("NXTNXT", kINFO, "Actioning %s", [[a description] UTF8String]);
    NSArray *acts = [a actuators];
    NXTActuator *act;
    if(acts != nil) {
        for(int i=0; i<[acts count]; i++) {
            act = [acts objectAtIndex:i];
            success = [self setActuatorOnPort:[act port] toSpeed:[a power]] ? success : FALSE;
        }
    } else {
        act = [a actuator];
        success = [self setActuatorOnPort:[act port] toSpeed:[a power]];
    }
    return success;
}

- (BOOL)setActuatorOnPort:(NXTActuatorPort)p toSpeed:(float)speed {
    BOOL success = NO;
    switch(p) {
        case kNXTMotorA:
        case kNXTMotorB:
        case kNXTMotorC:
        case kNXTMotorAll:
            if(abs(speed) > 0.01)
                [self moveServo:p power:speed tacholimit:0];
            else
                [self setOutputState:p
                               power:0
                                mode:kNXTCoast
                      regulationMode:kNXTRegulationModeIdle
                           turnRatio:0
                            runState:kNXTMotorRunStateIdle
                          tachoLimit:0];   
            success = YES;
            break;
        default:
            success = NO;
            break;
    }
    return success;
}

- (BOOL)switchPollingActuatorOnPort:(NXTActuatorPort)port
                         atInterval:(NSTimeInterval)tI {
    BOOL success = NO;
    
    switch(port) {
        case kNXTMotorA:
        case kNXTMotorB:
        case kNXTMotorC:
            success = YES;
            break;
    }
    
    if(success) {
        NXTActuator *actuator = actuators[port];
        NXTActuatorType type = [actuator type];
        
        switch(type) {
            case kNXTActuatorServo:
                [self pollServo:port interval:tI];
                [actuator setPolled:YES];
                break;
            case kNXTActuatorNone:
                [actuator setPolled:NO];
                break;
            default:
                success = NO;
                break;
        }
    }
    
    return success;
}

- (void)moveServo:(NXTActuatorPort)port power:(SInt8)power tacholimit:(UInt32)tacholimit {
    NXT_ASSERT_MOTOR_PORT(port);
    
    [self setOutputState:port
                   power:power
                    mode:(kNXTMotorOn|kNXTRegulated)
          regulationMode:kNXTRegulationModeMotorSpeed
               turnRatio:0
                runState:kNXTMotorRunStateRunning
              tachoLimit:tacholimit];
}

- (void)pollServo:(NXTActuatorPort)port interval:(NSTimeInterval)seconds {
    NXT_ASSERT_MOTOR_PORT(port);
    
    if(motorTimers[port] != nil) {
        [motorTimers[port] invalidate];
        motorTimers[port] = nil;
    }
    
    if(seconds > 0)
        motorTimers[port] = [
                             [NSTimer scheduledTimerWithTimeInterval:seconds
                                                              target:self
                                                            selector:@selector(doServoPoll:)
                                                            userInfo:[NSData dataWithBytes:&port
                                                                                    length:1]
                                                             repeats:YES
                              ]
                             retain];
}

- (void)stopServos {
    [self setOutputState:kNXTMotorAll
                   power:0
                    mode:0
          regulationMode:kNXTRegulationModeIdle
               turnRatio:0
                runState:kNXTMotorRunStateIdle
              tachoLimit:0];
}

#pragma mark Sensors

- (BOOL)attachSensor:(NXTSensor *)sensor {
    BOOL success = NO;
    NXTSensorPort port = [sensor port];
    NXTSensorType type = [sensor type];
    NSTimeInterval tI = [sensor timeInterval];
    NSParameterAssert(sensor != nil);

    /*
    char txData[] = {
        0x02, //. I2C Addresss
        0x41, //. Internal address
        0x00  //. Function => 0x02: Set to continuous measurement 
    };
    UInt8 txLength = 3;
    */

    dbg(
        "NXT:[Mindstorm -attachSensor:]",
        kINFO,
        "Attaching Sensor: %s to port %d",
        [[sensor description] UTF8String],
        port
    );
    
    if(type != kNXTSensorNone) {
        success = YES;

        sensors[port] = sensor;
        [sensors[port] retain];

        id <NXTMessage> msg;

        /*! FIXME */
        switch(type) {
            case kNXTSensorLight:
            case kNXTSensorLightPassive:
            case kNXTSensorSound:
            case kNXTSensorSoundAdjusted:
            case kNXTSensorTouch:
            case kNXTSensorGyroscope:
                msg = [sensor txData];
                [self sendMessage:msg];
                break;
            case kNXTSensorUltrasonic:
            case kNXTSensorAccelerometer:
            case kNXTSensorCompass:
                msg = [sensor txData];
                [self sendMessage:msg];
                usleep(1000000);

                msg = [sensor txData1];
                [self LSWriteToSensor:sensor message:msg];
                //[self LSWrite:port txLength:txLength rxLength:0 txData:txData];
                success = [self switchPollingSensorOnPort:port atInterval:tI];
                break;
            default:
                break;
        }
    }

    return success;
}

- (void)pollSensor:(NXTSensor *)sensor
        atInterval:(NSTimeInterval)sec {
    
    UInt8 port = [sensor port];
    NXTSensorType type = [sensor type];
    
    NXT_ASSERT_SENSOR_PORT(port);
    
    int len = 1;
    SEL sel = @selector(doPollSensorWithTimer:);
    NSData *data = [NSData dataWithBytes:&port length:len];

    switch(type) {
        case kNXTSensorUltrasonic:
            sec = MAX(sec, 0.4f);
            break;
        case kNXTSensorAccelerometer:
            len = 6;
            sec = MAX(sec, 0.4f);
            break;
    }
    
    [sensor setTimer:
     [NSTimer scheduledTimerWithTimeInterval:sec
                                      target:self
                                    selector:sel
                                    userInfo:data
                                     repeats:YES
      ]
     ];
}

- (void)unpollSensorOnPort:(NXTSensorPort)port {
    NXTSensor *sensor = sensors[port];

    NXTSensorType type = [sensor type];
    switch(type) {
        case kNXTSensorLight:
            [self setInputMode:port
                          type:kNXTSensorLightPassive
                          mode:kNXTPCTFullScaleMode];
            break;
    }

    [sensor invalidateTimer];
}

- (BOOL)switchPollingSensorOnPort:(NXTSensorPort)p atInterval:(NSTimeInterval)tI {
    BOOL success = YES;

    NXTSensor *sensor = sensors[p];
    BOOL start = ![sensor polled];
    if(start && tI > 0)
        [self pollSensor:sensor atInterval:tI];
    else
        [self unpollSensorOnPort:p];

    return success;
}

- (void)removeSensorOnPort:(UInt8)port {
    [self unpollSensorOnPort:port];
    [sensors[port] release];
    sensors[port] = kNXTSensorNone;
}

@end
