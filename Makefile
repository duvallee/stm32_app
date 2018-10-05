###############################################################################
#
#  	  File        : Makefile
#
#       Abstract    : Example Makefile for a C Project
#
#       Environment : Atollic TrueSTUDIO(R)
#
###############################################################################

SHELL=cmd

# -----------------------------------------------------------------------------
MODEL_EXTRA_OPTIONS:=
SYSCALL_SOURCE:=
HAL_LIBRARY_SOURCE:=
SYSTEM_SOURCE:=
USB_DRIVER:=
USER_SOURCE:=
MODEL_SOURCE:=
C_INCLUDE:=

ifeq ("$(DEBUG_DEVICE)","NONE")
	MODEL_EXTRA_OPTIONS+=-USUPPORT_DEBUG_OUTPUT
endif

ifeq ("$(DEBUG_DEVICE)","UART")
	MODEL_EXTRA_OPTIONS+=-DSUPPORT_DEBUG_OUTPUT -DUART_DEBUG_OUTPUT
	SYSCALL_SOURCE+=./src/syscall/printf.c ./src/syscall/uart_debug.c
endif

ifeq ("$(DEBUG_DEVICE)","USB")
	MODEL_EXTRA_OPTIONS+=-DSUPPORT_DEBUG_OUTPUT -DUSB_DEBUG_OUTPUT
	SYSCALL_SOURCE+=./src/syscall/printf.c
endif

ifeq ("$(DEBUG_DEVICE)","RTT")
	MODEL_EXTRA_OPTIONS+=-DSUPPORT_DEBUG_OUTPUT -DRTT_DEBUG_OUTPUT
	SYSCALL_SOURCE+=./src/syscall/printf.c
endif

# -----------------------------------------------------------------------------
# for ST's CubeMX
ifeq ("$(BUILD_TARGET)","STM32F4xx")
	ST_CUBEMX_SERIES:=F4
	ST_CUBEMX_MAJOR_VERSION:=1
	ST_CUBEMX_MINOR_VERSION:=21
	ST_CUBEMX_SUB_VERSION:=0
	ST_CUBEMX_HAL_DRIVER:=STM32F4xx_HAL_Driver
	ARM_INSTRUCTION:=-mthumb
	ARM_ARCHITECTURE:=-mcpu=cortex-m4
	ARM_FPU=-mfpu=fpv4-sp-d16
	ARM_FLOAT-ABI=-mfloat-abi=hard
endif

ifeq ("$(BUILD_TARGET)","STM32F7xx")
	ST_CUBEMX_SERIES:=F7
	ST_CUBEMX_MAJOR_VERSION:=1
	ST_CUBEMX_MINOR_VERSION:=11
	ST_CUBEMX_SUB_VERSION:=0
	ST_CUBEMX_HAL_DRIVER:=STM32F7xx_HAL_Driver
	ARM_INSTRUCTION:=-mthumb
	ARM_ARCHITECTURE:=-mcpu=cortex-m7
	ARM_FPU=-mfpu=fpv5-sp-d16
	ARM_FLOAT-ABI=-mfloat-abi=hard
endif

ifeq ("$(BUILD_TARGET)","STM32H7xx")
	ST_CUBEMX_SERIES:=H7
	ST_CUBEMX_MAJOR_VERSION:=1
	ST_CUBEMX_MINOR_VERSION:=2
	ST_CUBEMX_SUB_VERSION:=0
	ST_CUBEMX_HAL_DRIVER:=STM32H7xx_HAL_Driver
	ARM_INSTRUCTION:=-mthumb
	ARM_ARCHITECTURE:=-mcpu=cortex-m7
	ARM_FPU=-mfpu=fpv5-sp-d16
	ARM_FLOAT-ABI=-mfloat-abi=hard
endif

ST_CUBEMX_LIBRARY_PATH:=./STM32Cube_FW_$(ST_CUBEMX_SERIES)_V$(ST_CUBEMX_MAJOR_VERSION).$(ST_CUBEMX_MINOR_VERSION).$(ST_CUBEMX_SUB_VERSION)

# -----------------------------------------------------------------------------
# Link script file & add source file
ifeq ("$(BUILD_TARGET_CHIP)","STM32F401CC")
	LINK_SCRIPT:=./ldscript/$(BUILD_TARGET_CHIP)/STM32F401CCUx_FLASH.ld
	STARTUP_CODE:=./startup/$(BUILD_TARGET_CHIP)/startup_stm32f401xc.s
	TARGET_PATH:=$(BUILD_TARGET_CHIP)
	ST_HAL_LIBRARY_PREFIX:=stm32f4xx
	MODEL_EXTRA_OPTIONS+=-DSTM32F401xC
	# ADC
	MODEL_SOURCE+=./src/adc/$(BUILD_TARGET_CHIP)/battery_gauge.c
	C_INCLUDE+=-I./src/adc/$(BUILD_TARGET_CHIP)/
	# LED
	MODEL_SOURCE+=./src/led/$(BUILD_TARGET_CHIP)/led.c
	C_INCLUDE+=-I./src/led/$(BUILD_TARGET_CHIP)/
	# TIM4 for motor
	MODEL_SOURCE+=./src/tim/$(BUILD_TARGET_CHIP)/motor.c
	C_INCLUDE+=-I./src/tim/$(BUILD_TARGET_CHIP)/

	#TIM2 for motor & remote controller
	ifeq ("$(TIM2_CONTROL)","motor")
		MODEL_SOURCE+=./src/tim/$(BUILD_TARGET_CHIP)/motor_ext_esc.c
		MODEL_EXTRA_OPTIONS+=-DTIM2_MOTOR
	endif

	ifeq ("$(TIM2_CONTROL)","remote_control")
		MODEL_SOURCE+=./src/tim/$(BUILD_TARGET_CHIP)/remote_controller.c
		MODEL_EXTRA_OPTIONS+=-DTIM2_REMOTE_CONTROL
	endif

	# SPI
	C_INCLUDE+=-I./src/spi/$(BUILD_TARGET_CHIP)/
	# SPI1 for blue nrg
	MODEL_SOURCE+=./src/spi/$(BUILD_TARGET_CHIP)/blue_nrg_spi1.c
	# SPI2 for Sensor
	MODEL_SOURCE+=./src/spi/$(BUILD_TARGET_CHIP)/sensor_spi2.c

endif

ifeq ("$(BUILD_TARGET_CHIP)","STM32F413RG")
	LINK_SCRIPT:=./ldscript/$(BUILD_TARGET_CHIP)/STM32F413RG_FLASH.ld
	STARTUP_CODE:=./startup/$(BUILD_TARGET_CHIP)/startup_stm32f413xx.s
	TARGET_PATH:=$(BUILD_TARGET_CHIP)
	ST_HAL_LIBRARY_PREFIX:=stm32f4xx
	MODEL_EXTRA_OPTIONS+=-DSTM32F413xx
endif


ifeq ("$(BUILD_TARGET_CHIP)","STM32F746NG")
	LINK_SCRIPT:=./ldscript/$(BUILD_TARGET_CHIP)/STM32F746NGHx_FLASH.ld
	STARTUP_CODE:=./startup/$(BUILD_TARGET_CHIP)/startup_stm32f746xx.s
	TARGET_PATH:=$(BUILD_TARGET_CHIP)
	ST_HAL_LIBRARY_PREFIX:=stm32f7xx
	MODEL_EXTRA_OPTIONS+=-DSTM32F746NG
endif

ifeq ("$(BUILD_TARGET_CHIP)","STM32H743XI")
	LINK_SCRIPT:=./ldscript/$(BUILD_TARGET_CHIP)/stm32h7_flash.ld
	STARTUP_CODE:=./startup/$(BUILD_TARGET_CHIP)/startup_stm32h753xx.s
	TARGET_PATH:=$(BUILD_TARGET_CHIP)
	ST_HAL_LIBRARY_PREFIX:=stm32h7xx
	MODEL_EXTRA_OPTIONS+=-DSTM32H743xx
endif

# -----------------------------------------------------------------------------
# GCC Options
#
GCC_OPTIONS:=$(ARM_INSTRUCTION) $(ARM_ARCHITECTURE) $(ARM_FPU) $(ARM_FLOAT-ABI)
# enables all compilers warning messages
GCC_OPTIONS+=-Wall
# for C11 with CNU extensions(C11 was published in 2011 as ISO/IEC 9899:2011, gnu99(for C99 with GNU extensions))
GCC_OPTIONS+=-std=gnu11
# GNU Extension in ARM Compiler for weak Function
GCC_OPTIONS+=-D__weak=__attribute__((weak))
GCC_OPTIONS+=-D__packed=__attribute__((__packed__))

ifeq ("$(BUILD_DEBUG)","DEBUG")
	GCC_OPTIONS+=-g -O0
	ifneq ("$(DEBUG_DEVICE)","NONE")
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_ERROR
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_WARN
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_DEBUG
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_FN_TRACE
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_INFO
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_DUMP
	endif
endif

ifeq ("$(BUILD_DEBUG)","RELEASE")
	GCC_OPTIONS+=-O3
	ifneq ("$(DEBUG_DEVICE)","NONE")
		MODEL_EXTRA_OPTIONS+=-DSUPPORT_DEBUG_OUTPUT -DRTT_DEBUG_OUTPUT
		MODEL_EXTRA_OPTIONS+=-DDEBUG_STRING_LEVEL_ERROR
	endif
endif

ifeq ("$(MAVLink)","SUPPORT")
	MODEL_EXTRA_OPTIONS+=-DMAVLINK
endif

# -----------------------------------------------------------------------------
# Model Options
#
MODEL_OPTIONS:=-D$(BUILD_TARGET) -D$(BUILD_TARGET_CHIP)
MODEL_OPTIONS+=-DUSE_HAL_DRIVER
MODEL_OPTIONS+=$(MODEL_EXTRA_OPTIONS)

# -----------------------------------------------------------------------------
# USB Options
USB_OPTIONS:=

ifeq ("$(USB_DEVICE)","NONE")
	USB_OPTIONS+=-UUSE_USB
	USB_OPTIONS+=-UUSE_USB_BULK_DEVICE -UUSE_USB_CDC_DEVICE
endif

ifeq ("$(USB_DEVICE)","BULK")
	USB_OPTIONS+=-DUSE_USB
	USB_OPTIONS+=-DUSE_USB_BULK_DEVICE
endif

ifeq ("$(USB_DEVICE)","CDC")
	USB_OPTIONS+=-DUSE_USB
	USB_OPTIONS+=-DUSE_USB_CDC_DEVICE
endif

ifeq ("$(USB_SPEED)","HIGH_SPEED")
	USB_OPTIONS+=-DUSE_USB_HS
endif

ifeq ("$(USB_SPEED)","FULL_SPEED")
	USB_OPTIONS+=-DUSE_USB_FS
endif

# -----------------------------------------------------------------------------
TARGET:=$(BUILD_TARGET_CHIP)_app

# Define output directory
OBJECT_DIR:=$(BUILD_TARGET_CHIP)_output
BIN_DIR:=$(OBJECT_DIR)

# -----------------------------------------------------------------------------
# System configuration
CC:=arm-atollic-eabi-gcc
OBJCOPY:=arm-atollic-eabi-objcopy
SIZE:=arm-atollic-eabi-size

RM:=rm -rf

# -----------------------------------------------------------------------------
# Assembler
AFLAGS:=-c $($(ARM_INSTRUCTION) $(ARM_ARCHITECTURE) $(ARM_FPU) $(ARM_FLOAT-ABI) -specs=nano.specs -x assembler-with-cpp

ifeq ("$(BUILD_DEBUG)","DEBUG")
	AFLAGS+=-g -O0
endif

ifeq ("$(BUILD_DEBUG)","RELEASE")
	AFLAGS+=-O3
endif

# -----------------------------------------------------------------------------
# C
C_INCLUDE+=-Iinc
C_INCLUDE+=-Iinc/$(TARGET_PATH)
C_INCLUDE+=-Isrc/scheduler

ifeq ("$(USB_DEVICE)","BULK")
	C_INCLUDE+=-IMiddlewares/ST/STM32_USB_Device_Library/Core/Inc
	C_INCLUDE+=-IMiddlewares/ST/STM32_USB_Device_Library/Class/BULK/Inc
	C_INCLUDE+=-Isrc/usb/inc
	C_INCLUDE+=-Isrc/usb/bulk/inc
endif

ifeq ("$(USB_DEVICE)","CDC")
	C_INCLUDE+=-IMiddlewares/ST/STM32_USB_Device_Library/Core/Inc
	C_INCLUDE+=-IMiddlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc
	C_INCLUDE+=-Isrc/usb/inc
	C_INCLUDE+=-Isrc/usb/cdc/inc
endif

ifeq ("$(MAVLink)","SUPPORT")
	C_INCLUDE+=-Isrc/MAVLink
	C_INCLUDE+=-Isrc/MAVLink/common
	C_INCLUDE+=-Isrc/MAVLink/standard
endif

C_INCLUDE+=-I$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/Inc 
C_INCLUDE+=-I$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/Inc/Legacy
C_INCLUDE+=-I$(ST_CUBEMX_LIBRARY_PATH)/Drivers/CMSIS/Device/ST/$(BUILD_TARGET)/Include
C_INCLUDE+=-I$(ST_CUBEMX_LIBRARY_PATH)/Drivers/CMSIS/Include

# -----------------------------------------------------------------------------
# CFLAGS
CFLAGS:=-c
CFLAGS+=$(GCC_OPTIONS) $(MODEL_OPTIONS) $(USB_OPTIONS) $(C_INCLUDE)

# -----------------------------------------------------------------------------
LFLAGS:=$(ARM_INSTRUCTION) $(ARM_ARCHITECTURE) $(ARM_FPU) $(ARM_FLOAT-ABI)
LFLAGS+=-T$(LINK_SCRIPT)
LFLAGS+=-specs=nosys.specs -static 
LFLAGS+=-Wl,-Map=$(BIN_DIR)/$(TARGET).map
LFLAGS+=-Wl,--gc-sections
LFLAGS+=-Wl,--defsym=malloc_getpagesize_P=0x80
LFLAGS+=-Wl,--start-group -lc -lm -Wl,--end-group
LFLAGS+= -specs=nano.specs 

# --------------------------------------------------------------------
# C Source

# System Source
SYSTEM_SOURCE+=$(wildcard ./src/$(TARGET_PATH)/*.c)

# HAL Library Source
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_rcc.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_rcc_ex.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_gpio.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_cortex.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_adc.c
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_adc_ex.c

ifeq ("$(BUILD_TARGET_CHIP)","STM32F401CC")
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_tim.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_tim_ex.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_spi.c
endif

ifeq ("$(DEBUG_DEVICE)","UART")
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_uart.c
	ifeq ("$(BUILD_TARGET)","STM32H7xx")
		HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_uart_ex.c
	endif
endif
HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_dma.c
ifeq ("$(USB_DEVICE)","BULK")
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pcd.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pcd_ex.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pwr.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pwr_ex.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_ll_usb.c
endif
ifeq ("$(USB_DEVICE)","CDC")
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pcd.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pcd_ex.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pwr.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_hal_pwr_ex.c
	HAL_LIBRARY_SOURCE+=$(ST_CUBEMX_LIBRARY_PATH)/Drivers/$(ST_CUBEMX_HAL_DRIVER)/src/$(ST_HAL_LIBRARY_PREFIX)_ll_usb.c
endif
# USB Library Source
ifeq ("$(USB_DEVICE)","BULK")
   USB_DRIVER+=$(wildcard ./Middlewares/ST/STM32_USB_Device_Library/Core/Src/*.c)
   USB_DRIVER+=$(wildcard ./Middlewares/ST/STM32_USB_Device_Library/Class/BULK/Src/*.c)
   USB_DRIVER+=./src/usb/usb_device.c
   USB_DRIVER+=$(wildcard ./src/usb/bulk/src/*.c)
endif

ifeq ("$(USB_DEVICE)","CDC")
   USB_DRIVER+=$(wildcard ./Middlewares/ST/STM32_USB_Device_Library/Core/Src/*.c)
   USB_DRIVER+=$(wildcard ./Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Src/*.c)
   USB_DRIVER+=./src/usb/usb_device.c
   USB_DRIVER+=$(wildcard ./src/usb/cdc/src/*.c)
endif

# User Source
USER_SOURCE+=./src/main.c
USER_SOURCE+=./src/scheduler/scheduler.c
USER_SOURCE+= 

# all C Source
C_SRC:=$(SYSTEM_SOURCE) $(SYSCALL_SOURCE) $(HAL_LIBRARY_SOURCE) $(USB_DRIVER) $(USER_SOURCE) $(MODEL_SOURCE)

# --------------------------------------------------------------------
# ASM Source
A_SRC:=$(STARTUP_CODE)

# --------------------------------------------------------------------
OBJS:=$(C_SRC:%.c=$(OBJECT_DIR)/%.o) $(A_SRC:%.s=$(OBJECT_DIR)/%.o)
OBJS:=$(OBJS:%.S=$(OBJECT_DIR)/%.o)  


# --------------------------------------------------------------------
###############
# Build project
# Major targets
###############
all: BEFORE_MAKE_PROCESS $(TARGET) AFTER_MAKE_PROCESS

# --------------------------------------------------------------------
BEFORE_MAKE_PROCESS:
	@echo $(C_SRC)
	@echo $(USB_DEVICE)
	@echo $(USB_OPTIONS)
	@echo ================================================================

# --------------------------------------------------------------------
AFTER_MAKE_PROCESS:
	@echo ================================================================

# --------------------------------------------------------------------
$(TARGET): $(OBJS) 
	$(CC) -o "$(BIN_DIR)/$(TARGET).elf" $(OBJS) $(LFLAGS)
	$(OBJCOPY) -O ihex "$(BIN_DIR)/$(TARGET).elf" "$(BIN_DIR)/$(TARGET).hex"
	$(OBJCOPY) -O binary "$(BIN_DIR)/$(TARGET).elf" "$(BIN_DIR)/$(TARGET).bin"
	@echo ***************************************************************************************
	$(SIZE) "$(BIN_DIR)/$(TARGET).elf"
	@echo ***************************************************************************************

clean:
	$(RM) $(OBJS) "$(BIN_DIR)/$(TARGET).elf" "$(BIN_DIR)/$(TARGET).map"

##################
# Implicit targets
##################
$(OBJECT_DIR)/%.o: %.c
	@mkdir $(subst /,\,$(dir $@)) 2> NUL || echo off
	$(CC) $(CFLAGS) $< -o $@

$(OBJECT_DIR)/%.o: %.s
	@mkdir $(subst /,\,$(dir $@)) 2> NUL || echo off
	$(CC) $(AFLAGS) $< -o $@
	
$(OBJECT_DIR)/%.o: %.S
	@mkdir $(subst /,\,$(dir $@)) 2> NUL || echo off
	$(CC) $(AFLAGS) $< -o $@
 
 