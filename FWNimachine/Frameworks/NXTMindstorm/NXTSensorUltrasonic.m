
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

//.  Created by Nima Talebi on 5/01/10.

#import "NXTSensorUltrasonic.h"
#import "NXTMessageInit.h"

@implementation NXTSensorUltrasonic

@synthesize txData, txData1;

- (id)initWithType:(NXTSensorType)t andPort:(NXTSensorPort)p {
    NSAssert(p == kNXTSensor4, @"Ultrasonic can only work on port 0x03!");
    if(self = [super initWithType:t andPort:p]) {
        vendor = kNXTVendorHiTechnic;
        cls = kNXTSensorDigital;
        mode = kNXTPCTFullScaleMode;
        txData = [[NXTMessageInit alloc] initWithSensor:self];
        concrete = YES;

        i2CAddr = 0x02;
        regAddr = 0x41;
        function = 0x02; /*! Set continuous mode */
        
        rxAddr = 0x42;
        rxLength = 0x01;
    }
    return self;
}

- (id)initOnPort:(NXTSensorPort)p {
    self = [self initWithType:kNXTSensorUltrasonic andPort:p];
    return self;
}

- (void)dealloc {
    [txData release];
    [self release];
    [super dealloc];
}

@end
