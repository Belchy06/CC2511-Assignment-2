/* ###################################################################
 **     Filename    : main.c
 **     Project     : Assignment_2_Test
 **     Processor   : MK22FN512VDC12
 **     Version     : Driver 01.01
 **     Compiler    : GNU C Compiler
 **     Date/Time   : 2020-09-04, 16:22, # CodeGen: 0
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
/* Including shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"
#include "PDD_Includes.h"
#include "Init_Config.h"
/* User includes (#include below this line is not maintained by Processor Expert) */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

// Variables for receiving strings
volatile char buffer[100];
volatile uint8 index = 0;
volatile bool complete_command = false;

// Defined max function as C doesn't have a max function implemented as standard
#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

// Define struct for storing position data
struct position {
	int16 x;
	int16 y;
	int16 z;
};

void draw_GUI() {
	Term1_SetColor(clYellow, clBlack);
	Term1_MoveTo(1, 1);
	Term1_SendStr("CC2511 - Assignment 2");

	// Left hand box
	Term1_SetColor(clBlack, clYellow);
	Term1_MoveTo(1, 3);
	Term1_SendStr("+-- CNC Status --+\r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");
	Term1_SendStr("                  \r\n");

	//left instruction box
	Term1_SetColor(clWhite, clBlack);
	Term1_MoveTo(2, 4);
	Term1_SendStr("                ");
	Term1_MoveTo(2, 5);
	Term1_SendStr("                ");
	Term1_MoveTo(2, 6);
	Term1_SendStr("   X:  0        ");
	Term1_MoveTo(2, 7);
	Term1_SendStr("   Y:  0        ");
	Term1_MoveTo(2, 8);
	Term1_SendStr("   Z:  0        ");
	Term1_MoveTo(2, 9);
	Term1_SendStr("   S:  0        ");
	Term1_MoveTo(2, 10);
	Term1_SendStr("                ");

	// Right side instruction box
	Term1_SetColor(clBlack, clYellow);
	Term1_MoveTo(20, 3);
	Term1_SendStr("+----------------- [ How to Use ] -----------------+");
	Term1_MoveTo(20, 4);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 5);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 6);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 7);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 8);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 9);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 10);
	Term1_SendStr("                                                    ");
	Term1_MoveTo(20, 11);
	Term1_SendStr("                                                    ");

	Term1_SetColor(clWhite, clBlack);
	Term1_MoveTo(21, 4);
	Term1_SendStr("                                                  ");
	Term1_MoveTo(21, 5);
	Term1_SendStr("      Type the following command:                 ");
	Term1_MoveTo(21, 6);
	Term1_SendStr("       > Xn    Move to n position on X axis       ");
	Term1_MoveTo(21, 7);
	Term1_SendStr("       > Yn    Move to n position on Y axis       ");
	Term1_MoveTo(21, 8);
	Term1_SendStr("       > Zn    Move to n position on Z axis       ");
	Term1_MoveTo(21, 9);
	Term1_SendStr("       > H     Move spindle to designated home    ");
	Term1_MoveTo(21, 10);
	Term1_SendStr("       > Sn    Set spindle to speed n             ");

	Term1_SetColor(clWhite, clBlack);
	Term1_MoveTo(1, 13);
	Term1_SendStr("Command prompt: \r\n");
	Term1_SendStr("> ");

	Term1_MoveTo(3, 17);
	Term1_SendStr("Error Code:                                                                       ");
	Term1_MoveTo(3, 14);
}

// Time delay function
void timeDelay(word delayms) {
	//
	// Takes in a word delayms (the amount of milliseconds to be delayed), returns nothing
	//
	word time;
	timer_Reset();
	do {
		__asm("wfi");
		timer_GetTimeMS(&time);
	} while (time < delayms);
}

/*lint -save  -e970 Disable MISRA rule (6.3) checking. */
int main(void)
/*lint -restore Enable MISRA rule (6.3) checking. */
{
	/* Write your local variable definition here */
	// make these pos values a float
	// These variables are passed into the sscanf function for the received command
	// pretty self explanatory names
	int16 xPos;
	int16 yPos;
	int16 zPos;
	int8 sPWM;

	//set limit variables for error checking
	int32 xLim;
	int32 yLim;
	int32 zLim;
	int16 sLim;

	// These variables store the 'Dif'ference between the current amount of steps taken
	// and the amount of steps that should be take as received from the serial interface
	// eg currentPos.x = 500 (steps) and xPos = 700 (steps)
	// therefore we need to move 200 steps (the 'dif'ference) to be at our goal position
	int16 xDif = 0;
	int16 yDif = 0;
	int16 zDif = 0;

	// Initialising position structs. One for current position and the other for our
	// goal position as received from the serial interface
	struct position currentPos;
	currentPos.x = 0;
	currentPos.y = 0;
	currentPos.z = 0;

	// goalPos is kind of redundant as all the calculations rely on the difference but I keep it for souvenir sake
	// forever in my heart goalPos
	struct position goalPos;
	goalPos.x = 0;
	goalPos.y = 0;
	goalPos.z = 0;

	//Variables foe error checking
	const char *acceptable_inputs = "XYZSH0123456789-";
	int error_code = 0;
	char errorone[] ="Error 1-Command entered is an invalid command";
	char errortwo[] ="Error 2-Value entered is out of range for desired command";

	/*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
	PE_low_level_init();
	/*** End of Processor Expert internal initialization.                    ***/

	// Setting relevant enabling bits for the stepper drivers as defined in DRV8825 datasheet
	nSleep_SetVal();
	nEnable_ClrVal();
	nReset_SetVal();
	// Full step mode. Could add functionality to change this but full stepping works fine ATM
	mode0_ClrVal();
	mode1_ClrVal();
	mode2_ClrVal();

	// Redundant terminal block code YUCK. GUI ALL THA WAY BABY!!!
	/* Write your code here */
	/* For example: for(;;) { } */

	draw_GUI();
	for (;;) {

		// Wait For Interrupt
		while (!complete_command) {
			__asm("wfi");
		}

		// We have gotten a complete
		if (complete_command) {

			//clear any previous error codes when a new input is entered and move cursor back to desired position
			Term1_MoveTo(3, 17);
			Term1_SendStr("Error Code:                                                                                    ");
			Term1_MoveTo(3, 14);
			error_code = 0;

			// Extract the first split element from the command
			// Command is in form "X. Y. Z. S." with dot being an integer value for the amount of steps the engraver should be at from 0
			char *element = strtok(buffer, " ");

			//Check for acceptable_inputs

			// Loop over each element extracted "X.", "Y.", etc.
			while (element != NULL && error_code == 0) {

				char *serialInput = element;
				char *c = serialInput;
				while (*c) {
					if (!strchr(acceptable_inputs, *c)) {
						error_code = 1;
						break;
					}
					c++;
				}

				// If there is an X. present
				if (sscanf((char *) element, "X%hu", &xPos) > 0) {

					// Calculate the difference between where engraver currently is and where serial command says it should be
					xDif = currentPos.x - xPos;

					if (abs(xDif) > 1000) {
						error_code = 2;
						break;
					}


					// If the difference is less than 0, move forward (our target position is further ahead than out current position)
					if (xDif > 0) {
						xDir_ClrVal();
					} else {
						// else move backward
						xDir_PutVal(1);
					}
					// Update the goal position struct
					goalPos.x = xPos;
					Term1_MoveTo(3, 6);
					Term1_SendStr("  X:       ");
					Term1_MoveTo(9, 6);
					Term1_SendNum(xPos);
				}

				// Same process for Y
				if (sscanf((char *) element, "Y%hu", &yPos) > 0) {

					yDif = currentPos.y - yPos;

					if (abs(yDif) > 1000) {
						error_code = 2;
						break;
					}


					if (yDif > 0) {
						yDir_ClrVal();
					} else {
						yDir_PutVal(1);
					}
					goalPos.y = yPos;
					Term1_MoveTo(3, 7);
					Term1_SendStr("  Y:       ");
					Term1_MoveTo(9, 7);
					Term1_SendNum(yPos);
				}

				// Same process for Z
				if (sscanf((char *) element, "Z%hu", &zPos) > 0) {

					zDif = currentPos.z - zPos;
					if (abs(zDif) > 1000) {
						error_code = 2;
						break;
					}


					if (zDif > 0) {
						zDir_ClrVal();
					} else {
						zDir_PutVal(1);
					}
					goalPos.z = zPos;
					Term1_MoveTo(3, 8);
					Term1_SendStr("  Z:       ");
					Term1_MoveTo(9, 8);
					Term1_SendNum(zPos);
				}

				// If there is an "S."
				// The value after the spindle ranges from 0 - 255 (an 8bit integer)
				// Therefore we can set this value staright to the spindle PWM component
				if (sscanf((char *) element, "S%hu", &sLim) > 0) {

					//check if spindle input is a valid input
					if (sLim < 0 || sLim > 255) {
						error_code = 2;
						break;
					}
					sPWM = sLim;
					spindle_SetRatio8(sPWM);
					Term1_MoveTo(3, 9);
					Term1_SendStr("  S:       ");
					Term1_MoveTo(9, 9);
					Term1_SendNum(sPWM);
				}

				// If "HOME" command is received. This is the calibrating command that sets location our engraver to be at [0, 0, 0]
				// NOTE: This function does not move the engraver, it merely sets the current position stored in memory to be at 0,
				// The moving is done through normal "X. Y. Z." instructions
				if (0 == strcmp((char *) element, "H")) {
					currentPos.x = 0;
					currentPos.y = 0;
					currentPos.z = 0;
					goalPos.x = 0;
					goalPos.y = 0;
					goalPos.z = 0;
				}

				// Get the next element in the instruction.
				element = strtok(NULL, " ");
			}

			if (error_code == 0) {
				// Dodgy workaround to find the maximum value of 3 variables by using a temporary variable to store the max of the first two and
				// then comparing the temporary max and the third variable.
				int16 temp = max(abs(xDif), abs(yDif));
				int16 maxValue = max(temp, abs(zDif));

				// The maximum value will be a hard stop for this loop, preventing unnecessary iterations
				for (int i = 0; i < maxValue; i++) {
					// If the amount of times iterated is less than the number of steps that need to be taken, set the step bit to be
					// high, causing a rising edge and a step from the DRV8825
					if (i < abs(xDif)) {
						xStep_SetVal();
					}
					if (i < abs(yDif)) {
						yStep_SetVal();
					}
					if (i < abs(zDif)) {
						zStep_SetVal();
					}

					// wait 5 milliseconds. Hard coded value could be better.
					timeDelay(5);
					// Set all the step bits back to low
					xStep_ClrVal();
					yStep_ClrVal();
					zStep_ClrVal();
				}
				// Clear the direction bits, not really necessary as these bits get set in the extracting elements
				// and completing necessary calculations loop
				xDir_ClrVal();
				yDir_ClrVal();
				zDir_ClrVal();

				// Set the differences back to 0 as otherwise the difference will be executed on the next command even if that axes was specified
				// eg If xDif was 50 and the next command is "Y0 Z0", xDif will not be recalculated leading to 50 steps in the x direction
				// being executed. UNIDEAL
				xDif = 0;
				yDif = 0;
				zDif = 0;

				// Update the current position to reflect the fact we have moved. I LIKE TO MOVE IT MOVE IT
				currentPos.x = goalPos.x;
				currentPos.y = goalPos.y;
				currentPos.z = goalPos.z;

			} else if (error_code == 1) {
				Term1_MoveTo(15, 17);
				Term1_SendStr(errorone);
			} else if (error_code == 2) {
				Term1_MoveTo(15, 17);
				Term1_SendStr(errortwo);
			}
			// Set these to prevent constant looping and issues with the receiving buffer
			complete_command = false;
			index = 0;
			Term1_MoveTo(1, 14);
			Term1_SendStr(">                                       ");
			Term1_MoveTo(3, 14);

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
