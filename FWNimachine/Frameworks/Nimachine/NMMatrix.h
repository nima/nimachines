
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

/*!
 @header     Matrix.h
 @abstract   Utility macros and functions.
 @discussion This file is used in almost all classes and provides useful macros
 and utility functions.
 @copyright  Copyright 2008 Autonomy. All rights reserved.
 @created    2008-08-22
 @updated    2008-09-04
*/

#import <Foundation/Foundation.h>

#import "NMVector3.h"

/*!
 @class      Matrix
 @abstract   The Matrix Utility class
 @discussion This class provides high-level services to any class that needs to
 perform matrix calculations without having to deal with the mathematics of it.
*/
@interface NMMatrix:NSObject {
  @private
  GLfloat xx, xy, xw;
  GLfloat yx, yy, yw;
}

/*!
 @method matrixRotateAboutPoint:atAngle:
 @abstract class method which returns an auto-release Matrix instance
 @discussion This instance is of a rotation matrix, with a given angle and
 about a given point
*/
+ (NMMatrix *)matrixRotateAboutPoint:(NSPoint)c atAngle:(GLfloat)a;

/*!
 @method matrixScaleAboutPoint:sX:sY:
 @abstract class method which returns an auto-release Matrix instance.
 @discussion This instance is of a scale matrix, about a given point, by a
 given X-scale factor, as well as a Y-scale factor.  It is upto the caller
 to maintain the ratio between the two.
*/
+ (NMMatrix *)matrixScaleAboutPoint:(NSPoint)c sX:(GLfloat)sx sY:(GLfloat)sy;

/*!
 @method matrixTranslateByDx:andDy:
 @abstract class method which returns an auto-release Matrix instance
 @discussion This instance is of a translation matrix, with a given shift in
 the X and Y axis.
 */
+ (NMMatrix *)matrixTranslateByDx:(GLfloat)dx andDy:(GLfloat)dy;

- (id)initWithArray:(GLfloat *)data;

- (NMMatrix *)compose:(NMMatrix *)m;

/*!
 @method apply:
 @abstract apply the instance of this matrix to a point
 @returns NSPoint The new point after matrix multiplications have taken place.
*/
- (NSPoint)apply:(NSPoint)p;

@property GLfloat xx, xy, xw, yx, yy, yw;

@end
