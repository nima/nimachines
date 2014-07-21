
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
//  NMMachine.h
//  SOM
//
//  Created by Nima on 17/11/08.
//  Copyright 2008 Autonomy. All rights reserved.
//
// http://developer.apple.com/mac/library/documentation/DeveloperTools/Conceptual/HeaderDoc/tags/tags.html

#import <Cocoa/Cocoa.h>

#import "NMTangibleObject.h"

@class NMTangibleObject, NMInputNode;

@interface NMMachine:NMTangibleObject {
    NMInputNode **inputs;
    
    /*!
     @var stepCount
     @abstract The number of steps that have passed (in total, not per epoch)
     */
    UInt32 stepCount;
    
    /*!
     @var stepLimit
     @abstract The upper bound on the number of steps that can be executed before learning stops.
     */
    UInt32 stepLimit;
    
    /*!
     @discussion In training a learning machine, the term epoch is used to describe a complete pass through
     all of the training patterns.  The weights in the neural network for example may be updated after each
     pattern is presented to the network, or they may be updated just once at the end of the epoch. Frequently
     used as a measure of speed of learning - as in "training was complete after x epochs".
     */
    
    /*!
     @var epochCount
     @abstract The number of epochs that have passed
     */
    UInt32 epochCount;
    
    /*!
     @var epochSize
     @abstract The cardinality (number of steps) of an epoch 
     */
    UInt32 epochSize;
    
    /*!
     @var Training Vector Cardinality
     @abstract This gets determined from the input data file...
     */
    int trainingVectorDimension;
    
    NMPoint3 *vrp;
    float **trainingData;
    float t0_learningRate, learningRate, tN_learningRate;
    BOOL valid;
    NSString *trainingDataFile;
    float averageError, *errors;
}

@property(readwrite, assign) NMPoint3 *vrp;
@property(readwrite, assign) int trainingVectorDimension;//, dimensions;
@property(readonly) BOOL valid;
@property(readonly) UInt32 stepCount, stepLimit, epochCount, epochSize;
@property(readonly) float learningRate, t0_learningRate;
@property(readonly) float averageError;

+ (int)machineId;
+ (NSString *)dataSubDir;

- (id)initWithDataFile:(NSString *)dataFile;
- (NMPoint3)lookAtMe;
- (void)render;
- (void)epoch;
- (void)step;

@end
