
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
//  Camera.m
//  Gliss
//
//  Created by Nima on 5/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import <OpenGL/glu.h>

#import "NMCamera.h"
#import "NMLight.h"
#import "NMMath.h"

#pragma mark Camera(Private)
@interface NMCamera()
- (void)rotateAboutN:(GLfloat)roll;
- (void)rotateAboutU:(GLfloat)pitch;
- (void)rotateAboutV:(GLfloat)yaw;
- (void)recalculate;

@property(readwrite, assign) NMVector3 up, u, v, n;
@end

#pragma mark -
#pragma mark Camera(Public)
@implementation NMCamera

static unsigned short _cameraId = 0;

@synthesize cameraId;
@synthesize viewAngle, aspectRatio, nearPlane, farPlane, zoom;
@synthesize u, v, n;
@synthesize up, eye, look;

- (id)copyWithZone:(NSZone *)zone {
  NMCamera *copy = [NMCamera new];
  copy->eye = NMPoint3$newFrom(eye);
  copy->look = NMPoint3$newFrom(look);
  copy.aspectRatio = self.aspectRatio;
  copy.viewAngle = self.viewAngle;
  copy.nearPlane = self.nearPlane;
  copy.farPlane = self.farPlane;
  copy.up = self.up;
  [copy recalculate];
  return copy;
}


- (id)initWithView:(NSView *)nSV {
  if(self = [super init]) {
    view = nSV;
    [self resize];
    viewAngle = 60.0;
    nearPlane = 10.0;
    farPlane  = 2000.0;

    cameraId = _cameraId++;
    
    managedObjects = [NSMutableArray new];
    
    eye = NMPoint3$new();
    eye->x =  128;
    eye->y =  64;
    eye->z =  128;
    
    look = NMPoint3$new();
    look->x = 0;
    look->y = 0;
    look->z = 0;
    
    zoom = 1.0f;
    
    up = NMVector3$initWithXYZOnly(0, 1, 0);
    [self recalculate];
  }
  [self retain];
  return self;
}

- (void)dealloc {
  free(eye);
  free(look);
  [super dealloc];
}

- (void)manage:(id)o {
  [managedObjects addObject:o];
}

- (void)render {
  for(int i=(int)farPlane; i>nearPlane; i--) {
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Camera %d: %@ --> %@, zoom:%.2f",
          self.cameraId, NMPoint3toString(*eye), NMPoint3toString(*look), zoom];
}

- (void)resize {
  aspectRatio = [view frame].size.width/[view frame].size.height;
}

- (void)setViewVolumeWithViewAngle:(GLfloat)vA
                      aspectRation:(GLfloat)aR
                         nearPlane:(GLfloat)nP
                       andFarPlane:(GLfloat)fP {
  self.viewAngle = vA;
  self.aspectRatio = aR;
  self.nearPlane = nP;
  self.farPlane = fP;
}

/*!
 @discussion The texture matrix allows you to transform texture coordinates to
 accomplish effects such as projected textures or sliding a texture image across
 a geometric surface.
 */

/*
model(l2w) view(w2c) 
 -> projection(perspective)
 -> clipping(cvv or frustum)
 -> viewport
 -> rasterization
 
 http://www.cprogramming.com/tutorial/opengl_projections.html
*/
#pragma mark Open GL Interface
- (void)setZoom:(GLfloat)z {
  zoom = z;
  [self execProjectionMatrix];
}

- (void)execViewportMatrix {
  NSRect w = [view frame];
  
  //. Called ONCE, and then only when the window is resized...
  glViewport(-32, -32, w.size.width+32, w.size.height+32);
}

/*!
 @discussion The perspective matrix mutates the view volume frustum into a
 cube, 2x2x2 centered at the origin.
 @discussion The projection matrix defines the view frustum and controls the
 how the 3D scene is projected into a 2D image.
 @discussion This method should be called when the window is resized, more
 importantly, when the aspect ratio changes. As most typical OpenGL programs,
 the resizing of the window is one of the few times, or even only time, that
 the projection matrix gets changed, after initialization.
 @todo make this called automatically when aspect ratio chaneges.
 */
- (void)execProjectionMatrix {

  NSRect w = [view frame];
  NSSize s = w.size;
  
  //GLint viewport[4];
  //glGetIntegerv (GL_VIEWPORT, viewport);

  //. ### 1 ###
  //. Inform OpenGL that we are about to alter the Projection Matrix and then
  //. clear it...
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
  //. ### 2 ###
  //. if (Ortho) {
  //glOrtho(-s.width/2, +s.width/2, -s.height/2, s.height/2, self.nearPlane, self.farPlane);
  //. } else(Perspective) { /* glFrustrum == gluPerspective */
  glFrustum(-s.width*zoom/2, +s.width*zoom/2, -s.height*zoom/2, s.height*zoom/2, self.nearPlane, self.farPlane);  
  //gluPerspective(self.viewAngle, self.aspectRatio, self.nearPlane, self.farPlane);
  //. }

  //. ### 3 ###
  //. Let's be safe and not leave it in the Projection matrix, returning to the
  //. ModelView matrix...
  //. Note, you could use glGetIntegerv to get the current active matrix, but
  //. in OpenGL, you're better off aiming for performance, i.e. it is faster
  //. to just set the matrix mode, than doing all the `clean' checks.
  //. glGetIntegerv() is there for debugging only.
  glMatrixMode(GL_MODELVIEW);  
  glLoadIdentity();
}

/*!
 @abstract Replacement for...
 gluLookAt(eye->x, eye->y, eye->z, look->x, look->y, look->z, up.x, up.y, up.z);
 @discussion The modelview matrix controls the viewing and modeling 
 transformations for your scene. 
 */
- (void)execModelViewMatrix {
  //. Inform OpenGL that we are about to alter the Model-View Matrix...
  glMatrixMode(GL_MODELVIEW);
  
  /*
  Vector3 eyeVector = Vector3$initFromPoint(eye);
  matrix[0x0] = self.u.x; matrix[0x4] = self.u.y; matrix[0x8] = self.u.z; matrix[0xc] = -Vector3$scalarDotProduct(eyeVector, self.u);
  matrix[0x1] = self.v.x; matrix[0x5] = self.v.y; matrix[0x9] = self.v.z; matrix[0xd] = -Vector3$scalarDotProduct(eyeVector, self.v);
  matrix[0x2] = self.n.x; matrix[0x6] = self.n.y; matrix[0xa] = self.n.z; matrix[0xe] = -Vector3$scalarDotProduct(eyeVector, self.n);
  matrix[0x3] = 0.0;      matrix[0x7] = 0.0;      matrix[0xb] = 0.0;      matrix[0xf] = 1.0;
  */
  
  matrix[0x0] = self.u.x; matrix[0x4] = self.u.y; matrix[0x8] = self.u.z; matrix[0xc] = 0;
  matrix[0x1] = self.v.x; matrix[0x5] = self.v.y; matrix[0x9] = self.v.z; matrix[0xd] = 0;
  matrix[0x2] = self.n.x; matrix[0x6] = self.n.y; matrix[0xa] = self.n.z; matrix[0xe] = 0;
  matrix[0x3] = 0.0;      matrix[0x7] = 0.0;      matrix[0xb] = 0.0;      matrix[0xf] = 1.0;
  
  //. And then do so...
  glLoadMatrixf(matrix);
  glTranslatef(-eye->x, -eye->y, -eye->z);
  /*
  glLoadIdentity();
  gluLookAt(self.eye.x, self.eye.y, self.eye.z,
  self.look.x, self.look.y, self.look.z,
  self.up.x, self.up.y, self.up.z);
  */
}

#pragma mark -
#pragma mark Cartesian Coordinate Navigation
- (void)setEye:(NMPoint3)_eye look:(NMPoint3)_look andUp:(NMVector3)_up {
  up = _up;
  memcpy(eye, &_eye, sizeof(NMPoint3));
  memcpy(look, &_look, sizeof(NMPoint3));
  [self recalculate];
}

- (void)setUp:(NMVector3)p { up = p; }
- (void)setUpX:(GLfloat)x { up.x = x; } 
- (void)setUpY:(GLfloat)y { up.y = y; }
- (void)setUpZ:(GLfloat)z { up.z = z; }
- (void)setUpWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z { up.x = x; up.y = y; up.z = z; }

#pragma mark -
#pragma mark Rotations
- (void)pitchBy:(GLfloat)pitch { [self rotateAboutU:pitch]; }
- (void)rotateAboutU:(GLfloat)pitch {
  float cT, sT, theta;
  theta = toRadians(pitch);
  cT = cos(theta); sT = sin(theta);
  NMPoint3 pV = { cT*n.x - sT*n.x, cT*v.y - sT*n.y, cT*v.z - sT*n.z };  
  NMPoint3 pN = { sT*n.x + cT*n.x, sT*v.y + cT*n.y, sT*v.z + cT*n.z };  
  v = NMVector3$initFromPoint(pV);
  n = NMVector3$initFromPoint(pN);  
  //NSLog(@"U:%.2f %@ %@ %@", theta, Vector3$description(u), Vector3$description(v), Vector3$description(n));
}

- (void)yawBy:(GLfloat)yaw { [self rotateAboutV:yaw]; }
- (void)rotateAboutV:(GLfloat)yaw {
  float cT, sT, theta;
  theta = toRadians(yaw);
  cT = cos(theta); sT = sin(theta);
  NMPoint3 pN = { cT*n.x - sT*u.x, cT*n.y - sT*u.y, cT*n.z - sT*u.z };  
  NMPoint3 pU = { sT*n.x + cT*u.x, sT*n.y + cT*u.y, sT*n.z + cT*u.z };  
  n = NMVector3$initFromPoint(pN);
  u = NMVector3$initFromPoint(pU);  
  //NSLog(@"V:%.2f %@ %@ %@", theta, Vector3$description(u), Vector3$description(v), Vector3$description(n));
}

- (void)rollBy:(GLfloat)roll { [self rotateAboutN:roll]; }
- (void)rotateAboutN:(GLfloat)roll {
  float cT, sT, theta;
  theta = toRadians(roll);
  cT = cos(theta); sT = sin(theta);
  NMPoint3 pU = { cT*u.x - sT*v.x, cT*u.y - sT*v.y, cT*u.z - sT*v.z };  
  NMPoint3 pV = { sT*u.x + cT*v.x, sT*u.y + cT*v.y, sT*u.z + cT*v.z };  
  u = NMVector3$initFromPoint(pU);
  v = NMVector3$initFromPoint(pV);
  //NSLog(@"N:%.2f %@ %@ %@", theta, Vector3$description(u), Vector3$description(v), Vector3$description(n));
}

#pragma mark -
#pragma mark Transpositions
- (void)setEye:(NMPoint3)_eye {
  memcpy(eye, &_eye, sizeof(NMPoint3));
  [self recalculate];
}

- (void)setEyeX:(GLfloat)x { eye->x = x; [self recalculate]; } 
- (void)setEyeY:(GLfloat)y { eye->y = y; [self recalculate]; }
- (void)setEyeZ:(GLfloat)z { eye->z = z; [self recalculate]; }
- (void)setEyeWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
  eye->x = x; eye->y = y; eye->z = z; [self recalculate];
}

#pragma mark -
- (void)setLook:(NMPoint3)_look {
  memcpy(look, &_look, sizeof(NMPoint3));
  [self recalculate];
}
- (void)setLookX:(GLfloat)x { look->x = x; [self recalculate]; } 
- (void)setLookY:(GLfloat)y { look->y = y; [self recalculate]; }
- (void)setLookZ:(GLfloat)z { look->z = z; [self recalculate]; }
- (void)setLookWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
  look->x = x; look->y = y; look->z = z; [self recalculate];
}

#pragma mark World Coordinate Movements
- (void)moveEyeWithVector:(NMVector3)vector {
  [self moveEyeWithDx:vector.x dy:vector.y dz:vector.z];
  [self recalculate];
}

- (void)moveLookWithVector:(NMVector3)vector {
  [self moveLookWithDx:vector.x dy:vector.y dz:vector.z];
  [self recalculate];
}

- (void)moveWithVector:(NMVector3)vector {
  [self moveWithDx:vector.x dy:vector.y dz:vector.z];
}

- (void)moveWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz {
  [self moveEyeWithDx:dx dy:dy dz:dz];
  [self moveLookWithDx:dx dy:dy dz:dz];
}

- (void)moveEyeWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz {
  eye->x += dx;
  eye->y += dy;
  eye->z += dz;
}

- (void)moveLookWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz {
  look->x += dx;
  look->y += dy;
  look->z += dz;
}

#pragma mark Camera Coordinate Movements
- (void)slideEyeWithVector:(NMVector3)vector {
  [self slideEyeWithDu:vector.x dv:vector.y dn:vector.z];
  [self recalculate];
}  

- (void)slideLookWithVector:(NMVector3)vector {
  [self slideLookWithDu:vector.x dv:vector.y dn:vector.z];
  [self recalculate];
}  

- (void)slideWithVector:(NMVector3)vector {
  [self slideWithDu:vector.x dv:vector.y dn:vector.z];
}

- (void)slideWithDu:(GLfloat)du dv:(GLfloat)dv dn:(GLfloat)dn {
  [self slideEyeWithDu:du dv:dv dn:dn];
  [self slideLookWithDu:du dv:dv dn:dn];
}

- (void)slideEyeWithDu:(GLfloat)du dv:(GLfloat)dv dn:(GLfloat)dn {
  GLfloat dx = du*u.x + dv*v.x + dn*n.x;
  GLfloat dy = du*u.y + dv*v.y + dn*n.y;
  GLfloat dz = du*u.z + dv*v.z + dn*n.z;
  eye->x += dx;
  eye->y += dy;
  eye->z += dz;
}

- (void)slideLookWithDu:(GLfloat)du dv:(GLfloat)dv dn:(GLfloat)dn {
  GLfloat dx = du*u.x + dv*v.x + dn*n.x;
  GLfloat dy = du*u.y + dv*v.y + dn*n.y;
  GLfloat dz = du*u.z + dv*v.z + dn*n.z;
  look->x += dx;
  look->y += dy;
  look->z += dz;
}

#pragma mark Private Methods

/*!
 Reload the new MV matrix, as a function of the current eye vector
 */
/*
 - (void)rotate {
 //[self rotateAboutU];
 //[self rotateAboutV];
 //[self rotateAboutN];
 //roll around our forward axis
 glRotatef(+self.roll, 0, 0, 1);
 //pitch up or down
 glRotatef(-self.pitch, 1, 0, 0);
 // set our heading
 glRotatef(-self.yaw, 0, 1, 0);
 //now move to our location
 glTranslatef(-eye.x, -eye.y, -eye.z);
 glLoadIdentity();
 glMatrixMode(GL_MODELVIEW);
 }
 */


- (void)recalculate {
  n = NMVector3$initWithPoints(*look, *eye);
  u = NMVector3$cross(up, n);
  if(NMVector3$scalar(n) != 0.0f)
    NMVector3$resetNormalized(&n);
  if(NMVector3$scalar(u) != 0.0f)
    NMVector3$resetNormalized(&u);
  v = NMVector3$cross(n, u);
}

@end
