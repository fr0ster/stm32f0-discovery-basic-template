PROJ_NAME=hello
DEVICE=STM32F051x8
# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Libraries
INC := inc
INC += $(STD_PERIPH_LIB)/CMSIS/Include
INC += $(STD_PERIPH_LIB)/CMSIS/Device/ST/STM32F0xx/Include
SRC := src
BUILD_DIR := build

CC=clang
CXX=clang++
OBJCOPY=llvm-objcopy
OBJDUMP=llvm-objdump
SIZE=llvm-size
LD=ld.lld

# Location of the linker scripts
LDSCRIPT_INC=Device/ldscripts

ASMFLAGS = $(addprefix -I,$(INC))
ASMFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb --target=thumbv6-unknown-none-eabi
CFLAGS = $(addprefix -I,$(INC))
CFLAGS += -Wall -g -Os -D$(DEVICE)
CFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb --target=thumbv6-unknown-none-eabi
CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS = -L$(LDSCRIPT_INC) -TSTM32F051R8Tx_FLASH.ld
LDFLAGS += --gc-sections -Map=$(BUILD_DIR)/$(PROJ_NAME).map
LDFLAGS += --lto-O3

SOURCES := $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.c))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.s))
SOURCES += $(foreach sdir,$(SRC),$(wildcard $(sdir)/*.cpp))
OBJECTS := $(patsubst %, $(BUILD_DIR)/%.o, $(SOURCES))

all: $(BUILD_DIR)/$(PROJ_NAME).elf

$(BUILD_DIR)/$(PROJ_NAME).elf: $(OBJECTS)
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@
#	$(OBJCOPY) -O ihex $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).bin
	$(OBJDUMP) -S $(BUILD_DIR)/$(PROJ_NAME).elf >$(BUILD_DIR)/$(PROJ_NAME).lst
	$(SIZE) $(BUILD_DIR)/$(PROJ_NAME).elf

$(BUILD_DIR):
	mkdir -p $(addprefix $@/, $(SRC))

$(BUILD_DIR)/%.s.o: %.s | $(BUILD_DIR)
	$(CC) $(ASMFLAGS) -c $< -o $@
$(BUILD_DIR)/%.cpp.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CFLAGS) -c $< -o $@
$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -fR $(BUILD_DIR)

rebuild: clean all
