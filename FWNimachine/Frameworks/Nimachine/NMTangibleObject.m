
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

#import <OpenGL/glu.h>

#import "NMTangibleObject.h"
#import "NMPoint3.h"
#import "NMMath.h"
#import "NMMatrix.h"

#pragma mark Private Methods and Properties
@interface NMTangibleObject();

- (NSString *)classAlias;
- (void)rotateBy:(double)theta;
- (void)moveByDx:(double)dx andDy:(double)dy;
- (void)scaleBySx:(double)sx andSy:(double)sy;

@property(readwrite, assign)  NSMutableArray *dataPoints;
@property(readwrite, assign)  NMPoint3 center;
@property(readwrite, assign)  BOOL renderValid;
@property(readwrite, assign)  NSValue *activePoint;

@end;

#pragma mark -
@implementation NMTangibleObject
static unsigned long displayId = 0;

#pragma mark Readonly Properties
@synthesize center, renderValid, activePoint;

#pragma mark Read-Write Properties
@synthesize textureId;
@synthesize renderComplete, renderActive, scale, color, texture;
@synthesize dataPoints;

#pragma mark -
#pragma mark Initialization Methods

- (id)init {
  if(self = [super init]) {
    self.color = [NSColor colorWithDeviceWhite:1.0 alpha:1.0];
    self.dataPoints = [NSMutableArray new];
    self.renderComplete = NO;
    self.renderValid = NO;
    self.renderActive = YES;
    self.activePoint = nil;
    self.texture = nil;
    self.textureId = -1;
    self.scale = 0.0;   //. -1 implies object has no texture support
    
    matSpec[0] = 0.1; matSpec[1] = 0.1; matSpec[2] = 0.1; matSpec[3] = 0.1;
    matDiff[0] = 1.0; matDiff[1] = 1.0; matDiff[2] = 1.0; matDiff[3] = 1.0;
    matAmbi[0] = 1.0; matAmbi[1] = 1.0; matAmbi[2] = 1.0; matAmbi[3] = 1.0;
    matEmis[0] = 0.0; matEmis[1] = 0.0; matEmis[2] = 0.0; matEmis[3] = 0.0; 
    matShin[0] = 70.0;
    
    display = glGenLists(++displayId);    
    //render = (void (*)(id, SEL))[[self class] instanceMethodForSelector:@selector(render3D)];
  }
  return self;
}

- (id)initWithColor:(NSColor *)c {
  if(self = [self init]) {
    self.color = c;
  }
  return self;
}

- (id)initWithArray:(NSArray *)a {
  CGFloat r, g, b;
  r = [[a objectAtIndex:1] floatValue]/255.0;
  g = [[a objectAtIndex:2] floatValue]/255.0;
  b = [[a objectAtIndex:3] floatValue]/255.0;
  self = [self initWithColor:[NSColor colorWithDeviceRed:r green:g blue:b alpha:1]];
  if(self) {
    if(![[a objectAtIndex:4] isEqualToString:@"null"]) {
      NSBundle *bundle = [NSBundle bundleForClass:[self class]];
      NSArray *file = [[a objectAtIndex:4] componentsSeparatedByString:@"."];
      self.texture = [bundle pathForResource:[file objectAtIndex:0]
                                      ofType:[file objectAtIndex:1]];
    }
    self.scale = [[a objectAtIndex:5] doubleValue];
    int i;
    for(i=0; i<[[a objectAtIndex:7] intValue]; i++) {
      NMPoint3 p = {
        [[a objectAtIndex:8+2*i] doubleValue],
        0,
        [[a objectAtIndex:9+2*i] doubleValue],
      };
      [self addPoint:p];
    }
    [self setRenderComplete:YES];
    [self setRenderActive:NO];
  }
  return self;
}

#pragma mark -

- (NSString *)saveString {
  NSString *representation;
  
  int i;
  CGFloat r, g, b;
  NSPoint p;
  r = [color redComponent];
  g = [color greenComponent];
  b = [color blueComponent];
  NSString *fN = texture?[[self.texture componentsSeparatedByString:@"/"] lastObject]:@"null";
  
  representation = [NSString stringWithFormat:
                    @"%@ %u %u %u %@ %.1f %.1f %u",
                    [self classAlias],
                    (int)(r*255.0), (int)(g*255.0), (int)(b*255.0),
                    fN, scale, 0, [dataPoints count]];

  for(i=0; i<[dataPoints count]; i++) {
    p = [[dataPoints objectAtIndex:i] pointValue];
    representation = [NSString stringWithFormat:@"%@ %.1f %.1f", representation, p.x, p.y];
  }
  return representation;
}

#pragma mark Accessor Methods

- (BOOL)intersectsWithPoint:(NSPoint)p {
  NSRect r = {{p.x-FUZZ_POINT/2, p.y-FUZZ_POINT/2}, {FUZZ_POINT, FUZZ_POINT}};
  int i;
  for(i=0; i<[dataPoints count]; i++) {
    NSPoint _ = [[dataPoints objectAtIndex:i] pointValue];
    NSPoint dP;
    dP.x = _.x;
    dP.y = _.y;
    if(NSPointInRect(dP, r)) return YES;
  }
  return NO;
}

- (BOOL)containsPoint:(NSPoint)p { return NO; }

- (NSImage *)image {
  return texture?[[[NSImage alloc] initWithContentsOfFile:texture] autorelease]:nil;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ <0x%x>", [self classAlias], self];
}

- (NSString *)classAlias { return NSStringFromClass([self class]); }

#pragma mark Mutator Methods

- (void)drawSierpinski:(NSArray *)data {
  int index;
  NSPoint point;
  NSPoint triangle[3] = {
    [[data objectAtIndex:0] pointValue],
    [[data objectAtIndex:1] pointValue],
    [[data objectAtIndex:2] pointValue]
  };
  
  index = rand()%3;
  point = triangle[index];
  glBegin(GL_POINTS);
  glVertex2i(point.x, point.y);
  int i;
  double r, g, b;
  for(i=0; i<pow(2,16); i++) {
    index = rand()%3;
    point.x = (point.x + triangle[index].x)/2;
    point.y = (point.y + triangle[index].y)/2;
    
    r = hypotenuse_p(point, triangle[0])/hypotenuse_p(triangle[0], triangle[1]);
    g = hypotenuse_p(point, triangle[1])/hypotenuse_p(triangle[1], triangle[2]);
    b = hypotenuse_p(point, triangle[2])/hypotenuse_p(triangle[2], triangle[0]);
    
    glColor3f(r, g, b);
    glVertex2i(point.x, point.y);  
  }
  glEnd();
}

- (void)resetCenter {
  //. Center object...
  int i;
  double xMin=DBL_MAX, xMax=0, yMin=DBL_MAX, yMax=0;
  NSPoint p2;
  for(i=0; i<[dataPoints count]; i++) {
    p2 = [[dataPoints objectAtIndex:i] pointValue];
    xMin = min(xMin, p2.x);
    yMin = min(yMin, p2.y);
    xMax = max(xMax, p2.x);
    yMax = max(yMax, p2.y);
  }
  center.x = (xMin + xMax)/2;
  center.y = (yMin + yMax)/2;
}

- (void)resetColor {
  glColor3f([color redComponent], [color greenComponent], [color blueComponent]);  
}

- (BOOL)resetTexture {
  //. Enable Minmaps
  static BOOL warned = NO;
  BOOL success = NO;
  if(textureId > -1) {
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glEnable(GL_COLOR_MATERIAL);
    success = YES;
  } else if(self.texture) {
    NSLog(@"Setting texture %@ for the first time...", self.texture);
    NSFileManager *fM = [NSFileManager defaultManager];
    if([fM fileExistsAtPath:self.texture]) {
      self.textureId = [NMTangibleObject applyTextureWith:self.texture];
      return [self resetTexture];
      NSLog(@" * Done setting texture %@ for the first time...", self.texture);
    } else if(!warned) {
      NSLog(@"Texture %@ is missing", self.texture);
      warned = YES;
    }
  }
  return success;
}

- (void)resetMaterial {
  float ambient_light[] = {0.4f, 0.4f, 0.4f, 1.0f};
  glEnable(GL_COLOR_MATERIAL);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient_light);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
  glColorMaterial(GL_FRONT_AND_BACK,  GL_AMBIENT_AND_DIFFUSE);
  glMaterialfv(GL_FRONT_AND_BACK,     GL_DIFFUSE,   matDiff);
  glMaterialfv(GL_FRONT_AND_BACK,     GL_AMBIENT,   matAmbi);
  glMaterialfv(GL_FRONT_AND_BACK,     GL_SPECULAR,  matSpec);
  glMaterialfv(GL_FRONT_AND_BACK,     GL_SHININESS, matShin);
}


+ (GLuint)applyTextureWith:(NSString *)textureFile {
  NSAssert(textureFile, @"Trying to set the Texture Mode, while no texture has been set");

  GLuint tid;
  glGenTextures(1, &tid);
  glBindTexture(GL_TEXTURE_2D, tid);

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  //. Flat 2D setting...
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  //. Lighting & Colouring...
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  NSImage *image = [[NSImage alloc] initWithContentsOfFile:textureFile];
  NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];

#ifdef ENABLE_MIPMAP
  glEnable(GL_TEXTURE_2D);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB,
                    [bitmap size].width , [bitmap size].height,
                    [bitmap hasAlpha]?GL_RGBA:GL_RGB,
                    GL_UNSIGNED_BYTE, [bitmap bitmapData]);
#else  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
               [bitmap size].width, [bitmap size].height, 0,
               [bitmap hasAlpha]?GL_RGBA:GL_RGB,
               GL_UNSIGNED_BYTE, [bitmap bitmapData]);
#endif
  [image release];
  [bitmap release];
  return tid;
}



- (void)addPoint:(NMPoint3)p {
  if(!renderComplete) {
    [self resetCenter];
    [dataPoints addObject:[NSValue valueWithBytes:&p objCType:@encode(NMPoint3)]];
    //[self highlight];
  }
}

//- (void)render { render(self, NULL); }
//- (void)render3D { [self doesNotRecognizeSelector:_cmd]; }

#pragma mark Mouse Event Handling

- (void)mouseDown:(NMPoint3)p metaFlags:(unsigned int)flags {
  [self addPoint:p];
}

/*
- (void)draggedToPoint:(NSPoint)p {
  glBegin(GL_LINE_STRIP);
  NSPoint p0 = [[dataPoints objectAtIndex:[dataPoints count]-1] pointValue];
  glVertex2i(p0.x, p0.y);
  glVertex2i(p.x, p.y);
  glEnd();
}
*/

- (void)setActivePointCloseTo:(NSPoint)p {
  renderActive = YES;
  NSRect r = {{p.x-FUZZ_POINT/2, p.y-FUZZ_POINT/2}, {FUZZ_POINT, FUZZ_POINT}};
  int i;
  for(i=0; i<[dataPoints count]; i++) {
    NSPoint _ = [[dataPoints objectAtIndex:i] pointValue];
    NSPoint dP;
    dP.x = _.x;
    dP.y = _.y;
    if(NSPointInRect(dP, r)) {
      activePoint = [dataPoints objectAtIndex:i];
      break;
    }
  }
}




#pragma mark Matrix Transformations

- (void)transformFromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint usingMode:(int)mode {  
  if(mode == DRAG_MOVE) {
    double dx = toPoint.x - fromPoint.x;
    double dy = toPoint.y - fromPoint.y;
    [self moveByDx:dx andDy:dy];
  } else if(!activePoint) {
    if(mode == DRAG_ROTATE) {
      NSPoint v1 = { fromPoint.x - center.x, fromPoint.y - center.y };
      NSPoint v2 = { toPoint.x - center.x, toPoint.y - center.y };
      double fromTheta = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
      [self rotateBy:(fromTheta)];
    } else if(mode == DRAG_SCALE) {
      double sF = hypotenuse_p(fromPoint, center);
      double sT = hypotenuse_p(toPoint, center);
      [self scaleBySx:sT/sF andSy:sT/sF];
    }
  }
}

- (void)moveByDx:(double)dx andDy:(double)dy {
  NMMatrix *m = [NMMatrix matrixTranslateByDx:dx andDy:dy];
  int i;
  if(activePoint) { //. One point is active
    i = [dataPoints indexOfObject:activePoint];
    [dataPoints replaceObjectAtIndex:i withObject:[NSValue valueWithPoint:[m apply:[[dataPoints objectAtIndex:i] pointValue]]]];
    activePoint = [dataPoints objectAtIndex:i];    
  } else { //. Entire object (all points) are active
    for(i=0; i<[dataPoints count]; i++)
      [dataPoints replaceObjectAtIndex:i withObject:[NSValue valueWithPoint:[m apply:[[dataPoints objectAtIndex:i] pointValue]]]];
  }
}

- (void)rotateBy:(double)theta {
  NMMatrix *m = [NMMatrix matrixRotateAboutPoint:NSPointWithPoint3(center) atAngle:theta];
  int i;
  for(i=0; i<[dataPoints count]; i++)
    [dataPoints replaceObjectAtIndex:i withObject:[NSValue valueWithPoint:[m apply:[[dataPoints objectAtIndex:i] pointValue]]]];  
}

- (void)scaleBySx:(double)sx andSy:(double)sy {
  NMMatrix *m = [NMMatrix matrixScaleAboutPoint:NSPointWithPoint3(center) sX:sx sY:sy];
  int i;
  for(i=0; i<[dataPoints count]; i++)
    [dataPoints replaceObjectAtIndex:i withObject:[NSValue valueWithPoint:[m apply:[[dataPoints objectAtIndex:i] pointValue]]]];  
}

- (void)setActive:(BOOL)a {
  //. Setting an entire object active implies unsetting a single point active
  activePoint = nil;
  renderActive = a;
}

@end
