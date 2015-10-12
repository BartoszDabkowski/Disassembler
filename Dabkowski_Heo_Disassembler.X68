*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Bartosz Dabkowski and Bethel Heo
* Date       : 6/7/2015
* Description: CSS 422 - Final Project
*-----------------------------------------------------------

*-------------------------------------------------------------------
* Constants
*-------------------------------------------------------------------

*A1
*A2 
*A3 VALID BUFFER
*A4
*A5 STARTING ADDRESS
*A6 ENDING ADDRESS
*A7

*D1
*D2
*D3 
*D4
*D5 START ADDRESS
*D6 END ADDRESS
*D7 Max number of lines


VALID_BUFFER        EQU     $00800000               valid buffer
CR                  EQU     $0D
LF                  EQU     $0A

*-------------------------------------------------------------------
* Bitmasks
*-------------------------------------------------------------------

OP_AND_BITMASK      EQU %1111000000000000   value to and with to check op code
OP_0000_BITMASK     EQU %0000000000000000   bitmask for 0000
OP_0001_BITMASK     EQU %0001000000000000   bitmask for 0001
OP_0010_BITMASK     EQU %0010000000000000   bitmask for 0010
OP_0011_BITMASK     EQU %0011000000000000   bitmask for 0011
OP_0100_BITMASK     EQU %0100000000000000   bitmask for 0100
OP_0101_BITMASK     EQU %0101000000000000   bitmask for 0101
OP_0110_BITMASK     EQU %0110000000000000   bitmask for 0110
OP_1000_BITMASK     EQU %1000000000000000   bitmask for 1000
OP_1001_BITMASK     EQU %1001000000000000   bitmask for 1001
OP_1011_BITMASK     EQU %1011000000000000   bitmask for 1011
OP_1100_BITMASK     EQU %1100000000000000   bitmask for 1100
OP_1101_BITMASK     EQU %1101000000000000   bitmask for 1101
OP_1110_BITMASK     EQU %1110000000000000   bitmask for 1110

D_REG_BITMASK       EQU %0000111000000000   bitmask for destination reg
D_MODE_BITMASK      EQU %0000000111000000   bitmask for destination mode
S_MODE_BITMASK      EQU %0000000000111000   bitmask for source mode
S_REG_BITMASK       EQU %0000000000000111   bitmask for source reg

BIT_15_BITMASK      EQU %1000000000000000   bitmask for bit 15
BIT_14_BITMASK      EQU %0100000000000000   bitmask for bit 14
BIT_13_BITMASK      EQU %0010000000000000   bitmask for bit 13
BIT_12_BITMASK      EQU %0001000000000000   bitmask for bit 12
BIT_11_BITMASK      EQU %0000100000000000   bitmask for bit 11
BIT_10_BITMASK      EQU %0000010000000000   bitmask for bit 10
BIT_09_BITMASK      EQU %0000001000000000   bitmask for bit 09
BIT_08_BITMASK      EQU %0000000100000000   bitmask for bit 08
BIT_07_BITMASK      EQU %0000000010000000   bitmask for bit 07
BIT_06_BITMASK      EQU %0000000001000000   bitmask for bit 06
BIT_05_BITMASK      EQU %0000000000100000   bitmask for bit 05
BIT_04_BITMASK      EQU %0000000000010000   bitmask for bit 04
BIT_03_BITMASK      EQU %0000000000001000   bitmask for bit 03
BIT_02_BITMASK      EQU %0000000000000100   bitmask for bit 02
BIT_01_BITMASK      EQU %0000000000000010   bitmask for bit 01
BIT_00_BITMASK      EQU %0000000000000001   bitmask for bit 00

BIT_11_TO_09        EQU %0000111000000000   bitmask for bits 11-09
BIT_11_TO_08        EQU %0000111100000000   bitmask for bits 11-08
BIT_11_TO_06        EQU %0000111111000000   bitmask for bits 11-06
BIT_08_TO_06        EQU %0000000111000000   bitmask for bits 08-06 
BIT_07_TO_00        EQU %0000000011111111   bitmask for bits 07-00
BIT_07_TO_06        EQU %0000000011000000   bitmask for bits 07-00
BIT_04_TO_03        EQU %0000000000011000   bitmask for bits 04-03
BIT_07_TO_06        EQU %0000000011000000   bitmask for bits 07-06
BIT_05_TO_00        EQU %0000000000111111   bitmask for bits 05-00
BIT_05_TO_03        EQU %0000000000111000   bitmask for bits 05-03
        
        
        ORG    $1000
START:
        LEA     VALID_BUFFER,A3     load valid buffer into A3

*******************************************************************
*                       GET_ADDRESSES                             *
*******************************************************************
*   Gets valid starting and end addresses from user
*   Address must be 8 bits            ORG    $1000*   POST:  D4 will store starting address
*          A4 will have starting address set to user input
*          D5 will store ending address
*          A5 will have ending address set to user input
*------------------------------------------------------------------
GET_ADDRESSES  
*-------Print welcome message-------------------
        LEA     WELCOME,A1     
        MOVE.B  #14,D0
        TRAP    #15
        
*-------Print starting address input message----    
        LEA     START_ADDRESS,A1  
        MOVE.B  #14,D0
        TRAP    #15
*-----------------------------------------------
        
        MOVEA.L #$00000000,A1       change A1 address to $0000 0000
        MOVE.L  #$00000000,(A1)     clear A1
        
*-------Get user input (STRING) for starting address

        MOVE.B  #2,D0                   
        TRAP    #15
        
        JSR     CHECK_VALID_ADDRESS
           
        MOVE.L  ($00000000),D5      move 4 most significant bytes to D5 (contents of A1)
        MOVE.L  D5,D2               copy D6 to D2
        MOVE.L  ($00000004),D5      move 4 least significant bytes to D5 (contents of A1)
        MOVE.L  D5,D3               copy D6 to D3   
        JSR     CONVERT_DEC_TO_ASCII 
        
        MOVE.L  D2,A5               assign address to A5
        MOVE.L  D2,D5               assign address to D5
        
*-------Print ending address input message------   
        LEA     END_ADDRESS,A1  
        MOVE.B  #14,D0
        TRAP    #15
        
*-----------------------------------------------

        MOVEA.L #$00000000,A1       change A1 address to $0000 0000
        MOVE.L  #$00000000,(A1)     clear A1
        
*-------Get user input (STRING) for ending address
        MOVE.B  #2,D0                   
        TRAP    #15
        
        JSR     CHECK_VALID_ADDRESS
        
        MOVE.L  ($00000000),D6      move 4 most significant bytes to D6 (contents of A1)
        MOVE.L  D6,D2               copy D7 to D2
        MOVE.L  ($00000004),D6      move 4 least significant bytes to D6 (contents of A1)
        MOVE.L  D6,D3               copy D7 to D2   
        JSR     CONVERT_DEC_TO_ASCII 
        
        MOVE.L  D2,A6               assign address to A6
        MOVE.L  D2,D6               assign address to D6

*-------Check to see if start address is smaller than end address    
        CMP.L   D5,D6
        BLT     INVALID_ADDRESS                              

*-------Clear registers
        MOVE.L  #$00000000,D0
        MOVE.L  #$00000000,D1
        MOVE.L  #$00000000,D2
        MOVE.L  #$00000000,D3
        
*-------Load Max lines to print (25) and start the simulation
        LEA     STARTINGDIS,A1      print starting message
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.B  #$00,D7             max lines
        BRA     START_DISASSEMBLER  start dissassmbler

      
 
*************************************************
*           CHECK_VALID_ADDRESS                 *
*************************************************
* checks if the address stored in A1 is a valid *
* 8 byte hex value                              *
*************************************************
CHECK_VALID_ADDRESS
                                    *D2 keeps track of loop
        MOVE.L  #0,D2               zeros out D2
        
LOOP_1  CMP.B   #8,D2               checks loop (8 loops total)
        BGE     END_LOOP_1
        MOVE.B  (A1)+,D1            move contents of A1 to D1 and increment pointer
        JSR     CHECK_IF_HEX        check if inputed is a valid hex
        ADDI.B  #1,D2               increment D2
        BRA     LOOP_1   

END_LOOP_1        
        MOVE.B  (A1),D1             check if 9th byte is NULL
        CMP.B   #$00,D1             so that lenght is a long
        BNE     INVALID_ADDRESS
        RTS                         address is valid
     
*************************************************
*           CHECK_IF_HEX                        *
*************************************************
* checks if the byte is a valid hex number      *   
* 0-9 and A-F                                   *
*************************************************   
CHECK_IF_HEX

        CMP.B   #$30,D1             check if number
        BLT     CHECK_IF_HEX_LETTER check if letter
        
        CMP.B   #$39,D1             check if number
        BGT     CHECK_IF_HEX_LETTER check if letter
        
        RTS                         hex is valid

*************************************************
*           CHECK_IF_HEX_LETTER                 *
*************************************************
* checks if the byte is between A and F         *
*************************************************        
CHECK_IF_HEX_LETTER

        CMP.B   #$41,D1            less than A
        BLT     INVALID_ADDRESS
    
        CMP.B   #$46,D1            greater than F
        BGT     INVALID_ADDRESS

        RTS                        if it passes all tests then it is a valid hex
  
*************************************************
*           INVALID_ADDRESS                     *
*************************************************
* outputs invalid address message and returns   * 
* back to address input                         *
*************************************************       
INVALID_ADDRESS

*-------Print invalid address message------------ 
        LEA     INVALIDA, A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     GET_ADDRESSES       invalid address start over
        
        
*******************************************************************
*                       CONVERT_DEC_TO_ASCII                      *
*******************************************************************
*   PRE:   D2 & D3 must store decimals that are to be converted to 
*          ascii 4 most significant digits      ex: FFFF....
*          D3 must store last 4                 ex: ....FFFF
*   POST:  D2 will store the converted value
*               ex: D2 = 41424344  -> D2 = 0000ABCD
*                   D3 = 31323334  -> D3 = 12340000
*                   D2 = D2 + D3
*                   D2 = 1234ABCD
*------------------------------------------------------------------
CONVERT_DEC_TO_ASCII
        
        MOVE.L  D2,D1               moves D2 into D1
        LSR.L   #8,D1               isolate MSD
        LSR.L   #8,D1
        LSR.L   #8,D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D2,D1               make a copy of starting to D1
        LSR.L   #8,D1               isolate the next digits
        LSR.L   #8,D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D2,D1               make a copy of starting to D1
        LSR.L   #8,D1               isolate the next digits
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D2,D1               make a copy of starting to D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
*-------------------------------------------------------------------
* Creates a long of the address and then points A6 to that value
*-------------------------------------------------------------------        

        MOVE.L  #$00000000,A2   return to beginning of A6
        MOVE.B  (A2)+,D1        move the byte into D1
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2)+,D1        adds the next byte
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2)+,D1        adds the next byte
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2),D1         adds the next byte
        
        MOVE.L  #$00000000,A2   return to beginning of A6
        
        LSL.L   #8,D1           adds in zeros so we can swap                
        LSL.L   #8,D1
        
        MOVE.L  D1,D2
        
*---------------------------------------------------------------------

        MOVE.L  D3,D1               moves D2 into D1
        LSR.L   #8,D1               isolate MSD
        LSR.L   #8,D1
        LSR.L   #8,D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D3,D1               make a copy of starting to D1
        LSR.L   #8,D1               isolate the next digits
        LSR.L   #8,D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D3,D1               make a copy of starting to D1
        LSR.L   #8,D1               isolate the next digits
        JSR     NUMBER_OR_LETTER    check if letter or number
        
        MOVE.L  D3,D1               make a copy of starting to D1
        JSR     NUMBER_OR_LETTER    check if letter or number
        
*-------------------------------------------------------------------
* Creates a long of the address and then points A6 to that value
*-------------------------------------------------------------------        

        MOVE.L  #$00000000,A2   return to beginning of A6
        MOVE.B  (A2)+,D1        move the byte into D1
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2)+,D1        adds the next byte
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2)+,D1        adds the next byte
        
        LSL.L   #4,D1           shifts the nibble left
        ADD.B   (A2),D1         adds the next byte
        
        MOVE.L  #$00000000,A2   return to beginning of A6
        
        LSL.L   #8,D1           adds in zeros so we can swap                
        LSL.L   #8,D1
        
        SWAP    D1
        
        ADD.W   D1,D2

        RTS
                
NUMBER_OR_LETTER
        CMP.B   #$41,D1         less than 41 hex is a number
        BLT     CONVERT_NUMBER  branch for number
        
        SUBI.B  #$37,D1         no branch is letter. convert to hex
        MOVE.B  D1,(A2)+        store in A6 and increment
        RTS
        
CONVERT_NUMBER
        SUBI.B  #$30,D1         convert to hex for number
        MOVE.B  D1,(A2)+        store in A6 and increment
        RTS        


*******************************************************************
*                       START_DISASSEMBLER                        *
*******************************************************************
*   PRE:    A2 
*           A3 VALID BUFFER
*           A4 INVALID BUFFER
*           A5 CURRENT ADDRESS
*           A6 ENDING ADDRESS

*           D2 DATA TO MINIPULATE
*           D3 ORIGINAL CODE
*           D4 
*           D5 
*           D6
*           D7 MAX LINES TO PRINT (25)
*------------------------------------------------------------------
START_DISASSEMBLER
        ADDI.B  #1,D7               increment max lines
        CMP.B   #$19,D7             compare it to 25 lines
        BGT     FULL_SCREEN         screen is full
        
        CMPA.L  A5,A6               compare starting address to ending
        BLT     END_DISASSEMBLER    reached the end
        
        JSR     BUFFER_ADDRESS      buffers the address
        JSR     PRINT_VALID_BUFFER  prints the address
        
        LEA     TAB,A1              print tab
        MOVE.B  #14,D0
        TRAP    #15
        
        BRA     PRINT_INSTRUCTION   buffers and prints instruction

*******************************************************************
*                         FULL_SCREEN                             *
*******************************************************************
*   PRE:   Max lines reached. Prompt user to continue.
*   POST:  Clears the screen and continues
*------------------------------------------------------------------
FULL_SCREEN 
        MOVE.B  #$00,D7             starts counter over
        
        MOVE.B  #14,D0              asks user to continue
        LEA     CONTINUEPROMPT,A1
        TRAP    #15
        
        MOVEA.L #$00000000,A1       move A1
        MOVE.B  #2,D0               user input
        TRAP    #15
        
        BRA     CLEAR_SCREEN

*-------------------------------------------------------------------
* Clears the screen if the user choose yes. Starts buffers over
*------------------------------------------------------------------- 
CLEAR_SCREEN
        MOVE.W  #$FF00,D1           clear screen                                      
        MOVE.B  #11,D0
        TRAP    #15
        
        MOVEA.L #$00800000,A3       reset valid buffer
        MOVEA.L #$00900000,A4       reset invalid buffer
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*                       BUFFER_ADDRESS                            *
*******************************************************************
*   PRE:   A3 VALID BUFFER
*          A5 CURRENT ADDRESS
*          
*          D2 ADDRESS TO MINIPULATE
*   POST:  Prints the current address and then increments by 1
*------------------------------------------------------------------
BUFFER_ADDRESS
        CLR.L   D2                  clear data registers
        CLR.L   D3
        MOVE.L  A5,D3
        MOVE.L  D3,D2               move the address location to D2
        
        JSR     ISOLATE_FIRST_DIGIT isolate and buffer MSD digit
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_SECOND_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_THIRD_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_FOURTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_FIFTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_SIXTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_SEVENTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_EIGHTH_DIGIT isolate and buffer LSD digit
        JSR     CONVERT_AND_BUFFER
        
        RTS
        
*-------------------------------------------------------------------
* Isolates the digits so we can convert them to ASCII to print
*-------------------------------------------------------------------      
   
ISOLATE_FIRST_DIGIT
        LSR.L   #8,D2
        LSR.L   #8,D2
        LSR.L   #8,D2
        LSR.L   #4,D2
        RTS
    
ISOLATE_SECOND_DIGIT
        LSL.L   #4,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS
        
ISOLATE_THIRD_DIGIT
        LSL.L   #8,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS

ISOLATE_FOURTH_DIGIT
        LSL.L   #8,D2
        LSL.L   #4,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS

ISOLATE_FIFTH_DIGIT
        LSL.L   #8,D2
        LSL.L   #8,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS
        
ISOLATE_SIXTH_DIGIT
        LSL.L   #8,D2
        LSL.L   #8,D2
        LSL.L   #4,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS

ISOLATE_SEVENTH_DIGIT
        LSL.L   #8,D2
        LSL.L   #8,D2
        LSL.L   #8,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS

ISOLATE_EIGHTH_DIGIT
        LSL.L   #8,D2
        LSL.L   #8,D2
        LSL.L   #8,D2
        LSL.L   #4,D2
        JSR     ISOLATE_FIRST_DIGIT
        RTS      
        
*-------------------------------------------------------------------
* Converts the hex to ASCII for printing the address
*-------------------------------------------------------------------
CONVERT_AND_BUFFER
        JSR     CONVERT_TO_ASCII    convert to ASCII
        MOVE.B  D2,(A3)+            put into buffer
        
        MOVE.L  D3,D2               restore address
        
        RTS
        
CONVERT_TO_ASCII
        CMP.B   #$A,D2              find out if its letter or number
        BLT     ASCII_NUMBER        number
        BRA     ASCII_LETTER        letter

ASCII_NUMBER
        ADD.B   #$30,D2             convert to ascii number
        RTS
        
ASCII_LETTER
        ADD.B   #$37,D2             convert to ascii letter
        RTS


*******************************************************************
*                     PRINT_INSTRUCTION                           *
*******************************************************************
*   PRE:    A2 
*           A3 VALID BUFFER
*           A4 INVALID BUFFER
*           A5 CURRENT ADDRESS
*           A6 ENDING ADDRESS

*           D2 DATA TO MINIPULATE
*           D3 ORIGINAL CODE
*           D4 
*           D5 
*           D6
*           D7 MAX LINES TO PRINT (25)
*------------------------------------------------------------------
PRINT_INSTRUCTION
        MOVE.W  (A5)+,D3         move the data from A5 to D3
        BRA     OP_CODE_TABLE    check through the op code table

****************************************************************************************
*                               OPCODE                                                 *
****************************************************************************************

*******************************************************************
*                       OP_CODE_TABLE                             *
*******************************************************************
*   PRE:   D2 DATA TO MINIPULATE
*          D3 ORIGINAL CODE
*          D4 HOLDS CODE_BITMASK
*          D5 HOLDS OP_BITMASK
*          D6 HOLDS #$0000 TO COMPARE
*          D7 MAX LINES *
*          
*   POST:  Goes through the op codes to find out which one it is
*------------------------------------------------------------------

OP_CODE_TABLE
        MOVE.W  D3,D2               move original to D2 to mess with
        MOVE.W  #$0000,D6           #$0000 value to compare
        
        JSR     OPCODE_0000_TEST
        JSR     OPCODE_0001_TEST
        JSR     OPCODE_0010_TEST
        JSR     OPCODE_0011_TEST
        JSR     OPCODE_0100_TEST
        JSR     OPCODE_0101_TEST
        JSR     OPCODE_0110_TEST
        JSR     OPCODE_1000_TEST
        JSR     OPCODE_1001_TEST
        JSR     OPCODE_1011_TEST
        JSR     OPCODE_1100_TEST
        JSR     OPCODE_1101_TEST
        JSR     OPCODE_1110_TEST
        
        BRA     INVALID_DATA        not one of the op codes we're disassembling

*******************************************************************
*           OPCODE TESTS :: load op bitask to D5                  *
*                           XOR instruction to D5                 *
*                           AND 1111 to XOR'd OP                  *
*                           check if all 0s                       *
*                           if all 0s then found op code          *  
*                           if not go back to table and check next*
*******************************************************************

OPCODE_0000_TEST
        MOVE.W  #OP_0000_BITMASK,D5     load 0000 bitmask to D5
        EOR.W   D2,D5                   XOR instruction to D5
        AND.W   #OP_AND_BITMASK,D5      AND 1111 to XOR'd OP
        CMP.W   D5,D6                   check if all 0s
        BEQ     OPCODE_0000             if all 0s then 0000 op code
        RTS                             if not go back to table and check next
        
OPCODE_0001_TEST
        MOVE.W  #OP_0001_BITMASK,D5     same but for 0001
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0001         
        RTS                         
        
OPCODE_0010_TEST
        MOVE.W  #OP_0010_BITMASK,D5     same but for 0010
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0010        
        RTS         

OPCODE_0011_TEST
        MOVE.W  #OP_0011_BITMASK,D5     same but for 0011
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0011        
        RTS                   
        
OPCODE_0100_TEST
        MOVE.W  #OP_0100_BITMASK,D5     same but for 0100
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0100        
        RTS 
        
OPCODE_0101_TEST
        MOVE.W  #OP_0101_BITMASK,D5     same but for 0101
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0101        
        RTS 
        
OPCODE_0110_TEST
        MOVE.W  #OP_0110_BITMASK,D5     same but for 0110
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_0110        
        RTS 
        
OPCODE_1000_TEST
        MOVE.W  #OP_1000_BITMASK,D5     same but for 1000
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1000        
        RTS 
        
OPCODE_1001_TEST
        MOVE.W  #OP_1001_BITMASK,D5     same but for 1001
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1001        
        RTS 
        
OPCODE_1011_TEST
        MOVE.W  #OP_1011_BITMASK,D5     same but for 1011
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1011        
        RTS 
        
OPCODE_1100_TEST
        MOVE.W  #OP_1100_BITMASK,D5     same but for 1100
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1100      
        RTS 
        
OPCODE_1101_TEST
        MOVE.W  #OP_1101_BITMASK,D5     same but for 1101
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1101        
        RTS 
        
OPCODE_1110_TEST
        MOVE.W  #OP_1110_BITMASK,D5     same but for 1110
        EOR.W   D2,D5               
        AND.W   #OP_AND_BITMASK,D5       
        CMP.W   D5,D6               
        BEQ     OPCODE_1110        
        RTS
        
*******************************************************************
*           OPCODE_0000 ::                                        *
*                            ORI, CMPI, BCLR                      *
*******************************************************************
OPCODE_0000
* ORI
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0000,D5               ORI
        BEQ     ORI                     
        
* CMPI
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0C00,D5               CMPI
        BEQ     CMPI
        
* BCLR
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0180,D5               BLCR_DN_EA
        BEQ     BCLR_DN_EA
        
        MOVE.W  #BIT_11_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5
        CMP.W   #$0880,D5               BLCR_IM_EA
        BEQ     BCLR_IM_EA

*******************************************************************
*           OPCODE_0001 ::                                        *
*                            MOVEB                               *
*******************************************************************
OPCODE_0001
* MOVE.B
        MOVE.L  #$00000000,D1           word / in case immediate
        BRA     MOVEB                   OP code is for MOVE.B
        
*******************************************************************
*           OPCODE_0010 ::                                        *
*                           MOVEA.L, MOVE.L                       *
*******************************************************************
OPCODE_0010
        MOVE.W  #D_MODE_BITMASK,D5      bitmask dest mode
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5                   shift dest mode right
        
        MOVE.B  #%1,D1                  long / in case immediate
        
        CMP.B   #1,D5                   compare with 001
        
* MOVEA.L
        BEQ     MOVEAL                  if equal it's a MOVEA.L
        
* MOVE.L
        BRA     MOVEL                   if not MOVEL
        
*******************************************************************
*           OPCODE_0011 ::                                        *
*                           MOVEA.W, MOVE.W                       *
*******************************************************************
OPCODE_0011
        MOVE.W  #D_MODE_BITMASK,D5      bitmask dest mode
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5                   shift dest mode right
        
        
        MOVE.B  #%0,D1                  WORD / in case immediate
        CMP.B   #1,D5                   compare with 001
* MOVEA.W
        BEQ     MOVEAW                  if equal it's a MOVEA.W
        
* MOVE.W
        BRA     MOVEW                   if not MOVEW
        
*******************************************************************
*           OPCODE_0100 ::                                        *
*                           NEG, RTS, JSR, MOVEM, LEA             *
*******************************************************************
OPCODE_0100
* RTS
        CMP.W   #%0100111001110101,D2   RTS instruction
        BEQ     RTS
           
* NEG
        MOVE.W  #BIT_11_TO_06,D5        bitmask bits 11-06
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5                   shift right
        CMP.B   #%000010000,D5          NEG byte
        BEQ     NEGB                
        CMP.B   #%000010001,D5          NEG word
        BEQ     NEGW
        CMP.B   #%000010010,D5          NEG long
        BEQ     NEGL
        CMP.B   #%000010011,D5          MOVE to CCR / invalid
        BEQ     INVALID_DATA

* JSR
        MOVE.W  #BIT_11_TO_06,D5        bitmask bits 11-06
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5                   shift right
        CMP.B   #%00111010,D5           JSR
        BEQ     JSR
        
* LEA
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5                   shift right
        CMP.B   #%00000111,D5           LEA
        BEQ     LEA
        
* MOVEM
*        MOVE.W  #%0000111110111000,D5   bitmask bits 11-03 minus 6
*        AND.W   D2,D5                   and with instruction
*        CMP.W   #%0000100010000000,D5   EXT
*        BEQ     INVALID_DATA            invalid
*        
*        MOVE.W  #%0000101110000000,D5   bitmask bits 11-08 minus 10
*        AND.W   D2,D5                   and with instruction
*        CMP.W   #%0000100010000000,D5   MOVEM
*        BEQ     MOVEM
        
        BRA     INVALID_DATA    
        
*******************************************************************
*           OPCODE_0101 ::                                        *
*                           SUBQ                                  *
*******************************************************************
OPCODE_0101
        MOVE.W  #BIT_07_TO_06,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #6,D5
*Scc_DBcc        
        CMP.W   #3,D5        
        BEQ     INVALID_DATA
        
        MOVE.W  #BIT_08_BITMASK,D5        bitmask bits 08
        AND.W   D2,D5                   and with instruction        
        LSR.W   #8,D5
*ADDQ        
        CMP.W   #%0,D5        
        BEQ     INVALID_DATA
*SUBQ 
        BRA     SUBQ  
        
*******************************************************************
*           OPCODE_0110 ::                                        *
*                           BRA, BCC, BCS, BGE, BLT, BVC          *
*******************************************************************
OPCODE_0110
* BRA
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0000,D5               BRA
        BEQ     BRA
        
* BCC
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0400,D5               BCC
        BEQ     BCC
        
* BCS
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0500,D5               BCS
        BEQ     BCS
        
* BGE
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0C00,D5               BGE
        BEQ     BGE

* BLT
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0D00,D5               BLT
        BEQ     BLT
        
* BVC
        MOVE.W  #BIT_11_TO_08,D5        bitmask bits 11-08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0800,D5               BVC
        BEQ     BVC
        
        BRA     INVALID_DATA
*******************************************************************
*           OPCODE_1000 ::                                        *
*                           DIVS, OR                              *
*******************************************************************
OPCODE_1000
*DIVS
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$01C0,D5               DIVS
        BEQ     DIVS
        
*OR
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$00C0,D5               DIVU
        BEQ     INVALID_DATA            invalid
        
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-04
        ADD.W   #BIT_05_BITMASK,D5
        ADD.W   #BIT_04_BITMASK,D5
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0100,D5               SBCD
        BEQ     INVALID_DATA            invalid data
        
        BRA     OR                      else OR operation
        
*******************************************************************
*           OPCODE_1001 ::                                        *
*                           SUB, SUBX, SUBA                                   *
*******************************************************************
OPCODE_1001
        MOVE.W  #BIT_07_TO_06,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #6,D5
*SUBA        
        CMP.W   #3,D5        
        BEQ     INVALID_DATA
        
        MOVE.W  #%0000000100110000,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #4,D5
*SUBX        
        CMP.W   #%10011,D5        
        BEQ     INVALID_DATA
*SUB 
        BRA     SUB  
        
*******************************************************************
*           OPCODE_1011 ::                                        *
*                           EOR, CMP                              *
*******************************************************************
OPCODE_1011
        MOVE.W  #BIT_07_TO_06,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction
        LSR.W   #6,D5
*CMPA
        CMP.W   #%11,D5               
        BEQ     INVALID_DATA
        
        MOVE.W  #BIT_08_BITMASK,D5      Bitmask bits 08
        AND.W   D2,D5                   and with instruction
        LSR.W   #8,D5
*CMP
        CMP.W   #0,D5               
        BEQ     CMP
        
        MOVE.W  #S_MODE_BITMASK,D5        Bitmask bits 05-03
        AND.W   D2,D5                   and with instruction
        LSR.W   #3,D5
*CMPM
        CMP.W   #1,D5               
        BEQ     INVALID_DATA
*EOR        
        BRA     EOR

*******************************************************************
*           OPCODE_1100 ::                                        *
*                           MULS                                  *
*******************************************************************
OPCODE_1100
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$01C0,D5               MULS
        BEQ     MULS
        
        BRA     INVALID_DATA            invalid data
        
*******************************************************************
*           OPCODE_1101 ::                                        *
*                           ADD, ADDA                             *
*******************************************************************
OPCODE_1101
        MOVE.W  #BIT_07_TO_06,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #6,D5
*ADDA        
        CMP.W   #3,D5        
        BEQ     ADDA
        
        MOVE.W  #%0000000100110000,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #4,D5
*ADDX        
        CMP.W   #%10011,D5        
        BEQ     INVALID_DATA
*ADD 
        BRA     ADD                                                        
        
*******************************************************************
*           OPCODE_1110 ::                                        *
*                           ASL, ASR, LSL, LSR, ROL, ROR          *
*******************************************************************
OPCODE_1110
        MOVE.W  #BIT_07_TO_06,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        
        LSR.W   #6,D5
        CMP.W   #%11,D5 
        
*1110_MEMORY_SHIFT               
        BEQ     MEMORY_SHIFT_1110
        
*1110_REGISTER_SHIFT   
        BRA     REGISTER_SHIFT_1110     not memory shift therefore register shift
        
****************************************************************************************
*                               EFFECTIVE ADDRESSING                                   *
****************************************************************************************
*   PRE:   D2 DATA TO MINIPULATE
*          D3 ORIGINAL CODE
*          D4 HOLDS BITMASK
*          D5 HOLDS MODE
*          D6 HOLDS REGISTER 
*          D7 MAX LINES *
*          
*   POST:  Goes through the op codes to find out which one it is
*------------------------------------------------------------------

*******************************************************************
*          ORI                                                    *
*******************************************************************
ORI
* invalid
        MOVE.W  #BIT_05_TO_00,D5    bitmask for bits 05-00
        AND.W   D2,D5               and with instruction
        CMP.W   #$003C,D5           invalid
        BEQ     INVALID_DATA

* ORI.B
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0000,D5           byte
        BEQ     ORIB

* ORI.W
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0040,D5           word
        BEQ     ORIW

* ORI.L           
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0080,D5           long
        BEQ     ORIL
        
        BRA     INVALID_DATA
        
ORIB
        MOVE.B  #'O',(A3)+              add OR.B to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1 to check immediate word
        JSR     IMMEDIATE_DATA_WORD     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
ORIW
        MOVE.B  #'O',(A3)+              add ORI.W to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1
        JSR     IMMEDIATE_DATA_WORD     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER 

ORIL
        MOVE.B  #'O',(A3)+              add ORI.L to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1
        JSR     IMMEDIATE_DATA_LONG     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          CMPI                                                   *
******************************************************************* 
CMPI
* CMPI.B
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0000,D5           byte
        BEQ     CMPIB
        
* CMPI.W
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0040,D5           word
        BEQ     CMPIW
        
* CMPI.B
        MOVE.W  #BIT_07_BITMASK,D5  bitmask for bits 07-06
        ADD.W   #BIT_06_BITMASK,D5
        AND.W   D2,D5               and with instruction
        CMP.W   #$0080,D5           long
        BEQ     CMPIL
        
        BRA     INVALID_DATA
        
CMPIB
        MOVE.B  #'C',(A3)+              add CMPI.B to buffer
        MOVE.B  #'M',(A3)+
        MOVE.B  #'P',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1
        JSR     IMMEDIATE_DATA_WORD     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
CMPIW
        MOVE.B  #'C',(A3)+              add CMPI.W to buffer
        MOVE.B  #'M',(A3)+
        MOVE.B  #'P',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1
        JSR     IMMEDIATE_DATA_WORD     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
CMPIL
        MOVE.B  #'C',(A3)+              add CMPI.L to buffer
        MOVE.B  #'M',(A3)+
        MOVE.B  #'P',(A3)+
        MOVE.B  #'I',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1
        JSR     IMMEDIATE_DATA_LONG     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        JSR     PRINT_VALID_BUFFER      print what's in buffer
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          BCLR                                                   *
*******************************************************************
BCLR_DN_EA
        MOVE.W  #BIT_05_TO_03,D5        bitmask bits 05-03
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0000,D5               EA mode is Dn. Long.
        BEQ     BCLR_DN_EA_L
        
        BRA     BCLR_DN_EA_B            else is byte
 
BCLR_DN_EA_L
        MOVE.B  #'B',(A3)+              add BCLR.L to buffer
        MOVE.B  #'C',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.W  #BIT_11_TO_09,D6        bitmask bits 11-09
        AND.W   D2,D6                   and with instruction
        LSR.W   #8,D6                   shift right
        LSR.W   #1,D6                   
        JSR     BUFFER_DN               buffer Dn
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER

BCLR_DN_EA_B
        MOVE.B  #'B',(A3)+              add BCLR.L to buffer
        MOVE.B  #'C',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.W  #BIT_11_TO_09,D6        bitmask bits 11-09
        AND.W   D2,D6                   and with instruction
        LSR.W   #8,D6                   shift right
        LSR.W   #1,D6                   
        JSR     BUFFER_DN               buffer Dn
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
BCLR_IM_EA
        MOVE.B  #'B',(A3)+              add BCLR.L to buffer
        MOVE.B  #'C',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$0000,D1               clear D1
        JSR     IMMEDIATE_DATA_WORD     print immediate data
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer EA
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          ADD                                                    *
*******************************************************************       
ADD
        MOVE.B  #'A',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        BRA     ADD_SUB_DIRECTION
        
ADD_SUB_DIRECTION
        MOVE.W  #BIT_08_BITMASK,D5      bitmask dest mode
        AND.W   D2,D5                   and with instruction
        LSR.W   #8,D5                   shift dest mode right
        
        CMP.B   #0,D5                   compare with 000
        BEQ     Dn_TO_EA
        
        BRA     EA_TO_DN

Dn_TO_EA
        JSR     SOURCE_MOVE
        JSR     BUFFER_COMMA
        MOVE.B  #'D',(A3)+
        JSR     SOURCE_NUM                                                                    
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER


EA_TO_DN
        MOVE.B  #'D',(A3)+
        JSR     SOURCE_NUM
        JSR     BUFFER_COMMA
        JSR     SOURCE_MOVE                                                                    
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
       
*******************************************************************
*          ADDA                                                   *
*******************************************************************       
ADDA
        MOVE.B  #'A',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE_WL
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE
        JSR     BUFFER_COMMA
        MOVE.B  #'A',(A3)+
        JSR     SOURCE_NUM                                                      
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          CMP                                                    *
*******************************************************************        
CMP
        MOVE.B  #'C',(A3)+
        MOVE.B  #'M',(A3)+
        MOVE.B  #'P',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE
        JSR     BUFFER_COMMA
        MOVE.B  #'D',(A3)+
        JSR     DESTINATION_NUM
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          EOR                                                    *
*******************************************************************        
EOR
        MOVE.B  #'E',(A3)+
        MOVE.B  #'O',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.B  #'D',(A3)+
        JSR     SOURCE_NUM
        JSR     BUFFER_COMMA
        JSR     SOURCE_MOVE
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          MOVE.B                                                 *
*******************************************************************
MOVEB
        MOVE.B  #'M',(A3)+          add MOVE.B to buffer
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer source EA
        JSR     BUFFER_COMMA        buffer comma
        JSR     DESTINATION_MOVE    buffer destination EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          MOVE.L                                                 *
*******************************************************************
MOVEL
        MOVE.B  #'M',(A3)+          add MOVE.L to buffer
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer source EA
        JSR     BUFFER_COMMA        buffer comma
        JSR     DESTINATION_MOVE    buffer destination EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          MOVEA.L                                                *
*******************************************************************
MOVEAL
        MOVE.B  #'M',(A3)+          add MOVEA.L to buffer
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer source EA
        JSR     BUFFER_COMMA        buffer comma
        JSR     DESTINATION_MOVE    buffer destination EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          MOVE.W                                                 *
*******************************************************************
MOVEW
        MOVE.B  #'M',(A3)+          add MOVE.L to buffer
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer source EA
        JSR     BUFFER_COMMA        buffer comma
        JSR     DESTINATION_MOVE    buffer destination EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          MOVEA.W                                                *
*******************************************************************
MOVEAW
        MOVE.B  #'M',(A3)+          add MOVEA.L to buffer
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer source EA
        JSR     BUFFER_COMMA        buffer comma
        JSR     DESTINATION_MOVE    buffer destination EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          MOVEM                                                  *
*******************************************************************
*MOVEM
*        MOVE.B  #'M',(A3)+          add MOVEM to buffer
*        MOVE.B  #'O',(A3)+
*        MOVE.B  #'V',(A3)+
*        MOVE.B  #'E',(A3)+
*        MOVE.B  #'M',(A3)+
*        MOVE.B  #'.',(A3)+
*        
*        JSR     MOVEM_WORD_LONG     figure out word or long
*        
*        MOVE.B  #' ',(A3)+
*        MOVE.B  #' ',(A3)+
*        
*        MOVE.W  #BIT_10_BITMASK,D5  bitmask bit 10
*        AND.W   D2,D5               and with instruction
*        CMP.W   #$0000,D5           
*        BEQ     MOVEM_REG_MEM       register to memory
*        BRA     MOVEM_MEM_REG       memory to register
*
*MOVEM_WORD_LONG
*        MOVE.W  #BIT_06_BITMASK,D5  bitmask bit 06
*        AND.W   D2,D5               and with instruction
*        CMP.W   #$0000,D5           
*        BEQ     BUFFER_W            word
*        BRA     BUFFER_L            long
*
*MOVEM_REG_MEM
*        JSR     BUFFER_LIST
*
*MOVEM_MEM_REG
*
*BUFFER_LIST
*        MOVE.W  (A5)+,D3        move the data from A5 to D3
*        MOVE.W  D3,D2
*        
*        MOVE.B  #0,D1           counter
*        BRA     DLIST
*        
*DLIST
*        CMP.B   #8,D1           compare with counter
*        BEQ     ALIST           done with Dn
        
        
        
        
*******************************************************************
*          NEG.B                                                  *
*******************************************************************
NEGB
        MOVE.B  #'N',(A3)+          add NEG.B to buffer
        MOVE.B  #'E',(A3)+
        MOVE.B  #'G',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          NEG.W                                                  *
*******************************************************************
NEGW
        MOVE.B  #'N',(A3)+          add NEG.W to buffer
        MOVE.B  #'E',(A3)+
        MOVE.B  #'G',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          NEG.L                                                  *
*******************************************************************
NEGL
        MOVE.B  #'N',(A3)+          add NEG.L to buffer
        MOVE.B  #'E',(A3)+
        MOVE.B  #'G',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          RTS                                                    *
*******************************************************************   
RTS
        MOVE.B  #'R',(A3)+          add RTS to buffer
        MOVE.B  #'T',(A3)+
        MOVE.B  #'S',(A3)+
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line

        BRA     START_DISASSEMBLER
        
*******************************************************************
*          JSR                                                    *
*******************************************************************
JSR
        MOVE.B  #'J',(A3)+          add JSR to buffer
        MOVE.B  #'S',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer EA
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          LEA                                                    *
*******************************************************************
LEA
        MOVE.B  #'L',(A3)+          add JSR to buffer
        MOVE.B  #'E',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     SOURCE_MOVE         buffer EA
        JSR     BUFFER_COMMA        prints comma
        
        MOVE.W  #BIT_11_TO_09,D5    bitmask bits 11-09
        AND.W   D2,D5               and with instruction
        LSR.W   #8,D5               shift right
        LSR.W   #1,D5
        MOVE.B  D5,D6               move the data in D5 to D6
        JSR     BUFFER_AN           buffer An
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          BRA                                                    *
*******************************************************************
BRA
        MOVE.B  #'B',(A3)+              add BRA to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement

*******************************************************************
*          BCC                                                    *
*******************************************************************
BCC
        MOVE.B  #'B',(A3)+              add BCC to buffer
        MOVE.B  #'C',(A3)+
        MOVE.B  #'C',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement
        
*******************************************************************
*          BCS                                                    *
*******************************************************************
BCS
        MOVE.B  #'B',(A3)+              add BCS to buffer
        MOVE.B  #'C',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement        

*******************************************************************
*          BGE                                                    *
*******************************************************************
BGE
        MOVE.B  #'B',(A3)+              add BGE to buffer
        MOVE.B  #'G',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement

*******************************************************************
*          BLT                                                    *
*******************************************************************
BLT
        MOVE.B  #'B',(A3)+              add BLT to buffer
        MOVE.B  #'L',(A3)+
        MOVE.B  #'T',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement

*******************************************************************
*          BVC                                                    *
*******************************************************************
BVC
        MOVE.B  #'B',(A3)+              add BVC to buffer
        MOVE.B  #'V',(A3)+
        MOVE.B  #'C',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     PRINT_VALID_BUFFER      prints
        
        MOVE.W  #BIT_07_TO_00,D5        bitmask bits 07-00
        AND.W   D2,D5                   and with instruction
        
        CMP.B   #$00,D5                 compare with $00
        BEQ     DISPLACE_16             16 bit displacement
        
        CMP.B   #$FF,D5                 compare with $FF
        BEQ     DISPLACE_32             32 bit displacement
        
        BRA     DISPLACE_8              8 bit displacement

*******************************************************************
*          DIVS                                                   *
*******************************************************************
DIVS
        MOVE.B  #'D',(A3)+              add DIVS to buffer
        MOVE.B  #'I',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1
        JSR     SOURCE_MOVE             buffer EA
        JSR     BUFFER_COMMA            prints comma
        
        MOVE.W  #BIT_11_TO_09,D5        bitmask bits 11-09
        AND.W   D2,D5                   and with instruction
        LSR.W   #8,D5                   shift right
        LSR.W   #1,D5
        MOVE.B  D5,D6                   move the data in D5 to D6
        JSR     BUFFER_DN               buffer Dn
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          OR                                                     *
*******************************************************************
OR
        MOVE.W  #BIT_08_BITMASK,D5      bitmask bit 08
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0000,D5               register to memory
        BEQ     OR_REG_TO_MEM

        BRA     OR_MEM_TO_REG

OR_REG_TO_MEM
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0000,D5               byte
        BEQ     OR_REG_TO_MEM_B

        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0040,D5               word
        BEQ     OR_REG_TO_MEM_W

        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0080,D5               long
        BEQ     OR_REG_TO_MEM_L         
        
        BRA     INVALID_DATA
        
OR_REG_TO_MEM_B
        MOVE.B  #'O',(A3)+              add OR.B to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1 to check immediate word
        BRA     OR_REG_TO_MEM_EA_DN     buffer the rest

OR_REG_TO_MEM_W
        MOVE.B  #'O',(A3)+              add OR.W to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1 to check immediate word
        BRA     OR_REG_TO_MEM_EA_DN     buffer the rest
        
OR_REG_TO_MEM_L
        MOVE.B  #'O',(A3)+              add OR.L to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000001,D1           clear D1 to check immediate long
        BRA     OR_REG_TO_MEM_EA_DN     buffer the rest
        
OR_REG_TO_MEM_EA_DN
        JSR     SOURCE_MOVE             buffer source EA
        JSR     BUFFER_COMMA            buffer comma
        
        MOVE.W  #BIT_11_TO_09,D6        bitmask bits 11-09
        AND.W   D2,D6                   and with instruction
        LSR.W   #8,D6                   shift to the right
        LSR.W   #1,D6               
        JSR     BUFFER_DN               buffer destination EA
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
OR_MEM_TO_REG
        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0100,D5               byte
        BEQ     OR_MEM_TO_REG_B

        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0140,D5               word
        BEQ     OR_MEM_TO_REG_W

        MOVE.W  #BIT_08_TO_06,D5        bitmask bits 08-06
        AND.W   D2,D5                   and with instruction
        CMP.W   #$0180,D5               long
        BEQ     OR_MEM_TO_REG_L         
        
        BRA     INVALID_DATA

OR_MEM_TO_REG_B      
        MOVE.B  #'O',(A3)+              add OR.B to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        BRA     OR_MEM_TO_REG_DN_EA     buffer the rest
        
OR_MEM_TO_REG_W      
        MOVE.B  #'O',(A3)+              add OR.W to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        BRA     OR_MEM_TO_REG_DN_EA     buffer the rest
        
OR_MEM_TO_REG_L      
        MOVE.B  #'O',(A3)+              add OR.L to buffer
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        BRA     OR_MEM_TO_REG_DN_EA     buffer the rest
        
OR_MEM_TO_REG_DN_EA
        MOVE.W  #BIT_11_TO_09,D6        bitmask bits 11-09
        AND.W   D2,D6                   and with instruction
        LSR.W   #8,D6                   shift to the right
        LSR.W   #1,D6               
        JSR     BUFFER_DN               buffer destination EA
        
        JSR     BUFFER_COMMA            buffer comma
        JSR     SOURCE_MOVE             buffer source EA
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          MULS                                                   *
*******************************************************************
MULS
        MOVE.B  #'M',(A3)+              add MULS to buffer
        MOVE.B  #'U',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.L  #$00000000,D1           clear D1 to check word
        JSR     SOURCE_MOVE             buffer EA
        JSR     BUFFER_COMMA            prints comma
        
        MOVE.W  #BIT_11_TO_09,D5        bitmask bits 11-09
        AND.W   D2,D5                   and with instruction
        LSR.W   #8,D5                   shift right
        LSR.W   #1,D5
        MOVE.B  D5,D6                   move the data in D5 to D6
        JSR     BUFFER_DN               buffer Dn
        
        JSR     PRINT_VALID_BUFFER      prints
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER

*******************************************************************
*          SUB                                                    *
*******************************************************************       
SUB
        MOVE.B  #'S',(A3)+
        MOVE.B  #'U',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        BRA     ADD_SUB_DIRECTION       
        
*******************************************************************
*          SUBQ                                                   *
*******************************************************************          
SUBQ
        MOVE.B  #'S',(A3)+
        MOVE.B  #'U',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #'Q',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.B  #'#',(A3)+
        JSR     SOURCE_NUM
        JSR     BUFFER_COMMA        
        JSR     SOURCE_MOVE
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
        
*******************************************************************
*          MEMORY_SHIFT_1110                                      *
*******************************************************************
MEMORY_SHIFT_1110
        MOVE.W  #D_REG_BITMASK,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        *0000000000011000
        LSR.W   #8,D5
        LSR.W   #1,D5
        
        CMP.W   #%000,D5 
*ASd                
        BEQ     ASd_MEM
        
        CMP.W   #%001,D5 
*LSd                
        BEQ     LSd_MEM
        
        CMP.W   #%011,D5 
*ROd                
        BEQ     ROd_MEM

        BRA     INVALID_DATA            invalid data
        
*******************************************************************
*          ASd_MEM                                               *
*******************************************************************
ASd_MEM
        MOVE.B  #'A',(A3)+
        MOVE.B  #'S',(A3)+
        
        BRA     OP_1110_MEM
        
*******************************************************************
*          LSd_MEM                                                *
*******************************************************************
LSd_MEM
        MOVE.B  #'L',(A3)+
        MOVE.B  #'S',(A3)+
        
        BRA     OP_1110_MEM

*******************************************************************
*          ROd_MEM                                                *
*******************************************************************
ROd_MEM
        MOVE.B  #'R',(A3)+
        MOVE.B  #'O',(A3)+
        
        BRA     OP_1110_MEM
        
*******************************************************************
*          OP_1110_MEM                                            *
*******************************************************************
OP_1110_MEM        
        JSR     DIRECTION
        
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        MOVE.W  #S_REG_BITMASK ,D5        bitmask bits 07-06
        AND.W   D2,D5                   and with instruction        *0000000000011000
        MOVE.L  D5,D6
        

        JSR     SOURCE_MOVE
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        

*******************************************************************
*          REGISTER_SHIFT_1110                                    *
*******************************************************************    
REGISTER_SHIFT_1110
        MOVE.W  #BIT_04_TO_03,D5        bitmask bits 04-03
        AND.W   D2,D5                   and with instruction        *0000000000011000
        LSR.W   #3,D5
*ASd_REG        
        CMP.W   #%00,D5                 
        BEQ     ASd_REG
*LSd_REG        
        CMP.W   #%01,D5                 
        BEQ     LSd_REG
*ROd_REG        
        CMP.W   #%11,D5                 
        BEQ     ROd_REG
*INVALID
        BRA     INVALID_DATA            invalid data

*******************************************************************
*          ASd_REG                                                *
*******************************************************************
ASd_REG
        MOVE.B  #'A',(A3)+
        MOVE.B  #'S',(A3)+
        
        BRA     OP_1110_REG
        
*******************************************************************
*          LSd_REG                                                *
*******************************************************************
LSd_REG
        MOVE.B  #'L',(A3)+
        MOVE.B  #'S',(A3)+
        
        BRA     OP_1110_REG

*******************************************************************
*          ROd_REG                                                *
*******************************************************************
ROd_REG
        MOVE.B  #'R',(A3)+
        MOVE.B  #'O',(A3)+
        
        BRA     OP_1110_REG
        
*******************************************************************
*          OP_1110_REG                                            *
*******************************************************************
OP_1110_REG        
        JSR     DIRECTION
        
        MOVE.B  #'.',(A3)+
        
        JSR     BUFFER_SIZE
        
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        MOVE.B  #' ',(A3)+
        
        JSR     IMMEDIATE_OR_REGISTER

        JSR     SOURCE_NUM
        JSR     BUFFER_COMMA
        MOVE.B  #'D',(A3)+ 
        JSR     DESTINATION_NUM
        
        JSR     PRINT_VALID_BUFFER  prints
        JSR     PRINT_NEWLINE       print new line
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          DIRECTION                                              *
*******************************************************************
DIRECTION        
        MOVE.W  #BIT_08_BITMASK,D5        bitmask bit 08
        AND.W   D2,D5                     and with instruction  
        LSR.W   #8,D5
        
        CMP.B   #0,D5
*R
        BEQ     BUFFER_R
*L
        BRA     BUFFER_L
        
*******************************************************************
*          IMMEDIATE_OR_REGISTER                                  *
*******************************************************************        
IMMEDIATE_OR_REGISTER
        MOVE.W  #BIT_05_BITMASK,D5        bitmask bit 05
        AND.W   D2,D5                     and with instruction  
        LSR.W   #5,D5
        
        CMP.B   #0,D5
*#
        BEQ     BUFFER_HASHTAG
*D
        BRA     BUFFER_D
        
*******************************************************************
*          SOURCE_NUM                                             *
*******************************************************************         
SOURCE_NUM
        MOVE.W  #D_REG_BITMASK,D5          bitmask bit 11-09
        AND.W   D2,D5                     and with instruction  
        LSR.W   #8,D5
        LSR.W   #1,D5
        MOVE.L  D5,D6
        
*REGISTER_NUM
        BRA     REGISTER_NUMBER

*******************************************************************
*          DESTINATION_NUM                                        *
*******************************************************************         
DESTINATION_NUM
        MOVE.W  #S_REG_BITMASK,D5          bitmask bit 1-09
        AND.W   D2,D5                     and with instruction 
        MOVE.L  D5,D6
        
*REGISTER_NUM
        BRA     REGISTER_NUMBER
        
*******************************************************************
*          BUFFER_SIZE                                            *
*******************************************************************       
BUFFER_SIZE
        MOVE.W  #BIT_07_TO_06,D5            bitmask bit 07-06
        AND.W   D2,D5                       and with instruction  
        LSR.W   #6,D5
*B        
        CMP.B   #%00,D5
        BEQ     BUFFER_B
*W       
        CMP.B   #%01,D5
        BEQ     BUFFER_W
*L       
        CMP.B   #%10,D5
        BEQ     BUFFER_L
*INVALID        
        BRA     INVALID_DATA
        
*******************************************************************
*          BUFFER_SIZE_WL                                         *
******************************************************************* 
BUFFER_SIZE_WL
        MOVE.W  #BIT_08_BITMASK,D5          bitmask bit 08
        AND.W   D2,D5                       and with instruction  
        LSR.W   #8,D5
*B        
        CMP.B   #0,D5
        BEQ     BUFFER_W
*W       
        CMP.B   #1,D5
        BEQ     BUFFER_L
        


*******************************************************************
*          8, 16, 32 DISPLACEMENTS                                *
*******************************************************************
DISPLACE_8
        MOVE.L  #$00000000,D1           clear D1
        MOVE.B  D5,D1                   move the 8 bit displacement
        NEG.B   D1                      flip bits
        ADD.B   #1,D1                   add one
        
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        JSR     PRINT_NEWLINE           print new line
        
        BRA     START_DISASSEMBLER

DISPLACE_16
        MOVE.L  #$00000000,D1           clear D1
        MOVE.W  (A5)+,D3                move the data from A5 to D3
        MOVE.W  D3,D1                   move the 16 bit displacement
 
        EXT.L   D1                      sign extend
        ADD.L   A5,D1                   add the current address
        SUB.B   #2,D1                   subtract 2 to get correct address
 
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        JSR     PRINT_NEWLINE
        
        BRA     START_DISASSEMBLER

DISPLACE_32
        MOVE.L  #$00000000,D1           clear D1 
        MOVE.L  (A5)+,D3                move the data from A5 to D3
        MOVE.L  D3,D1                   move the 32 bit displacement
        
        ADD.L   A5,D1
        SUB.B   #2,D1                   subtract 2 to get correct address
        
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        JSR     PRINT_NEWLINE
        
        BRA     START_DISASSEMBLER
        
*******************************************************************
*          SOURCE_MOVE                                            *
*******************************************************************        
SOURCE_MOVE
        MOVE.W  #S_MODE_BITMASK,D4  holds bitmask %0000000000111000
        MOVE.W  D2,D5               moves instruction to D5
        AND     D4,D5               uses bitmask to get source mode
        LSR.W   #3,D5               shifts source mode right
        
        MOVE.W  #S_REG_BITMASK,D4   holds bitmask %0000000000000111
        MOVE.W  D2,D6               moves instruction to D6
        AND     D4,D6               uses bitmask to get source register
        
        JSR     MODE_TABLE          figures out the mode and buffers
        
        RTS
        
*******************************************************************
*          DESTINATION_MOVE                                       *
*******************************************************************
DESTINATION_MOVE   
        MOVE.W  #D_MODE_BITMASK,D4      holds bitmask %0000000111000000
        MOVE.W  D2,D5                   moves instruction to D5
        AND     D4,D5                   uses bitmask to get dest mode
        LSR.W   #6,D5                   shifts dest mode right
        
        MOVE.W  #D_REG_BITMASK,D4       holds bitmask %0000111000000000
        MOVE.W  D2,D6                   moves instruction to D6
        AND     D4,D6                   uses bitmask to get dest reg
        LSR.W   #8,D6                   shifts dest reg right
        LSR.W   #1,D6
        
        JSR     MODE_TABLE              figures out the mode and buffers
        
        RTS
        
****************************************************************************************
*                               MODE_TABLE                                             *
****************************************************************************************
*   PRE:   D2 DATA TO MINIPULATE
*          D3 ORIGINAL CODE
*          D4 HOLDS BITMASK
*          D5 HOLDS MODE
*          D6 HOLDS REGISTER 
*          D7 MAX LINES *
*          
*   POST:  Buffers the Mode
*------------------------------------------------------------------    
MODE_TABLE
        CMP.B   #%000,D5            mode is a data register Dn
        BEQ     BUFFER_DN   
        
        CMP.B   #%001,D5            mode is an address register An
        BEQ     BUFFER_AN
        
        CMP.B   #%010,D5            mode is an address register indirect (An)
        BEQ     BUFFER_AN_I
        
        CMP.B   #%011,D5            mode is an ari post (An)+
        BEQ     BUFFER_AN_POST
        
        CMP.B   #%100,D5            mode is an ari pre -(An)
        BEQ     BUFFER_AN_PRE
        
        CMP.B   #%111,D5            mode is either immediate, or absolute
        BEQ     OTHER_MODE
    
        BRA     INVALID_DATA
        
*******************************************************************
*          OTHER_MODE                                             *
*******************************************************************
OTHER_MODE
* absolute addressing
        CMP.B   #%000,D6            register is 000
        BEQ     ABSOLUTE_WORD       absolute word
        
        CMP.B   #%001,D6            register is 001
        BEQ     ABSOLUTE_LONG       absolute long

* immediate data
        ADD.B   D1,D6
        CMP.B   #%100,D6                 register is 100 and word
        BEQ     IMMEDIATE_DATA_WORD      immediate data
        
        CMP.B   #%101,D6                 register is 100 and long
        BEQ     IMMEDIATE_DATA_LONG      immediate data
        
        BRA     INVALID_DATA
        
*******************************************************************
*          ABSOLUTE_WORD                                          *
*******************************************************************        
ABSOLUTE_WORD
        JSR     PRINT_VALID_BUFFER      prints what's in the buffer
        
        MOVE.L  #$00000000,D3           clear D3
        MOVE.L  #$00000000,D1           clear D1
        MOVE.W  (A5)+,D3                move the data from A5 to D3
        MOVE.W  D3,D1                   move the word 
 
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        RTS
        
*******************************************************************
*          ABSOLUTE_LONG                                          *
*******************************************************************        
ABSOLUTE_LONG
        JSR     PRINT_VALID_BUFFER      prints what's in the buffer
        
        MOVE.L  #$00000000,D3           clear D3
        MOVE.L  #$00000000,D1           clear D1
        MOVE.L  (A5)+,D3                move the data from A5 to D3
        MOVE.L  D3,D1                   move the 16 bit displacement
 
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        RTS
        
*******************************************************************
*          IMMEDIATE_DATA                                         *
*******************************************************************        
IMMEDIATE_DATA_WORD       
        MOVE.B  #'#',(A3)+              print #
        JSR     PRINT_VALID_BUFFER
     
        MOVE.W  (A5)+,D3                move the data from A5 to D3
        MOVE.W  D3,D1                   move the 16 bit displacement
 
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        RTS
        
IMMEDIATE_DATA_LONG
        MOVE.B  #'#',(A3)+              print #
        JSR     PRINT_VALID_BUFFER
        
        MOVE.L  (A5)+,D3                move the data from A5 to D3
        MOVE.L  D3,D1                   move the 16 bit displacement
 
        MOVE.B  #3,D0                   display signed number in D1.L
        TRAP    #15
        
        RTS
        
*******************************************************************
*          BUFFER_DN                                              *
******************************************************************* 
BUFFER_DN
        MOVE.B  #'D',(A3)+          add D to valid buffer
        BRA     REGISTER_NUMBER     add register number to D
        
*******************************************************************
*          BUFFER_AN                                              *
*******************************************************************
BUFFER_AN
        MOVE.B  #'A',(A3)+          add A to valid buffer
        BRA     REGISTER_NUMBER     add register number to A      

*******************************************************************
*          BUFFER_AN_I                                            *
*******************************************************************
BUFFER_AN_I
        MOVE.B  #'(',(A3)+          add ( to valid buffer
        JSR BUFFER_AN               add An to valid buffer
        MOVE.B  #')',(A3)+          add ) to valid buffer
        RTS
        
*******************************************************************
*          BUFFER_AN_POST                                         *
*******************************************************************
BUFFER_AN_POST
        MOVE.B  #'(',(A3)+          add ( to valid buffer
        JSR BUFFER_AN               add An to valid buffer
        MOVE.B  #')',(A3)+          add ) to valid buffer
        MOVE.B  #'+',(A3)+          add + to valid buffer
        RTS
        
*******************************************************************
*          BUFFER_AN_PRE                                          *
*******************************************************************
BUFFER_AN_PRE
        MOVE.B  #'-',(A3)+          add + to valid buffer
        MOVE.B  #'(',(A3)+          add ( to valid buffer
        JSR BUFFER_AN               add An to valid buffer
        MOVE.B  #')',(A3)+          add ) to valid buffer
        RTS

*******************************************************************
*          REGISTER_NUMBER                                        *
*******************************************************************
REGISTER_NUMBER
        CMP.B   #0,D6              figure out which register number
        BEQ     BUFFER_0
        
        CMP.B   #1,D6
        BEQ     BUFFER_1
        
        CMP.B   #2,D6
        BEQ     BUFFER_2
        
        CMP.B   #3,D6
        BEQ     BUFFER_3
        
        CMP.B   #4,D6
        BEQ     BUFFER_4
        
        CMP.B   #5,D6
        BEQ     BUFFER_5
        
        CMP.B   #6,D6
        BEQ     BUFFER_6
        
        CMP.B   #7,D6
        BEQ     BUFFER_7

*******************************************************************
*          BUFFER_# TABLE                                         *
*******************************************************************             
BUFFER_0
        MOVE.B  #'0',(A3)+
        RTS
        
BUFFER_1
        MOVE.B  #'1',(A3)+
        RTS
        
BUFFER_2
        MOVE.B  #'2',(A3)+
        RTS
        
BUFFER_3
        MOVE.B  #'3',(A3)+
        RTS
        
BUFFER_4
        MOVE.B  #'4',(A3)+
        RTS
        
BUFFER_5
        MOVE.B  #'5',(A3)+
        RTS
        
BUFFER_6
        MOVE.B  #'6',(A3)+
        RTS
        
BUFFER_7
        MOVE.B  #'7',(A3)+
        RTS
        
*******************************************************************
*          BUFFER_B                                               *
*******************************************************************
BUFFER_B
        MOVE.B  #'B',(A3)+
        RTS

*******************************************************************
*          BUFFER_W                                               *
*******************************************************************
BUFFER_W
        MOVE.B  #'W',(A3)+
        RTS

*******************************************************************
*          BUFFER_L                                               *
*******************************************************************
BUFFER_L
        MOVE.B  #'L',(A3)+
        RTS

*******************************************************************
*          BUFFER_R                                               *
*******************************************************************
BUFFER_R
        MOVE.B  #'R',(A3)+
        RTS

*******************************************************************
*          BUFFER_HASHTAG                                         *
*******************************************************************
BUFFER_HASHTAG
        MOVE.B  #'#',(A3)+
        RTS

*******************************************************************
*          BUFFER_D                                               *
*******************************************************************
BUFFER_D
        MOVE.B  #'D',(A3)+
        RTS

       
*******************************************************************
*          BUFFER_COMMA                                           *
*******************************************************************
BUFFER_COMMA
        MOVE.B  #',',(A3)+
        RTS

*******************************************************************
*          PRINT_NEWLINE                                          *
*******************************************************************
PRINT_NEWLINE
        LEA     NEWLINE,A1          print new line
        MOVE.B  #14,D0
        TRAP    #15
        RTS
        
*******************************************************************
*                       PRINT_VALID_BUFFER                        *
*******************************************************************
*   PRE:   A2 BUFFER ITERATOR
*          A3 VALID BUFFER
*          
*          D2 ADDRESS TO MINIPULATE
*   POST:  Prints what is in the valid buffer
*------------------------------------------------------------------
PRINT_VALID_BUFFER
        MOVEA.L #$00800000,A2           move buffer iterator to the beginning
        JSR     VALID_BUFFER_LOOP
        
        MOVEA.L #$00800000,A3           restart valid buffer location
        
        RTS
VALID_BUFFER_LOOP
        CMPA.L  A2,A3                   compare iterator to end of buffer
        BGT     OUTPUT_VALID_BUFFER     branch if we're not there yet
        
        RTS
OUTPUT_VALID_BUFFER
        MOVE.B  (A2)+,D1                print char in buffer and increment
        MOVE.B  #6,D0                   pointer
        TRAP    #15
        
        BRA     VALID_BUFFER_LOOP
        
*******************************************************************
*                       INVALID_DATA                              *
*******************************************************************
*   PRE:   invalid data
*   POST:  print 1000 DATA $WXYZ where WXYZ is the hex number of data
*------------------------------------------------------------------
INVALID_DATA
        LEA     PRINT_INVALID,A1        print 1000 DATA $
        MOVE.B  #14,D0
        TRAP    #15
        
        JSR     ISOLATE_FIFTH_DIGIT     convert the instruction to ascii
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_SIXTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_SEVENTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     ISOLATE_EIGHTH_DIGIT
        JSR     CONVERT_AND_BUFFER
        
        JSR     PRINT_VALID_BUFFER      prints the instruction hex
        JSR     PRINT_NEWLINE           prints new line
        
        BRA     START_DISASSEMBLER
            
*******************************************************************
*                       END_DISASSEMBLER                          *
*******************************************************************
*   PRE:   We have reached the ending address and so disassembled
*          all of the lines of code
*   POST:  Ends simulation
*------------------------------------------------------------------
END_DISASSEMBLER
        LEA     END_MESSAGE,A1          display final message
        MOVE.B  #14,D0
        TRAP    #15
        
        SIMHALT                         end of program 
        
        MOVE.W  D0,D1
        MOVE.W  A0,D2
        MOVE.W  (A1),D3
        MOVE.W  (A2)+,D4
        MOVE.W  -(A3),D5
        MOVE.W  #$1000,D6
        MOVE.W  $1000,D7
        MOVE.W  D0,$1000
        MOVE.W  #$1000,(A4)
        MOVE.W  #$1000,$1001
        
        MOVEA.W D1,A0
        MOVEA.W A1,A2
        MOVEA.W (A3),A4
        MOVEA.W (A5)+,A6
        MOVEA.W -(A7),A0
        MOVEA.W $1000,A1
        MOVEA.W $10000000,A2
        MOVEA.W #$1000,A3

NEWLINE         DC.B    CR,LF,0
WELCOME         DC.B    'Hello and welcome to the disassembler.',CR,LF,0
START_ADDRESS   DC.B    'Type in the starting address: ',CR,LF,0
END_ADDRESS     DC.B    'Type in the ending address: ',CR,LF,0  
INVALIDA        DC.B    'Invalid information inputed. Starting over.',CR,LF,0
CONTINUEPROMPT  DC.B    'Enter to continue...',0
STARTINGDIS     DC.B    '---------------Starting the disassembler---------------',CR,LF,0
END_MESSAGE     DC.B    'Thank you for using our disassembler. Good bye.',CR,LF,0
TAB             DC.B    '        ',0
PRINT_INVALID   DC.B    '1000 DATA $',0

        END    START       
                
                
                
                
                
                
                
                
                
                
                
                


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
