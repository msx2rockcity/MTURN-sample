;
; MSX2 MTURN SAMPLE Machine Language File
;
; write by msx2rockcity
;
FORCLR:   EQU     0F3E9H
BAKCLR:   EQU     0F3EAH
BDRCLR:   EQU     0F3EBH
RG8SAV:   EQU     0FFE7H
CHGMOD:   EQU     005FH
BREAKX:   EQU     00B7H
GTSTCK:   EQU     00D5H
SIN15:    EQU     01000010B
COS15:    EQU     11110111B
          ORG     0D000H
          
;---- SCREEN & COLOR SET ----
          LD      A,15
          LD      (FORCLR),A
          LD      A,0
          LD      (BAKCLR),A
          LD      A,0
          LD      (BDRCLR),A
          ;
          LD      A,(RG8SAV)
          OR      00000010B
          LD      (RG8SAV),A
          ;
          LD      A,5
          RST     30H
          DB      0
          DW      CHGMOD
          ;
          LD      A,0
          LD      HL,0006H
          CALL    000CH
          LD      (RDVDP),A
          EI
          LD      A,0
          LD      HL,0007H
          CALL    000CH
          LD      (RDVDP+1),A
          EI
          CALL    CLS
	      CALL	  MAIN
          JR      KE2
      
;---- MAIN KEY ROUTINE ----
KEY:      RST     30H
          DB      0
          DW      BREAKX
          JR      C,RETURN
          ;
          XOR     A
          RST     30H
          DB      0
          DW      GTSTCK
          OR      A
          JR      Z,KEY
          ;
          LD      HL,PORIDAT+6
          LD      B,(HL) ;NX
          INC     HL
          LD      C,(HL) ;NZ
          LD      DE,PAD
          DEC     A
          ADD     A,A
          ADD     A,E
          JR      NC,KE1
          INC     D
KE1:      LD      E,A
          EX      DE,HL
          LD      A,(HL)
          ADD     A,C
          AND     00011111B
          LD      (DE),A
          DEC     DE
          INC     HL
          LD      A,(HL)
          ADD     A,B
          AND     00011111B
          LD      (DE),A
KE2:      CALL    MAIN
          ;
          LD      A,(VIJUAL)
          XOR     1
          LD      (VIJUAL),A
          RRCA
          RRCA
          RRCA
          OR      00011111B
          DI
          OUT     (99H),A
          LD      A,80H+2
          OUT     (99H),A
          EI
          ;
          CALL    CLS
          JR      KEY
          ;
RETURN:   LD      A,15
          LD      HL,0
          LD      (FORCLR),A
          LD      (BAKCLR),HL
          LD      A,0
          RST     30H
          DB      0
          DW      CHGMOD
          JP      103H
          ;
PAD:      DEFB     0, 2
          DEFB     1, 1
          DEFB     2, 0
          DEFB     1,-1
          DEFB     0,-2
          DEFB    -1,-1
          DEFB    -2, 0
          DEFB    -1, 1

;---- POINT TURN ROUTINE ----
MAIN:     LD      IX,PORIDAT
          LD      L,(IX+1)
          LD      H,(IX+2)
          LD      B,(HL);SUU
          INC     HL
          LD      E,(HL);TYOUTEN
          INC     HL
          LD      D,(HL);TYOUTEN
          INC     HL
          PUSH    HL  ;PORIDAT
          EX      DE,HL ;HL<-TDAT
          LD      D,(IX+6)  ;NX
          LD      E,(IX+7)  ;NY
LOOP:     PUSH    BC ;SUU
          PUSH    HL ;TYOUTEN
          PUSH    DE ;NX NY
          CALL    TURN
          ;
          LD      HL,WORK
          LD      A,(IX+3);CENTER
          ADD     A,(HL)
          LD      (HL),A
          INC     HL
          LD      A,(IX+4)
          ADD     A,(HL)
          LD      (HL),A
          INC     HL
          LD      A,(IX+5)
          ADD     A,(HL)
          LD      (HL),A
          ;
          LD      HL,(HYOUJI)
          CALL    MONMAK
          LD      (HYOUJI),HL
          POP     DE
          POP     HL
          POP     BC
          INC     HL
          INC     HL
          INC     HL
          DJNZ    LOOP
          LD      HL,HYOUJI+2
          LD      (HYOUJI),HL
          ;
SCREEN:   POP     BC ;PORIDAT
          LD      A,(BC);COLOR
          LD      E,A
          LD      D,0
          LD      (LIDAT+4),DE
          INC     BC
SC0:      LD      A,(BC)
          ADD     A,A
          LD      HL,HYOUJI
          ADD     A,L
          JR      NC,SC1
          INC     H
SC1:      LD      L,A
          LD      D,(HL) ;X
          INC     HL
          LD      E,(HL) ;Y
          INC     BC
          LD      A,(BC)
          ADD     A,A
          LD      HL,HYOUJI
          ADD     A,L
          JR      NC,SC2
          INC     HL
SC2:      LD      L,A
          PUSH    DE
          LD      D,(HL)
          INC     HL
          LD      E,(HL)
          POP     HL
          LD      (LIDAT),HL
          LD      (LIDAT+2),DE
          CALL    LINE
          INC     BC
          LD      A,(BC)
          DEC     BC
          OR      A
          JR      NZ,SC0
          INC     BC
          INC     BC
          LD      A,(BC)
          OR      A
          JR      NZ,SC0
          RET
;----- POINT TURN -----
          ;
TURN:     PUSH    AF
          PUSH    BC
          LD      A,D  ;NX
          LD      B,(HL) ;X
          INC     HL
          LD      C,(HL) ;Y
          INC     HL
          CALL    KAITEN
          LD      D,C    ;Y'
          LD      C,(HL)
          LD      A,E
          CALL    KAITEN
          LD      HL,WORK
          LD      (HL),B ;X''
          INC     HL
          LD      (HL),D ;Y'
          INC     HL
          LD      (HL),C ;Z'
          POP     BC
          POP     AF
          RET
          ;
KAITEN:   PUSH    DE
          PUSH    HL
          LD      HL,SINDAT
          ADD     A,A
          ADD     A,L
          JR      NC,JR0
          INC     H
JR0:      LD      L,A
          LD      D,(HL) ;SINn
          INC     HL
          LD      E,(HL) ;COSn
          LD      A,D    ;SINn
          LD      H,B    ;X
          CALL    TIMES  ;XSINn
          LD      L,A    ;L<-
          LD      A,E    ;COSn
          LD      H,C    ;Y
          CALL    TIMES  ;YCOSn
          LD      H,A    ;H<-
          PUSH    HL
          LD      A,D    ;SINn
          LD      H,C    ;Y
          CALL    TIMES  ;YSINn
          LD      L,A    ;L<-
          LD      A,E    ;COSn
          LD      H,B    ;X
          CALL    TIMES  ;XCOSn
          SUB     L   ;XCOS-YSIN
          LD      B,A ;B<- X'
          POP     HL
          LD      A,H
          ADD     A,L ;XSIN+YCOS
          LD      C,A ;C<- Y'
          POP     HL
          POP     DE
          RET
          ;
TIMES:    OR      A
          RET     Z   ;SIN=0
          PUSH    HL
          PUSH    BC
          PUSH    DE
          LD      D,0
          LD      E,H
          LD      HL,0
          SLA     A   ;SIN<0
          LD      B,A
          JR      NC,JR1
          LD      HL,44EDH
JR1:      LD      (NEGPAT),HL
          LD      HL,0
          LD      A,E
          OR      A
          JP      P,JR2
          LD      HL,44EDH
          NEG
JR2:      LD      (NEGPT2),HL
          LD      E,A
          LD      A,B
          CP      0FEH  ;SIN=1
          JR      NZ,JR3
          LD      A,E
          JR      NEGPAT
JR3:      LD      HL,0
          LD      B,8
LOOP2:    RRA
          JR      NC,JR4
          ADD     HL,DE
JR4:      SLA     E
          RL      D
          DJNZ    LOOP2
          LD      A,H
NEGPAT:   NOP
          NOP
NEGPT2:   NOP
          NOP
          POP     DE
          POP     BC
          POP     HL
          RET
          ;
;-------- SIN COS SIN COS ---
SINDAT:
DEFB        0,127, 25,126 ;0
DEFB       49,119, 71,107 ;1
DEFB       91, 91,107, 71 ;2
DEFB      119, 49,126, 25 ;3
DEFB      127,  0,126,153 ;4
DEFB      119,177,107,199 ;5
DEFB       91,219, 71,235 ;6
DEFB       49,247, 25,254 ;7
DEFB        0,255,153,254 ;8
DEFB      177,247,199,235 ;9
DEFB      219,219,235,199 ;A
DEFB      247,177,254,153 ;B
DEFB      255,  0,254, 25 ;C
DEFB      247, 49,235, 71 ;D
DEFB      219, 91,199,107 ;E
DEFB      177,119,153,126 ;F
;
;---- MONPOI MAKE ----;
          ;
MONMAK:   PUSH    AF
          PUSH    BC
          PUSH    DE
          LD      DE,WORK
          EX      DE,HL
          LD      A,(HL) ;X
          LD      BC,0
          INC     HL
          INC     HL
          ADD     A,(HL) ;X+Z
          RRA
          RR      C
          RRA
          RR      C
          LD      B,A
          LD      A,(HL)
          ADD     A,128
          RRA
          CALL    WARIZU
          LD      (DE),A
          DEC     HL
          INC     DE
          LD      A,(HL)  ;Y
          LD      BC,0
          INC     HL
          ADD     A,(HL)
          RRA
          RR      C
          RRA
          RR      C
          LD      B,A
          LD      A,(HL)
          ADD     A,128
          RRA
          CALL    WARIZU
          LD      (DE),A
          INC     DE
          EX      DE,HL
          POP     DE
          POP     BC
          POP     AF
          RET
          ;
WARIZU:   PUSH    BC
          EXX
          POP     BC
          LD      L,0
          LD      H,L
          LD      E,A
          LD      D,H
          EXX
          LD      B,16
WA0:      EXX
          SLA     C
          RL      B
          RL      L
          RL      H
          OR      A
          SBC     HL,DE
          JR      NC,WA1
          ADD     HL,DE
          SCF
WA1:      CCF
          EXX
          RL      C
          RL      A
          DJNZ    WA0
          LD      A,C
          RET
          ;
;----- LINE MAKE ROUTINE -----
          ;
LINE:     PUSH    AF
          PUSH    BC
          PUSH    DE
          PUSH    HL
          LD      BC,(RDVDP)
          INC     B
          INC     C
          LD      L,C
          LD      C,B
          LD      DE,028FH
          DI
          OUT     (C),D
          OUT     (C),E
          LD      DE,2491H
          OUT     (C),D
          OUT     (C),E
          LD      H,C
          LD      C,L
WAITLI:   IN      A,(C)
          AND     1
          JR      NZ,WAITLI
          LD      C,H
          OUT     (C),A
          LD      A,8FH
          OUT     (C),A
          INC     C
          INC     C
          ;
          LD      HL,(LIDAT)
          LD      DE,(LIDAT+2)
          XOR     A
          OUT     (C),H
          OUT     (C),A
          OUT     (C),L
          LD      A,(VIJUAL)
          XOR     1
          OUT     (C),A
          LD      B,00000000B
          LD      A,D
          SUB     H
          JR      NC,LINE1
          NEG
          SET     2,B
LINE1:    LD      D,A
          LD      A,E
          SUB     L
          JR      NC,LINE2
          NEG
          SET     3,B
LINE2:    LD      E,A
          CP      D
          JR      C,LINE3
          SET     0,B
          LD      A,D
          LD      D,E
          LD      E,A
LINE3:    XOR     A
          OUT     (C),D
          OUT     (C),A
          OUT     (C),E
          OUT     (C),A
          LD      DE,(LIDAT+4)
          OUT     (C),E
          OUT     (C),B
          LD      A,D
          OR      01110000B
          OUT     (C),A
          EI
          POP     HL
          POP     DE
          POP     BC
          POP     AF
          RET
          ;
LIDAT:    DEFB    0,0  ;X ,Y
          DEFB    0,0  ;X',Y'
          DEFB    0,0  ;COLOR,LOG
;---- CLS ROUTINE ----
CLS:      PUSH    AF
          PUSH    BC
          PUSH    DE
          PUSH    HL
          LD      A,(VIJUAL)
          XOR     1
          LD      (CMDDAT+3),A
          LD      BC,(RDVDP)
          LD      DE,028FH
          INC     B
          INC     C
          LD      L,C
          LD      C,B
          DI
          OUT     (C),D
          OUT     (C),E
          LD      DE,2491H
          OUT     (C),D
          OUT     (C),E
          INC     C
          INC     C
          LD      H,C
          LD      C,L
WAITCL:   IN      A,(C)
          AND     1
          JR      NZ,WAITCL
          LD      C,H
          LD      HL,CMDDAT
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          OUTI
          DEC     C
          DEC     C
          OUT     (C),A
          LD      A,8FH
          OUT     (C),A
          EI
          POP     HL
          POP     DE
          POP     BC
          POP     AF
          RET
          ;
CMDDAT:   DEFB    0,0
          DEFB    0,0
          DEFB    256,0,212,0
          DEFB    11H
          DEFB    00000000B
          DEFB    11000000B
          ;
;---- WORK AREA ----
RDVDP:    DEFS    2
VIJUAL:   DEFB    00000000B
WORK:     DEFB    0,0,0
HYOUJI:   DEFW    HYOUJI+2
          DEFS    120
;---- POINT DATA ----
          ;
PORIDAT:  DEFB    0
          DEFW    DATA
CENTER:   DEFB    128,108,90
          DEFB    0,0
          DEFB    0
          DEFB    0
          ;
DATA:     DEFB    24
          DEFW    TYOUTEN
          DEFB    8
          DEFB    1,2,3,4,1,0
          DEFB    3,7,6,2,0
          DEFB    1,5,8,4,0
          DEFB    6,9,10,7,0
          DEFB    10,14,13,9,0
          DEFB    13,20,19,14,0
          DEFB    19,18,17,20,0
          DEFB    18,24,23,17,0
          DEFB    24,21,22,23,0
          DEFB    21,15,16,22,0
          DEFB    15,11,12,16,0
          DEFB    8,11,12,5,0
          DEFB    1,5,8,4,0,0
          ;
TYOUTEN:  DEFB    -50,-50,-15
          DEFB    -50,+50,-15
          DEFB    -50,+50,+15
          DEFB    -50,-50,+15
          DEFB    -25,-50,-15
          DEFB    -25,+50,-15
          DEFB    -25,+50,+15
          DEFB    -25,-50,+15
          DEFB    -25,  0,-15
          DEFB    -25,  0,+15
          DEFB      0,  0,+15
          DEFB      0,  0,-15
          DEFB      0,+50,-15
          DEFB      0,+50,+15
          DEFB    +25,-50,+15
          DEFB    +25,-50,-15
          DEFB    +25,+50,-15
          DEFB    +25,+50,+15
          DEFB    +25,  0,+15
          DEFB    +25,  0,-15
          DEFB    +50,-50,+15
          DEFB    +50,-50,-15
          DEFB    +50,+50,-15
          DEFB    +50,+50,+15
          END
          