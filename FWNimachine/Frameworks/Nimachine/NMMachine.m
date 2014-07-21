
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
//  Machine.m
//  SOM
//
//  Created by Nima on 17/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//

#import "NMMachine.h"
#import "NMInputNode.h"
#import "NMMath.h"
#define FAIL_NOW assert(0!=0)

@implementation NMMachine

@synthesize stepCount, stepLimit;
@synthesize epochCount, epochSize;
@synthesize t0_learningRate, learningRate;
@synthesize /*dimensions, */vrp, valid;
@synthesize trainingVectorDimension;
@synthesize averageError;

+ (void)initialize {
  if(self == [NMMachine class]) {
    sranddev();
    //srand((unsigned int)time(NULL));
  }
}

+ (int)machineId {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
  return 0;
}

+ (NSString *)dataSubDir {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
  return nil;
}

- (id)init {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
  return nil;
}

- (id)initWithDataFile:(NSString *)tDF {
  if(self = [super init]) {
    trainingDataFile = tDF;
    assert(trainingDataFile);
    NSFileHandle *fH = [NSFileHandle fileHandleForReadingAtPath:trainingDataFile];
    NSString *data = [[NSString alloc] initWithData:[fH readDataToEndOfFile] 
                                           encoding:NSUTF8StringEncoding];
    [data autorelease];
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *words;
    NSString *line;
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    epochSize = [lines count]; //. FIXME: Better way to do this.
    trainingVectorDimension = 0;

    if(epochSize == 0) {
      NSLog(@"Failed to read from %s", trainingDataFile);
      [self autorelease];
      return nil;
    }
    
    trainingData = malloc([lines count]*sizeof(float*));
    for(int i=0; i<epochSize; i++) {
      line = [[lines objectAtIndex:i] stringByTrimmingCharactersInSet:ws];    
      NSArray *l = [line componentsSeparatedByCharactersInSet:ws];
      words = [NSMutableArray arrayWithArray:l];
      while([words indexOfObject:@""] != NSNotFound) [words removeObject:@""];
      if(!trainingVectorDimension) trainingVectorDimension = [words count];
      trainingData[i] = malloc(trainingVectorDimension*sizeof(float));
      for(int j=0; j<trainingVectorDimension; j++)
        trainingData[i][j] = [[words objectAtIndex:j] floatValue];
    }
    
    errors = malloc(epochSize*sizeof(float));
    for(int i=0; i<epochSize; i++)
      errors[i] = 0.00f;
  }
  
  return self;
}

- (void)dealloc {
  for(int i=0; i<epochSize; i++)
    free(trainingData[i]);
  free(trainingData);
  free(errors);
  [super dealloc];
}

/*!
 @method     
 @abstract A epoch is composed of 1 or more steps
 @discussion How many steps per epoch, and the internals of each is very
 specific to the implementation of each machine, and each machine must define
 this method.
*/
- (void)step {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
}

/*!
 @method     
 @abstract A epoch is composed of 1 or more steps
 @discussion How many steps per epoch, and the internals of each is very
 specific to the implementation of each machine, and each machine must define
 this method.
*/
- (void)epoch {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
}

- (void)render {
  [self doesNotRecognizeSelector:_cmd];
  FAIL_NOW;
}

- (NMPoint3)lookAtMe {
  return [self center];
}

@end
