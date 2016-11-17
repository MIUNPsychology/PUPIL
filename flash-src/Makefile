MXMLC_BIN=mxmlc
MXMLC_FLAGS=-static-link-runtime-shared-libraries
MXMLC=$(MXMLC_BIN) $(MXMLC_FLAGS)
DIST_ROOT=../dist/PUPIL
DIST_FLASH=$(DIST_ROOT)/flash

build: reaction.swf teacher.swf

reaction.swf:
	$(MXMLC) reaction.as

teacher.swf:
	$(MXMLC) teacher.as

clean:
	rm -f *.swf

distclean: clean
	rm -rf $(DIST_ROOT)

dist: build
	mkdir -p $(DIST_FLASH)
	cp -rfv static-files/* $(DIST_FLASH)
	cp reaction.swf $(DIST_FLASH)
	cp teacher.swf $(DIST_FLASH)

all: clean dist

