
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

#import "NMVector3.h"

const NMVector3 NMVector3Zero = { NMPoint3_ZERO, 0.0f, 0.0f, 0.0f };

NSString* NMVector3$description(NMVector3 v) {
  return [NSString stringWithFormat:@"<Vector3: %.2f, %.2f, %.2f>", v.x, v.y, v.z];
}
//Vector3 Vector3$initWithAngle(Point3 startPoint, GLfloat angle);
//Vector3 Vector3$initWithAngleOnly(GLfloat angle);

NMVector3 NMVector3$init(const NMPoint3 startPoint, const GLfloat x, const GLfloat y, const GLfloat z) {
  NMVector3 v = { startPoint, x, y, z };
  return v;
}

NMVector3 NMVector3$initWithXYZOnly(const GLfloat x, const GLfloat y, const GLfloat z) {
  return NMVector3$init(Point3Zero, x, y, z);
}

NMVector3 NMVector3$initFromPoint(const NMPoint3 p) {
  return NMVector3$init(Point3Zero, p.x, p.y, p.z);
}

NMVector3 NMVector3$initWithPoints(const NMPoint3 startPoint, const NMPoint3 endPoint) {
  NMVector3 v = {
    startPoint,
    endPoint.x - startPoint.x,
    endPoint.y - startPoint.y,
    endPoint.z - startPoint.z,
  };
  return v;
}


/*
Vector3 Vector3$makeWithPointAngle(Point3 startPoint, GLfloat angle) {
  return Vector3$makeWithPoint(startPoint, cos(angle), sin(angle));
}

Vector3 Vector3$makeWithAngle(GLfloat angle) {
  return Vector3$make(cos(angle), sin(angle));
}
*/

BOOL NMVector3$equal(const NMVector3 v1, const NMVector3 v2) {
  return (v1.x==v2.x && v1.y==v2.y && v1.z==v2.z); 
}

BOOL NMVector3$equalBounds(const NMVector3 v1, const NMVector3 v2) {
  return NMPoint3$equal(v1.startPoint, v2.startPoint) && NMVector3$equal(v1, v2);
}

NMVector3 NMVector3$normalize(const NMVector3 v) {
  GLfloat scalar = NMVector3$scalar(v);
  if(scalar == 0.0f)
    [NSException raise:@"NullVectorException"
                format:@"Can't normalize a null-length vector"];  
  NMVector3 $v = {
    v.startPoint,
    v.x/scalar,
    v.y/scalar,
    v.z/scalar,
  };
  return $v;
}

void NMVector3$resetNormalized(NMVector3 *v) {
  *v = NMVector3$normalize(*v);
}

GLfloat NMVector3$scalar(const NMVector3 v) {
  return sqrtf(powf(v.x, 2) + powf(v.y, 2) + powf(v.z, 2));
}

NMPoint3 NMVector3$endPoint(const NMVector3 v) {
  NMPoint3 p = {
    v.startPoint.x + v.x,
    v.startPoint.y + v.y,
    v.startPoint.z + v.z,
  };
  return p;
}

void NMVector3$resetEndPoint(NMVector3 *v, const NMPoint3 p) {
  v->x = p.x - v->startPoint.x;
  v->y = p.y - v->startPoint.y;
  v->z = p.z - v->startPoint.z;
}

void NMVector3$resetStartPointTo(NMVector3 *v, const NMPoint3 p) {
  NMVector3 $v = {
    p,
    v->startPoint.x - p.x,
    v->startPoint.y - p.y,
    v->startPoint.z - p.z,
  };
  memcpy(v, &$v, sizeof(NMVector3));
}

NMVector3 NMVector3$add(NMVector3 v1, const NMVector3 v2) {
  v1.x += v2.x; v1.y += v2.y; v1.z += v2.z;
  return v1;
}

NMVector3 NMVector3$sub(NMVector3 v1, const NMVector3 v2) {
  v1.x -= v2.x; v1.y -= v2.y; v1.z -= v2.z;
  return v1;
}

NMVector3 NMVector3$mul(NMVector3 v, const GLfloat coefficient) {
  v.x *= coefficient; v.y *= coefficient; v.z *= coefficient;
  return v;
}

NMVector3 NMVector3$div(NMVector3 v, const GLfloat coefficient) {
  v.x /= coefficient; v.y /= coefficient; v.z /= coefficient;
  return v;
}

GLfloat NMVector3$scalarDotProduct(NMVector3 v1, const NMVector3 v2) {
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}

GLfloat NMVector3$scalarProductWithPoint(NMVector3 v, const NMPoint3 p) {
  return v.x*p.x + v.y*p.y + v.z*p.z;
}

GLfloat NMVector3$scalarDotProductWithPoints(NMPoint3 p1, const NMPoint3 p2) {
  return p1.x*p2.x + p1.y*p2.y, p1.z*p2.z;
}

NMPoint3 NMVector3$projectPoint(NMVector3 v, NMPoint3 p) {
  if(NMVector3$scalar(v) == 0)
    [NSException raise:@"NullVectorException"
                format:@"Can't project point on a null-length vector"];
  
  NMPoint3 projected;
  GLfloat product = NMVector3$scalarProductWithPoint(v, p);
  product /= (powf(v.x, 2) + powf(v.y, 2) * powf(v.z, 2));
  projected.x = v.startPoint.x + v.x*product;
  projected.y = v.startPoint.y + v.y*product;
  projected.z = v.startPoint.z + v.z*product;
  
  return projected;
}

GLfloat NMVector3$dot(const NMVector3 v1, const NMVector3 v2) {
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}

NMVector3 NMVector3$cross(const NMVector3 v1, const NMVector3 v2) {
  NMVector3 v = {
    NMPoint3_ZERO,
    v1.y*v2.z - v1.z*v2.y,
    v1.z*v2.x - v1.x*v2.z,
    v1.x*v2.y - v1.y*v2.x,
  };
  return v;
}

void    NMVector3$writeNormalized(GLfloat *n, const NMVector3 v) {
  NMVector3 $v = NMVector3$normalize(v);
  n[0] = $v.x;
  n[1] = $v.y;
  n[2] = $v.z;  
}

NMVector3 NMVector3$cCWPlaneNormal(const NMPoint3 pA, const NMPoint3 pB, const NMPoint3 pC) {
  return NMVector3$normalize(NMVector3$cross(NMVector3$initWithPoints(pA, pB), NMVector3$initWithPoints(pB, pC)));
}

void    NMVector3$writeCCWPlaneNormal(GLfloat *n, const NMPoint3 pA, const NMPoint3 pB, const NMPoint3 pC) {
  NMVector3 v = NMVector3$normalize(NMVector3$cross(NMVector3$initWithPoints(pA, pB), NMVector3$initWithPoints(pB, pC)));
  n[0] = v.x;
  n[1] = v.y;
  n[2] = v.z;
}

#pragma mark -
#pragma mark Test Cases

void NMVector3$testCrossProduct(const NMPoint3 p1, const NMPoint3 p2, const NMVector3 vS) {
  NMVector3 v1 = NMVector3$initFromPoint(p1);
  NMVector3 v2 = NMVector3$initFromPoint(p2);
  NMVector3 vT = NMVector3$cross(v1, v2);
  NSLog(@"Testing CrossProduct...");
  if(!NMVector3$equal(vT, vS)) {
    [NSException raise:@"CrossProductDeveloperException"
                format:@"Expected %@, got %@", NMVector3$description(vS), NMVector3$description(vT)];
  }
}

void NMVector3$testDotProduct(const NMPoint3 p1, const NMPoint3 p2, const GLfloat sS) {
  GLfloat sT = NMVector3$scalarDotProductWithPoints(p1, p2);
  NSLog(@"Testing DotProduct...");
  if(sT != sS) {
    [NSException raise:@"CrossProductDeveloperException"
                format:@"Cross Product calculations are incorrect."];
  }
}

void NMVector3$testAll() {
  NMPoint3 pA1 = {3, -3, 1};
  NMPoint3 pA2 = {-12, 12, -4};
  NMVector3$testCrossProduct(pA1, pA2, NMVector3Zero);
  
  NMPoint3 pB1 = {3, -3, 1};
  NMPoint3 pB2 = {4, 9, 2};
  NMPoint3 pBS = {-15, -2, 39};
  NMVector3$testCrossProduct(pB1, pB2, NMVector3$initFromPoint(pBS));
}

/*
@implementation Vector3

+ (id)vectorWithPoint:(Point3 *)p {
  return [[[Vector3 alloc] initWithPoint:p] autorelease];
}

+ (id)vectorWithVector:(Vector3 *)v {
  return [[[Vector3 alloc] initWithVector:v] autorelease];
}

+ (id)vectorFromPoint:(Point3 *)p1 toPoint:(Point3 *)p2 {
  Vector3 *v = [Vector3 new];
  v.x = p2->x - p1->x;
  v.y = p2->y - p1->y;
  v.z = p2->z - p1->z;
  return [v autorelease];
}

+ (id)vectorNormalGivenP1:(Point3 *)p1 p2:(Point3 *)p2 andP3:(Point3 *)p3 {
  Vector3 *v1 = [Vector3 vectorFromPoint:p1 toPoint:p2];
  Vector3 *v2 = [Vector3 vectorFromPoint:p2 toPoint:p3];
  Vector3 *v3 = [v1 cross:v2];
  [v3 normalize];
  return v3;
}

+ (void)normalizeP1:(Point3 *)p1 p2:(Point3 *)p2 andP3:(Point3 *)p3 into:(GLfloat *)n {
  Vector3 *vN = [self vectorNormalGivenP1:p1 p2:p2 andP3:p3];
  n[0] = vN.x;
  n[1] = vN.y;
  n[2] = vN.z;
}

+ (id)vectorNormalized:(Vector3 *)v {
  [v normalize];
  return v;
}

- (id)vectorByAddVector:(Vector3 *)v {
  Vector3 *vNew = [[Vector3 alloc] initWithVector:self];
  vNew.x += v.x;
  vNew.y += v.y;
  vNew.z += v.z;
  return [vNew autorelease];
}

- (id)vectorBySubVector:(Vector3 *)v {
  Vector3 *vNew = [[Vector3 alloc] initWithVector:self];
  vNew.x -= v.x;
  vNew.y -= v.y;
  vNew.z -= v.z;
  return [vNew autorelease];
}

- (id)vectorByMul:(GLfloat)scalar {
  Vector3 *vNew = [[Vector3 alloc] initWithVector:self];
  vNew.x *= scalar;
  vNew.y *= scalar;
  vNew.z *= scalar;
  return [vNew autorelease];
}

- (id)vectorByDiv:(GLfloat)scalar {
  Vector3 *vNew = [[Vector3 alloc] initWithVector:self];
  vNew.x /= scalar;
  vNew.y /= scalar;
  vNew.z /= scalar;
  return [vNew autorelease];
}

- (void)mul:(GLfloat)scalar {
  self.x *= scalar;
  self.y *= scalar;
  self.z *= scalar;
}
- (void)div:(GLfloat)scalar {
  self.x /= scalar;
  self.y /= scalar;
  self.z /= scalar;
}
- (void)add:(GLfloat)scalar {
  self.x += scalar;
  self.y += scalar;
  self.z += scalar;
}
- (void)sub:(GLfloat)scalar {
  self.x -= scalar;
  self.y -= scalar;
  self.z -= scalar;
}

- (id)init {
  return [self initWithX:0.0 y:0.0 z:0.0];
}

- (id)initWithX:(GLfloat)_x y:(GLfloat)_y z:(GLfloat)_z {
  if(self = [super init]) {
    self.x = _x;
    self.y = _y;
    self.z = _z;
  }
  return self;
}

- (id)initWithPoint:(Point3 *)p {
  if(self = [super init]) {
    self.x = p->x;
    self.y = p->y;
    self.z = p->z;
  }
  return self;
}

- (id)initWithVector:(Vector3 *)v {
  if(self = [super init])
    [self setWithVector:v];
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%.2f, %.2f, %.2f, l:%.2f>", self.x, self.y, self.z, [self length]];
}


- (void)setWithVector:(Vector3 *)v {
  self.x = v.x;
  self.y = v.y;
  self.z = v.z;
}

- (void)setFrom:(Point3 *)from to:(Point3 *)to {
  self.x = to->x - from->x;
  self.y = to->y - from->y;
  self.z = to->z - from->z;
}

- (GLfloat)dot:(Vector3 *)v { / * The Innter Product * /
  return self.x*v.x + self.y*v.y + self.z*v.z;
}

- (Vector3 *)cross:(Vector3 *)v {
  Vector3 *vN = [Vector3 new];
  vN.x = self.y*v.z - self.z*v.y;
  vN.y = self.z*v.x - self.x*v.z;
  vN.z = self.x*v.y - self.y*v.x;
  return [vN autorelease];
}

- (GLfloat)length {
  return sqrtf(powf(self.x, 2)+powf(self.y, 2)+powf(self.z, 2));
}

- (void)normalize {
  GLfloat scalar = [self length];
  self.x /= scalar;
  self.y /= scalar;
  self.z /= scalar;
}

- (BOOL)equalsVector:(Vector3 *)v {
  return (self.x == v.x) && (self.y == v.y) && (self.z == v.z);
}

@synthesize x, y, z;

+ (void)test1 {
  Point3 p1 = {3, -3, 1};  
  Point3 p2 = {4, 9, 2};
  Point3 pS = {-15, -2, 39};
  Vector3 *v1 = [Vector3 vectorWithPoint:&p1];
  Vector3 *v2 = [Vector3 vectorWithPoint:&p2];
  Vector3 *vT = [v1 cross:v2];
  Vector3 *vS = [Vector3 vectorWithPoint:&pS];
  NSAssert([vT equalsVector:vS], @"Failed Test 1");
}

+ (void)test2 {
  Point3 p1 = {3, -3, 1};
  Point3 p2 = {-12, 12, -4};
  Point3 pS = {0, 0, 0};
  Vector3 *v1 = [Vector3 vectorWithPoint:&p1];
  Vector3 *v2 = [Vector3 vectorWithPoint:&p2];
  Vector3 *vT = [v1 cross:v2];
  Vector3 *vS = [Vector3 vectorWithPoint:&pS];
  NSAssert([vT equalsVector:vS], @"Failed Test 1");
}  

@end
*/



