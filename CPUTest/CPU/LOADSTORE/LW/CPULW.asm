; N64 'Bare Metal' CPU Load Word Test Demo by krom (Peter Lemon):
  include LIB\N64.INC ; Include N64 Definitions
  dcb 1052672,$00 ; Set ROM Size
  org $80000000 ; Entry Point Of Code
  include LIB\N64_HEADER.ASM  ; Include 64 Byte Header & Vector Table
  incbin LIB\N64_BOOTCODE.BIN ; Include 4032 Byte Boot Code

PrintString: macro vram, xpos, ypos, fontfile, string, length ; Print Text String To VRAM Using Font At X,Y Position
  lui a0,vram ; A0 = Frame Buffer Pointer
  addi a0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la a1,fontfile ; A1 = Characters
  la a2,string ; A2 = Text Offset
  li t0,length ; T0 = Number of Text Characters to Print
  DrawChars\@:
    li t1,7 ; T1 = Character X Pixel Counter
    li t2,7 ; T2 = Character Y Pixel Counter

    lb t3,0(a2) ; T3 = Next Text Character
    addi a2,1

    sll t3,8 ; Add Shift to Correct Position in Font (* 256)
    add t3,a1

    DrawCharX\@:
      lw t4,0(t3) ; Load Font Text Character Pixel
      addi t3,4
      sw t4,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4
    bnez t0,DrawChars\@ ; Continue to Print Characters
    subi t0,1 ; Subtract Number of Text Characters to Print
    endm

PrintValue: macro vram, xpos, ypos, fontfile, value, length ; Print HEX Chars To VRAM Using Font At X,Y Position
  lui a0,vram ; A0 = Frame Buffer Pointer
  addi a0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la a1,fontfile ; A1 = Characters
  la a2,value ; A2 = Value Offset
  li t0,length ; T0 = Number of HEX Chars to Print
  DrawHEXChars\@:
    li t1,7 ; T1 = Character X Pixel Counter
    li t2,7 ; T2 = Character Y Pixel Counter

    lb t3,0(a2) ; T3 = Next 2 HEX Chars
    addi a2,1

    srl t4,t3,4 ; T4 = 2nd Nibble
    andi t4,$F
    subi t5,t4,9
    bgtz t5,HEXLetters\@
    addi t4,$30 ; Delay Slot
    j HEXEnd\@
    nop ; Delay Slot

    HEXLetters\@:
    addi t4,7
    HEXEnd\@:

    sll t4,8 ; Add Shift to Correct Position in Font (* 256)
    add t4,a1

    DrawHEXCharX\@:
      lw t5,0(t4) ; Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawHEXCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawHEXCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    li t2,7 ; Reset Character Y Pixel Counter

    andi t4,t3,$F ; T4 = 1st Nibble
    subi t5,t4,9
    bgtz t5,HEXLettersB\@
    addi t4,$30 ; Delay Slot
    j HEXEndB\@
    nop ; Delay Slot

    HEXLettersB\@:
    addi t4,7
    HEXEndB\@:

    sll t4,8 ; Add Shift to Correct Position in Font (* 256)
    add t4,a1

    DrawHEXCharXB\@:
      lw t5,0(t4) ; Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawHEXCharXB\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawHEXCharXB\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    bnez t0,DrawHEXChars\@ ; Continue to Print Characters
    subi t0,1 ; Subtract Number of Text Characters to Print
    endm

Start:
  include LIB\N64_GFX.INC ; Include Graphics Macros
  N64_INIT ; Run N64 Initialisation Routine

  ScreenNTSC 640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000 ; Screen NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin = $A0100000

  lui a0,$A010 ; A0 = VRAM Start Offset
  addi a1,a0,((640*480*4)-4) ; A1 = VRAM End Offset
  li t0,$000000FF ; T0 = Black
ClearScreen:
  sw t0,0(a0)
  bne a0,a1,ClearScreen
  addi a0,4 ; Delay Slot


  PrintString $A010,88,8,FontRed,WORDHEX,9 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,232,8,FontRed,WORDDEC,13 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,384,8,FontRed,RTHEX,7 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,528,8,FontRed,TEST,10 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,0,16,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,8,24,FontRed,LW,1 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEWORDA ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,24,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,24,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,24,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,24,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,24,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKA ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,24,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDA
  nop ; Delay Slot
  LWPASSA:
  PrintString $A010,528,24,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDA:

  la a0,VALUEWORDB ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,32,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,32,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,32,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,32,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,32,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKB ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,32,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDB
  nop ; Delay Slot
  LWPASSB:
  PrintString $A010,528,32,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDB:

  la a0,VALUEWORDC ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,40,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,40,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,40,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,40,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,40,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKC ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,40,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDC
  nop ; Delay Slot
  LWPASSC:
  PrintString $A010,528,40,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDC:

  la a0,VALUEWORDD ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,48,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,48,FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,48,FontBlack,TEXTWORDD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,48,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,48,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKD ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,48,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDD
  nop ; Delay Slot
  LWPASSD:
  PrintString $A010,528,48,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDD:

  la a0,VALUEWORDE ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,56,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,56,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,56,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,56,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,56,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKE ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,56,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDE
  nop ; Delay Slot
  LWPASSE:
  PrintString $A010,528,56,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDE:

  la a0,VALUEWORDF ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,64,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,64,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,64,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,64,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,64,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKF ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,64,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDF
  nop ; Delay Slot
  LWPASSF:
  PrintString $A010,528,64,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDF:

  la a0,VALUEWORDG ; A0 = Word Data Offset
  lw t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,72,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,72,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,72,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,72,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,72,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG   ; A0 = Long Data Offset
  ld t0,0(a0)    ; T0 = Long Data
  la a0,LWCHECKG ; A0 = Long Check Data Offset
  ld t1,0(a0)    ; T1 = Long Check Data
  beq t0,t1,LWPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,72,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWENDG
  nop ; Delay Slot
  LWPASSG:
  PrintString $A010,528,72,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWENDG:


  PrintString $A010,8,88,FontRed,LWL,2 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEWORDA ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,88,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,88,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,88,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,88,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,88,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKA ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,88,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDA
  nop ; Delay Slot
  LWLPASSA:
  PrintString $A010,528,88,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDA:

  la a0,VALUEWORDB ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,96,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,96,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,96,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,96,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,96,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKB ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,96,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDB
  nop ; Delay Slot
  LWLPASSB:
  PrintString $A010,528,96,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDB:

  la a0,VALUEWORDC ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,104,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,104,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,104,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,104,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,104,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKC ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,104,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDC
  nop ; Delay Slot
  LWLPASSC:
  PrintString $A010,528,104,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDC:

  la a0,VALUEWORDD ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,112,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,112,FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,112,FontBlack,TEXTWORDD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,112,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,112,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKD ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,112,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDD
  nop ; Delay Slot
  LWLPASSD:
  PrintString $A010,528,112,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDD:

  la a0,VALUEWORDE ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,120,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,120,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,120,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,120,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,120,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKE ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,120,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDE
  nop ; Delay Slot
  LWLPASSE:
  PrintString $A010,528,120,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDE:

  la a0,VALUEWORDF ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,128,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,128,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,128,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,128,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,128,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKF ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,128,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDF
  nop ; Delay Slot
  LWLPASSF:
  PrintString $A010,528,128,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDF:

  la a0,VALUEWORDG ; A0 = Word Data Offset
  lwl t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,136,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,136,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,136,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,136,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,136,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWLCHECKG ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWLPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,136,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWLENDG
  nop ; Delay Slot
  LWLPASSG:
  PrintString $A010,528,136,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWLENDG:


  PrintString $A010,8,152,FontRed,LWR,2 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEWORDA ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,152,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,152,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,152,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,152,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,152,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKA ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,152,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDA
  nop ; Delay Slot
  LWRPASSA:
  PrintString $A010,528,152,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDA:

  la a0,VALUEWORDB ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,160,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,160,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,160,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,160,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,160,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKB ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,160,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDB
  nop ; Delay Slot
  LWRPASSB:
  PrintString $A010,528,160,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDB:

  la a0,VALUEWORDC ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,168,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,168,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,168,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,168,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,168,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKC ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,168,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDC
  nop ; Delay Slot
  LWRPASSC:
  PrintString $A010,528,168,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDC:

  la a0,VALUEWORDD ; T0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; T1 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,176,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,176,FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,176,FontBlack,TEXTWORDD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,176,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,176,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKD ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,176,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDD
  nop ; Delay Slot
  LWRPASSD:
  PrintString $A010,528,176,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDD:

  la a0,VALUEWORDE ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,184,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,184,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,184,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,184,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,184,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKE ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,184,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDE
  nop ; Delay Slot
  LWRPASSE:
  PrintString $A010,528,184,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDE:

  la a0,VALUEWORDF ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,192,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,192,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,192,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,192,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,192,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKF ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,192,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDF
  nop ; Delay Slot
  LWRPASSF:
  PrintString $A010,528,192,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDF:

  la a0,VALUEWORDG ; A0 = Word Data Offset
  lwr t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,200,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,200,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,200,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,200,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,200,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWRCHECKG ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWRPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,200,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWRENDG
  nop ; Delay Slot
  LWRPASSG:
  PrintString $A010,528,200,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWRENDG:


  PrintString $A010,8,216,FontRed,LWU,2 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEWORDA ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,216,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,216,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,216,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,216,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,216,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKA ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,216,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDA
  nop ; Delay Slot
  LWUPASSA:
  PrintString $A010,528,216,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDA:

  la a0,VALUEWORDB ; T0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; T1 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,224,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,224,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,224,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,224,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,224,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKB ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,224,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDB
  nop ; Delay Slot
  LWUPASSB:
  PrintString $A010,528,224,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDB:

  la a0,VALUEWORDC ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,232,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,232,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,232,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,232,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,232,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKC ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,232,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDC
  nop ; Delay Slot
  LWUPASSC:
  PrintString $A010,528,232,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDC:

  la a0,VALUEWORDD ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,240,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,240,FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,240,FontBlack,TEXTWORDD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,240,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,240,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKD ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,240,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDD
  nop ; Delay Slot
  LWUPASSD:
  PrintString $A010,528,240,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDD:

  la a0,VALUEWORDE ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,248,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,248,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,248,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,248,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,248,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKE ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,248,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDE
  nop ; Delay Slot
  LWUPASSE:
  PrintString $A010,528,248,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDE:

  la a0,VALUEWORDF ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,256,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,256,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,256,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,256,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,256,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKF ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,256,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDF
  nop ; Delay Slot
  LWUPASSF:
  PrintString $A010,528,256,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDF:

  la a0,VALUEWORDG ; A0 = Word Data Offset
  lwu t0,0(a0) ; T0 = Test Long Data
  la a0,RTLONG ; A0 = RTLONG Offset
  sd t0,0(a0)  ; RTLONG = Long Data
  PrintString $A010,144,264,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,264,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,264,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,376,264,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,264,FontBlack,RTLONG,7 ; Print Text String To VRAM Using Font At X,Y Position
  la a0,RTLONG    ; A0 = Long Data Offset
  ld t0,0(a0)     ; T0 = Long Data
  la a0,LWUCHECKG ; A0 = Long Check Data Offset
  ld t1,0(a0)     ; T1 = Long Check Data
  beq t0,t1,LWUPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,264,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j LWUENDG
  nop ; Delay Slot
  LWUPASSG:
  PrintString $A010,528,264,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  LWUENDG:


  PrintString $A010,0,272,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


Loop:
  WaitScanline $1E0 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $1E2

  li t0,$00000800 ; Even Field
  sw t0,VI_Y_SCALE(a0)

  WaitScanline $1E0 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $1E2

  li t0,$02000800 ; Odd Field
  sw t0,VI_Y_SCALE(a0)

  j Loop
  nop ; Delay Slot

LW: db "LW"
LWL: db "LWL"
LWR: db "LWR"
LWU: db "LWU"

RTHEX: db "RT (Hex)"
WORDHEX: db "WORD (Hex)"
WORDDEC: db "WORD (Decimal)"
TEST: db "Test Result"
FAIL: db "FAIL"
PASS: db "PASS"

DOLLAR: db "$"

TEXTWORDA: db "0"
TEXTWORDB: db "123456789"
TEXTWORDC: db "123456"
TEXTWORDD: db "123451234"
TEXTWORDE: db "-123451234"
TEXTWORDF: db "-123456"
TEXTWORDG: db "-123456789"

PAGEBREAK: db "--------------------------------------------------------------------------------"

  align 4 ; Align 32-Bit
VALUEWORDA: dw 0
VALUEWORDB: dw 123456789
VALUEWORDC: dw 123456
VALUEWORDD: dw 123451234
VALUEWORDE: dw -123451234
VALUEWORDF: dw -123456
VALUEWORDG: dw -123456789

  align 8 ; Align 64-Bit
LWCHECKA: data $0000000000000000
LWCHECKB: data $00000000075BCD15
LWCHECKC: data $000000000001E240
LWCHECKD: data $00000000075BB762
LWCHECKE: data $FFFFFFFFF8A4489E
LWCHECKF: data $FFFFFFFFFFFE1DC0
LWCHECKG: data $FFFFFFFFF8A432EB

LWLCHECKA: data $0000000000000000
LWLCHECKB: data $00000000075BCD15
LWLCHECKC: data $000000000001E240
LWLCHECKD: data $00000000075BB762
LWLCHECKE: data $FFFFFFFFF8A4489E
LWLCHECKF: data $FFFFFFFFFFFE1DC0
LWLCHECKG: data $FFFFFFFFF8A432EB

LWRCHECKA: data $FFFFFFFFFFFFFF00
LWRCHECKB: data $FFFFFFFFFFFFFF07
LWRCHECKC: data $FFFFFFFFFFFFFF00
LWRCHECKD: data $FFFFFFFFFFFFFF07
LWRCHECKE: data $FFFFFFFFFFFFFFF8
LWRCHECKF: data $FFFFFFFFFFFFFFFF
LWRCHECKG: data $FFFFFFFFFFFFFFF8

LWUCHECKA: data $0000000000000000
LWUCHECKB: data $00000000075BCD15
LWUCHECKC: data $000000000001E240
LWUCHECKD: data $00000000075BB762
LWUCHECKE: data $00000000F8A4489E
LWUCHECKF: data $00000000FFFE1DC0
LWUCHECKG: data $00000000F8A432EB

RTLONG: data 0

FontBlack: incbin FontBlack8x8.bin
FontGreen: incbin FontGreen8x8.bin
FontRed: incbin FontRed8x8.bin