
#. ******* coding:utf-8 AUTOHEADER START v1.2 *******
#. vim: fileencoding=utf-8 syntax=Makefile sw=4 ts=4 et
#.
#. © 2007-2009 Nima Talebi <nima@autonomy.net.au>
#.
#. This file is part of the Nimachine Suite.
#.
#.     Nimachine is free software: you can redistribute it and/or modify
#.     it under the terms of the GNU General Public License as published by
#.     the Free Software Foundation, either version 3 of the License, or
#.     (at your option) any later version.
#.
#.     Nimachine is distributed in the hope that it will be useful,
#.     but WITHOUT ANY WARRANTY; without even the implied warranty of
#.     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#.     GNU General Public License for more details.
#.
#.     You should have received a copy of the GNU General Public License
#.     along with Nimachine.  If not, see <http://www.gnu.org/licenses/>.
#.
#. THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#. WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#. MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#. EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#. INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#. LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#. PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#. LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#. OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#. ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#.
#. ADAPTED M. STONE & T. PARKER DISCLAIMER: THIS SOFTWARE COULD RESULT IN INJURY
#. AND/OR DEATH, AND AS SUCH, IT SHOULD NOT BE BUILT, INSTALLED OR USED BY ANYONE.
#. ******* AUTOHEADER END v1.2 *******

FRAMEWORKS := NXTMindstorm Nimachine
APPLICATIONS := Nimachines BenderBot
CONFIG := Release

SDK := macosx10.6

info:
	@echo "You do not need to run as the superuser, or via sudo, as long as you do the"
	@echo "following (as the superuser) in preparation..."
	@echo ""
	@echo "    install -o $(USER) -m 755 -d /Library/Frameworks/NXTMindstorm.framework"
	@echo "    install -o $(USER) -m 755 -d /Library/Frameworks/Nimachine.framework"
	@echo ""
	@echo "Next, build and install the Nimachine suite..."
	@echo ""
	@echo "    make build"
	@echo "    make install"
	@echo ""
	@echo "To uninstall, simply remove the following..."
	@echo ""
	@echo "    make uninstall"
	@echo ""
	@echo "...which is equivalent to..."
	@echo ""
	@echo "    rm -rf /Library/Frameworks/NXTMindstorm.framework"
	@echo "    rm -rf /Library/Frameworks/Nimachine.framework"
	@echo "    rm -rf /Users/$(HOME)/Nimachines"
	@echo ""

ah:
	PKG=Nimachine find . -name '*.[chm]' -exec ah {} \;

build:
	$(foreach \
		F, \
		$(FRAMEWORKS), \
		pushd Frameworks/$(F); \
		xcodebuild \
			-sdk $(SDK) \
			-parallelizeTargets \
			-configuration $(CONFIG) \
			build; \
		popd; \
	)
	$(foreach \
		A, \
		$(APPLICATIONS), \
		pushd Applications/$(A); \
		xcodebuild \
			-sdk $(SDK) \
			-parallelizeTargets \
			-configuration $(CONFIG) \
			build; \
		popd; \
	)


uninstall:
	rm -rf /Library/Frameworks/NXTMindstorm.framework/*
	rm -rf /Library/Frameworks/Nimachine.framework/*
	rm -rf /Users/$(HOME)/Nimachines

install:
	$(foreach \
		F, \
		$(FRAMEWORKS), \
		pushd Frameworks/$(F); \
		xcodebuild \
			-sdk $(SDK) \
			-parallelizeTargets \
			-configuration $(CONFIG) \
			DEPLOYMENT_LOCATION=YES \
			SKIP_INSTALL=NO \
			DSTROOT=/ \
			install; \
		popd; \
	)
	$(foreach \
		A, \
		$(APPLICATIONS), \
		pushd Applications/$(A); \
		xcodebuild \
			-sdk $(SDK) \
			-parallelizeTargets \
			-configuration $(CONFIG) \
			DEPLOYMENT_LOCATION=YES \
			SKIP_INSTALL=NO \
			DSTROOT=/ \
			INSTALL_PATH=$(HOME)/Applications \
			install; \
		popd; \
	)

clean:
	$(foreach \
		F, \
		$(FRAMEWORKS), \
		rm -rf Frameworks/$(F)/build \
	)
	$(foreach \
		A, \
		$(APPLICATIONS), \
		rm -rf Applications/$(A)/build \
	)


dist: Nimachine.dmg
	hdiutil internet-enable -yes $<

.PHONY: dist clean install build
