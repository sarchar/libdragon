all: libdragon

V = 1  # force verbose (at least until we have converted all sub-Makefiles)
SOURCE_DIR = src
BUILD_DIR = build
include n64.mk
INSTALLDIR = $(N64_INST)

# N64_INCLUDEDIR is normally (when building roms) a path to the installed include files
# (e.g. /opt/libdragon/mips64-elf/include), set in n64.mk
# When building libdragon, override it to use the source include files instead (./include)
N64_INCLUDEDIR = $(CURDIR)/include

LIBDRAGON_CFLAGS = -I$(CURDIR)/src -ffile-prefix-map=$(CURDIR)=libdragon

# Activate N64 toolchain for libdragon build
libdragon: CC=$(N64_CC)
libdragon: CXX=$(N64_CXX)
libdragon: AS=$(N64_AS)
libdragon: LD=$(N64_LD)
libdragon: CFLAGS+=$(N64_CFLAGS) $(LIBDRAGON_CFLAGS)
libdragon: CXXFLAGS+=$(N64_CXXFLAGS) $(LIBDRAGON_CFLAGS)
libdragon: ASFLAGS+=$(N64_ASFLAGS) $(LIBDRAGON_CFLAGS)
libdragon: RSPASFLAGS+=$(N64_RSPASFLAGS) $(LIBDRAGON_CFLAGS)
libdragon: LDFLAGS+=$(N64_LDFLAGS)
libdragon: libdragon.a libdragonsys.a

libdragonsys.a: $(BUILD_DIR)/system.o

LIBDRAGON_OBJS += \
             $(BUILD_DIR)/n64sys.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/backtrace.o \
			 $(BUILD_DIR)/fmath.o $(BUILD_DIR)/inthandler.o $(BUILD_DIR)/entrypoint.o \
			 $(BUILD_DIR)/debug.o $(BUILD_DIR)/debugcpp.o $(BUILD_DIR)/usb.o $(BUILD_DIR)/libcart/cart.o $(BUILD_DIR)/fatfs/ff.o \
			 $(BUILD_DIR)/fatfs/ffunicode.o $(BUILD_DIR)/rompak.o $(BUILD_DIR)/dragonfs.o \
			 $(BUILD_DIR)/audio.o $(BUILD_DIR)/display.o $(BUILD_DIR)/surface.o \
			 $(BUILD_DIR)/console.o $(BUILD_DIR)/asset.o \
			 $(BUILD_DIR)/compress/lzh5.o $(BUILD_DIR)/compress/lz4_dec.o $(BUILD_DIR)/compress/lz4_dec_fast.o $(BUILD_DIR)/compress/ringbuf.o \
			 $(BUILD_DIR)/compress/aplib_dec_fast.o $(BUILD_DIR)/compress/aplib_dec.o \
			 $(BUILD_DIR)/compress/shrinkler_dec_fast.o $(BUILD_DIR)/compress/shrinkler_dec.o \
			 $(BUILD_DIR)/joybus.o $(BUILD_DIR)/joybus_accessory.o $(BUILD_DIR)/pixelfx.o \
			 $(BUILD_DIR)/joypad.o $(BUILD_DIR)/joypad_accessory.o \
			 $(BUILD_DIR)/controller.o $(BUILD_DIR)/rtc.o \
			 $(BUILD_DIR)/eeprom.o $(BUILD_DIR)/eepromfs.o $(BUILD_DIR)/mempak.o \
			 $(BUILD_DIR)/tpak.o $(BUILD_DIR)/graphics.o $(BUILD_DIR)/rdp.o \
			 $(BUILD_DIR)/rsp.o $(BUILD_DIR)/rsp_crash.o \
			 $(BUILD_DIR)/inspector.o $(BUILD_DIR)/sprite.o \
			 $(BUILD_DIR)/dma.o $(BUILD_DIR)/timer.o \
			 $(BUILD_DIR)/exception.o $(BUILD_DIR)/do_ctors.o \
			 $(BUILD_DIR)/video/mpeg2.o $(BUILD_DIR)/video/yuv.o \
			 $(BUILD_DIR)/video/profile.o $(BUILD_DIR)/video/throttle.o \
			 $(BUILD_DIR)/video/rsp_yuv.o $(BUILD_DIR)/video/rsp_mpeg1.o \
			 $(BUILD_DIR)/rspq/rspq.o $(BUILD_DIR)/rspq/rsp_queue.o \
			 $(BUILD_DIR)/rspq/rspq_profile.o $(BUILD_DIR)/rspq/rsp_profile.o \
			 $(BUILD_DIR)/rdpq/rdpq.o $(BUILD_DIR)/rdpq/rsp_rdpq.o \
			 $(BUILD_DIR)/rdpq/rdpq_debug.o $(BUILD_DIR)/rdpq/rdpq_tri.o \
			 $(BUILD_DIR)/rdpq/rdpq_rect.o $(BUILD_DIR)/rdpq/rdpq_mode.o \
			 $(BUILD_DIR)/rdpq/rdpq_sprite.o $(BUILD_DIR)/rdpq/rdpq_tex.o \
			 $(BUILD_DIR)/rdpq/rdpq_attach.o $(BUILD_DIR)/rdpq/rdpq_font.o \
			 $(BUILD_DIR)/rdpq/rdpq_text.o $(BUILD_DIR)/rdpq/rdpq_paragraph.o \
			 $(BUILD_DIR)/surface.o $(BUILD_DIR)/GL/gl.o \
			 $(BUILD_DIR)/GL/lighting.o $(BUILD_DIR)/GL/matrix.o \
			 $(BUILD_DIR)/GL/primitive.o $(BUILD_DIR)/GL/query.o \
			 $(BUILD_DIR)/GL/rendermode.o $(BUILD_DIR)/GL/texture.o \
			 $(BUILD_DIR)/GL/array.o $(BUILD_DIR)/GL/pixelrect.o \
			 $(BUILD_DIR)/GL/obj_map.o $(BUILD_DIR)/GL/list.o \
			 $(BUILD_DIR)/GL/buffer.o $(BUILD_DIR)/GL/rsp_gl.o \
			 $(BUILD_DIR)/GL/rsp_gl_pipeline.o $(BUILD_DIR)/GL/glu.o \
			 $(BUILD_DIR)/GL/cpu_pipeline.o $(BUILD_DIR)/GL/rsp_pipeline.o \
			 $(BUILD_DIR)/dlfcn.o $(BUILD_DIR)/model64.o \
			 $(BUILD_DIR)/bb/skc.o $(BUILD_DIR)/bb/nand.o $(BUILD_DIR)/bb/bbfs.o \
			 $(BUILD_DIR)/rust_bindings.o

include $(SOURCE_DIR)/audio/libdragon.mk

libdragon.a: $(LIBDRAGON_OBJS)

%.a:
	@echo "    [AR] $@"
	$(N64_AR) -rcs -o $@ $^

examples:
	$(MAKE) -C examples
# We are unable to clean examples built with n64.mk unless we
# install it first
examples-clean: $(INSTALLDIR)/include/n64.mk
	$(MAKE) -C examples clean

doxygen-api: doxygen-public.conf
	doxygen doxygen-public.conf

tools:
	$(MAKE) -C tools
tools-install:
	$(MAKE) -C tools install
tools-clean:
	$(MAKE) -C tools clean

install-mk: $(INSTALLDIR)/include/n64.mk

$(INSTALLDIR)/include/n64.mk: n64.mk
# Always update timestamp of n64.mk. This make sure that further targets
# depending on install-mk won't always try to re-install it.
	mkdir -p $(INSTALLDIR)/include
	install -cv -m 0644 n64.mk $(INSTALLDIR)/include/n64.mk

install: install-mk libdragon
	mkdir -p $(INSTALLDIR)/$(N64_TRIPLET)/lib
	mkdir -p $(INSTALLDIR)/$(N64_TRIPLET)/include/GL
	install -Cv -m 0644 libdragon.a $(INSTALLDIR)/$(N64_TRIPLET)/lib/libdragon.a
	install -Cv -m 0644 n64.ld $(INSTALLDIR)/$(N64_TRIPLET)/lib/n64.ld
	install -Cv -m 0644 dso.ld $(INSTALLDIR)/$(N64_TRIPLET)/lib/dso.ld
	install -Cv -m 0644 rsp.ld $(INSTALLDIR)/$(N64_TRIPLET)/lib/rsp.ld
	install -Cv -m 0644 libdragonsys.a $(INSTALLDIR)/$(N64_TRIPLET)/lib/libdragonsys.a
	install -Cv -m 0644 include/n64types.h $(INSTALLDIR)/$(N64_TRIPLET)/include/n64types.h
	install -Cv -m 0644 include/pputils.h $(INSTALLDIR)/$(N64_TRIPLET)/include/pputils.h
	install -Cv -m 0644 include/n64sys.h $(INSTALLDIR)/$(N64_TRIPLET)/include/n64sys.h
	install -Cv -m 0644 include/fmath.h $(INSTALLDIR)/$(N64_TRIPLET)/include/fmath.h
	install -Cv -m 0644 include/backtrace.h $(INSTALLDIR)/$(N64_TRIPLET)/include/backtrace.h
	install -Cv -m 0644 include/cop0.h $(INSTALLDIR)/$(N64_TRIPLET)/include/cop0.h
	install -Cv -m 0644 include/cop1.h $(INSTALLDIR)/$(N64_TRIPLET)/include/cop1.h
	install -Cv -m 0644 include/mi.h $(INSTALLDIR)/$(N64_TRIPLET)/include/mi.h
	install -Cv -m 0644 include/interrupt.h $(INSTALLDIR)/$(N64_TRIPLET)/include/interrupt.h
	install -Cv -m 0644 include/dma.h $(INSTALLDIR)/$(N64_TRIPLET)/include/dma.h
	install -Cv -m 0644 include/dragonfs.h $(INSTALLDIR)/$(N64_TRIPLET)/include/dragonfs.h
	install -Cv -m 0644 include/asset.h $(INSTALLDIR)/$(N64_TRIPLET)/include/asset.h
	install -Cv -m 0644 include/audio.h $(INSTALLDIR)/$(N64_TRIPLET)/include/audio.h
	install -Cv -m 0644 include/surface.h $(INSTALLDIR)/$(N64_TRIPLET)/include/surface.h
	install -Cv -m 0644 include/display.h $(INSTALLDIR)/$(N64_TRIPLET)/include/display.h
	install -Cv -m 0644 include/debug.h $(INSTALLDIR)/$(N64_TRIPLET)/include/debug.h
	install -Cv -m 0644 include/debugcpp.h $(INSTALLDIR)/$(N64_TRIPLET)/include/debugcpp.h
	install -Cv -m 0644 include/usb.h $(INSTALLDIR)/$(N64_TRIPLET)/include/usb.h
	install -Cv -m 0644 include/console.h $(INSTALLDIR)/$(N64_TRIPLET)/include/console.h
	install -Cv -m 0644 include/joybus.h $(INSTALLDIR)/$(N64_TRIPLET)/include/joybus.h
	install -Cv -m 0644 include/joybus_accessory.h $(INSTALLDIR)/$(N64_TRIPLET)/include/joybus_accessory.h
	install -Cv -m 0644 include/pixelfx.h $(INSTALLDIR)/$(N64_TRIPLET)/include/pixelfx.h
	install -Cv -m 0644 include/joypad.h $(INSTALLDIR)/$(N64_TRIPLET)/include/joypad.h
	install -Cv -m 0644 include/mempak.h $(INSTALLDIR)/$(N64_TRIPLET)/include/mempak.h
	install -Cv -m 0644 include/controller.h $(INSTALLDIR)/$(N64_TRIPLET)/include/controller.h
	install -Cv -m 0644 include/rtc.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rtc.h
	install -Cv -m 0644 include/eeprom.h $(INSTALLDIR)/$(N64_TRIPLET)/include/eeprom.h
	install -Cv -m 0644 include/eepromfs.h $(INSTALLDIR)/$(N64_TRIPLET)/include/eepromfs.h
	install -Cv -m 0644 include/tpak.h $(INSTALLDIR)/$(N64_TRIPLET)/include/tpak.h
	install -Cv -m 0644 include/sprite.h $(INSTALLDIR)/$(N64_TRIPLET)/include/sprite.h
	install -Cv -m 0644 include/graphics.h $(INSTALLDIR)/$(N64_TRIPLET)/include/graphics.h
	install -Cv -m 0644 include/rdp.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdp.h
	install -Cv -m 0644 include/rsp.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp.h
	install -Cv -m 0644 include/timer.h $(INSTALLDIR)/$(N64_TRIPLET)/include/timer.h
	install -Cv -m 0644 include/exception.h $(INSTALLDIR)/$(N64_TRIPLET)/include/exception.h
	install -Cv -m 0644 include/system.h $(INSTALLDIR)/$(N64_TRIPLET)/include/system.h
	install -Cv -m 0644 include/dir.h $(INSTALLDIR)/$(N64_TRIPLET)/include/dir.h
	install -Cv -m 0644 include/libdragon.h $(INSTALLDIR)/$(N64_TRIPLET)/include/libdragon.h
	install -Cv -m 0644 include/ucode.S $(INSTALLDIR)/$(N64_TRIPLET)/include/ucode.S
	install -Cv -m 0644 include/rsp.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp.inc
	install -Cv -m 0644 include/rsp_dma.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_dma.inc
	install -Cv -m 0644 include/rsp_assert.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_assert.inc
	install -Cv -m 0644 include/rsp_highpri.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_highpri.inc
	install -Cv -m 0644 include/mpeg2.h $(INSTALLDIR)/$(N64_TRIPLET)/include/mpeg2.h
	install -Cv -m 0644 include/yuv.h $(INSTALLDIR)/$(N64_TRIPLET)/include/yuv.h
	install -Cv -m 0644 include/throttle.h $(INSTALLDIR)/$(N64_TRIPLET)/include/throttle.h
	install -Cv -m 0644 include/mixer.h $(INSTALLDIR)/$(N64_TRIPLET)/include/mixer.h
	install -Cv -m 0644 include/samplebuffer.h $(INSTALLDIR)/$(N64_TRIPLET)/include/samplebuffer.h
	install -Cv -m 0644 include/wav64.h $(INSTALLDIR)/$(N64_TRIPLET)/include/wav64.h
	install -Cv -m 0644 include/xm64.h $(INSTALLDIR)/$(N64_TRIPLET)/include/xm64.h
	install -Cv -m 0644 include/ym64.h $(INSTALLDIR)/$(N64_TRIPLET)/include/ym64.h
	install -Cv -m 0644 include/ay8910.h $(INSTALLDIR)/$(N64_TRIPLET)/include/ay8910.h
	install -Cv -m 0644 include/rspq.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rspq.h
	install -Cv -m 0644 include/rspq_constants.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rspq_constants.h
	install -Cv -m 0644 include/rspq_profile.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rspq_profile.h
	install -Cv -m 0644 include/rsp_queue.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_queue.inc
	install -Cv -m 0644 include/rdpq.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq.h
	install -Cv -m 0644 include/rdpq_tri.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_tri.h
	install -Cv -m 0644 include/rdpq_rect.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_rect.h
	install -Cv -m 0644 include/rdpq_attach.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_attach.h
	install -Cv -m 0644 include/rdpq_mode.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_mode.h
	install -Cv -m 0644 include/rdpq_tex.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_tex.h
	install -Cv -m 0644 include/rdpq_sprite.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_sprite.h
	install -Cv -m 0644 include/rdpq_font.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_font.h
	install -Cv -m 0644 include/rdpq_text.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_text.h
	install -Cv -m 0644 include/rdpq_paragraph.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_paragraph.h
	install -Cv -m 0644 include/rdpq_debug.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_debug.h
	install -Cv -m 0644 include/rdpq_macros.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_macros.h
	install -Cv -m 0644 include/rdpq_constants.h $(INSTALLDIR)/$(N64_TRIPLET)/include/rdpq_constants.h
	install -Cv -m 0644 include/rsp_rdpq.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_rdpq.inc
	install -Cv -m 0644 include/rsp_rdpq_tri.inc $(INSTALLDIR)/$(N64_TRIPLET)/include/rsp_rdpq_tri.inc
	install -Cv -m 0644 include/surface.h $(INSTALLDIR)/$(N64_TRIPLET)/include/surface.h
	install -Cv -m 0644 include/GL/gl.h $(INSTALLDIR)/$(N64_TRIPLET)/include/GL/gl.h
	install -Cv -m 0644 include/GL/gl_enums.h $(INSTALLDIR)/$(N64_TRIPLET)/include/GL/gl_enums.h
	install -Cv -m 0644 include/GL/gl_integration.h $(INSTALLDIR)/$(N64_TRIPLET)/include/GL/gl_integration.h
	install -Cv -m 0644 include/GL/glu.h $(INSTALLDIR)/$(N64_TRIPLET)/include/GL/glu.h
	install -Cv -m 0644 include/dlfcn.h $(INSTALLDIR)/$(N64_TRIPLET)/include/dlfcn.h
	install -Cv -m 0644 include/model64.h $(INSTALLDIR)/$(N64_TRIPLET)/include/model64.h
	install -Cv -m 0644 include/skc.h $(INSTALLDIR)/$(N64_TRIPLET)/include/skc.h
	install -Cv -m 0644 include/nand.h $(INSTALLDIR)/$(N64_TRIPLET)/include/nand.h
	install -Cv -m 0644 include/bbfs.h $(INSTALLDIR)/$(N64_TRIPLET)/include/bbfs.h
	mkdir -p $(INSTALLDIR)/$(N64_TRIPLET)/include/libcart
	install -Cv -m 0644 src/libcart/cart.h $(INSTALLDIR)/$(N64_TRIPLET)/include/libcart/cart.h
	mkdir -p $(INSTALLDIR)/$(N64_TRIPLET)/include/fatfs
	install -Cv -m 0644 src/fatfs/diskio.h $(INSTALLDIR)/$(N64_TRIPLET)/include/fatfs/diskio.h
	install -Cv -m 0644 src/fatfs/ff.h $(INSTALLDIR)/$(N64_TRIPLET)/include/fatfs/ff.h
	install -Cv -m 0644 src/fatfs/ffconf.h $(INSTALLDIR)/$(N64_TRIPLET)/include/fatfs/ffconf.h
	

clean:
	rm -f *.o *.a
	rm -rf $(CURDIR)/build

test:
	$(MAKE) -C tests

test-clean: install-mk
	$(MAKE) -C tests clean

clobber: clean examples-clean tools-clean test-clean

.PHONY : clobber clean doxygen-api examples examples-clean tools tools-clean tools-install test test-clean install-mk

# Automatic dependency tracking
-include $(wildcard $(BUILD_DIR)/*.d) $(wildcard $(BUILD_DIR)/*/*.d)
