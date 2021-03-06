      SUBROUTINE COMB1        
C        
C     THIS IS THE MODULE FOR THE COMBINATION OF SUBSTRUCTURES.        
C        
C     IT IS PRIMARILY AN INITIALIZER AND DRIVER CALLING THE ROUTINES    
C     NECESSARY TO PROCESS THE COMBINE. THE SUBROUTINES ARE        
C        
C          CMCASE  -  READS THE CASECC DATA BLOCK AND INITIALIZES       
C                     PARAMETERS FOR THE COMBINE OPERATION.        
C          CMTOC   -  GENERATES THE TABLE OF CONTENTS OF PSEUDO-        
C                     STRUCTURES BEING COMBINED AND THEIR COMPONENT     
C                     BASIC SUBSTRUCTURES.        
C          BDAT01  -  PROCESSES THE CONCT1 BULK DATA.        
C          BDAT02  -  PROCESSES THE CONCT  BULK DATA.        
C          BDAT03  -  PROCESSES THE TRANS  BULK DATA.        
C          BDAT04  -  PROCESSES THE RELES  BULK DATA.        
C          BDAT05  -  PROCESSES THE GNEW   BULK DATA.        
C          BDAT06  -  PROCESSES THE GTRAN  BULK DATA.        
C          CMSFIL  -  GENERATES SUBFIL - THE BASIC FILE USED TO STORE   
C                     THE DATA NECESSARY TO AFFECT THE COMBINATION.     
C          CMCONT  -  GENERATES THE CONNECTION ENTRIES TO BE USED.      
C          CMCKCD  -  CHECKS VALIDITY OF MANUALLY-SPECIFIED CONNECTIONS 
C          CMAUTO  -  PROCESSES USERS REQUEST FOR AUTOMATIC        
C                     COMBINATION OF SUBSTRUCTURES.        
C          CMRELS  -  APPLIES ANY MANUAL RELEASE DATA TO THE SYSTEM.    
C          CMCOMB  -  PROCESSES MULTIPLY CONNECTED POINTS.        
C          CMDISC  -  PROCESSES GRID POINTS NOT TO BE CONNECTED.        
C          CMSOFO  -  GENERATES NEW SOF ITEMS FOR THE RESULTANT        
C                     COMBINED STRUCTURE.        
C          CMHGEN  -  GENERATES THE DOF TRANSFORMATION MATRIX FOR       
C                     EACH COMPONENT TO THE COMBINATION        
C        
      LOGICAL         TDAT,CONECT,IAUTO,TRAN,MCON,TOCOPN,LONLY        
      INTEGER         SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,GEOM4,
     1                CASECC,BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,DRY,STEP,   
     2                SYS,OUTT,AAA(2),RESTCT,SCCSTM,SCR3        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC,SCCSTM,SCR3        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INTP,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT,TOCOPN  
      COMMON /CMB004/ TDAT(6),NIPNEW,CNAM(2),LONLY        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYS(69)        
      COMMON /BLANK / STEP,DRY        
      DATA    AAA   / 4HCOMB,4H1    /        
C        
      IF (DRY.EQ.0 .OR. DRY.EQ.-2) GO TO 210        
      SCR1   = 301        
      SCR2   = 302        
      SCBDAT = 303        
      SCSFIL = 304        
      SCCONN = 305        
      SCMCON = 306        
      SCTOC  = 307        
      SCCSTM = 308        
      SCR3   = 309        
      GEOM4  = 102        
      CASECC = 101        
      DO 10 I = 1,6        
      TDAT(I) = .FALSE.        
   10 CONTINUE        
      DO 20 I = 1,7        
      DO 20 J = 1,3        
      ORIGIN(I,J) = 0.0        
   20 CONTINUE        
      LONLY = .FALSE.        
      INTP  = SYS(4)        
      OUTT  = SYS(2)        
      IBUF  = SYS(1)        
C        
      NZ    = KORSZ(Z(1))        
      BUF1  = NZ - IBUF - 2        
      BUF2  = BUF1 - IBUF        
      BUF3  = BUF2 - IBUF        
      BUF4  = BUF3 - IBUF        
      BUF5  = BUF4 - IBUF        
      IB1   = BUF5 - IBUF        
      IB2   = IB1  - IBUF        
      IB3   = IB2  - IBUF        
      SCORE = 1        
      LCORE = IB3 - 1        
      IF (LCORE .GT. 0) GO TO 30        
      CALL MESAGE (8,0,AAA)        
      DRY   = -2        
      GO TO 210        
C        
   30 CALL OPEN (*120,SCCONN,Z(BUF2),1)        
      CALL CLOSE (SCCONN,2)        
      CALL SOFOPN (Z(IB1),Z(IB2),Z(IB3))        
C        
      CALL CMCASE        
      IF (DRY .EQ. -2) GO TO 130        
      CALL CMTOC        
      IF (.NOT.LONLY) GO TO 40        
      CALL CMSOFO        
      GO TO 70        
C        
   40 IFILE = GEOM4        
      CALL PRELOC (*90,Z(BUF1),GEOM4)        
      IF (.NOT.CONECT) GO TO 50        
      CALL BDAT01        
      CALL BDAT02        
   50 IFILE = SCBDAT        
      CALL OPEN (*120,SCBDAT,Z(BUF2),1)        
      CALL BDAT05        
      CALL BDAT06        
      CALL BDAT03        
      CALL CLOSE (GEOM4,1)        
C        
      CALL CMSFIL        
      CALL PRELOC (*100,Z(BUF1),GEOM4)        
      CALL BDAT04        
      CALL CLOSE (GEOM4,1)        
      IF (DRY .EQ. -2) GO TO 150        
   60 IF (TDAT(1) .OR. TDAT(2)) CALL CMCONT        
      IF (DRY .EQ. -2) GO TO 170        
      CALL CMAUTO        
      IF (TDAT(1) .OR. TDAT(2)) CALL CMCKCD        
      IF (DRY .EQ. -2) GO TO 170        
      IF (TDAT(4)) CALL CMRELS        
      CALL CMMCON (NCE)        
      NPS  = NPSUB + 1        
      NDOF = 6        
      IF (MCON) CALL CMCOMB (NPS,NCE,NDOF,Z)        
      IF (DRY .EQ. -2) GO TO 170        
C        
      CALL CMCKDF        
      IF (DRY .EQ. -2) GO TO 170        
      CALL CMDISC        
      CALL CMSOFO        
      CALL CMHGEN        
C        
   70 CALL SOFCLS        
      IF (TOCOPN) CALL CLOSE (SCTOC,1)        
      WRITE  (OUTT,80) UIM        
   80 FORMAT (A29,' 6521, MODULE COMB1 SUCCESSFULLY COMPLETED.')        
      GO TO 210        
C        
   90 IF (CONECT .OR. TRAN) GO TO 100        
      IFILE = SCBDAT        
      CALL OPEN (*120,SCBDAT,Z(BUF2),1)        
      CALL EOF (SCBDAT)        
      CALL CLOSE (SCBDAT,1)        
      CALL CMSFIL        
      IF (.NOT.CONECT) GO TO 60        
C        
C     ERRORS        
C        
  100 WRITE  (OUTT,110) UFM        
  110 FORMAT (A23,' 6510, THE REQUESTED COMBINE OPERATION REQUIRES ',   
     1       'SUBSTRUCTURE BULK DATA WHICH HAS NOT BEEN GIVEN.')        
      GO TO  190        
  120 CALL MESAGE (1,SCBDAT,AAA)        
      GO TO  170        
  130 WRITE  (OUTT,140) UFM        
  140 FORMAT (A23,' 6535, MODULE COMB1 TERMINATING DUE TO ABOVE ',      
     1       'SUBSTRUCTURE CONTROL ERRORS.')        
      GO TO  200        
  150 WRITE  (OUTT,160) UFM        
  160 FORMAT (A23,' 6536, MODULE COMB1 TERMINATING DUE TO ABOVE ERRORS',
     1       ' IN BULK DATA.')        
      GO TO  190        
  170 WRITE  (OUTT,180) UFM        
  180 FORMAT (A23,' 6537, MODULE COMB1 TERMINATING DUE TO ABOVE ERRORS')
  190 IF (TOCOPN) CALL CLOSE (SCTOC,1)        
  200 DRY = -2        
      CALL SOFCLS        
  210 RETURN        
      END        
