/* ###################################################################
**     Filename    : Events.h
**     Project     : Assignment_2_Test
**     Processor   : MK22FN512VDC12
**     Component   : Events
**     Version     : Driver 01.00
**     Compiler    : GNU C Compiler
**     Date/Time   : 2020-09-04, 16:22, # CodeGen: 0
**     Abstract    :
**         This is user's event module.
**         Put your event handler code here.
**     Contents    :
**         Cpu_OnNMI - void Cpu_OnNMI(void);
**
** ###################################################################*/
/*!
** @file Events.h
** @version 01.00
** @brief
**         This is user's event module.
**         Put your event handler code here.
*/         
/*!
**  @addtogroup Events_module Events module documentation
**  @{
*/         

#ifndef __Events_H
#define __Events_H
/* MODULE Events */

#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"
#include "Pins1.h"
#include "xStep.h"
#include "BitIoLdd2.h"
#include "xDir.h"
#include "BitIoLdd1.h"
#include "Term1.h"
#include "Inhr1.h"
#include "ASerialLdd1.h"
#include "RealTimeLdd1.h"
#include "TU2.h"
#include "TU1.h"
#include "timer.h"
#include "mode0.h"
#include "BitIoLdd3.h"
#include "mode1.h"
#include "BitIoLdd4.h"
#include "mode2.h"
#include "BitIoLdd5.h"
#include "nSleep.h"
#include "BitIoLdd6.h"
#include "nEnable.h"
#include "BitIoLdd7.h"
#include "nReset.h"
#include "BitIoLdd8.h"
#include "yDir.h"
#include "BitIoLdd9.h"
#include "zStep.h"
#include "BitIoLdd11.h"
#include "zDir.h"
#include "BitIoLdd12.h"
#include "spindle.h"
#include "PwmLdd1.h"
#include "yStep.h"
#include "BitIoLdd10.h"

#ifdef __cplusplus
extern "C" {
#endif 

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
void Cpu_OnNMI(void);


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
void Inhr1_OnRxChar(void);

/* END Events */

#ifdef __cplusplus
}  /* extern "C" */
#endif 

#endif 
/* ifndef __Events_H*/
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
