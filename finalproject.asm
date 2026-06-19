; =====================================================================
; Project Title: Text-Based "Loading" Bar (Project 7)
; Course: Low-Level System Design & Hardware-Software Interfacing
; Description: Visual progress bar using colored blocks (ASCII 219) with 
;              a delay loop. Demonstrates memory segmentation, logical 
;              control flow, modular procedures, and BIOS/DOS interrupts.
; =====================================================================

.MODEL SMALL        ; Defines memory model: 1 segment for code (<64KB), 1 for data (<64KB)
.STACK 100h         ; Reserves 256 bytes (100 in Hex) in memory for the Stack operations

.DATA               ; Starts the Data Segment where variables and strings are stored
    ; Strings must end with '$' so DOS interrupt 21h knows where the text stops
    msg_loading  DB 'System Initializing...', '$' ; Defines bytes for the loading text
    msg_done     DB 'Loading Complete! Press any key to exit.', '$' ; Defines completion text
    msg_100      DB '100%$'                       ; Defines the final 100% text

.CODE               ; Starts the Code Segment where actual executable instructions go
MAIN PROC           ; Defines the start of the Main Procedure
START:              ; A label marking the entry point of the program execution

    ; --- 1. Memory Segmentation Setup ---
    MOV AX, @DATA       ; Loads the starting memory address of the Data Segment into AX
    MOV DS, AX          ; Moves that address from AX to DS (Data Segment Register) to access variables

    ; --- 2. Screen Initialization ---
    CALL CLEAR_SCREEN_PROC  ; Jumps to the procedure that clears the screen and sets the background

    ; --- 3. Display Header Message ---
    MOV AH, 02h         ; Prepares AH register with 02h (BIOS function to set cursor position)
    MOV BH, 0           ; Sets Video Page Number to 0 (default display page)
    MOV DL, 28          ; Sets the X-coordinate (Column) to 28
    MOV DH, 10          ; Sets the Y-coordinate (Row) to 10
    INT 10h             ; Executes Video BIOS Interrupt to physically move the cursor

    MOV AH, 09h         ; Prepares AH with 09h (DOS function to output a string)
    LEA DX, msg_loading ; Loads the memory address of 'msg_loading' into the DX register
    INT 21h             ; Executes DOS Interrupt to print the string to the screen

    ; --- 4. Draw Progress Bar Borders ---
    CALL DRAW_BORDERS_PROC  ; Jumps to the procedure that draws the top and bottom dashes

    ; --- 5. Main Loading Loop ---
    MOV CX, 1           ; Initializes loop counter CX to 1 (starting block number)
    
START_LOADING_LOOP:     ; Label indicating the start of the repeating loop
    PUSH CX             ; Pushes the current value of CX onto the Stack to save it

    ; Calculate and position the block
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position for the new block
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 24          ; Sets the base column starting point for the bar (Column 24)
    ADD DL, CL          ; Adds current loop number to column to move cursor right step-by-step
    MOV DH, 13          ; Sets the Y-coordinate (Row) to 13 (between the drawn borders)
    INT 10h             ; Executes Video BIOS Interrupt to move the cursor

    ; Draw the solid block character (ASCII 219)
    MOV AH, 09h         ; Prepares AH with 09h (BIOS function to write char and attribute)
    MOV AL, 219         ; Loads the ASCII code 219 (Solid green block) into AL
    MOV BL, 1Ah         ; Sets color attribute: Light Green text (A) on Blue background (1)
    PUSH CX             ; Saves CX again because INT 10h (function 09h) uses CX for repetition
    MOV CX, 1           ; Tells the interrupt to print exactly 1 character at a time
    INT 10h             ; Executes Video BIOS Interrupt to print the colored block
    POP CX              ; Restores the original loop counter back into CX from the stack

    ; Position cursor for percentage output
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position for the numbers
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 56          ; Sets the X-coordinate (Column) to 56 (right side of the bar)
    MOV DH, 13          ; Sets the Y-coordinate (Row) to 13 (same line as the bar)
    INT 10h             ; Executes Video BIOS Interrupt to move the cursor
    
    ; Retrieve loop counter for math
    MOV BP, SP          ; Copies Stack Pointer (SP) into Base Pointer (BP) to access stack safely
    MOV AX, [BP]        ; Retrieves the saved CX value from the stack memory into AX

    ; Calculate Percentage
    MOV BL, 3           ; Loads multiplier 3 into BL (Each step is roughly 3.3%)
    MUL BL              ; Multiplies AL by BL (Result is stored in AX)
    
    MOV BL, 10          ; Loads divisor 10 into BL to separate tens and units
    DIV BL              ; Divides AX by 10 (AL = Tens quotient, AH = Units remainder)
    ADD AX, 3030h       ; Adds 30h to both AH and AL to convert raw numbers to ASCII characters
    MOV BX, AX          ; Saves the ASCII characters safely into the BX register
    
    ; Print tens digit
    MOV AH, 02h         ; Prepares AH with 02h (DOS function to output a single character)
    MOV DL, BL          ; Moves the tens digit (from BL) into DL for printing
    INT 21h             ; Executes DOS Interrupt to print the tens digit
    
    ; Print units digit
    MOV DL, BH          ; Moves the units digit (from BH) into DL for printing
    INT 21h             ; Executes DOS Interrupt to print the units digit
    
    ; Print '%' symbol
    MOV DL, '%'         ; Loads the percentage symbol character into DL
    INT 21h             ; Executes DOS Interrupt to print the '%' symbol

    ; Delay for visual animation effect
    CALL DELAY_PROC     ; Jumps to the procedure that pauses the CPU for a fraction of a second

    POP CX              ; Restores the main loop counter from the Stack back into CX
    INC CX              ; Increments the loop counter by 1 (moves to the next step)
    CMP CX, 31          ; Compares CX with 31 (Checking if we printed all 30 blocks)
    JNE START_LOADING_LOOP  ; Jumps back to START_LOADING_LOOP if CX is Not Equal to 31

    ; --- 6. Finalize Loading (100%) ---
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 56          ; Sets column to 56 (where the percentage was printing)
    MOV DH, 13          ; Sets row to 13
    INT 10h             ; Executes BIOS Interrupt to move cursor
    
    MOV AH, 09h         ; Prepares AH with 09h to print a string
    LEA DX, msg_100     ; Loads the address of 'msg_100' ("100%") to overwrite the 90%
    INT 21h             ; Executes DOS Interrupt to print the string

    ; --- 7. Display Completion Message ---
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 20          ; Sets Column to 20 (centered below the bar)
    MOV DH, 16          ; Sets Row to 16
    INT 10h             ; Executes BIOS Interrupt to move cursor
    
    MOV AH, 09h         ; Prepares AH with 09h to print a string
    LEA DX, msg_done    ; Loads the address of 'msg_done' into DX
    INT 21h             ; Executes DOS Interrupt to print the final message

    ; Wait for keypress before closing
    MOV AH, 00h         ; Prepares AH with 00h (BIOS function to read keyboard input)
    INT 16h             ; Executes Keyboard BIOS Interrupt (pauses program until key is pressed)

EXIT_PROG:          ; Label marking the exit routine
    MOV AH, 4Ch         ; Prepares AH with 4Ch (DOS function to terminate process securely)
    INT 21h             ; Executes DOS Interrupt to return control to the Operating System
MAIN ENDP           ; Marks the end of the Main Procedure

; =====================================================================
; PROCEDURES (Modular Code Implementation)
; =====================================================================

; Procedure to clear screen and set background color
CLEAR_SCREEN_PROC PROC  ; Defines the start of the CLEAR_SCREEN_PROC procedure
    MOV AX, 0600h       ; AH=06h (BIOS scroll up function), AL=00h (Clear entire screen)
    MOV BH, 17h         ; Sets color attribute: Light Gray text (7) on Blue background (1)
    MOV CX, 0000h       ; Sets top-left corner of the scroll window at Row 0, Column 0
    MOV DX, 184Fh       ; Sets bottom-right corner of the scroll window at Row 24, Column 79
    INT 10h             ; Executes Video BIOS Interrupt to apply the clear/color operation
    RET                 ; Returns control back to the line that called this procedure
CLEAR_SCREEN_PROC ENDP  ; Marks the end of the procedure

; Procedure to draw top and bottom borders for the progress bar
DRAW_BORDERS_PROC PROC  ; Defines the start of the DRAW_BORDERS_PROC procedure
    ; Top Border
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 25          ; Sets Column to 25
    MOV DH, 12          ; Sets Row to 12 (one row above the loading bar)
    INT 10h             ; Executes BIOS Interrupt to move cursor
    
    MOV AH, 09h         ; Prepares AH with 09h to write character and attribute
    MOV AL, '-'         ; Loads the dash character '-' into AL
    MOV BL, 1Fh         ; Sets color: Bright White text (F) on Blue background (1)
    MOV CX, 30          ; Sets CX to 30 (tells the interrupt to print the dash 30 times)
    INT 10h             ; Executes Video BIOS Interrupt to draw the top border

    ; Bottom Border
    MOV AH, 02h         ; Prepares AH with 02h to set cursor position
    MOV BH, 0           ; Sets Video Page to 0
    MOV DL, 25          ; Sets Column to 25
    MOV DH, 14          ; Sets Row to 14 (one row below the loading bar)
    INT 10h             ; Executes BIOS Interrupt to move cursor
    
    MOV AH, 09h         ; Prepares AH with 09h to write character and attribute
    MOV AL, '-'         ; Loads the dash character '-' into AL
    MOV CX, 30          ; Sets CX to 30 to repeat the character 30 times
    INT 10h             ; Executes Video BIOS Interrupt to draw the bottom border
    RET                 ; Returns control back to the caller
DRAW_BORDERS_PROC ENDP  ; Marks the end of the procedure

; Procedure to create a time delay using System Interrupt
DELAY_PROC PROC         ; Defines the start of the DELAY_PROC procedure
    MOV CX, 02h         ; Loads High Word of the wait time (in microseconds) into CX
    MOV DX, 4240h       ; Loads Low Word of the wait time into DX (Total time ~150ms)
    MOV AH, 86h         ; Prepares AH with 86h (BIOS System function for Wait/Pause)
    INT 15h             ; Executes System Services BIOS Interrupt to pause the CPU
    RET                 ; Returns control back to the caller
DELAY_PROC ENDP         ; Marks the end of the procedure

END START               ; Directs the Assembler to finish, setting 'START' as the entry point
