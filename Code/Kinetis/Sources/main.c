/* ###################################################################
 **     Filename    : main.c
 **     Project     : Kinetis
 **     Processor   : MK22FN512VDC12
 **     Version     : Driver 01.01
 **     Compiler    : GNU C Compiler
 **     Date/Time   : 2020-09-20, 19:07, # CodeGen: 0
 **     Abstract    :
 **         Main module.
 **         This module contains user's application code.
 **     Settings    :
 **     Contents    :
 **         No public methods
 **
 ** ###################################################################*/
/*!
 ** @file main.c
 ** @version 01.01
 ** @brief
 **         Main module.
 **         This module contains user's application code.
 */
/*!
 **  @addtogroup main_module main module documentation
 **  @{
 */
/* MODULE main */

/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "Pins1.h"
#include "RedPWM.h"
#include "PwmLdd1.h"
#include "TU1.h"
#include "GreenPWM.h"
#include "PwmLdd2.h"
#include "fault.h"
#include "ExtIntLdd1.h"
#include "Terminal.h"
#include "Inhr1.h"
#include "ASerialLdd1.h"
/* Including shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"
#include "PDD_Includes.h"
#include "Init_Config.h"
/* User includes (#include below this line is not maintained by Processor Expert) */
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

/* User declared global variables */
volatile bool faultFlag = false;

volatile char buffer[100];
volatile uint8 index = 0;
volatile bool complete_command = false;

bool blinkLed(bool ledStatus) {
	if (ledStatus) {
		GreenPWM_SetRatio8(0);
	} else {
		GreenPWM_SetRatio8(255);
	}
	return !ledStatus;
}

/*lint -save  -e970 Disable MISRA rule (6.3) checking. */
int main(void)
/*lint -restore Enable MISRA rule (6.3) checking. */
{
	/* Write your local variable definition here */

	bool ledStatus = false;
	/*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
	PE_low_level_init();
	/*** End of Processor Expert internal initialization.                    ***/

	/* Write your code here */
	/* For example: for(;;) { } */
	Terminal_SendStr("Hello!\r\n");
	for (;;) {
		while (!complete_command) {
			__asm("wfi");
		}

		if (complete_command) {
			Terminal_SendStr("\r\n");
			Terminal_SendStr("Received Command: \r\n");
			Terminal_SendStr(buffer);
			Terminal_SendStr("\r\n");
			complete_command = false;
			index = 0;
		}
	}
	/*** Don't write any code pass this line, or it will be deleted during code generation. ***/
	/*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
#ifdef PEX_RTOS_START
	PEX_RTOS_START(); /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
#endif
	/*** End of RTOS startup code.  ***/
	/*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
	for (;;) {
	}
	/*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
 ** @}
 */
/*
 ** ###################################################################
 **
 **     This file was created by Processor Expert 10.5 [05.21]
 **     for the Freescale Kinetis series of microcontrollers.
 **
 ** ###################################################################
 */
