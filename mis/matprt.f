      SUBROUTINE MATPRT (*,*,A,OPTION,COLUMN)        
C        
C     MATPRT AND PRTMAT ARE CALLED ONLY BY INTPRT        
C        
      REAL            A(1)        
      INTEGER         OPTION,COLUMN(1),FILE,TYPE,BUFSIZ,COUNT,        
     1                UTYPE,UI,UJ,UINC,RSP,RDP,CSP,CDP,REW        
      COMMON /SYSTEM/ BUFSIZ,MO,SKP1(6),MAXLIN,SKP2(2),COUNT        
      COMMON /UNPAKX/ UTYPE,UI,UJ,UINC        
      COMMON /XXMPRT/ MCB(7)        
C        
C     MCB = MATRIX CONTROL BLOCK.        
C     A   = ARRAY OF BUFSIZ + I (REAL) OR 2I (COMPLEX) LOCATIONS.       
C     OPTION IS AS DESCRIBED IN -VECPRT-.        
C     RETURN 1 ... PRINT MATRIX TITLE + COLUMN IDENTIFIER.        
C     RETURN 2 ... PRINT COLUMN IDENTIFIER ONLY.        
C                  (PRTMAT = RETURN ENTRY POINT)        
C     COLUMN = CURRENT COLUMN NUMBER        
C        
      EQUIVALENCE (FILE,MCB(1)), (J,MCB(2)), (I,MCB(3)), (TYPE,MCB(5))  
      DATA        RSP,RDP,CSP,CDP,REW,INPREW / 1,2,3,4,1,0 /        
C        
      IF (I.LE.0 .OR. J.LE.0)  GO TO 150        
      UTYPE = TYPE        
      IF (TYPE .EQ. RDP) UTYPE = RSP        
      IF (TYPE .EQ. CDP) UTYPE = CSP        
      UI   = 1        
      UJ   = I        
      UINC = 1        
      CALL GOPEN (FILE,A,INPREW)        
      COUNT = MAXLIN        
C        
      COLUMN(1) = 0        
  110 COLUMN(1) = COLUMN(1) + 1        
      CALL UNPACK (*140,FILE,A(BUFSIZ+1))        
      CALL VECPRT (*120,*130,UTYPE,I,A(BUFSIZ+1),OPTION)        
      GO TO 140        
  120 RETURN 1        
  130 RETURN 2        
C        
C        
      ENTRY PRTMAT (*,*,COLUMN)        
C     =========================        
C        
      CALL PRTVEC (*120,*130)        
  140 IF (COLUMN(1) .NE. J) GO TO 110        
C        
      CALL CLOSE (FILE,REW)        
  150 RETURN        
      END        
