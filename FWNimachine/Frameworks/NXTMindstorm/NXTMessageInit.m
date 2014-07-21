
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

//  Created by Nima Talebi on 5/01/10.

#import "NXTMessageInit.h"
#import "NXTSensor.h"

@implementation NXTMessageInit

- (id)initWithSensor:(NXTSensor *)s {
    if(self = [super init]) {
        sensor = s;
        
        NXTSensorType type = [sensor type];
        NXTSensorClass cls = [sensor cls];
        
        if(cls == kNXTSensorDigital) {
            NSAssert(
                type >= 0x80,
                @"ERROR: Digital devices shoudl have ID >= 0x80"
            );
            type = kNXTSensorLowSpeed9V;
        } else if(cls == kNXTSensorAnalog) {
            NSAssert(
                type < 0x80,
                @"ERROR: Analog devices shoudl have ID < 0x80"
            );
        } else {
            [NSException raise:@"ERROR" format:@"BAD DEVICE CONFIGURATION"];
        }

        payload = (struct _payload) {
            kNXTRet,            //. 0x02
            kNXTSetInputMode,   //. 0x03
            [sensor port],      //. 0x04
            type,               //. 0x05
            [sensor mode]       //. 0x06
        };

    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%#04x, %#04x, %#04x, %#04x, %#04x]",
        payload.ret_mode,
        payload.op_code,
        payload.sns_port,
        payload.sns_type,
        payload.sns_mode
    ];
}

- (NXTMessageType)type {
    return kNXTMsgInit;
}

- (NSUInteger)length {
    NSAssert(sizeof(payload) == 0x05, @"505: Internal Error");
    return sizeof(payload);
}

- (const UInt8 *) payload {
    return (const UInt8 *)&payload;
}

@end




@implementation NXTMessageInit1

- (id)initWithSensor:(NXTSensor *)s {
    if(self = [super init]) {
        sensor = s;

        NXTSensorClass cls = [sensor cls];
        NSAssert(
            cls == kNXTSensorDigital,
            @"ERROR: Digital devices only."
        );

        NXTSensorType type = [sensor type];
        NSAssert(
            type >= 0x80,
            @"ERROR: Digital devices shoudl have ID >= 0x80"
        );
        
        rxLength = [sensor rxLength];
        payload = (struct _payload1) {
            [sensor i2CAddr],
            [sensor regAddr],
            [sensor function]
        };
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%#04x, %#04x, %#04x]",
        payload.addr_i2c,
        payload.addr_reg,
        payload.function
    ];
}

- (NXTMessageType)type {
    return kNXTMsgInit1;
}

- (NSUInteger)length {
    NSAssert(sizeof(payload) == 0x03, @"505: Internal Error");
    return sizeof(payload);
}

- (const UInt8 *)payload {
    return (const UInt8 *)&payload;
}

@synthesize rxLength;

@end
