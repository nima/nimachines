
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
 @header      AbstractObject.h
 @abstract    Any object drawn by the user is an subclass of this class
 @discussion  The term `object' in this project pertains to the shapes, roads,
 trees etc that are drawn on the Open-GL canvas, not the term generally used in
 the context of object oriented programming languages.
 @copyright   Copyright 2008 Autonomy. All rights reserved.
 @created     2008-08-08
 @updated     2008-08-08
*/

#import <Cocoa/Cocoa.h>
#import "NMPoint3.h"

#define DRAG_MOVE   0
#define DRAG_ROTATE 1
#define DRAG_SCALE  2

@class NMMatrix;

/*!
 @defined     ENABLE_MIPMAP
 @abstract    Enable OpenGL MipMaps or not
 @discussion  If you do enable it, set it to an integer equal to the depth.
 */
#define ENABLE_MIPMAP 1

/*!
 @defined     FUZZ_LINE
 @abstract    Fuzz for clicking on a line
*/
#define FUZZ_LINE  6.0   

/*!
 @defined     FUZZ_POINT
 @abstract    Fuzz for clicking on a control point
 @discussion  If the clicked point is within a a square of this size, centere
 around any of the points of this objectm then the point itself is selected
 and made active.
*/
#define FUZZ_POINT 12.0

/*!
 @class       AbstractObject
 @abstract    All objects placed on the OpenGL canvas inherit from this class
 @superclass
*/
@interface NMTangibleObject:NSObject {
  BOOL renderComplete;  //. Is this object complete (no more points can be added)
  BOOL renderValid;     //. Is this object valid (can it be rendered)
  BOOL renderActive;    //. Is this object in the active state
  NSValue *activePoint; //. If a point is active, which one
  NSColor *color;
  NSMutableArray *dataPoints; //. Points supplied as input
  NMPoint3 center;
  NSString *type, *texture;
  double scale, textureZoom;
  long textureId;
  int display;
  BOOL prepared;

  GLfloat matSpec[4];
  GLfloat matAmbi[4];
  GLfloat matDiff[4];
  GLfloat matEmis[4];
  GLfloat matShin[1];
  
  void (*render)(id, SEL);
}

+ (GLuint)applyTextureWith:(NSString *)textureFile;

#pragma mark Readonly Properties
@property(readonly,  assign)  NMPoint3 center;
@property(readonly,  assign)  BOOL renderValid;
@property(readonly,  assign)  NSValue *activePoint;

#pragma mark Read-Write Properties
@property(readwrite, assign)  BOOL renderComplete, renderActive;
@property(readwrite, assign)  double scale;
@property(readwrite, retain)  NSString *texture;
@property(readwrite, retain)  NSColor *color;
@property(readwrite, assign)  long textureId;

#pragma mark Initialization Methods
/*!
 @method     initWithColor:
 @abstract   Used when objects are created interactively
*/
- (id)initWithColor:(NSColor *)c;

/*!
 @method     initWithArray
 @abstract   Used when initializing objects from file
 @discussion A bug that exists is that for rectangles, 2 points are read in
 however 4 points are written on saving the file, this is to not lose data
 of the building pertaining to the rotation state of the object.
*/
- (id)initWithArray:(NSArray *)a;

/*!
 @method     saveString
 @abstract   Generates the string to write this object to file
*/
- (NSString *)saveString;

#pragma mark Accessor Methods
- (NSString *)classAlias;

/*!
 @method     interesectsWithPoint
 @abstract   Does a given point intersect with any points in the object
*/
- (BOOL)intersectsWithPoint:(NSPoint)p;

/*!
 @method     interesectsWithPoint
 @abstract   Does a given point intersect with the body of the object
*/
- (BOOL)containsPoint:(NSPoint)p;

/*!
 @method     image
 @abstract   Create and return an NSImage autorelease instance
 @discussion This method will return nil if the object has no texture set
*/
- (NSImage *)image;

#pragma mark Mutator Methods
- (void)drawSierpinski:(NSArray *)data;
/*!
 @method     resetCenter
 @abstract   Recalculate the 2D coordinates of the center of this object
*/
- (void)resetCenter;

/*!
 @method     resetColot
 @abstract   Reset the OpenGL color to the color of this object
*/
- (void)resetColor;

/*!
 @method     applyTexture
 @returns    Success of texture setting
 @abstract   Apply the objects texture to the OpenGL canvas.
 @discussion This method does all the hard work only once, on consequent
 calls, it merely rebinds to the texture id now stored in the object.  It
 does however compare to see if the new texture supplied is different to the
 existing and if so, does the hard work over again.
*/
- (BOOL)resetTexture;


- (void)resetMaterial;

/*!
 @method     addPoint
 @abstract   Add a point to the object
 @discussion Note that this may or may not autocomplete the object depending
 on the class of the object.  This method is very specific to the objects
 being drawn and hence always redefined in the subclasses.
*/
- (void)addPoint:(NMPoint3)p;

/*!
 @method     render
 @abstract   This renders the object (if it is valid) to the OpenGL canvas
*/
//- (void)render;

#pragma mark Mouse Event Handling
/*!
 @method     mouseDown:metaFlags
 @abstract   Pass in an event stating the mouse button click, and meta keys
 @discussion This data is usually 2nd-hand details caught by the event listener
 which is the OpenGL canvas instance (NSOpenGLView).  It decodes the event into
 the relevant bits which are the mouseDown event, and any meta keys (ctrl, alt,
 shift) that were held down at the time.
*/
- (void)mouseDown:(NMPoint3)p metaFlags:(unsigned int)flags;

//. - (void)draggedToPoint:(NSPoint)p;

/*!
 @method     setActivePointCloseTo:
 @abstract   Set a point active, if it is with the surounding FUZZ_POINT square
 @discussion This occurs when the user clicks on a control point of an object
 however if the user clicks further away from these points, but still within
 the area that is `owned' by an object, the the property `setActive' is called.
 @see        property active
*/
- (void)setActivePointCloseTo:(NSPoint)p;

#pragma mark Matrix Transformations
/*!
 @method     transformFromPoint:toPoint:usingMode:
 @abstract   All transformations are made via this function
 @discussion The mode int tells the function of the nature of the transformation
 being rotation, scaling or translation.  This method in turn uses the private
 methods defined below.
 @see        rotateBy:
 @see        moveByDx:andDy:
 @see        scaleBySx:andSy:
*/
- (void)transformFromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint usingMode:(int)mode;

@end
