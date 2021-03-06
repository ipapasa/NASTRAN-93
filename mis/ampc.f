      SUBROUTINE AMPC (DJH1,DJH2,DJH,AJJL,QJH,QJHO,QJHUA,SCR1,SCR2,SCR3,
     1                 SCR4,SCR5,SCR6)        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO COMPUTE (OR RETRIEVE QJH)       
C        
C     IF QJH MUST BE COMPUTED        
C        
C     1. FORM DJH FOR THIS K (IF IDJH.EQ.0)        
C        DJH = DJH1 + I*K*DJH2        
C     2. FOR EACH CONSTANT THEORY        
C        A. RETRIEVE AJJ PORTION = AJJTH        
C        B. PERFORM THEORY FOR QJH        
C           1) DOUBLET LATTICE        
C              A) DECOMPOSE AJJTH        
C              B) FIND PROPER DJH PORTION DJHTH        
C              C) FBS FOR QJHTH        
C              D) ADD TO BOTTOM OF QJHUA(CYCLE)        
C           6) COMPRESSOR BLADES  (IONCE = 1).        
C              A) COMPUTE QJHTH = (AJJ)*DJH.        
C              B) QJHUA = QJHTH SINCE ONLY ONE BLADE AND GROUP (NGP = 1)
C           7) SWEPT TURBOPROPS   (IONCE = 1).        
C              A) COMPUTE QJHTH = (AJJ)*DJH.        
C              B) QJHUA = QJHTH SINCE ONLY ONE BLADE AND GROUP (NGP = 1)
C        
      INTEGER         DJH1,DJH2,DJH,AJJL,QJH,QJHO,QJHUA,AJJCOL,QHHCOL,  
     1                SYSBUF,FILE,NAME(2),IBLOCK(11),MCB(7),SCR1,SCR2,  
     2                SCR3,SCR4,SCR5,SCR6,QJHTH        
      REAL            BLOCK(11)        
      COMMON /AMPCOM/ NCOLJ,NSUB,XM,XK,AJJCOL,QHHCOL,NGP,NGPD(2,30),    
     1                MCBQHH(7),MCBQJH(7),NOH,IDJH        
      COMMON /SYSTEM/ SYSBUF,NOUT,SKP(52),IPREC        
CZZ   COMMON /ZZAMPC/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /UNPAKX/ ITC,II,JJ,INCR        
      COMMON /PACKX / ITC1,ITC2,II1,JJ1,INCR1        
      COMMON /CDCMPX/ DUM32(32),IB        
      EQUIVALENCE     (IBLOCK(1),BLOCK(1))        
      DATA    NAME  / 4HAMPC,4H    /        
      DATA    IBLOCK(1),IBLOCK(7),BLOCK(2),BLOCK(3),BLOCK(8) /        
     1                3,        3,     1.0,      0.,      0. /        
C        
C     INITIALIZE        
C        
      IBUF1 = KORSZ(IZ) - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      ITC   = MCBQHH(5)        
      INCR  = 1        
      ITC1  = ITC        
      ITC2  = ITC1        
      INCR1 = INCR        
      II1   = 1        
C        
C     IS QJH ON SAVE FILE        
C        
      IF (QHHCOL .EQ. 0) GO TO 100        
C        
C     COPY QJH FROM OLD FILE TO QJH        
C        
      IF (MCBQJH(1) .LE. 0) GO TO 10        
      CALL GOPEN (QJHO,IZ(IBUF1),0)        
      CALL GOPEN (QJH, IZ(IBUF2),3)        
      K = QHHCOL - 1        
      IF (K .EQ. 0) GO TO 20        
      FILE = QJHO        
      DO 30 I = 1,K        
      CALL FWDREC (*910,QJHO)        
   30 CONTINUE        
   20 CONTINUE        
      CALL CYCT2B (QJHO,QJH,NOH,IZ,MCBQJH)        
      CALL CLOSE (QJHO,1)        
      CALL CLOSE (QJH,3)        
   10 CONTINUE        
      RETURN        
C        
C     COMPUTE QJH        
C        
  100 CONTINUE        
C        
C     HAS DJH ALREADY BEEN COMPUTED        
C        
      IF (IDJH .NE. 0) GO TO 110        
      BLOCK(9) = XK        
      CALL SSG2C (DJH1,DJH2,DJH,1,BLOCK)        
C        
C     POSITION AJJL        
C        
  110 CALL GOPEN (AJJL,IZ(IBUF1),0)        
      K = AJJCOL - 1        
      IF (K .EQ. 0) GO TO 120        
      FILE = AJJL        
      DO 130 I = 1,K        
      CALL FWDREC (*910,AJJL)        
  130 CONTINUE        
  120 CONTINUE        
      CALL CLOSE (AJJL,2)        
C        
C     SET UP TO LOOP ON CONSTANT THEORY        
C        
      NGPS = 1        
      NTH  = NGPD(1,NGPS)        
      NCOLTH = 0        
  135 NCLOLD = NCOLTH + 1        
  140 IF (NGPS .GT. NGP) GO TO 150        
      IF (NGPD(1,NGPS) .NE. NTH) GO TO 150        
      NCOLTH = NCOLTH + NGPD(2,NGPS)        
      NGPS   = NGPS + 1        
      GO TO 140        
C        
C     BRANCH ON THEORY        
C        
  150 CONTINUE        
      IONCE = 0        
      IF (NCLOLD.EQ.1 .AND. NGPS.GT.NGP) IONCE = 1        
C        
C     COPY AJJL TO SCR1        
C        
      CALL GOPEN (AJJL,IZ(IBUF1),2)        
      CALL GOPEN (SCR1,IZ(IBUF2),1)        
      MCB(1) = AJJL        
      CALL RDTRL (MCB)        
      MCB(1) = SCR1        
      MCB(2) = 0        
      MCB(3) = NCOLTH        
      MCB(6) = 0        
      MCB(7) = 0        
      II     = NC LOLD        
      JJ     = NCOLTH        
      II1    = 1        
      JJ1    = NCOLTH - NC LOLD + 1        
      ITC    = MCB(5)        
      ITC1   = ITC        
      ITC2   = ITC        
      INCR   = 1        
      INCR1  = 1        
      CALL AMPC1 (AJJL,SCR1,NCOLTH,IZ,MCB)        
      CALL CLOSE (AJJL,2)        
      CALL CLOSE (SCR1,1)        
      CALL WRTTRL (MCB)        
      GO TO (1000,2000,3000,4000,5000,6000,7000), NTH        
C        
C     DOUBLET LATTICE WITH SLENDER BODIES        
C        
 1000 CONTINUE        
 2000 CONTINUE        
C        
C     TRANSPOSE MATRIX        
C        
      CALL TRANP1 (SCR1,SCR4,4,SCR2,SCR3,SCR5,SCR6,0,0,0,0)        
C        
C     DECOMPOSE MATRIX        
C        
      IB = 0        
      CALL CFACTR (SCR4,SCR2,SCR3,SCR1,SCR5,SCR6,IOPT)        
C        
C     MACH BOX        
C     PISTON        
C        
C        
C     COMPRESSOR BLADE AND SWEPT TURBOPROP THEORIES -        
C     ONE BLADE ALLOWED, ONE GROUP, USE WHOLE AJJ AND DJH MATRICES.     
C        
 3000 CONTINUE        
 4000 CONTINUE        
 5000 CONTINUE        
 6000 CONTINUE        
 7000 CONTINUE        
C        
C     COPY PROPER ROWS OF DJH TO SCR4        
C        
      IDJHA = DJH        
      IF (IONCE .NE. 0) GO TO 1010        
      II  = NC LOLD        
      JJ  = NCOLTH        
      II1 = 1        
      JJ1 = NCOLTH-NC LOLD+1        
      MCB(1) = DJH        
      CALL RDTRL (MCB)        
      ITC  = MCB(5)        
      ITC1 = ITC        
      ITC2 = ITC        
      INCR = 1        
      INCR1  = 1        
      MCB(2) = 0        
      MCB(3) = JJ1        
      MCB(6) = 0        
      MCB(7) = 0        
      MCB(1) = SCR4        
      CALL GOPEN (DJH,IZ(IBUF1),0)        
      CALL GOPEN (SCR4,IZ(IBUF2),1)        
      CALL AMPC1 (DJH,SCR4,NOH,IZ,MCB)        
      CALL CLOSE (DJH,1)        
      CALL CLOSE (SCR4,1)        
      CALL WRTTRL (MCB)        
      IDJHA = SCR4        
 1010 CONTINUE        
      QJHTH = SCR5        
      IF (IONCE .NE. 0) QJHTH = QJHUA        
      GO TO (1001,2001,3001,4001,5001,6001,7001), NTH        
 1001 CONTINUE        
 2001 CONTINUE        
C        
C     SOLVE FOR THIS PORTION OF QJH        
C        
      CALL CFBSOR (SCR2,SCR3,IDJHA,QJHTH,IOPT)        
 1020 CONTINUE        
C        
C     COPY ACCUMULATIVELY ONTO QJHUA        
C        
      IF (IONCE .NE. 0) GO TO 8000        
      CALL AMPC2 (SCR5,QJHUA,SCR1)        
      IF (NGPS .GT. NGP) GO TO 8000        
      GO TO 135        
C        
C     COMPUTE THIS PORTION OF QJH  = AJJ*DJH        
C        
 3001 CONTINUE        
 4001 CONTINUE        
 5001 CONTINUE        
 6001 CONTINUE        
 7001 CONTINUE        
      CALL SSG2B (SCR1,IDJHA,0,QJHTH,0,IPREC,1,SCR6)        
      GO TO 1020        
C        
C     ALL GROUPS / THEORIES COMPLETE        
C        
 8000 CONTINUE        
      GO TO 10        
C        
C     ERROR MESSAGES        
C        
  901 CALL MESAGE (IP1,FILE,NAME)        
  910 IP1 = -2        
      GO TO 901        
      END        
