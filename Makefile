###############################################################################
#                                  MAKEFILE                                   #
###############################################################################

# Be silent per default, but 'make V=1' will show all compiler calls.
ifneq ($(V),1)
Q		 := @
NULL := 2>/dev/null
endif

###############################################################################
# Binary name

BINARY = firmware

###############################################################################
# Paths

CURRENT_DIR        := $(notdir $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
PRJ_ROOT           := 

BUILD_DIR          := build
LIB_DIR            := lib
OUTPUT_DIR         := output
SRC_DIR            := source
TOOLS_DIR          := tools
VSCODE_DIR         := .vscode
BUILD_SCRIPTS_DIR  := $(BUILD_DIR)/scripts
OPENCM3_DIR        := $(LIB_DIR)/libopencm3
OUTPUT_OBJECTS_DIR := ${OUTPUT_DIR}/objects

TOOL_CXX_PROPS_GEN_DIR := ${TOOLS_DIR}/cxx_props_gen

###############################################################################
# Source files

# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

SRC_C   := $(call rwildcard,$(SRC_DIR)/,*.c)
SRC_CPP := $(call rwildcard,$(SRC_DIR)/,*.cpp)
SRC_ASM := $(call rwildcard,$(SRC_DIR)/,*.s)
SRCS    := $(SRC_C) $(SRC_CPP) $(SRC_ASM) 

OBJS    := $(addprefix $(OUTPUT_OBJECTS_DIR)/,$(addsuffix .o,$(basename $(SRCS))))
DEPS    := $(OBJS:.o=.d)

###############################################################################
# Basic Device Setup

LIBNAME     = opencm3_stm32f1
DEFINES    += STM32F1
ARCH_FLAGS  = -mthumb -mcpu=cortex-m3

###############################################################################
# Linkerscript

LDSCRIPT   = $(BUILD_DIR)/linkerscript.ld
LDLIBS    += -l$(LIBNAME)
LDFLAGS   += -L$(OPENCM3_DIR)/lib

###############################################################################
# Includes

SRC_HPP := $(call rwildcard,$(SRC_DIR)/,*.hpp)
SRC_H   := $(call rwildcard,$(SRC_DIR)/,*.h)
INCLUDE_DIRS := $(dir $(SRC_HPP)) $(dir $(SRC_H)) $(OPENCM3_DIR)/include

DEFS +=  $(addprefix -I,$(INCLUDE_DIRS))

###############################################################################
# Executables

PREFIX	?= arm-none-eabi-

CC      := $(PREFIX)gcc
CXX     := $(PREFIX)g++
LD      := $(PREFIX)gcc
AR      := $(PREFIX)ar
AS      := $(PREFIX)as
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
GDB     := $(PREFIX)gdb
STFLASH  = $(shell which st-flash)
OPT     := -Os
DEBUG   := -ggdb3
CSTD    ?= -std=c99

###############################################################################
# Defines

DEFINES ?=
DEFS    += $(addprefix -D,$(DEFINES))

###############################################################################
# C flags

TGT_CFLAGS += $(OPT) $(CSTD) $(DEBUG)
TGT_CFLAGS += $(ARCH_FLAGS)
TGT_CFLAGS += -Wextra -Wshadow -Wimplicit-function-declaration
TGT_CFLAGS += -Wredundant-decls -Wstrict-prototypes
TGT_CFLAGS += -fno-common -ffunction-sections -fdata-sections

###############################################################################
# C++ flags

TGT_CXXFLAGS += $(OPT) $(CXXSTD) $(DEBUG)
TGT_CXXFLAGS += $(ARCH_FLAGS)
TGT_CXXFLAGS += -Wextra -Wshadow -Wredundant-decls  -Weffc++
TGT_CXXFLAGS += -fno-common -ffunction-sections -fdata-sections

###############################################################################
# C & C++ preprocessor common flags

TGT_CPPFLAGS += -MD
TGT_CPPFLAGS += -Wall -Wundef
TGT_CPPFLAGS += $(DEFS)

###############################################################################
# Linker flags

TGT_LDFLAGS += --static -nostartfiles
TGT_LDFLAGS += -T$(LDSCRIPT)
TGT_LDFLAGS += $(ARCH_FLAGS) $(DEBUG)
TGT_LDFLAGS += -Wl,-Map=$(*).map -Wl,--cref
TGT_LDFLAGS += -Wl,--gc-sections

ifeq ($(V),99)
TGT_LDFLAGS += -Wl,--print-gc-sections
endif

###############################################################################
# Used libraries

LDLIBS += -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group

###############################################################################
###############################################################################
###############################################################################

###############################################################################
# Build targets

.SUFFIXES: .elf .bin .hex .srec .list .map .images
.SECONDEXPANSION:
.SECONDARY:

all: $(OUTPUT_DIR) $(OUTPUT_OBJECTS_DIR) elf bin

OUTPUT_BINARY := $(OUTPUT_DIR)/$(BINARY)

elf: $(OUTPUT_BINARY).elf
bin: $(OUTPUT_BINARY).bin
hex: $(OUTPUT_BINARY).hex
srec: $(OUTPUT_BINARY).srec
list: $(OUTPUT_BINARY).list
GENERATED_BINARIES=$(OUTPUT_BINARY).elf $(OUTPUT_BINARY).bin $(OUTPUT_BINARY).hex $(OUTPUT_BINARY).srec $(OUTPUT_BINARY).list $(BINARY).map

images: $(OUTPUT_BINARY).images
flash: $(OUTPUT_BINARY).flash

$(OUTPUT_DIR):
	$(Q)#   $(OUTPUT_DIR) created
	@mkdir -p $(OUTPUT_DIR)

$(OUTPUT_OBJECTS_DIR):
	$(Q)#   $(OUTPUT_OBJECTS_DIR) created
	@mkdir -p $(OUTPUT_OBJECTS_DIR)

$(OPENCM3_DIR)/lib/lib$(LIBNAME).a:
ifeq (,$(wildcard $@))
	$(warning lib$(LIBNAME).a not found, attempting to rebuild in $(OPENCM3_DIR))
	bash -c "make -C $(OPENCM3_DIR)"
endif

%.images: %.bin %.hex %.srec %.list %.map
	$(Q)# *** $* images generated ***

$(OUTPUT_BINARY).flash: $(OUTPUT_BINARY).elf
	$(Q)#   OBJCOPY $(*).flash
	$(Q)$(OBJCOPY) -O binary $< $@

%.bin: %.elf
	$(Q)#   OBJCOPY $(*).bin
	$(Q)$(OBJCOPY) -Obinary $(*).elf $(*).bin

%.hex: %.elf
	$(Q)#   OBJCOPY $(*).hex
	$(Q)$(OBJCOPY) -Oihex $(*).elf $(*).hex

%.srec: %.elf
	$(Q)#   OBJCOPY $(*).srec
	$(Q)$(OBJCOPY) -Osrec $(*).elf $(*).srec

%.list: %.elf
	$(Q)#   OBJDUMP $(*).list
	$(Q)$(OBJDUMP) -S $(*).elf > $(*).list

%.elf %.map: $(OBJS) $(LDSCRIPT) $(OPENCM3_DIR)/lib/lib$(LIBNAME).a Makefile
	$(Q)#   LD      $(*).elf
	$(Q)$(LD) $(TGT_LDFLAGS) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(*).elf

$(OUTPUT_OBJECTS_DIR)/%.o: %.c
	$(Q)#   CC      $(*).c
	$(Q)@mkdir -p $(dir $@)
	$(Q)$(CC) $(TGT_CFLAGS) $(CFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $<

$(OUTPUT_OBJECTS_DIR)/%.o: %.S
	$(Q)#   CC      $(*).S
	$(Q)@mkdir -p $(dir $@)
	$(Q)$(CC) $(TGT_CFLAGS) $(CFLAGS) -o $@ -c $<

$(OUTPUT_OBJECTS_DIR)/%.o: %.cxx
	$(Q)#   CXX     $(*).cxx
	$(Q)@mkdir -p $(dir $@)
	$(Q)$(CXX) $(TGT_CXXFLAGS) $(CXXFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $<

$(OUTPUT_OBJECTS_DIR)/%.o: %.cpp
	$(Q)#   CXX     $(*).cpp
	$(Q)@mkdir -p $(dir $@)
	$(Q)$(CXX) $(TGT_CXXFLAGS) $(CXXFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $<

clean:
	$(Q)# CLEAN
	$(Q)$(RM) -r $(OUTPUT_DIR)/*
	$(Q)$(RM) generated.* $(OBJS) $(OBJS:%.o=%.d)

###############################################################################
# Helper targets

# Define a helper macro for debugging make errors online
# you can type "make print-OPENCM3_DIR" and it will show you
# how that ended up being resolved by all of the included
# makefiles.
print-%:
	@echo $*=$($*)

# In case that file includes \r that leads to error
libopencm3-to-unix:
	$(Q)#   dos2unix on libopencm3 files
	$(Q)bash -c "find $(OPENCM3_DIR)/ -type f -exec dos2unix {} \;"

# Call "make clean" on libopencm3
libopencm3-clean:
	$(Q)#   Clean libopencm3
	bash -c "make -j4 clean -C $(OPENCM3_DIR)"

rebuild: clean all

# Call this when new file is added or DEFINES changed
update:
	$(Q)#   Update vscode
	$(Q)py $(TOOL_CXX_PROPS_GEN_DIR)/vscode_cprops_gen.py \
	--template "$(TOOL_CXX_PROPS_GEN_DIR)/c_cpp_properties.template.json" \
	--include_dirs "$(INCLUDE_DIRS)" \
	--defines "$(DEFINES)" \
	--output "$(VSCODE_DIR)/c_cpp_properties.json"

.PHONY: images clean elf bin hex srec list rebuild libopencm3-to-unix libopencm3-clean update

-include $(OBJS:.o=.d)
