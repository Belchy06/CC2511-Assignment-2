/* ###################################################################
 **     Filename    : Events.c
 **     Project     : Kinetis
 **     Processor   : MK22FN512VDC12
 **     Component   : Events
 **     Version     : Driver 01.00
 **     Compiler    : GNU C Compiler
 **     Date/Time   : 2020-09-20, 19:07, # CodeGen: 0
 **     Abstract    :
 **         This is user's event module.
 **         Put your event handler code here.
 **     Contents    :
 **         Cpu_OnNMI - void Cpu_OnNMI(void);
 **
 ** ###################################################################*/
/*!
 ** @file Events.c
 ** @version 01.00
 ** @brief
 **         This is user's event module.
 **         Put your event handler code here.
 */
/*!
 **  @addtogroup Events_module Events module documentation
 **  @{
 */
/* MODULE Events */

#include "Cpu.h"
#include "Events.h"
#include "Init_Config.h"
#include "PDD_Includes.h"

#ifdef __cplusplus
extern "C" {
#endif 

#include <stdbool.h>

extern volatile bool faultFlag;
extern volatile char buffer[100];
extern volatile uint8 index;
extern volatile bool complete_command;
/* User includes (#include below this line is not maintained by Processor Expert) */

/*
 ** ===================================================================
 **     Event       :  Cpu_OnNMI (module Events)
 **
 **     Component   :  Cpu [MK22FN512DC12]
 */
/*!
 **     @brief
 **         This event is called when the Non maskable interrupt had
 **         occurred. This event is automatically enabled when the [NMI
 **         interrupt] property is set to 'Enabled'.
 */
/* ===================================================================*/
void Cpu_OnNMI(void) {
	/* Write your code here ... */
}

/*
 ** ===================================================================
 **     Event       :  fault_OnInterrupt (module Events)
 **
 **     Component   :  fault [ExtInt]
 **     Description :
 **         This event is called when an active signal edge/level has
 **         occurred.
 **     Parameters  : None
 **     Returns     : Nothing
 ** ===================================================================
 */
void fault_OnInterrupt(void) {
	faultFlag = true;
}

/*
 ** ===================================================================
 **     Event       :  Inhr1_OnRxChar (module Events)
 **
 **     Component   :  Inhr1 [AsynchroSerial]
 **     Description :
 **         This event is called after a correct character is received.
 **         The event is available only when the <Interrupt
 **         service/event> property is enabled and either the <Receiver>
 **         property is enabled or the <SCI output mode> property (if
 **         supported) is set to Single-wire mode.
 **     Parameters  : None
 **     Returns     : Nothing
 ** ===================================================================
 */
void Inhr1_OnRxChar(void) {
	char c;
	if (ERR_OK == Inhr1_RecvChar(&c)) {
		// New char has been received
		switch (c) {
		case '\r':
			// new line received
			if (index > 0) {
				buffer[index] = '\0';
				complete_command = true;
			}
			break;
		case 0x7f:
			// Backspace pressed
			if (index > 0) {
				buffer[index] = '\0';
				index--;
				Terminal_SendChar(0x7f);
			}
			break;
		default:
			if (index < 99) {
				buffer[index] = c;
				index++;
				Terminal_SendChar(c);
			}
			break;
		}
	}
}

/* END Events */

#ifdef __cplusplus
} /* extern "C" */
#endif 

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