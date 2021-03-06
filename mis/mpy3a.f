      SUBROUTINE MPY3A (Z,IZ,DZ)
C*****
C    PREPARES B AND A(T).
C*****
      DOUBLE PRECISION DZ(1),DA
C
C
C
      INTEGER FILEA,FILEB,SCR1,SCR2,FILE
      INTEGER BUF1,BUF2,BUF3
      INTEGER PREC,PRECN
      INTEGER ZPNTRS
      INTEGER TYPIN,TYPOUT,ROW1,ROWM
      INTEGER UTYP,UROW1,UROWN,UINCR
      INTEGER EOL,EOR
      INTEGER PRECL
C
C
C
      DIMENSION Z(1),IZ(1)
      DIMENSION NAME(2)
      DIMENSION MCB(7)
C
C
C FILES
      COMMON / MPY3TL / FILEA(7),FILEB(7),FILEE(7),FILEC(7),SCR1,SCR2,
     1                  SCR,LKORE,CODE,PREC,LCORE,SCR3(7),BUF1,BUF2,
     2                  BUF3,BUF4,E
C SUBROUTINE CALL PARAMETERS
      COMMON / MPY3CP / ITRL,ICORE,N,NCB,M,DUMCP(3),ZPNTRS(22),LAEND
C PACK
      COMMON / PACKX  / TYPIN,TYPOUT,ROW1,ROWM,INCR
C UNPACK
      COMMON / UNPAKX / UTYP,UROW1,UROWN,UINCR
C TERMWISE MATRIX READ
      COMMON / ZNTPKX / A(2),DUM(2),IROW,EOL,EOR
C
C
C
      EQUIVALENCE     (IPOINT,ZPNTRS(3)),      (NPOINT,ZPNTRS(4)),
     *                (IACOLS,ZPNTRS(5)),      (ITRANS,ZPNTRS(7)),
     *                (IBCOLS,ZPNTRS(11))
      EQUIVALENCE     (A(1),DA)
C
C
C
      DATA NAME / 4HMPY3,4HA    /                                       
C*****                                                                  
C    FILE OPENING.                                                      
C*****                                                                  
      FILE = SCR1
      CALL OPEN(*901,SCR1,Z(BUF2),1)
      FILE = FILEB(1)
      CALL OPEN(*901,FILEB,Z(BUF3),0)
      CALL FWDREC(*902,FILEB)
C*****
C    UNPACK B AND PACK INTO SCRATCH FILE 1.
C*****
C PACK PARAMETERS
      TYPIN = PREC
      TYPOUT = PREC
      ROW1 = 1
      ROWM = N
      INCR = 1
C UNPACK PARAMETERS
      UTYP = PREC
      UROW1 = 1
      UROWN = N
      UINCR = 1
      PRECN = PREC*N
      MCB(1) = 301
      MCB(2) = 0
      MCB(3) = N
      MCB(4) = 1
      MCB(5) = PREC
      MCB(6) = 0
      MCB(7) = 0
      DO 50 K=1,NCB
      CALL UNPACK(*20,FILEB,Z(IBCOLS))
      GO TO 40
   20 IB = IBCOLS - 1
      DO 30 L=1,PRECN
      IB = IB + 1
   30 Z(IB) = 0.
   40 CALL PACK (Z(IBCOLS),SCR1,MCB)
      CALL SAVPOS (SCR1,IZ(K))
   50 CONTINUE
      CALL CLOSE (SCR1,1)
      CALL CLOSE (FILEB,1)
      IF (ICORE .EQ. 1) GO TO 9999
C*****
C    INITIALIZE ARRAY CONTAINING POINTERS TO ROWS OF MATRIX A TO 0.
C*****
      DO 100 L=IPOINT,NPOINT
  100 IZ(L) = 0
C*****
C    COUNT NO. OF NON-ZERO COLUMNS IN EACH ROW OF A.
C*****
      FILE = FILEA(1)
      CALL OPEN(*901,FILEA,Z(BUF1),0)
      CALL FWDREC(*902,FILEA)
      DO 120 I=1,M
      CALL INTPK(*120,FILEA,0,PREC,0)
  110 CALL ZNTPKI
      II = IPOINT + IROW - 1
      IZ(II) = IZ(II) + 1
      IF (EOL .EQ. 1) GO TO 120
      GO TO 110
  120 CONTINUE
C*****
C    CALCULATE POINTERS TO ROWS OF MATRIX A.
C*****
      JJ = 1
      DO 130 L=IPOINT,NPOINT
      IF (IZ(L) .EQ. 0) GO TO 130
      INCRJJ = IZ(L)
      IZ(L) = JJ
      JJ = JJ + INCRJJ
  130 CONTINUE
      LAEND = JJ - 1
C*****
C    PROCESS A(T) MATRIX.
C*****
      FILE = FILEA(1)
      CALL REWIND (FILEA)
      CALL FWDREC(*902,FILEA)
      JJ2 = IACOLS + LAEND - 1
      DO 200 JJ=IACOLS,JJ2
  200 IZ(JJ) = 0
      DO 250 J=1,M
      CALL INTPK(*250,FILEA,0,PREC,0)
  210 CALL ZNTPKI
      L = IPOINT + IROW - 1
      JJ = IZ(L)
      JJC = IACOLS + JJ - 1
  220 IF (IZ(JJC) .EQ. 0) GO TO 230
      JJ = JJ + 1
      JJC = JJC + 1
      GO TO 220
  230 IZ(JJC) = J
      IF (PREC .EQ. 2) GO TO 240
      JJT = ITRANS + JJ - 1
      Z(JJT) = A(1)
      IF (EOL .EQ. 1) GO TO 250
      GO TO 210
  240 JJT = (ITRANS - 1)/2 + JJ
      DZ(JJT) = DA
      IF (EOL .EQ. 1) GO TO 250
      GO TO 210
  250 CONTINUE
      PRECL = PREC*LAEND
      CALL CLOSE (FILEA,1)
      GO TO 9999
C*****
C    ERROR MESSAGES.
C*****
  901 NERR = -1
      GO TO 1001
  902 NERR = -2
 1001 CALL MESAGE (NERR,FILE,NAME)
C
 9999 RETURN
      END
