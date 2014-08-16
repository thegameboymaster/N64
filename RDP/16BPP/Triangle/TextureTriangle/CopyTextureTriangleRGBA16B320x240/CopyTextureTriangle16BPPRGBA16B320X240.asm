; N64 'Bare Metal' 16BPP 320x240 Copy Texture Triangle RGBA16B RDP Demo by krom (Peter Lemon):

  include LIB\N64.INC ; Include N64 Definitions
  dcb 2097152,$00 ; Set ROM Size
  org $80000000 ; Entry Point Of Code
  include LIB\N64_HEADER.ASM  ; Include 64 Byte Header & Vector Table
  incbin LIB\N64_BOOTCODE.BIN ; Include 4032 Byte Boot Code

Start:
  include LIB\N64_INIT.ASM ; Include Initialisation Routine
  include LIB\N64_GFX.INC  ; Include Graphics Macros

  ScreenNTSC 320,240, BPP16|AA_MODE_2, $A0100000 ; Screen NTSC: 320x240, 16BPP, Resample Only, DRAM Origin $A0100000

  DMA Texture,TextureEnd, $00200000 ; DMA Data Copy Cart->DRAM: Start Cart Address, End Cart Address, Destination DRAM Address

  WaitScanline $200 ; Wait For Scanline To Reach Vertical Blank

  DPC RDPBuffer,RDPBufferEnd ; Run DPC Command Buffer: Start Address, End Address

Loop:
  j Loop
  nop ; Delay Slot

  align 8 ; Align 64-bit
RDPBuffer:
  Set_Scissor 0<<2,0<<2, 320<<2,240<<2, 0 ; Set Scissor: XH 0.0, YH 0.0, XL 320.0, YL 240.0, Scissor Field Enable Off
  Set_Other_Modes CYCLE_TYPE_FILL, 0 ; Set Other Modes
  Set_Color_Image SIZE_OF_PIXEL_16B|(320-1), $00100000 ; Set Color Image: SIZE 16B, WIDTH 320, DRAM ADDRESS $00100000
  Set_Fill_Color $FF01FF01 ; Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 ; Fill Rectangle: XL 319.0, YL 239.0, XH 0.0, YH 0.0

  Set_Other_Modes CYCLE_TYPE_COPY, ALPHA_COMPARE_EN ; Set Other Modes

  Set_Texture_Image SIZE_OF_PIXEL_16B|(8-1), $00200000 ; Set Texture Image: SIZE 16B, WIDTH 8, DRAM ADDRESS $00200000
  Set_Tile SIZE_OF_PIXEL_16B|(2<<9)|$000, 0<<24 ; Set Tile: SIZE 16B, Tile Line Size 2 (64bit Words), TMEM Address $000, Tile 0
  Load_Tile 0<<2,0<<2, 0, 7<<2,7<<2 ; Load Tile: SL 0.0, TL 0.0, Tile 0, SH 7.0, TH 7.0
  ;
  ;      DxHDy
  ;      .___. v[2]:XH,XM(X:72.0) YH(Y:122.0), v[1]:XL(X:79.0) YM(Y:122.0)
  ;      |  /
  ; DxMDy| /DxLDy
  ;      ./    v[0]:(X:72.0) YL(Y:129.0)
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 129.0, YM 122.0, YH 122.0, XL 79.0, DxLDy -1.0, XH 72.0, DxHDy 0.0, XM 72.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 516,488,488, 79,0, -1,0, 72,0, 0,0, 72,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 0.0, T 0.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe 0.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 0,0,0, 128,0,0, 0,0,0, 0,0,0, 0,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf
  ;
  ;          . v[2]:XH,XM(X:79.0) YH(Y:123.0)
  ;         /|
  ; DxMDy  / |DxHDy
  ;      ./__. v[0]:(X:72.0) YL(Y:130.0), v[1]:XL(X:79.0) YM(Y:130.0)
  ;      DxLDy
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 130.0, YM 130.0, YH 123.0, XL 79.0, DxLDy 0.0, XH 79.0, DxHDy -1.0, XM 79.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 520,520,492, 79,0, 0,0, 79,0, -1,0, 79,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 240.0, T 32.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe -32.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 240,32,0, 128,0,0, 0,0,0, 0,0,0, -32,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf

  Sync_Tile ; Sync Tile
  Set_Texture_Image SIZE_OF_PIXEL_16B|(16-1), $00200080 ; Set Texture Image: SIZE 16B, WIDTH 16, DRAM ADDRESS $00200080
  Set_Tile SIZE_OF_PIXEL_16B|(4<<9)|$000, 0<<24 ; Set Tile: SIZE 16B, Tile Line Size 4 (64bit Words), TMEM Address $000, Tile 0
  Load_Tile 0<<2,0<<2, 0, 15<<2,15<<2 ; Load Tile: SL 0.0, TL 0.0, Tile 0, SH 15.0, TH 15.0
  ;
  ;      DxHDy
  ;      .___. v[2]:XH,XM(X:152.0) YH(Y:114.0), v[1]:XL(X:167.0) YM(Y:114.0)
  ;      |  /
  ; DxMDy| /DxLDy
  ;      ./    v[0]:(X:152.0) YL(Y:129.0)
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 129.0, YM 114.0, YH 114.0, XL 167.0, DxLDy -1.0, XH 152.0, DxHDy 0.0, XM 152.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 516,456,456, 167,0, -1,0, 152,0, 0,0, 152,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 0.0, T 0.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe 0.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 0,0,0, 128,0,0, 0,0,0, 0,0,0, 0,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf
  ;
  ;          . v[2]:XH,XM(X:167.0) YH(Y:115.0)
  ;         /|
  ; DxMDy  / |DxHDy
  ;      ./__. v[0]:(X:152.0) YL(Y:130.0), v[1]:XL(X:167.0) YM(Y:130.0)
  ;      DxLDy
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 130.0, YM 130.0, YH 115.0, XL 167.0, DxLDy 0.0, XH 167.0, DxHDy -1.0, XM 167.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 520,520,460, 167,0, 0,0, 167,0, -1,0, 167,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 496.0, T 32.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe -32.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 496,32,0, 128,0,0, 0,0,0, 0,0,0, -32,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf

  Sync_Tile ; Sync Tile
  Set_Texture_Image SIZE_OF_PIXEL_16B|(32-1), $00200280 ; Set Texture Image: SIZE 16B, WIDTH 32, DRAM ADDRESS $00200280
  Set_Tile SIZE_OF_PIXEL_16B|(8<<9)|$000, 0<<24 ; Set Tile: SIZE 16B, Tile Line Size 8 (64bit Words), TMEM Address $000, Tile 0
  Load_Tile 0<<2,0<<2, 0, 31<<2,31<<2 ; Load Tile: SL 0.0, TL 0.0, Tile 0, SH 31.0, TH 31.0
  ;
  ;      DxHDy
  ;      .___. v[2]:XH,XM(X:244.0) YH(Y:98.0), v[1]:XL(X:275.0) YM(Y:98.0)
  ;      |  /
  ; DxMDy| /DxLDy
  ;      ./    v[0]:(X:244.0) YL(Y:129.0)
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 129.0, YM 98.0, YH 98.0, XL 275.0, DxLDy -1.0, XH 244.0, DxHDy 0.0, XM 244.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 516,392,392, 275,0, -1,0, 244,0, 0,0, 244,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 0.0, T 0.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe 0.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 0,0,0, 128,0,0, 0,0,0, 0,0,0, 0,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf
  ;
  ;          . v[2]:XH,XM(X:275.0) YH(Y:99.0)
  ;         /|
  ; DxMDy  / |DxHDy
  ;      ./__. v[0]:(X:244.0) YL(Y:130.0), v[1]:XL(X:275.0) YM(Y:130.0)
  ;      DxLDy
  ;
  ; Output: Dir 1, Level 0, Tile 0, YL 130.0, YM 130.0, YH 99.0, XL 275.0, DxLDy 0.0, XH 275.0, DxHDy -1.0, XM 275.0, DxMDy 0.0
    Texture_Triangle 1, 0, 0, 520,520,396, 275,0, 0,0, 275,0, -1,0, 275,0, 0,0 ; Generated By N64RightMajorTriangleCalc.py
  ; Output: S 992.0, T 32.0, W 0.0, DsDx 128.0, DtDx 0.0, DwDx 0.0, DsDe -32.0, DtDe 32.0, DwDe 0.0, DsDy 0.0, DtDy 0.0, DwDy 0.0
    Texture_Coefficients 992,32,0, 128,0,0, 0,0,0, 0,0,0, -32,32,0, 0,0,0, 0,0,0, 0,0,0 ; s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf

  Sync_Full ; Ensure Entire Scene Is Fully Drawn
RDPBufferEnd:

Texture:
  dh $F001,$0000,$0000,$0001,$0001,$0000,$0000,$0000 // 8x8x16B = 128 Bytes
  dh $0000,$0000,$0001,$FFFF,$FFFF,$0001,$0000,$0000
  dh $0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$0001,$0001,$FFFF,$FFFF,$0001,$0001,$0001
  dh $0000,$0000,$0001,$FFFF,$FFFF,$0001,$0000,$0000
  dh $0000,$0000,$0001,$0001,$0001,$0001,$0000,$0000

  dh $F001,$F001,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000 // 16x16x16B = 512 Bytes
  dh $F001,$F001,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000
  dh $0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000
  dh $0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$0001,$0001,$0001,$0001,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0001,$0001,$0001,$0001,$0001
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000

  dh $F001,$F001,$F001,$F001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 // 32x32x16B = 2048 Bytes
  dh $F001,$F001,$F001,$F001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $F001,$F001,$F001,$F001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $F001,$F001,$F001,$F001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000
  dh $0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000
  dh $0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001
  dh $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dh $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
TextureEnd: