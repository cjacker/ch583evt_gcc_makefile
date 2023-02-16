######################################
# target
######################################
TARGET = ch582_ble


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization for size
OPT = -Os


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
# C sources
C_SOURCES = \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_clk.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_timer0.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_i2c.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_flash.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_timer2.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usbhostBase.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_pwr.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_pwm.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_uart3.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_spi0.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_uart2.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usbhostClass.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_uart0.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_timer3.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_adc.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usb2hostClass.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usbdev.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_gpio.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_sys.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_uart1.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_timer1.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usb2dev.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_spi1.c \
CH5xx_ble_firmware_library/StdPeriphDriver/CH58x_usb2hostBase.c \
CH5xx_ble_firmware_library/RVMSIS/core_riscv.c \
User/Main.c \


# ASM sources
ASM_SOURCES =  \
CH5xx_ble_firmware_library/Startup/startup_CH583.S

#######################################
# binaries
#######################################
PREFIX = riscv-none-embed-

CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu
CPU = -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 

# fpu
FPU = 

# float-abi
FLOAT-ABI =

# mcu
MCU = $(CPU) $(FPU) $(FLOAT-ABI)

# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-ICH5xx_ble_firmware_library/StdPeriphDriver/inc \
-ICH5xx_ble_firmware_library/RVMSIS \
-ICH5xx_ble_firmware_library/Core \
-IUser

# compile gcc flags
ASFLAGS = $(MCU) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = CH5xx_ble_firmware_library/Ld/Link.ld 

# libraries
LIBS = -lc -lm -lnosys ./CH5xx_ble_firmware_library/StdPeriphDriver/libISP583.a
LIBDIR = 
LDFLAGS = $(MCU) -mno-save-restore -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wunused -Wuninitialized -T $(LDSCRIPT) -nostartfiles -Xlinker --gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map --specs=nano.specs $(LIBS)

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@
#$(LUAOBJECTS) $(OBJECTS)
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# Program
#######################################
program: $(BUILD_DIR)/$(TARGET).elf
	sudo wch-openocd -f /usr/share/wch-openocd/openocd/scripts/interface/wch-riscv.cfg -c 'init; halt; program $(BUILD_DIR)/$(TARGET).elf; reset; wlink_reset_resume; exit;'

isp: $(BUILD_DIR)/$(TARGET).bin
	wchisp flash $(BUILD_DIR)/$(TARGET).bin

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
