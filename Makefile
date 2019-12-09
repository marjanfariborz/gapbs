# See LICENSE.txt for license details.

CXX_FLAGS += -std=c++11 -O3 -Wall -DM5OP_ADDR=0xFFFF0000
PAR_FLAG = -fopenmp
CC = gcc

CCOMPILE = $(CC)  -c $(C_INC) $(CFLAGS)
#COMMON =  /home/fariborz/base_experiment/gem5/util/m5
#OBJS = ${COMMON}/m5.o  ${COMMON}/m5op_x86.o

COMMON = src
GEM5DIR = /home/fariborz/base_experiment/gem5

ifneq (,$(findstring icpc,$(CXX)))
	PAR_FLAG = -openmp
endif

ifneq (,$(findstring sunCC,$(CXX)))
	CXX_FLAGS = -std=c++11 -xO3 -m64 -xtarget=native
	PAR_FLAG = -xopenmp
endif

ifneq ($(SERIAL), 1)
	CXX_FLAGS += $(PAR_FLAG)
endif

KERNELS = bc bfs cc cc_sv pr sssp tc
SUITE = $(KERNELS) converter

.PHONY: all
all: $(SUITE)

${COMMON}/hooks.o: ${COMMON}/hooks.c
	 cd ${COMMON}; ${CCOMPILE} hooks.c -Wno-implicit-function-declaration -I ${GEM5DIR}/include/
${COMMON}/m5op_x86.o: ${GEM5DIR}/util/m5/m5op_x86.S
	cd ${COMMON}; gcc -O2 -DM5OP_ADDR=0xFFFF0000 -I ${GEM5DIR}/include/ -o ../$@ -c  ${GEM5DIR}/util/m5/m5op_x86.S
${COMMON}/m5_mmap.o: ${GEM5DIR}/util/m5/m5_mmap.c
	cd ${COMMON}; ${CCOMPILE} ${GEM5DIR}/util/m5/m5_mmap.c -Wno-implicit-function-declaration -I ${GEM5DIR}/include/
#	cd ${COMMON}; ${CCOMPILE} -DM5OP_ADDR=0xFFFF0000  -I ${GEM5DIR}/include/ -o ../$@ -c  ${GEM5DIR}/util/m5/m5_mmap.c
OBJS = 
ifeq (${HOOKS}, 1)
        OBJS += ${COMMON}/hooks.o ${COMMON}/m5op_x86.o #${COMMON}/m5_mmap.o
endif

#ifeq (${HOOKS}, 1)
#	CXX_FLAGS += -DHOOKS
#endif


% : src/%.cc src/*.h $(OBJS) 
	$(CXX) $(CXX_FLAGS) $< -o $@ ${GEM5DIR}/util/m5/m5_mmap.c  $(OBJS) -no-pie

# Testing
include test/test.mk

# Benchmark Automation
include benchmark/bench.mk


.PHONY: clean
clean:
	rm -f $(SUITE) test/out/*
