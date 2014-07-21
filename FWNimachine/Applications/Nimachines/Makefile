APPNAME=Nimachines

CONFIG=Release
OBJROOT=/tmp/Xcode/$(APPNAME)/obj
SYMROOT=/tmp/Xcode/$(APPNAME)/sym
RESOURCES=$(SYMROOT)/$(CONFIG)/$(APPNAME).app/Contents/Resources/

APP=$(SYMROOT)/$(CONFIG)/$(APPNAME).app
DMG=$(HOME)/$(APPNAME).dmg

$(DMG): $(APP)
	test ! -f $@ || rm -f $@
	hdiutil create $@ -srcfolder $<

$(APP):
	xcodebuild -configuration $(CONFIG) -parallelizeTargets OBJROOT=$(OBJROOT) SYMROOT=$(SYMROOT)
	rsync -a --exclude ".svn" perceptron.d $(RESOURCES)/
	rsync -a --exclude ".svn" som.d $(RESOURCES)/

install: /Applications/$(APPNAME).app
/Applications/$(APPNAME).app: $(DMG)
	test ! -d $@ || sudo rm -rf $@
	hdiutil mount $<
	sudo cp -R /Volumes/$(APPNAME)/$(APPNAME).app $@
	hdiutil unmount /Volumes/$(APPNAME)
clean:
	xcodebuild clean
	-rm -rf $(APP) $(DMG)


.PHONY: clean install
