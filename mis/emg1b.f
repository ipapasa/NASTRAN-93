      SUBROUTINE EMG1B (BUF,SIL,II,FILE,DAMPC)        
C        
C     THIS ROUTINE REPLACES SMA1B AND GROUPS TOGETHER THE        
C     SUB-PARTITIONS OF A PIVOT-PARTITION.        
C        
C     THE SUB-PARTIONS ARE ARRANGED IN CORE BY ASCENDING SILS OF THE    
C     ELEMENT INVOLVED.        
C        
      LOGICAL          ANYCON, ERROR, DOUBLE, LAST, HEAT        
      INTEGER          Z, ZBASE, POSVEC, PRECIS, ROWSIZ, FILE,        
     1                 ELTYPE, ELID, DICT, OUTPT, ESTID,        
     2                 FILTYP, SIL, SILS, SUBR(2), FLAGS        
      REAL             RZ(1)        
      DOUBLE PRECISION DZ(1), DAMPC, BUF(1)        
      CHARACTER        UFM*23, UWM*25, UIM*29, SFM*25        
      COMMON /XMSSG /  UFM, UWM, UIM, SFM        
      COMMON /EMGPRM/  ICORE, JCORE, NCORE, ICSTM, NCSTM, IMAT, NMAT,   
     1                 IHMAT, NHMAT, IDIT, NDIT, ICONG, NCONG, LCONG,   
     2                 ANYCON, FLAGS(3), PRECIS, ERROR, HEAT, ICMBAR,   
     3                 LCSTM, LMAT, LHMAT        
      COMMON /EMG1BX/  NSILS, POSVEC(10), IBLOC, NBLOC, IROWS, DICT(15),
     1                 FILTYP, SILS(10), LAST        
      COMMON /EMGDIC/  ELTYPE, LDICT, NLOCS, ELID, ESTID        
      COMMON /SMA1IO/  SMAIO(36)        
CZZ   COMMON /ZZEMGX/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /IEMG1B/  ICALL, ILAST        
C        
      EQUIVALENCE      (KSYSTM(2), OUTPT)        
      EQUIVALENCE      (Z(1), DZ(1), RZ(1)),   (C, IC)        
      EQUIVALENCE      (SMAIO(13), IF4GG)        
C        
      DATA    SUBR  /  4HEMG1,4HB   /        
C        
      IF (ERROR) RETURN        
      IF (SIL .EQ. -1111111) GO TO 155        
      DOUBLE = .FALSE.        
      IF (PRECIS .EQ. 2) DOUBLE = .TRUE.        
      ICALL = ICALL + 1        
C        
C     IF -FILE- EQUALS IF4GG FOR THE OLD ELEMENTS, THEN THE ELEMENT     
C     DAMPING CONSTANT SENT IS PLACED IN THE DICTIONARY AND A SIMPLE    
C     RETURN IS MADE.        
C        
      IF (HEAT) GO TO  10        
      IF (FILE .NE. IF4GG) IF (II) 20,20,10        
      C = DAMPC        
      DICT(5) = IC        
      ICALL = ICALL - 1        
      RETURN        
C        
   10 IROWS = 1        
      DICT(4) = 1        
      GO TO 30        
   20 IROWS = 6        
      DICT(4) = 63        
   30 IF (ICALL .GT. 1) GO TO 70        
      ROWSIZ = NSILS*IROWS        
      DICT(3) = ROWSIZ        
      IBLOC = JCORE + MOD(JCORE+1,2)        
      IF (DICT(2) .EQ. 2) GO TO 40        
      NBLOC = IBLOC + ROWSIZ*IROWS*PRECIS - 1        
      GO TO 50        
   40 NBLOC = IBLOC + IROWS*PRECIS - 1        
   50 IF (NBLOC .GT. NCORE) CALL MESAGE (-8,NBLOC-NCORE,SUBR)        
      IF (DOUBLE) GO TO 60        
      DO  55  I = IBLOC, NBLOC        
      RZ(I) = 0.0E0        
   55 CONTINUE        
      GO TO 70        
C        
   60 IDBLOC = IBLOC/2 + 1        
      NDBLOC = NBLOC/2        
      DO 65 I = IDBLOC,NDBLOC        
      DZ(I) = 0.0D0        
   65 CONTINUE        
C        
C     INSERT SUB-PARTITION OF PARTITION IN POSITION OF SIL ORDER.       
C        
C     BUF IS ASSUMED DOUBLE PRECISION.        
C        
   70 DO 80 I = 1,NSILS        
      IF (SIL .EQ. SILS(I)) GO TO 100        
   80 CONTINUE        
      WRITE  (OUTPT,90) SFM,ELID        
   90 FORMAT (A25,' 3116, ELEMENT ID',I10,' SENDS BAD SIL TO ROUTINE ', 
     1       'EMG1B.')        
      CALL MESAGE (-37,0,SUBR)        
C        
  100 IF (DICT(2) .EQ. 2) GO TO 130        
      ZBASE = IROWS*(I-1)        
      KMAT = 1        
      IF (DOUBLE) GO TO 125        
C        
C     SINGLE PRECISION ADDITION OF DATA        
C        
      J1 = IBLOC + ZBASE        
      J2 = J1 + IROWS - 1        
      DO  120  I = 1,IROWS        
      DO  110  J = J1,J2        
      RZ(J) = RZ(J) + SNGL(BUF(KMAT))        
      KMAT = KMAT + 1        
  110 CONTINUE        
      J1 = J1 + ROWSIZ        
      J2 = J2 + ROWSIZ        
  120 CONTINUE        
      GO TO 150        
C        
C     DOUBLE PRECISION ADDITION OF MATRIX DATA.        
C        
  125 J1 = IDBLOC + ZBASE        
      J2 = J1 + IROWS - 1        
      DO  127  I = 1,IROWS        
      DO  126  J = J1,J2        
      DZ(J) = DZ(J) + BUF(KMAT)        
      KMAT = KMAT + 1        
  126 CONTINUE        
      J1 = J1 + ROWSIZ        
      J2 = J2 + ROWSIZ        
  127 CONTINUE        
      GO TO 150        
C        
C     SIMPLE DIAGONAL MATRIX INSERTION        
C        
  130 KMAT = 1        
      IF (DOUBLE) GO TO 145        
      J1 = IBLOC        
      DO  140  I = 1,IROWS        
      RZ(J1) = RZ(J1) + SNGL(BUF(KMAT))        
      J1 = J1 + 1        
      KMAT = KMAT + 14        
  140 CONTINUE        
      GO TO 150        
C        
  145 J1 = IDBLOC        
      DO  146  I = 1,IROWS        
      DZ(J1) = DZ(J1) + BUF(KMAT)        
      J1 = J1 + 1        
      KMAT = KMAT + 14        
  146 CONTINUE        
C        
  150 RETURN        
C        
C     OUTPUT PIVOT-ROWS-PARTITION        
C        
  155 IF (ICALL .LE. 0) GO TO 161        
      IF (.NOT. LAST) GO TO 160        
      ILAST = 1        
  160 CALL EMGOUT (Z(IBLOC),Z(IBLOC),(NBLOC-IBLOC+1)/PRECIS,ILAST,      
     1             DICT,FILTYP,PRECIS)        
  161 ILAST = 0        
      ICALL = 0        
      RETURN        
      END        
