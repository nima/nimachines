
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

/*
 *  Math.h
 *  SOM
 *
 *  Created by Nima on 3/11/08.
 *  Copyright 2008 Autonomy. All rights reserved.
 *
 */

#include <math.h>

#pragma mark 2D Vectors/Points

#define gradient_p(p1, p2) (p2.y - p1.y)/(p2.x - p1.x)
#define hypotenuse_p(p1, p2) (hypot((p2.x - p1.x), (p2.y - p1.y)))
#define hypotenuse_v(v) hypot(v.x, v.y)
#define angle_p(p1, p2, p3) (M_PI*hypotenuse_p(p1, p3)/(hypotenuse_p(p1, p3)+hypotenuse_p(p1, p2)+hypotenuse_p(p2, p3)))
#define toRadians(a) (a*M_PI/180)
#define toDegrees(a) (a*180/M_PI)
#define breath(theta) exp(pow(sin(theta), 2)+sin(theta))/7.0f
#define randf (((float)random())/RAND_MAX)
#define sigmoid(t) (1.0f/(1.0f+exp(-(t))))

#pragma mark Get filepath macros
#define GET_TEX(t) @"/Users/nima/Devel/AI/OpenGL/Gliss3D/textures/"t".png"
#define GET_MAP(m) @"/Users/nima/Devel/AI/OpenGL/Gliss3D/maps/"m

#pragma mark Other

#define GLERR { GLint err = glGetError(); if(err != GL_NO_ERROR) NSLog(@"OpenGL Error: %d", err); else NSLog(@"No OpenGL Error Reported"); }

#define BE(a) (int)powl(2, a)
#define DBUG_PNT(i, p) NSLog(@"Point %d { %0.2f, %.2f }", i, p.x, p.y);

#define min(a, b) ((a)<(b)?(a):(b))
#define max(a, b) ((a)>(b)?(a):(b))

float euclideanDistance(int size, float *v1, float *v2);
float squaredDistance(int size, float *v1, float *v2);
float average(int size, float *v);
