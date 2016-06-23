# Makefile.local must define the following variables
#   LIBDIR      install dir for C++ libraries
#   INCDIR      install dir for C++ headers
#   CPP         C++ compiler command line
#   CPP_LFLAGS  extra linker flags when creating a .so or executable file from .o files
#
# See site/Makefile.local.* for examples.

include Makefile.local

INCFILES=rf_pipelines.hpp rf_pipelines_internals.hpp

OFILES=detrenders.o \
	wi_run.o \
	wraparound_buf.o

all: librf_pipelines.so run-unit-tests

install: librf_pipelines.so
	cp -f $(INCFILES) $(INCDIR)/
	cp -f librf_pipelines.so $(LIBDIR)/

uninstall:
	for f in $(INCFILES); do rm -f $(INCDIR)/$$f; done
	rm -f $(LIBDIR)/librf_pipelines.so

clean:
	rm -f *~ *.o *.so

%.o: %.cpp $(INCFILES)
	$(CPP) -c -o $@ $<

librf_pipelines.so: $(OFILES)
	$(CPP) $(CPP_LFLAGS) -shared -o $@ $^

run-unit-tests: run-unit-tests.o librf_pipelines.so
	$(CPP) $(CPP_LFLAGS) -o $@ $< -lrf_pipelines
