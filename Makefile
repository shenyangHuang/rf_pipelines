# Makefile.local must define the following variables
#   LIBDIR      install dir for C++ libraries
#   INCDIR      install dir for C++ headers
#   CPP         C++ compiler command line
#   CPP_LFLAGS  extra linker flags when creating a .so or executable file from .o files
#
# See site/Makefile.local.* for examples.

include Makefile.local

INCFILES=rf_pipelines.hpp rf_pipelines_internals.hpp

OFILES=chime_file_stream.o \
	detrenders.o \
	misc.o \
	psrfits_stream.o \
	wi_run.o \
	wraparound_buf.o

LIBS=

ifeq ($(HAVE_PSRFITS),y)
	CPP += -DHAVE_PSRFITS
	LIBS += -lpsrfits_utils -lcfitsio
endif

ifeq ($(HAVE_CH_FRB_IO),y)
	CPP += -DHAVE_CH_FRB_IO
	LIBS += -lch_frb_io -lhdf5
endif

all: librf_pipelines.so rf_pipelines_c.so run-unit-tests

install: librf_pipelines.so rf_pipelines_c.so
	cp -f $(INCFILES) $(INCDIR)/
	cp -f librf_pipelines.so $(LIBDIR)/
	cp -f rf_pipelines_c.so $(PYDIR)/

uninstall:
	for f in $(INCFILES); do rm -f $(INCDIR)/$$f; done
	rm -f $(LIBDIR)/librf_pipelines.so
	rm -f $(PYDIR)/rf_pipelines_c.so

clean:
	rm -f *~ *.o *.so run-unit-tests

%.o: %.cpp $(INCFILES)
	$(CPP) -c -o $@ $<

librf_pipelines.so: $(OFILES)
	$(CPP) $(CPP_LFLAGS) -shared -o $@ $^ $(LIBS)

rf_pipelines_c.so: rf_pipelines_c.cpp $(INCFILES) librf_pipelines.so
	$(CPP) $(CPP_LFLAGS) -Wno-strict-aliasing -shared -o $@ $< -lrf_pipelines $(LIBS)

run-unit-tests: run-unit-tests.o librf_pipelines.so
	$(CPP) $(CPP_LFLAGS) -o $@ $< -lrf_pipelines
