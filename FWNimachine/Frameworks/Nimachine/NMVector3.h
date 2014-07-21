
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
#import "NMPoint3.h"

typedef struct _NMVector3 {
  NMPoint3 startPoint;
  GLfloat x, y, z;
} NMVector3;

extern const NMVector3 NMVector3Zero;

/*!
 @abstract (Vector3) init:  Initialize a new vector with the given data 
 */
NMVector3 NMVector3$init(const NMPoint3 startPoint, const GLfloat x, const GLfloat y, const GLfloat z);
NMVector3 NMVector3$initFromPoint(const NMPoint3 p);
NMVector3 NMVector3$initWithPoints(const NMPoint3 startPoint, const NMPoint3 endPoint);
NMVector3 NMVector3$initWithAngle(const NMPoint3 startPoint, const GLfloat angle);
NMVector3 NMVector3$initWithXYZOnly(const GLfloat x, const GLfloat y, const GLfloat z);
NMVector3 NMVector3$initWithAngleOnly(const GLfloat angle);

NMVector3 NMVector3$add(NMVector3 v1, const NMVector3 v2);
NMVector3 NMVector3$sub(NMVector3 v1, const NMVector3 v2);
NMVector3 NMVector3$mul(NMVector3 v, const GLfloat coefficient);
NMVector3 NMVector3$div(NMVector3 v, const GLfloat coefficient);
NMVector3 NMVector3$cross(NMVector3 v1, const NMVector3 v2);
NMVector3 NMVector3$normalize(const NMVector3 v);
NMVector3 NMVector3$calculateNormal(const NMPoint3 pA, const NMPoint3 pB, const NMPoint3 pC);

/*!
 @abstract (GLfloat)point:  Functions that return a scalar.
 */
GLfloat NMVector3$scalar(const NMVector3 v);
GLfloat NMVector3$scalarDotProduct(const NMVector3 v1, const NMVector3 v2);
GLfloat NMVector3$scalarDotProductWithPoint(const NMVector3 v, const NMPoint3 p);
GLfloat NMVector3$scalarDotProductWithPoints(const NMPoint3 v, const NMPoint3 p);

/*!
 @abstract (void)   point:  Functions that return a new (Point3) struct.
 */
NMPoint3  NMVector3$pointEnd(const NMVector3 v);
NMPoint3  NMVector3$pointProjection(const NMVector3 v, const NMPoint3 p);

/*!
 @abstract (void)   equal:  Obvious what these do.
 */
BOOL    NMVector3$equal(const NMVector3 v1, const NMVector3 v2);
BOOL    NMVector3$equalBounds(const NMVector3 v1, const NMVector3 v2);

/*!
 @abstract (void)   write:  Write information to a pointer passed in.
 */
void    NMVector3$writeCCWPlaneNormal(GLfloat *n, const NMPoint3 pA, const NMPoint3 pB, const NMPoint3 pC);
void    NMVector3$writeNormalized(GLfloat *n, const NMVector3 v);

/*!
 @abstract (void)   reset:  Amend the first entry (Vector3 *) passed in.
 */
void    NMVector3$resetEndPoint(NMVector3 *v, const NMPoint3 p);
void    NMVector3$resetStartPointTo(NMVector3 *v, const NMPoint3 aPoint);
void    NMVector3$resetNormalized(NMVector3 *v);

/*!
 @abstract (void)   test:  Test cases for when this `class' is modified/developed.
 */
void NMVector3$testAll();
void NMVector3$testCrossProduct(NMPoint3 p1, NMPoint3 p2, NMVector3 vS);
void NMVector3$testDotProduct(NMPoint3 p1, NMPoint3 p2, GLfloat sS);

/*!
 @abstract (void) other:  Other useful psudo-methods.
 */
NSString* NMVector3$description(NMVector3 v);


/*
@interface Vector3:NSObject {
  GLfloat x, y, z;
}

+ (id)vectorWithPoint:(Point3 *)p;
+ (id)vectorWithVector:(Vector3 *)v;
+ (id)vectorFromPoint:(Point3 *)p1 toPoint:(Point3 *)p2;
+ (id)vectorNormalGivenP1:(Point3 *)p1 p2:(Point3 *)p2 andP3:(Point3 *)p3;
+ (id)vectorNormalized:(Vector3 *)v;
+ (void)normalizeP1:(Point3 *)p1 p2:(Point3 *)p2 andP3:(Point3 *)p3 into:(GLfloat [3])n;

- (BOOL)equalsVector:(Vector3 *)v;

- (id)vectorByAddVector:(Vector3 *)v;
- (id)vectorBySubVector:(Vector3 *)v;
- (id)vectorByAddVector:(Vector3 *)v;
- (id)vectorBySubVector:(Vector3 *)v;
- (id)vectorByMul:(GLfloat)scalar;
- (id)vectorByDiv:(GLfloat)scalar;

- (void)mul:(GLfloat)scalar;
- (void)div:(GLfloat)scalar;
- (void)add:(GLfloat)scalar;
- (void)sub:(GLfloat)scalar;
  
- (id)initWithX:(GLfloat)_x y:(GLfloat)_y z:(GLfloat)_z;
- (id)initWithVector:(Vector3 *)p;
- (id)initWithPoint:(Point3 *)p;

- (GLfloat)dot:(Vector3 *)v;
- (Vector3 *)cross:(Vector3 *)v;

- (GLfloat)length;
- (void)normalize;

- (void)setWithVector:(Vector3 *)v;
- (void)setFrom:(Point3 *)from to:(Point3 *)to;

@property(readwrite, assign) GLfloat x, y, z;

@end

@interface Vector3(TestCase)
+ (void)test1;
+ (void)test2;
@end
*/
