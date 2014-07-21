
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
//  NXTState.m
//  Nimachines
//
//  Created by Nima Talebi on 2/07/09.
//  Copyright 2009 Autonomy. All rights reserved.
//

#import "NXTMindstorm.h"
#import "NXTState.h"
#import "NXTSensor.h"

@implementation NXTState

@synthesize reward, stateId, sensor, name, desc, minReading, maxReading, tone;

+ (id)stateFromState:(NXTState *)s {
    NSParameterAssert(s!=nil);
    return [[[self alloc] initWithSensor:[s sensor]
                                    name:[s name]
                                    desc:[s desc]
                                    tone:[s tone]
                                     min:[s minReading]
                                     max:[s maxReading]] autorelease];
}

+ (id)stateWithSensor:(NXTSensor *)s
                 name:(NSString *)n
                 desc:(NSString *)d
                 tone:(UInt16)t
                  min:(UInt16)mini
                  max:(UInt16)maxi {
    NSParameterAssert(s!=nil);
    return [[[self alloc] initWithSensor:s
                                    name:n
                                    desc:d
                                    tone:(UInt8)t
                                     min:mini
                                     max:maxi] autorelease];
}

- (id)initWithSensor:(NXTSensor *)s
                name:(NSString *)n
                desc:(NSString *)d
                tone:(UInt16)t
                 min:(UInt16)mini
                 max:(UInt16)maxi {
    NSParameterAssert(s!=nil);
    if(self = [super init]) {
        sensor = s;
        name = n;
        desc = d;
        minReading = mini;
        maxReading = maxi;
        reward = 0;
        tone = t;
    }
    return self;
}

- (NSString *)description {
    NSAssert(sensor!=nil, @"[self sensor] is nil");
    return [NSString stringWithFormat:@"<State Reading: %d < %@ <= %d>",
        minReading, sensor, maxReading
    ];
}

- (void)setReadingsMin:(SInt16)minr andMax:(SInt16)maxr {
    minReading = minr;
    maxReading = maxr;
}

- (BOOL)isActive {
    BOOL active = NO;
    SInt16 reading = [sensor reading];
    NSLog(@"(%d <= %d <= %d)",
        minReading,
        reading,
        maxReading
    );
    if((reading >= minReading) && (reading <= maxReading)) {
        active = YES;
        dbg(
            "NXTState",
            kINFO,
            "Robot is in state %s (%d <= %d <= %d)",
            [name UTF8String],
            minReading,
            reading,
            maxReading
        );
    }
    return active;
}

@end
