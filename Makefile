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

CC=clang
CXX=clang++
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size
LD=arm-none-eabi-gcc

# Location of the linker scripts
LINKER_SPECS := --specs=nano.specs --specs=nosys.specs
LDSCRIPT_INC=Device/ldscripts

OPT_LEVEL=3

CFLAGS = $(addprefix -I,$(INC))
CFLAGS += -Wall -g -O$(OPT_LEVEL)
CFLAGS += -mlittle-endian -mcpu=cortex-m0 -march=armv6-m -mthumb
CFLAGS += --target=thumbv6-unknown-none-eabi
CFLAGS += -D$(DEVICE) -ffunction-sections -fdata-sections
LDFLAGS = -L$(LDSCRIPT_INC) -TSTM32F051R8Tx_FLASH.ld
LDFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb
LDFLAGS += -Wl,--gc-sections -Wl,--cref -Wl,-Map=$(BUILD_DIR)/$(PROJ_NAME).map
LDFLAGS += -flto
LDFLAGS += $(LINKER_SPECS)

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
