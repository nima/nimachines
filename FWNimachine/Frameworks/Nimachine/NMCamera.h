
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
//  Camera.h
//  Gliss
//
//  Created by Nima on 5/10/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NMPoint3.h"
#import "NMVector3.h"

@interface NMCamera:NSObject {
  NMPoint3 *eye, *look;
  NMVector3 up, u, v, n;
  NSView *view;
  GLfloat viewAngle, aspectRatio, nearPlane, farPlane, zoom;
  GLfloat matrix[16];
  UInt8 cameraId;
  NSMutableArray *managedObjects;
}
- (void)resize;

@property(readonly, assign) NMPoint3 *eye, *look;
@property(readonly, assign) NMVector3 up, u, v, n;
@property(readwrite, assign) GLfloat viewAngle, aspectRatio, nearPlane, farPlane, zoom;
@property(readwrite, assign) UInt8 cameraId;

#pragma mark -
#pragma mark Let this camera decide how to render managed objects
- (void)manage:(id)o;
- (void)render;

#pragma mark -
#pragma mark Enable deep copying (conform to NSCopying protocol)
- (id)initWithView:(NSView *)nSV;
- (id)copyWithZone:(NSZone *)zone;



#pragma mark -
#pragma mark communication with Openg GL
- (void)execViewportMatrix;
- (void)execProjectionMatrix;
- (void)execModelViewMatrix;

#pragma mark -
#pragma mark Initial Setup
- (void)setViewVolumeWithViewAngle:(GLfloat)vA
                      aspectRation:(GLfloat)aR
                         nearPlane:(GLfloat)nP
                       andFarPlane:(GLfloat)fP;

#pragma mark -
#pragma mark Cartesian Coordinate Navigation
- (void)setEye:(NMPoint3)_eye;
- (void)setEyeWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
- (void)setEyeX:(GLfloat)x;
- (void)setEyeY:(GLfloat)y;
- (void)setEyeZ:(GLfloat)z;

- (void)setLook:(NMPoint3)_look;
- (void)setLookWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
- (void)setLookX:(GLfloat)x;
- (void)setLookY:(GLfloat)y;
- (void)setLookZ:(GLfloat)z;

- (void)setUpWithX:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;

#pragma mark Othert Navigation Methods
- (void)moveEyeWithVector:(NMVector3)vector;
- (void)moveLookWithVector:(NMVector3)vector;
- (void)moveWithVector:(NMVector3)vector;
- (void)moveWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz;
- (void)moveEyeWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz;
- (void)moveLookWithDx:(GLfloat)dx dy:(GLfloat)dy dz:(GLfloat)dz;

#pragma mark -
- (void)slideWithDu:(GLfloat)du  dv:(GLfloat)dv dn:(GLfloat)dn;
- (void)slideEyeWithDu:(GLfloat)du  dv:(GLfloat)dv dn:(GLfloat)dn;
- (void)slideLookWithDu:(GLfloat)du  dv:(GLfloat)dv dn:(GLfloat)dn;

- (void)slideWithVector:(NMVector3)vector;
- (void)slideEyeWithVector:(NMVector3)vector;
- (void)slideLookWithVector:(NMVector3)vector;

- (void)yawBy:(GLfloat)yaw;
- (void)pitchBy:(GLfloat)pitch;
- (void)rollBy:(GLfloat)roll;

@end
