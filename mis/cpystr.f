      SUBROUTINE CPYSTR (INBLK,OUTBLK,FLAG,COL)        
C        
C     CPYSTR COPIES A LOGICAL RECORD WRITTEN IN STRING FORMAT        
C     FROM ONE FILE TO ANOTHER FILE.        
C        
C     INBLK  = 15-WORD STRING COMMUNICATION BLOCK FOR INPUT FILE        
C     OUTBLK = 15-WORD STRING COMMUNICATION BLOCK FOR OUTPUT FILE       
C     FLAG .NE. 0 MEANS 1ST CALL GETSTR HAS BEEN MADE FOR THE RECORD    
C          .EQ. 0 MEANS 1ST CALL GETSTR HAS NOT BEEN MADE        
C     COL .EQ. 0 MEANS COLUMN NUMBER IS IN INBLK(12)        
C         .NE. 0 MEANS COL IS COLUMN NUMBER        
C        
C        
      INTEGER          INBLK(15),OUTBLK(15),FLAG,PRC,WORDS,RLCMPX,TYPE, 
     1                 PREC,RC,OUT,COL        
      DOUBLE PRECISION XND(1)        
CZZ   COMMON /XNSTRN/  XNS(1)        
      COMMON /ZZZZZZ/  XNS(1)        
      COMMON /TYPE  /  PRC(2),WORDS(4),RLCMPX(4)        
      EQUIVALENCE      (XNS(1),XND(1))        
C        
C     ON OPTION, MAKE 1ST CALL TO GETSTR AND THEN INITIALIZE        
C        
      IF (FLAG .NE. 0) GO TO 10        
      INBLK(8) = -1        
      CALL GETSTR (*50,INBLK)        
   10 OUTBLK(2) = INBLK(2)        
      OUTBLK(3) = INBLK(3)        
      OUTBLK(4) = INBLK(4)        
      OUTBLK(8) = -1        
      OUTBLK(12) = COL        
      IF (COL .EQ. 0) OUTBLK(12) = INBLK(12)        
      OUTBLK(13)= 0        
      TYPE = INBLK(2)        
      PREC = PRC(TYPE)        
      RC   = RLCMPX(TYPE)        
C        
C     COPY A STRING        
C        
   12 CALL PUTSTR (OUTBLK)        
      NPREV = 0        
      OUTBLK(7) = MIN0(INBLK(6),OUTBLK(6))        
   14 IN   = INBLK(5)        
      OUT  = OUTBLK(5)        
      NSTR = OUT + RC*(OUTBLK(7) - NPREV) - 1        
      IF (PREC .EQ. 2) GO TO 18        
C        
      DO 16 JOUT = OUT,NSTR        
      XNS(JOUT) = XNS(IN)        
      IN = IN + 1        
   16 CONTINUE        
      GO TO 20        
C        
   18 DO 19 JOUT = OUT,NSTR        
      XND(JOUT) = XND(IN)        
      IN = IN + 1        
   19 CONTINUE        
C        
C     TEST FOR END OF INPUT STRING(S)        
C        
   20 IF (OUTBLK(7) .EQ. INBLK(6)+NPREV) GO TO 30        
      OUTBLK(13) = OUTBLK(13) + OUTBLK(7)        
      CALL ENDPUT (OUTBLK)        
      OUTBLK(4) = OUTBLK(4) + OUTBLK(7)        
      INBLK(6)  = INBLK(6)  - (OUTBLK(7) - NPREV)        
      INBLK(5)  = IN        
      GO TO 12        
C        
C     INPUT STRING HAS BEEN COPIED.  GET ANOTHER STRING.        
C        
   30 CALL ENDGET (INBLK)        
      CALL GETSTR (*40,INBLK)        
C        
C     TEST FOR STRING CONTIGUOUS WITH PREVIOUS STRING.        
C     IF SO, AND IF TERMS AVAILABLE, CONCATENATE WITH PREVIOUS STRING.  
C        
      IF (INBLK(4) .NE. OUTBLK(4)+OUTBLK(7)) GO TO 35        
      IF (OUTBLK(7).GE. OUTBLK(6)) GO TO 35        
      OUTBLK(5) = NSTR + 1        
      NPREV     = OUTBLK(7)        
      OUTBLK(7) = MIN0(OUTBLK(7)+INBLK(6),OUTBLK(6))        
      GO TO 14        
   35 OUTBLK(13) = OUTBLK(13) + OUTBLK(7)        
      CALL ENDPUT (OUTBLK)        
      OUTBLK(4) = INBLK(4)        
      GO TO 12        
C        
C     NO MORE STRINGS -  CLOSE RECORD AND RETURN        
C        
   40 OUTBLK(8) = 1        
      CALL ENDPUT (OUTBLK)        
      OUTBLK(13) = (OUTBLK(13)+OUTBLK(7))*WORDS(TYPE)        
      RETURN        
C        
C     HERE IF NO STRINGS IN RECORD - MAKE A NULL RECORD        
C        
   50 OUTBLK(2) = 1        
      OUTBLK(3) = 0        
      OUTBLK(8) = -1        
      CALL PUTSTR (OUTBLK)        
      OUTBLK(8) = 1        
      CALL ENDPUT (OUTBLK)        
      RETURN        
      END        
