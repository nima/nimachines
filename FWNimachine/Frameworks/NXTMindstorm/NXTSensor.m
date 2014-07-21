
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

//. Created by Nima Talebi on 2/07/09.

#import "NXTSensor.h"
#import "NXTMindstorm.h"

@interface NXTSensor()
@property(readwrite, assign) BOOL polled, concrete;
@property(readwrite, assign) NSTimeInterval timeInterval;
@end

@implementation NXTSensor

+ (NSDictionary *) supported {
    static NSDictionary *supported;
    if(supported == nil) {
    supported = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithShort:kNXTSensorTouch],             @"Touch",
            [NSNumber numberWithShort:kNXTSensorLightPassive],      @"Light (Passive)",
            [NSNumber numberWithShort:kNXTSensorLight],             @"Light",
            [NSNumber numberWithShort:kNXTSensorSound],             @"Sound",
            [NSNumber numberWithShort:kNXTSensorSoundAdjusted],     @"Sound (DB-Adjusted)",
            [NSNumber numberWithShort:kNXTSensorUltrasonic],        @"Ultrasonic",
            [NSNumber numberWithShort:kNXTSensorColor],             @"Color",
            [NSNumber numberWithShort:kNXTSensorInfrared],          @"Infrared",
            [NSNumber numberWithShort:kNXTSensorCompass],           @"Magnetic Compass",
            [NSNumber numberWithShort:kNXTSensorAccelerometer],     @"Accelerometer (HiTechnic)",
            [NSNumber numberWithShort:kNXTSensorAccelerometerMSv3], @"Accelerometer (Mindsensor)",
            [NSNumber numberWithShort:kNXTSensorGyroscope],         @"Gyroscope (HiTechnic)",
        nil];
    }
    return supported;
}

- (id)initWithType:(NXTSensorType)t andPort:(NXTSensorPort)p {
    if(self = [super init]) {
        cls = kNXTSensorUnknown;
        type = t;
        port = p;
        polled = NO;
        concrete = NO;
    }
    return self;
}

- (void)invalidateTimer {
    if(timer != nil) {
        [timer invalidate];
        [timer release];
        [self setPolled:NO];
        timer = nil;
    }
}

- (void)dealloc {
    dbg("[NXTSensor -dealloc]", kINFO, "Sensor waves goodbye.");
    
    [self invalidateTimer];
    [self release];
    [super dealloc];
}

- (NSString *)description {
    return [
        NSString stringWithFormat:@"<NXTSensor:%d @ %d>",
        type,
        port
    ];
}

- (void)setTimer:(NSTimer *)t {
    [self invalidateTimer];
    timer = t;
    [timer retain];
    [self setPolled:YES];
    
    timeInterval = [timer timeInterval];
}

- (BOOL)switchPolled {
    polled = !polled;
    return polled;
}

@synthesize vendor, cls, port, type, mode, polled, timer, concrete;
@synthesize maximumPollRate, timeInterval;
@synthesize i2CAddr, regAddr, function, rxAddr, rxLength;

- (NXTSensorType)type {
    [NSException raise:@"Error" format:@"Subclass has failed to implement."];
    return 0;
}

- (BOOL)polled {
    [NSException raise:@"Error" format:@"Subclass has failed to implement."];
    return 0;
}

- (id <NXTMessage>)txData {
    [NSException raise:@"Error" format:@"Subclass has failed to implement."];
    return nil;
}

- (NSString *)interpretData:(NSData *)data {
    [NSException raise:@"Error" format:@"Subclass has failed to implement."];
    return nil;
}

- (id <NXTMessage>)txData1 {
    [NSException raise:@"Error" format:@"Subclass has failed to implement."];
    return nil;
}

@end
