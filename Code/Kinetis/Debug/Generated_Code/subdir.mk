################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Generated_Code/ASerialLdd1.c \
../Generated_Code/Cpu.c \
../Generated_Code/ExtIntLdd1.c \
../Generated_Code/GreenPWM.c \
../Generated_Code/Inhr1.c \
../Generated_Code/PE_LDD.c \
../Generated_Code/Pins1.c \
../Generated_Code/PwmLdd1.c \
../Generated_Code/PwmLdd2.c \
../Generated_Code/RedPWM.c \
../Generated_Code/TU1.c \
../Generated_Code/Terminal.c \
../Generated_Code/fault.c 

OBJS += \
./Generated_Code/ASerialLdd1.o \
./Generated_Code/Cpu.o \
./Generated_Code/ExtIntLdd1.o \
./Generated_Code/GreenPWM.o \
./Generated_Code/Inhr1.o \
./Generated_Code/PE_LDD.o \
./Generated_Code/Pins1.o \
./Generated_Code/PwmLdd1.o \
./Generated_Code/PwmLdd2.o \
./Generated_Code/RedPWM.o \
./Generated_Code/TU1.o \
./Generated_Code/Terminal.o \
./Generated_Code/fault.o 

C_DEPS += \
./Generated_Code/ASerialLdd1.d \
./Generated_Code/Cpu.d \
./Generated_Code/ExtIntLdd1.d \
./Generated_Code/GreenPWM.d \
./Generated_Code/Inhr1.d \
./Generated_Code/PE_LDD.d \
./Generated_Code/Pins1.d \
./Generated_Code/PwmLdd1.d \
./Generated_Code/PwmLdd2.d \
./Generated_Code/RedPWM.d \
./Generated_Code/TU1.d \
./Generated_Code/Terminal.d \
./Generated_Code/fault.d 


# Each subdirectory must supply rules for building sources it contributes
Generated_Code/%.o: ../Generated_Code/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross ARM C Compiler'
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment 2/Code/Kinetis/Static_Code/System" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment 2/Code/Kinetis/Static_Code/PDD" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment 2/Code/Kinetis/Static_Code/IO_Map" -I"C:\Freescale\KDS_v3\eclipse\ProcessorExpert/lib/Kinetis/pdd/inc" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment 2/Code/Kinetis/Sources" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment 2/Code/Kinetis/Generated_Code" -std=c99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


