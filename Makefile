# ------------------------------------------------------------------------------
# Makefile.linux \ 32-bit Pinguino
# Regis Blanchot <rblanchot@gmail.com> 
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# directories
# ------------------------------------------------------------------------------
P32_TRUNK = /home/cede/projects/lumi/pinguino32-trunk
SRCDIR		=	.

PROC      = 32MX440F256H
BOARD     = PIC32_PINGUINO

OSDIR			=	linux
P32DIR		=	$(P32_TRUNK)/p32
P32CORE		=	$(P32_TRUNK)/$(OSDIR)/p32
BINDIR		=	$(P32CORE)/bin
INCDIR		=	$(P32DIR)/include
LKRDIR		=	$(P32DIR)/lkr
OBJDIR		=	$(P32DIR)/obj/non-free

INCLUDEDIRS	=	-I$(INCDIR)/non-free\
					-I$(INCDIR)/pinguino/core\
					-I$(INCDIR)/pinguino/libraries\
					-I$(LKRDIR)\
					-I$(OBJDIR)

LIBDIRS		=	-L$(OBJDIR)/usb

# ------------------------------------------------------------------------------
# commands
# ------------------------------------------------------------------------------

CC				=	$(BINDIR)/mips-elf-gcc
OBJC			=	$(BINDIR)/mips-elf-objcopy
LIBS			=	-lm -lgcc -lc
#CC				=	$(BINDIR)/mips-elf-g++
#LIBS			=	-lstdc++ -lm -lgcc -lc
RM				=	rm -f -v
CP				=	cp
MV				=	mv

# ------------------------------------------------------------------------------
# flags
# ------------------------------------------------------------------------------

#-fdollars-in-identifiers for ISRwrapper.S
CFLAGS		=	-fdollars-in-identifiers $(INCLUDEDIRS)

LDFLAGS		=	$(LIBDIRS) $(LIBS)

ELF_FLAGS	=	-O2 -EL -march=24kc\
					-msoft-float\
					-Wl,--defsym,_min_heap_size=8192\
					-Wl,-Map=$(SRCDIR)/output.map\
					-D __PIC32MX__ -D __$(PROC)__ -D $(BOARD)\
					-T$(LKRDIR)/procdefs.ld\
					-T$(LKRDIR)/elf32pic32mx.x

#-------------------------------------------------------------------------------
#	rules
#-------------------------------------------------------------------------------

all: clean link exec correct

clean:
	#----------------------------------------------------------------------------
	#	clean
	#----------------------------------------------------------------------------
	$(RM) $(SRCDIR)/main32.o
	$(RM) $(SRCDIR)/main32.elf
	$(RM) $(SRCDIR)/main32.hex
	$(RM) $(SRCDIR)/output.map

link:
	#----------------------------------------------------------------------------
	#	compile and link
	#----------------------------------------------------------------------------
	$(CC) $(ELF_FLAGS) $(LDFLAGS) $(CFLAGS) -o $(SRCDIR)/main32.elf $(SRCDIR)/main32.c\
		$(OBJDIR)/crt0.S\
		$(OBJDIR)/$(PROC).o\
		$(OBJDIR)/usb/libcdc.a\
		$(OBJDIR)/usb/libadb.a\
		$(LKRDIR)/ISRwrapper.S\
		$(INCDIR)/non-free/p32xxxx.h\
		$(LIBS)

exec:
	#----------------------------------------------------------------------------
	#	exec
	#----------------------------------------------------------------------------
	$(OBJC) -O ihex $(SRCDIR)/main32.elf $(SRCDIR)/main32.hex

correct:
	#----------------------------------------------------------------------------
	#	correct
	#----------------------------------------------------------------------------
	grep --binary --invert-match '^:040000059D006000FA' $(SRCDIR)/main32.hex > $(SRCDIR)/temp.hex
	mv $(SRCDIR)/temp.hex $(SRCDIR)/main32.hex
  
upload:
	LD_LIBRARY_PATH=$(BINDIR) $(BINDIR)/ubw32 -w $(SRCDIR)/main32.hex -r -n
      

