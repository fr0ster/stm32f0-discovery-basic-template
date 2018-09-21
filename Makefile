PROJ_NAME=hello
DEVICE=STM32F051x8
# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Libraries
INC := inc
INC += $(STD_PERIPH_LIB)/CMSIS/Include
INC += $(STD_PERIPH_LIB)/CMSIS/Device/ST/STM32F0xx/Include
SRC := src
BUILD_DIR := build

CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size
LD=arm-none-eabi-ld

# Location of the linker scripts
LINKER_SPECS := --specs=nano.specs
LDSCRIPT_INC=Device/ldscripts
LIBSPEC := -L /usr/lib/gcc/arm-none-eabi/5.4.1/armv6-m
LIBSPEC += -L /usr/lib/arm-none-eabi/newlib
LIBSPEC += -L /usr/local/Caskroom/gcc-arm-embedded/7-2017-q4-major/gcc-arm-none-eabi-7-2017-q4-major/arm-none-eabi/lib/thumb/v6-m
LIBSPEC += -L /usr/local/Caskroom/gcc-arm-embedded/7-2017-q4-major/gcc-arm-none-eabi-7-2017-q4-major/lib/gcc/arm-none-eabi/7.2.1/thumb

CFLAGS = $(addprefix -I,$(INC))
CFLAGS += -Wall -g -Os -D$(DEVICE)
CFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb
CFLAGS += -ffunction-sections -fdata-sections -O3
LDFLAGS = -L$(LDSCRIPT_INC) -TSTM32F051R8Tx_FLASH.ld
LDFLAGS += $(LIBSPEC)
LDFLAGS += --gc-sections --cref -Map=$(BUILD_DIR)/$(PROJ_NAME).map
LDFLAGS += -flto -nostartfiles

SOURCES := $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.c))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.s))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.cpp))
OBJECTS := $(patsubst %, $(BUILD_DIR)/%.o, $(SOURCES))

all: $(BUILD_DIR)/$(PROJ_NAME).elf

$(BUILD_DIR)/$(PROJ_NAME).elf: $(OBJECTS)
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@
	$(OBJCOPY) -O ihex $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).bin
	$(OBJDUMP) -St $(BUILD_DIR)/$(PROJ_NAME).elf >$(BUILD_DIR)/$(PROJ_NAME).lst
	$(SIZE) $(BUILD_DIR)/$(PROJ_NAME).elf

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

