
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

#import "NMMatrix.h"

@implementation NMMatrix

#pragma mark Class Methods

//. return rotation about point
+ (NMMatrix *)matrixRotateAboutPoint:(NSPoint)c atAngle:(GLfloat)a {
  GLfloat kk[] = { 1, 0, -c.x, 0, 1, -c.y };
  GLfloat ll[] = { cos(a), -sin(a), 0, sin(a), cos(a), 0 };
  GLfloat mm[] = { 1, 0, c.x, 0, 1, c.y };
  //. Replaced (GLfloat *) with (void *) casts to shut the warnings up.
  NMMatrix *k = [[NMMatrix alloc] initWithArray:(void *)kk];
  NMMatrix *l = [[NMMatrix alloc] initWithArray:(void *)ll];
  NMMatrix *m = [[NMMatrix alloc] initWithArray:(void *)mm];
  [k autorelease]; [l autorelease]; [m autorelease];
  return [k compose:[l compose:m]];
}

//. return scale about point
+ (NMMatrix *)matrixScaleAboutPoint:(NSPoint)c sX:(GLfloat)sx sY:(GLfloat)sy {
  GLfloat kk[] = {1, 0, -c.x, 0, 1, -c.y};
  GLfloat ll[] = {sx, 0, 0, 0, sy, 0};
  GLfloat mm[] = {1, 0, c.x, 0, 1, c.y};
  //. Replaced (GLfloat *) with (void *) casts to shut the warnings up.
  NMMatrix *k = [[NMMatrix alloc] initWithArray:(void *)kk];
  NMMatrix *l = [[NMMatrix alloc] initWithArray:(void *)ll];
  NMMatrix *m = [[NMMatrix alloc] initWithArray:(void *)mm];
  [k autorelease]; [l autorelease]; [m autorelease];
  return [k compose:[l compose:m]];
}

+ (NMMatrix *)matrixTranslateByDx:(GLfloat)dx andDy:(GLfloat)dy {
  GLfloat nn[6] = {1, 0, dx, 0, 1, dy};
  NMMatrix *n = [[NMMatrix alloc] initWithArray:(void *)nn];
  [n autorelease];
  return n;  
}

#pragma mark Initialization Methods

- (id)init {
  GLfloat _[6] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  return [self initWithArray:_];
}

- (id)initWithArray:(GLfloat *)data {
  if(self = [super init]) {
    xx = data[0];
    xy = data[1];
    xw = data[2];
    yx = data[3];
    yy = data[4];
    yw = data[5];
  }
  return self;
}

#pragma mark Main Workhorse Methods

- (NMMatrix *)compose:(NMMatrix *)m {
  NMMatrix *result = [NMMatrix new];
  [result setXx:[m xx]*xx + [m xy]*yx];
  result.xy = m.xx*xy + m.xy*yy;
  result.xw = m.xx*xw + m.xy*yw + m.xw;
  result.yx = m.yx*xx + m.yy*yx;
  result.yy = m.yx*xy + m.yy*yy;
  result.yw = m.yx*xw + m.yy*yw + m.yw;
  [result autorelease];
  return result;  
}

- (NSPoint)apply:(NSPoint)p {
  NSPoint newPoint;
  newPoint.x = xx*p.x + xy*p.y + xw;
  newPoint.y = yx*p.x + yy*p.y + yw;
  return newPoint;
}

@synthesize xx, xy, xw, yx, yy, yw;

@end
