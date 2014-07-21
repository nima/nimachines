
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

#import <Foundation/Foundation.h>

typedef struct _NMPoint3 {
  GLfloat x, y, z; //. 3D Coordinates
  GLfloat u, v;    //. Texture Coordinates
} NMPoint3;

#define NMPoint3_ZERO { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f }
#define X 0
#define Y 1
#define Z 2
#define U 3
#define V 4
#define N 5

#define NSValueWithPoint3(p) [NSValue valueWithBytes:(p) objCType:@encode(NMPoint3)]
#define NMPoint3WithNSValue(nSV, p) [nSV getValue:(p)]

#define NMPoint3WithNSPoint(p) {(p).x, 0.0f, (p).y, 0.0f, 0.0f}
#define NMPoint3toString(p) [NSString stringWithFormat:@"<%.2f, %.2f, %.2f>", (p).x, (p).y, (p).z]
#define NSPointToString(p) [NSString stringWithFormat:@"<%.2f, ?, %.2f>", (p).x, (p).y]

#define NSPointWithPoint3(p) NSMakePoint((p).x, (p).z)

NMPoint3* NMPoint3$new();
NMPoint3* NMPoint3$newFrom(const NMPoint3 *p);

NMPoint3 NMPoint3$initWithXYZ(float x, float y, float z);
NMPoint3 NMPoint3$initFromNSPoint(NSPoint nSP);
float NMPoint3$distanceBetween(NMPoint3 p1, NMPoint3 p2);
float NMPoint3$squaredDistanceBetween(NMPoint3 p1, NMPoint3 p2);
BOOL NMPoint3$equal(const NMPoint3 p1, const NMPoint3 p2);
const NMPoint3 Point3Zero;
NSString* NMPoint3$description(NMPoint3 p);

