PROJ_NAME=hello
DEVICE=STM32F051x8
# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Libraries
INC := inc
INC += $(STD_PERIPH_LIB)/CMSIS/Include
INC += $(STD_PERIPH_LIB)/CMSIS/Device/ST/STM32F0xx/Include
INC += /usr/lib/arm-none-eabi/include
SRC := src
BUILD_DIR := build

#TOOLCHAIN_DIR=~/x-tools/arm-nano-eabi
TOOLCHAIN_DIR=~/x-tools/arm-none-eabi
#TOOLCHAIN_DIR=/usr
#PREFIX=$(TOOLCHAIN_DIR)/bin/arm-nano-eabi-
PREFIX=$(TOOLCHAIN_DIR)/bin/arm-none-eabi-

CC=$(PREFIX)gcc
CXX=$(PREFIX)g++
OBJCOPY=$(PREFIX)objcopy
OBJDUMP=$(PREFIX)objdump
SIZE=$(PREFIX)size
LD=$(PREFIX)ld

# Location of the linker scripts
LDSCRIPT_INC=Device/ldscripts

OPT_LEVEL=3

LIBSPEC := -L /usr/lib/gcc/arm-none-eabi/5.4.1/armv6-m
LIBSPEC += -L /usr/lib/arm-none-eabi/newlib
LIBSPEC += -L /usr/local/Caskroom/gcc-arm-embedded/7-2017-q4-major/gcc-arm-none-eabi-7-2017-q4-major/arm-none-eabi/lib/thumb/v6-m
LIBSPEC += -L /usr/local/Caskroom/gcc-arm-embedded/7-2017-q4-major/gcc-arm-none-eabi-7-2017-q4-major/lib/gcc/arm-none-eabi/7.2.1/thumb

CFLAGS = $(addprefix -I,$(INC))
CFLAGS += -Wall -g -O$(OPT_LEVEL)
CFLAGS += -mlittle-endian -mcpu=cortex-m0 -march=armv6-m -mthumb
CFLAGS += -D$(DEVICE) -ffunction-sections -fdata-sections
LDFLAGS = -L$(LDSCRIPT_INC) -TSTM32F051R8Tx_FLASH.ld
LDFLAGS += --gc-sections --cref -Map=$(BUILD_DIR)/$(PROJ_NAME).map
LDFLAGS += -flto -nostdlib -nostartfiles
LDFLAGS += $(LIBSPEC)

SOURCES := $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.c))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.s))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.cpp))
OBJECTS := $(patsubst %, $(BUILD_DIR)/%.o, $(SOURCES))

JLINK_SCRIPT=$(PROJ_NAME).jlink

all: $(BUILD_DIR)/$(PROJ_NAME).elf

$(BUILD_DIR)/$(PROJ_NAME).elf: $(OBJECTS)
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@
	$(OBJCOPY) -O ihex $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).bin
	$(OBJDUMP) -St $(BUILD_DIR)/$(PROJ_NAME).elf >$(BUILD_DIR)/$(PROJ_NAME).lst
	$(SIZE) $(BUILD_DIR)/$(PROJ_NAME).elf
	@echo 'connect' > $(BUILD_DIR)/$(JLINK_SCRIPT)
	@echo 'r' >> $(BUILD_DIR)/$(JLINK_SCRIPT)
	@echo 'h' >> $(BUILD_DIR)/$(JLINK_SCRIPT)
	@echo 'loadbin $(BUILD_DIR)/$(PROJ_NAME).bin 0x8000000' >> $(BUILD_DIR)/$(JLINK_SCRIPT)
	@echo 'r' >> $(BUILD_DIR)/$(JLINK_SCRIPT)
	@echo 'q' >> $(BUILD_DIR)/$(JLINK_SCRIPT)

$(BUILD_DIR):
	mkdir -p $(addprefix $@/, $(SRC))

$(BUILD_DIR)/%.s.o: %.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@
$(BUILD_DIR)/%.cpp.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CFLAGS) -c $< -o $@
$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -fR $(BUILD_DIR)

rebuild: clean all

flash:
	JLinkExe -if SWD -speed 10000 -device $(DEVICE) -commanderscript $(BUILD_DIR)/$(JLINK_SCRIPT)
