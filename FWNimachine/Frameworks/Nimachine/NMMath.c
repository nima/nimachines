
/*. ******* coding:utf-8 AUTOHEADER START v1.2 *******
 *. vim: fileencoding=utf-8 syntax=c sw=4 ts=4 et
 *. Copyrights:
 *.
 *.     © 2007-2009 Matt Harrington (Original Author to whom all credit should go to)
 *.     © 2007-2009 Nima Talebi <nima@autonomy.net.au>
 *.
 *. License:
 *.
 *.     MIT - The @PKG packages is available under the terms of
 *.     the MIT license.
 *.
 *. Homepage:
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
 *. LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *. PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *. LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 *. OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 *. ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *.
 *. ADAPTED M. STONE & T. PARKER DISCLAIMER: THIS SOFTWARE COULD RESULT IN INJURY
 *. AND/OR DEATH, AND AS SUCH, IT SHOULD NOT BE BUILT, INSTALLED OR USED BY ANYONE.
 *. ******* AUTOHEADER END v1.2 ******* */

/*
 *  Math.c
 *  SOM
 *
 *  Created by Nima on 3/11/08.
 *  Copyright 2008 Autonomy. All rights reserved.
 *
 */

#include "NMMath.h"
#include <string.h>
#include <stdio.h>

float euclideanDistance(int size, float *v1, float *v2) {
  float distance=0.0f;
  for(int i=0; i<size; i++)
    distance += powf(v2[i]-v1[i], 2);
  return sqrtf(distance);
}

float squaredDistance(int size, float *v1, float *v2) {
  float distance=0.0f;
  //printf(">>> %fx%fx%f vs %fx%fx%f\n", v1[0], v1[1], v1[2], v2[0], v2[1], v2[2]);
  //printf("xxx %d %d xxx", sizeof(v1), sizeof(v2));
  for(int i=0; i<size; i++)
    distance += powf(v2[i]-v1[i], 2);
  return distance;
}

float average(int size, float *v) {
  float average = 0.00f;
  for(int i=0; i<size; i++)
    average += v[i];
  return average/size;
}
