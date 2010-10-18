# Makefile for WoW-UI-Toolkit by Jamash (Kil'jaeden-US)
# Copyright 2010 Clement Cherlin

# Tools used:
# MSYS (32-bit) from http://www.mingw.org/wiki/MSYS
# Mingw-w64 (32-bit) from http://sourceforge.net/projects/mingw-w64/
# Cygwin from http://cygwin.com/
# Strawberry Perl (32-bit) from http://strawberryperl.com/

# Library used: StormLib from http://www.zezula.net/en/mpq/stormlib.html

# This makefile is intended to be run using MSYS make

VERSION = 1.02

CYGWIN=/c/cygwin/bin
CONSOLE=/bin/cmd
STRAWBERRY = /c/strawberry32/perl
PERL=$(STRAWBERRY)/bin/perl.exe
PP=$(STRAWBERRY)/site/bin/pp

STORMLIB_DIR = StormLib
STORMLIB_MAKEFILE = makefile.w32
STORMLIB_DLL = $(STORMLIB_DIR)/StormLib.dll

EXEFILES = $(STORMLIB_DLL) mpq.exe extract.exe extract-art.bat extract-code.bat
OTHERFILES = readme.txt
SRCFILES = Makefile stormlib.diff mpq.cpp extract.pl gpl.txt compiling.txt
ARCHIVE = Cata-UI-Toolkit

ZIPFILE = $(ARCHIVE)-$(VERSION).zip

TOOLPREFIX = i686-w64-mingw32-

G++ = $(TOOLPREFIX)g++
STRIP = $(TOOLPREFIX)strip
CFLAGS = --static
CFLAGS += -O
#CFLAGS += -ggdb

BETADIR = /d/Games/World of Warcraft Beta
PTRDIR = /d/Games/World of Warcraft Public Test
LIVEDIR = /d/Games/World of Warcraft

INSTALLDIRS = "$(BETADIR)" "$(PTRDIR)" "$(LIVEDIR)"


.PHONY: clean realclean stormclean all install code art patch diff

all: $(ZIPFILE)

patch: stormlib.diff
	patch -u -b -p1 -i stormlib.diff

diff: stormclean
	diff -N -a -u -r StormLib.original StormLib > stormlib.diff || true

mpq.exe: $(STORMLIB_DLL) mpq.cpp
	"$(G++)" $(CFLAGS) $^ -o $@
	"$(STRIP)" $@
	"$(CYGWIN)/chmod" 0755 $@
	"$(CYGWIN)/upx" -9 $@

extract.exe: extract.pl
	"$(PERL)" -c $^ && "$(PERL)" "$(PP)" $^ -o $@
	
$(STORMLIB_DLL):
	cd "$(STORMLIB_DIR)"; make -f "$(STORMLIB_MAKEFILE)"
	"$(CYGWIN)/chmod" 0755 $@
	"$(CYGWIN)/upx" -9 $@

realclean: clean stormclean

clean:
	rm -rf mpq.exe extract.exe "$(ARCHIVE)" "$(ZIPFILE)"

stormclean:
	cd "$(STORMLIB_DIR)"; make -f "$(STORMLIB_MAKEFILE)" clean

$(ZIPFILE): $(EXEFILES) $(SRCFILES) $(OTHERFILES)
	rm -f "$(ZIPFILE)"
	"$(CYGWIN)/chmod" 0755 $(EXEFILES)
	"$(CYGWIN)/chmod" 0644 $(SRCFILES) $(OTHERFILES)
	mkdir -p "$(ARCHIVE)/source"
	cp -p -u $(EXEFILES) $(OTHERFILES) $(ARCHIVE)
	cp -p -u $(SRCFILES) "$(ARCHIVE)/source"
	echo "Jamash's Unofficial Cataclysm UI Toolkit v$(VERSION)" | "$(CYGWIN)/zip" -z -9 -r "$(ZIPFILE)" "$(ARCHIVE)"

install: $(ZIPFILE)
#	rm -rf "$(LIVEDIR)/$(ARCHIVE)/"* "$(BETADIR)/$(ARCHIVE)"/* "$(PTRDIR)/$(ARCHIVE)"/*
	"$(CYGWIN)/unzip" -u -o "$(ZIPFILE)" -d "$(BETADIR)"
	"$(CYGWIN)/unzip" -u -o "$(ZIPFILE)" -d "$(PTRDIR)"
	"$(CYGWIN)/unzip" -u -o "$(ZIPFILE)" -d "$(LIVEDIR)"

code: install
	for i in $(INSTALLDIRS); do cd "$$i/$(ARCHIVE)" && $(CONSOLE) /Cextract-code.bat; done

art: install
	for i in $(INSTALLDIRS); do cd "$$i/$(ARCHIVE)" && $(CONSOLE) /Cextract-art.bat; done
