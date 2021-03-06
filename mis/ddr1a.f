      SUBROUTINE DDR1A (PD,K2DD,B2DD,MDD,VUD,PAD,FRL,FRQSET,SCR1,SCR2,  
     1                  SCR3,SCR4,ITYPE,SCR5)        
C        
C     ROUTINE TO COMPUTE PAD FROM MODAL APPROXIMATION TO SYSTEM        
C        
      INTEGER         B2DD,PD,VUD,FRL,FRQSET,SCR1,SCR2,SCR3,SCR4,SCR5,  
     1                SYSBUF,FILE,MCB(7),MCB1(7),MCB2(7),SR1,SR3,FREQ,  
     2                PAD,NAME(2)        
      DIMENSION       IBLK(60),B(2),IMCB(21),IFILE(3)        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /CONDAS/ CONSTS(5)        
CZZ   COMMON /ZZDDRA/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /ZNTPKX/ A(4),II,IEOL,IEOR        
      EQUIVALENCE     (MCB(1),IMCB(1)),(MCB2(1),IMCB(8)),        
     1                (MCB1(1),IMCB(15)),(CONSTS(2),TWOPI)        
      DATA    NAME  / 4HDDR1,4HA   /        
      DATA    FREQ  / 4HFREQ       /        
C        
C     INITIALIZE + FIND OUT WHAT EXISTS        
C        
      SR1  = SCR1        
      SR3  = SCR3        
      IBUF = KORSZ(CORE) - SYSBUF + 1        
      NOK2DD = 1        
      MCB(1) = K2DD        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) NOK2DD = -1        
      NOB2DD = 1        
      MCB(1) = B2DD        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) NOB2DD = -1        
      MCB(1) = PD        
      CALL RDTRL (MCB)        
C        
C     IS THIS FREQRES OR TRANSIENT        
C        
      IF (ITYPE .NE. FREQ) GO TO 160        
C        
C     BRING IN FRL        
C        
      FILE = FRL        
      CALL OPEN  (*280,FRL,CORE(IBUF),0)        
      CALL FREAD (FRL,0,-2,0)        
      CALL READ  (*300,*20,FRL,CORE(1),IBUF,0,NFREQ)        
      GO TO 310        
   20 CALL CLOSE (FRL,1)        
      NLOAD = MCB(2)/NFREQ        
      IT = 3        
C        
C     BUILD  ACCELERATION AND VELOCITY IF NEEDED        
C        
   30 CALL GOPEN (VUD,CORE(IBUF),0)        
C        
C     PUT  ACCELERATION VECTOR ON SCR1        
C        
      NZ = IBUF - SYSBUF        
      CALL GOPEN (SCR1,CORE(NZ),1)        
      CALL MAKMCB (MCB1,SCR1,MCB(3),2,IT)        
      IF (NOB2DD .LT. 0) GO TO 40        
C        
C     PUT VELOCITY VECTOR ON SCR2        
C        
      NZ = NZ - SYSBUF        
      CALL GOPEN (SCR2,CORE(NZ),1)        
      CALL MAKMCB (MCB2,SCR2,MCB(3),2,IT)        
   40 IF (ITYPE .NE. FREQ) GO TO 170        
C        
C     COMPUTE  VECTORS        
C        
      DO 45 I = 1,NFREQ        
   45 CORE(I) = CORE(I)*TWOPI        
      DO 100 J = 1,NLOAD        
      DO 90  I = 1,NFREQ        
      W  = CORE(I)        
      W2 = -W*W        
      CALL BLDPK (3,3,SCR1,IBLK(1),1)        
      IF (NOB2DD .LT. 0) GO TO 50        
      CALL BLDPK (3,3,SCR2,IBLK(21),1)        
   50 CALL INTPK (*80,VUD,0,3,0)        
   60 IF (IEOL)  80,70,80        
   70 CALL  ZNTPKI        
      B(1) = W2*A(1)        
      B(2) = W2*A(2)        
      CALL BLDPKI (B(1),II,SCR1,IBLK(1))        
      IF (NOB2DD .LT. 0) GO TO 60        
      B(1)  =-W*A(2)        
      B(2)  = W*A(1)        
      CALL BLDPKI (B(1),II,SCR2,IBLK(21))        
      GO TO 60        
C        
C     END OF COLUMN        
C        
   80 CALL BLDPKN (SCR1,IBLK(1),MCB1(1))        
      IF (NOB2DD .LT. 0) GO TO 90        
      CALL BLDPKN (SCR2,IBLK(21),MCB2(1))        
   90 CONTINUE        
  100 CONTINUE        
  110 CALL CLOSE  (SCR1,1)        
      CALL CLOSE  (VUD,1)        
      CALL WRTTRL (MCB1(1))        
      IF (NOB2DD .LT. 0) GO TO 120        
      CALL CLOSE  (SCR2,1)        
      CALL WRTTRL (MCB2(1))        
C        
C     MULTIPLY OUT        
C        
  120 IF (NOB2DD.LT.0 .AND. NOK2DD.LT.0) SR3 = PAD        
      CALL SSG2B (MDD,SCR1,PD,SR3,0,1,0,SCR4)        
      IF (NOK2DD .LT. 0) GO TO 130        
C        
C     MULTIPLY  IN K2DD        
C        
      IF (NOB2DD .LT. 0) SR1 = PAD        
      CALL SSG2B (K2DD,SCR5,SR3,SR1,0,1,0,SCR4)        
      GO TO 140        
C        
C     NO  K2DD        
C        
  130 SR1 = SR3        
C        
C     MULTIPLY IN B2DD        
C        
  140 IF (NOB2DD .LT. 0) GO TO 150        
      CALL SSG2B (B2DD,SCR2,SR1,PAD,0,1,0,SCR4)        
  150 RETURN        
C        
C     TRANSIENT ANALYSIS        
C        
  160 NLOAD = MCB(2)        
C        
C     PUT DISPLACEMENT ON SCR5,VELOCITY ON SCR2,ACCELERATION SCR1       
C        
      IT = 1        
C        
C     PUT HEADERS ON FILES        
C        
      GO TO 30        
C        
C     PUT DISPLACEMENT ON SCR5        
C        
  170 FILE = SCR5        
      NZ   = NZ - SYSBUF        
      CALL GOPEN (SCR5,CORE(NZ),1)        
      MCB(1) = SCR5        
      MCB(2) = 0        
      MCB(4) = 2        
      MCB(5) = 1        
      IFILE(1) = SCR5        
      IFILE(2) = SCR2        
      IFILE(3) = SCR1        
      MCB(6) = 0        
      DO 270 KK = 1,NLOAD        
      CALL BLDPK (1,1,SCR5,IBLK,1)        
      IF (NOB2DD .LT. 0) GO TO 190        
      CALL BLDPK (1,1,SCR2,IBLK(21),1)        
  190 CALL BLDPK (1,1,SCR1,IBLK(41),1)        
      DO 260 I = 1,3        
      L =  I*7 - 6        
      K = 20*I - 19        
      FILE = IFILE(I)        
C        
C     FWDREC OVER  UNNEEDED STUFF        
C        
      IF (I.EQ.2 .AND. NOB2DD.LT.0) GO TO 250        
      CALL INTPK (*240,VUD,0,1,0)        
  220 IF (IEOL) 240,230,240        
  230 CALL ZNTPKI        
      CALL BLDPKI (A,II,FILE,IBLK(K))        
      GO TO 220        
C        
C     END COLUMN        
C        
  240 CALL BLDPKN (FILE,IBLK(K),IMCB(L))        
      GO TO 260        
  250 CALL SKPREC (VUD,1)        
  260 CONTINUE        
  270 CONTINUE        
C        
C     FINISH OFF        
C        
      CALL CLOSE  (SCR5,1)        
      CALL WRTTRL (MCB)        
      GO TO 110        
C        
C     ERROR MESAGES        
C        
  280 IP1 = -1        
  290 CALL MESAGE (IP1,FILE,NAME)        
  300 IP1 = -2        
      GO TO 290        
  310 IP1 = -8        
      GO TO 290        
      END        
