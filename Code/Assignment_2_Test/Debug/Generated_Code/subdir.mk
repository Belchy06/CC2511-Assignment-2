################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Generated_Code/ASerialLdd1.c \
../Generated_Code/BitIoLdd1.c \
../Generated_Code/BitIoLdd10.c \
../Generated_Code/BitIoLdd11.c \
../Generated_Code/BitIoLdd12.c \
../Generated_Code/BitIoLdd2.c \
../Generated_Code/BitIoLdd3.c \
../Generated_Code/BitIoLdd4.c \
../Generated_Code/BitIoLdd5.c \
../Generated_Code/BitIoLdd6.c \
../Generated_Code/BitIoLdd7.c \
../Generated_Code/BitIoLdd8.c \
../Generated_Code/BitIoLdd9.c \
../Generated_Code/Cpu.c \
../Generated_Code/Inhr1.c \
../Generated_Code/PE_LDD.c \
../Generated_Code/Pins1.c \
../Generated_Code/PwmLdd1.c \
../Generated_Code/RealTimeLdd1.c \
../Generated_Code/TU1.c \
../Generated_Code/TU2.c \
../Generated_Code/Term1.c \
../Generated_Code/mode0.c \
../Generated_Code/mode1.c \
../Generated_Code/mode2.c \
../Generated_Code/nEnable.c \
../Generated_Code/nReset.c \
../Generated_Code/nSleep.c \
../Generated_Code/spindle.c \
../Generated_Code/timer.c \
../Generated_Code/xDir.c \
../Generated_Code/xStep.c \
../Generated_Code/yDir.c \
../Generated_Code/yStep.c \
../Generated_Code/zDir.c \
../Generated_Code/zStep.c 

OBJS += \
./Generated_Code/ASerialLdd1.o \
./Generated_Code/BitIoLdd1.o \
./Generated_Code/BitIoLdd10.o \
./Generated_Code/BitIoLdd11.o \
./Generated_Code/BitIoLdd12.o \
./Generated_Code/BitIoLdd2.o \
./Generated_Code/BitIoLdd3.o \
./Generated_Code/BitIoLdd4.o \
./Generated_Code/BitIoLdd5.o \
./Generated_Code/BitIoLdd6.o \
./Generated_Code/BitIoLdd7.o \
./Generated_Code/BitIoLdd8.o \
./Generated_Code/BitIoLdd9.o \
./Generated_Code/Cpu.o \
./Generated_Code/Inhr1.o \
./Generated_Code/PE_LDD.o \
./Generated_Code/Pins1.o \
./Generated_Code/PwmLdd1.o \
./Generated_Code/RealTimeLdd1.o \
./Generated_Code/TU1.o \
./Generated_Code/TU2.o \
./Generated_Code/Term1.o \
./Generated_Code/mode0.o \
./Generated_Code/mode1.o \
./Generated_Code/mode2.o \
./Generated_Code/nEnable.o \
./Generated_Code/nReset.o \
./Generated_Code/nSleep.o \
./Generated_Code/spindle.o \
./Generated_Code/timer.o \
./Generated_Code/xDir.o \
./Generated_Code/xStep.o \
./Generated_Code/yDir.o \
./Generated_Code/yStep.o \
./Generated_Code/zDir.o \
./Generated_Code/zStep.o 

C_DEPS += \
./Generated_Code/ASerialLdd1.d \
./Generated_Code/BitIoLdd1.d \
./Generated_Code/BitIoLdd10.d \
./Generated_Code/BitIoLdd11.d \
./Generated_Code/BitIoLdd12.d \
./Generated_Code/BitIoLdd2.d \
./Generated_Code/BitIoLdd3.d \
./Generated_Code/BitIoLdd4.d \
./Generated_Code/BitIoLdd5.d \
./Generated_Code/BitIoLdd6.d \
./Generated_Code/BitIoLdd7.d \
./Generated_Code/BitIoLdd8.d \
./Generated_Code/BitIoLdd9.d \
./Generated_Code/Cpu.d \
./Generated_Code/Inhr1.d \
./Generated_Code/PE_LDD.d \
./Generated_Code/Pins1.d \
./Generated_Code/PwmLdd1.d \
./Generated_Code/RealTimeLdd1.d \
./Generated_Code/TU1.d \
./Generated_Code/TU2.d \
./Generated_Code/Term1.d \
./Generated_Code/mode0.d \
./Generated_Code/mode1.d \
./Generated_Code/mode2.d \
./Generated_Code/nEnable.d \
./Generated_Code/nReset.d \
./Generated_Code/nSleep.d \
./Generated_Code/spindle.d \
./Generated_Code/timer.d \
./Generated_Code/xDir.d \
./Generated_Code/xStep.d \
./Generated_Code/yDir.d \
./Generated_Code/yStep.d \
./Generated_Code/zDir.d \
./Generated_Code/zStep.d 


# Each subdirectory must supply rules for building sources it contributes
Generated_Code/%.o: ../Generated_Code/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross ARM C Compiler'
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment-2/Code/Assignment_2_Test/Static_Code/System" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment-2/Code/Assignment_2_Test/Static_Code/PDD" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment-2/Code/Assignment_2_Test/Static_Code/IO_Map" -I"C:\Freescale\KDS_v3\eclipse\ProcessorExpert/lib/Kinetis/pdd/inc" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment-2/Code/Assignment_2_Test/Sources" -I"C:/Users/Will/Desktop/Uni/Year 2/SP 2/CC2511/Assignment-2/Code/Assignment_2_Test/Generated_Code" -std=c99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


