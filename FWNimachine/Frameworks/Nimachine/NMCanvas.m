
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
//  SOMCanvas.m
//  SOM
//
//  Created by Nima on 23/09/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMCanvas.h"

#import <GLUT/glut.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#import "NMCamera.h"
#import "NMLight.h"

#pragma mark -
#pragma mark Private Methods
@interface NMCanvas()
- (void)addObject:(NMTangibleObject *)object;
- (void)stepAnimation:(NSTimer *)t;
- (void)animate:(id)object;
@end

#pragma mark -
@implementation NMCanvas

@synthesize camera;

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)dc {
  if(self = [super initWithCoder:dc]) {
    decoder = dc;
    lights = [NSMutableArray new];
    objects = [NSMutableArray new];
  }
  return self;
}

#pragma mark -
#pragma mark Animation

- (void)awakeFromNib {
  [NSApp setDelegate:self];

  //. Camera...
  NMPoint3 p = NMPoint3_ZERO;
  camera = [[NMCamera alloc] initWithView:self];
  [camera setLook:p];
  [cameras addObject:camera];
  
#if ENABLE_MULTI_THREADED == 1
  [NSThread detachNewThreadSelector:@selector(animate:) toTarget:self withObject:nil];
#else
  timer = [[NSTimer scheduledTimerWithTimeInterval:ANIMATION_SLEEP
                                            target:self
                                          selector:@selector(stepAnimation:)
                                          userInfo:nil
                                           repeats:YES] retain];
#endif

  /*
  teapot = glGenLists(1024);
  glNewList(teapot, GL_COMPILE);
  glutSolidTeapot(32);
  glEndList();
  */
}

- (void)animate:(id)object{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  while(YES) {
    [self stepAnimation:nil];
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:ANIMATION_SLEEP]];
  }
  
  [pool release];
  [NSThread exit];
}

- (void)stepAnimation:(NSTimer *)t {
  [self doesNotRecognizeSelector:_cmd];
}

#pragma mark -
#pragma mark Rendering

+ (NSOpenGLPixelFormat*)defaultPixelFormat {
    const NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples,       2,
        
        NSOpenGLPFAMultisample,
        NSOpenGLPFADepthSize,     32,
        NSOpenGLPFAAccumSize,     32,
        NSOpenGLPFAAccelerated,
        
        NSOpenGLPFANoRecovery,
        (NSOpenGLPixelFormatAttribute)0x00
    };
    return [[[NSOpenGLPixelFormat alloc]
             initWithAttributes:attributes] autorelease];
}

- (void)prepareOpenGL {
#if ENABLE_GLUT != 1
  NSOpenGLPixelFormat* pF;
  
  //. Check if initWithAttributes succeeded.
  if((pF = [NMCanvas defaultPixelFormat]) != nil) [self setPixelFormat:pF];
  else [NSException raise:@"NSOpenGLPixelFormat"
                   format:@"initWithAttributes failed. Try to alloc/init with a different list of attributes."];
#else
  glutInitDisplayMode (GLUT_SINGLE|GLUT_RGB|GLUT_ACCUM|GLUT_DEPTH);
#endif
  
  glEnable(GL_NORMALIZE);
  glEnable(GL_RESCALE_NORMAL);
  glEnable(GL_STENCIL_TEST);
  
  /*************************** BACK-FACE CULLING ******************************/
  //glCullFace(GL_BACK);
  //glEnable(GL_CULL_FACE);
  
  /****************************** ANTIALIASING ********************************/
  glEnable(GL_MULTISAMPLE);
  glEnable(GL_MULTISAMPLE_ARB);
  glHint(GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST);
  GLERR;
  //glEnable(GL_LINE_SMOOTH);
  //glEnable(GL_POLYGON_SMOOTH);
  //glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
  //glPolygonMode(GL_FRONT, GL_LINE);            //. Wireframe
  //glPolygonMode(GL_FRONT, GL_POLYGON);         //. Solid
  
  
#if ANTIALIASING > 0
  glClearAccum(0.0, 0.0, 0.0, 0.0);
  float q = 0.99;
  glAccum(GL_MULT, q);
  glAccum(GL_ACCUM, 1-q);
  glAccum(GL_RETURN, 1.0);
#endif
  
  /***************************** TRANSPARENCY *********************************/
  glEnable(GL_ALPHA_TEST);
  glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ZERO);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  //glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ONE);
  
  /******************************* Z BUFFER ***********************************/
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  glDepthMask(GL_TRUE); //. Enable writing into the Z-buffer
  
  /********************************* SHADER ***********************************/
  glClearColor(0.0f, 0.0f, 0.0f, 0.9f);
  glShadeModel(GL_SMOOTH);
  glEnable(GL_LIGHTING);
  NMLight *l;
  NMPoint3 p;
  NSColor *lC = [NSColor colorWithDeviceRed:0.96f
                                      green:0.94f
                                       blue:0.92f
                                      alpha:1.0f];
  
  l = [[NMLight alloc] initWithColor:lC];
  p = NMPoint3$initWithXYZ(+200, +100, +200);
  [l setCenter:p];
  [lights addObject:l];
  
  l = [[NMLight alloc] initWithColor:lC];
  p = NMPoint3$initWithXYZ(-200, -100, -200);
  [l setCenter:p];
  [lights addObject:l];
  
  [self setAmbience:nil];
  
  if(![lights count])
    [self instantiateObjectFromString:@"Light 255 255 255 null 1.0 10.0 2 10.0 30.0 110.0 130.0"];
  
  for(int i=0; i<[lights count]; i++) {
    [[lights objectAtIndex:i] setPower:YES];
    NSLog(@"%@", [lights objectAtIndex:i]);
  }
  
  /********************************* FOG **************************************/
#if ENABLE_FOG
  GLfloat fogColor[4] = { 0.9, 0.9, 0.9, 0.9 };
  GLfloat fogDensity = 0.80;
  glEnable(GL_FOG);
  glFogi(GL_FOG_MODE, GL_LINEAR);
  glFogfv(GL_FOG_COLOR, fogColor);
  glFogf(GL_FOG_DENSITY, fogDensity);
  glFogf(GL_FOG_START, 32.0);
  glFogf(GL_FOG_END, 500.0);
  glHint(GL_FOG_HINT, GL_NICEST);
#endif  
  
  /******************************* LIGHTING ***********************************/
  
  [camera execProjectionMatrix];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
  [camera execProjectionMatrix];
  NSSize myWindowSize;
  unsigned short C = WINDOW_SIZE;
  myWindowSize.width = frameSize.width;
  myWindowSize.height = (frameSize.width - C)*3/4;
  [camera execViewportMatrix];
  [camera execModelViewMatrix];
  return myWindowSize;
}

- (void)reshape {
  //NSRect windowFrame = [[self window] frame];
  //NSRect openGLFrame = [[[self openGLContext] view] frame];
  //NSRect openGLFrame = [self convertRectToBase:[self bounds]];
  //[camera resizeTo:openGLFrame];
  [camera resize];
  [camera execViewportMatrix];
  [camera execProjectionMatrix];
  [self prepareOpenGL];  
}

- (void)drawRect:(NSRect)r {
  [self doesNotRecognizeSelector:_cmd];
}

- (IBAction)setAmbience:(id)sender {
  [self doesNotRecognizeSelector:_cmd];
}

- (IBAction)setZoom:(id)sender {
  double x = [sender doubleValue];
  double m = [sender maxValue];
  [camera setZoom: x/sqrt(1+pow(0.9*m-x, 2))];
}

#pragma mark -
#pragma mark Other

- (void)instantiateObjectFromString:(NSString *)line {
  NSMutableArray *words;
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
  if([line length]) {
    words = [NSMutableArray arrayWithArray:[line componentsSeparatedByCharactersInSet:ws]];
    while([words indexOfObject:@""] != NSNotFound) [words removeObject:@""];
    
    Class ConcreteObject = [words objectAtIndex:0];
    
    NMTangibleObject *obj = [[ConcreteObject alloc] initWithArray:words];
    [self addObject:obj];
  }
}

- (void)addObject:(NMTangibleObject *)obj {
  if([[obj classAlias] isEqualToString:@"Light"]) {
    [lights addObject:obj];
    //NSLog(@"Added Diffuse Light: %@", [ds_lights dataSource]);
  } else if([[obj classAlias] isEqualToString:@"Camera"]) {
    [cameras addObject:obj];
    //NSLog(@"Added Camera: %@", [ds_viewPoints dataSource]);
  } else [objects addObject:obj];
}

#pragma mark -
#pragma mark Debugging

- (void)openGLDump {
  
  GLint maxRectTextureSize; 
  GLint myMaxTextureUnits; 
  GLint myMaxTextureSize; 
  const GLubyte *strVersion;
  const GLubyte *strExt; 
  float myGLVersion; 
  GLboolean isVAO,isTexLOD,isColorTable,isFence,isShade, isTextureRectangle; 
  if(strVersion=glGetString(GL_VERSION))
    sscanf((char*)strVersion,"%f", &myGLVersion); 
  strExt=glGetString(GL_EXTENSIONS);
  glGetIntegerv(GL_MAX_TEXTURE_UNITS,&myMaxTextureUnits);  //4 
  glGetIntegerv(GL_MAX_TEXTURE_SIZE,&myMaxTextureSize); 
  isVAO=gluCheckExtension((const GLubyte*)"GL_APPLE_vertex_array_object",strExt); 
  isFence=gluCheckExtension((const GLubyte*)"GL_APPLE_fence",strExt); 
  isShade=gluCheckExtension((const GLubyte*)"GL_ARB_shading_language_100",strExt); 
  isColorTable=gluCheckExtension((const GLubyte*)"GL_SGI_color_table",strExt)||gluCheckExtension((const GLubyte*)"GL_ARB_imaging",strExt); 
  isTexLOD=gluCheckExtension((const GLubyte*)"GL_SGIS_texture_lod",strExt)||(myGLVersion>=1.2); 
  isTextureRectangle=gluCheckExtension((const GLubyte*) "GL_EXT_texture_rectangle",strExt); 
  if(isTextureRectangle) 
    glGetIntegerv(GL_MAX_RECTANGLE_TEXTURE_SIZE_EXT, &maxRectTextureSize); 
  else 
    maxRectTextureSize=0; 
  
  NSLog(@"1. Gets a string that specifies the version of OpenGL... %s", strVersion);
  NSLog(@"2. Gets the extension name string... %s", strExt);
  NSLog(@"3. Calls the OpenGL function glGetIntegerv to get the value of the"
        "attribute passed to it which, in this case, is the maximum number of"
        "texture units... %d", myMaxTextureUnits);
  NSLog(@"4. Gets the maximum texture size... %d", myMaxTextureSize);
  NSLog(@"5. Checks whether vertex array objects are supported... %d", isVAO);
  NSLog(@"6. Checks for the Apple fence extension... %d", isFence);
  NSLog(@"7. Checks for support for version 1.0 of the OpenGL shading language...%d", isShade);
  NSLog(@"8. Checks for RGBA-format color lookup table support. In this case,"
        "the code needs to check for the vendor-specific string and for the ARB"
        "string. If either is present, the functionality is supported... %d", isColorTable);
  NSLog(@"9. Checks for an extension related to the texture level of detail"
        "parameter (LOD). In this case, the code needs to check for the"
        "vendor-specific string and for the OpenGL version. If either the vendor"
        "string is present or the OpenGL version is greater than or equal to 1.2,"
        "the functionality is supported... %d", isTexLOD);
  NSLog(@"10. Gets the OpenGL limit for rectangle textures. For some extensions,"
        "such as the rectangle texture extension, it may not be enough to check"
        "whether the functionality is supported. You may also need to check the"
        "limits. You can use glGetIntegerv and related functions (glGetBooleanv,"
        "glGetDoublev, glGetFloatv) to obtain a variety of parameter values... %d", maxRectTextureSize);
}  

@end
