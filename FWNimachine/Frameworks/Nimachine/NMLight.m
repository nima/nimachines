
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

#import "NMLight.h"
#import "NMPoint3.h"
#import "NMMath.h"

@implementation NMLight

static unsigned short _lightId = 0;
@synthesize power, lightId;

- (id)initWithColor:(NSColor *)c {
  self = [super initWithColor:c];
  lightId = _lightId++;
  return self;
}

- (NSString *)classAlias { return @"Light"; }  

- (NSString *)description {
  return [NSString stringWithFormat:@"Light %d: %@, Powered %s",
          self.lightId, NMPoint3toString(self.center), power?"ON":"OFF"];
}

- (BOOL)containsPoint:(NSPoint)p {
  return (hypotenuse_p(center, p) < RADIUS);
}

- (void)setCenter:(NMPoint3)p {
  if([dataPoints count]==0) {
    [super addPoint:p];
    center = p;
    renderValid = YES;
    renderComplete = YES;
    renderActive = NO;
  }
}

- (void)resetCenter {
  if([self renderComplete]) {
    NMPoint3WithNSValue([dataPoints objectAtIndex:0], &center);
  }
}

- (void)render3D { }
- (void)flipSwitch { [self setPower:!power];}
- (void)setPower:(BOOL)p {
  [self resetCenter];
  if(power = p) {
    GLfloat aC[] = { 0.1f, 0.1f, 0.1f, 1.0f };
    GLfloat dC[] = { [color redComponent], [color greenComponent], [color blueComponent], 1.0f };
    GLfloat sC[] = { [color redComponent], [color greenComponent], [color blueComponent], 1.0f };
    GLfloat  c[] = { center.x, center.y, center.z };
    glLightfv(GL_LIGHT0+lightId, GL_POSITION, c);
    glLightfv(GL_LIGHT0+lightId, GL_AMBIENT,  aC);
    glLightfv(GL_LIGHT0+lightId, GL_DIFFUSE,  dC);
    glLightfv(GL_LIGHT0+lightId, GL_SPECULAR, sC);
    glEnable(GL_LIGHT0+lightId);
  } else glDisable(GL_LIGHT0+lightId);
}
@end
