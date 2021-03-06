      SUBROUTINE DLAMG(INPUT,MATOUT,SKJ)        
C        
C     DRIVER FOR THE DOUBLET LATTICE METHOD        
C     COMPUTATIONS ARE FOR THE AJJL MATRIX        
C        
      INTEGER         ECORE,SYSBUF,IZ(1),SKJ        
      DIMENSION       NAME(2),A(2)        
      COMPLEX         DT(1)        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK,TSKJ(7),ISK,NSK  
      COMMON /DLCOM / NP,NSTRIP,NTP,F,NJJ,NEXT,LENGTH,        
     1                INC,INB,IYS,IZS,IEE,ISG,ICG,        
     2                IXIC,IDELX,IXLAM,IDT,ECORE        
CZZ   COMMON /ZZDAMG/ WORK(1)        
      COMMON /ZZZZZZ/ WORK(1)        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /BLANK / NK,NJ        
      EQUIVALENCE     (WORK(1),IZ(1),DT(1))        
      DATA    NAME  / 4HDLAM,4HG   /        
C        
      NJJ = NJ        
C        
C     READ IN NP,NSIZE,NTP,F        
C        
      CALL READ(*999,*999,INPUT,NP,4,0,N)        
C        
C     COMPUTE POINTERS AND SEE IF THERE IS ENOUGH CORE        
C        
      ECORE = KORSZ(IZ)        
      ECORE =  ECORE - 4 * SYSBUF        
      INC = 1        
      INB = INC + NP        
      IYS = INB + NP        
      IZS = IYS + NSTRIP        
      IEE = IZS + NSTRIP        
      ISG = IEE + NSTRIP        
      ICG = ISG + NSTRIP        
      IXIC = ICG + NSTRIP        
      IDELX = IXIC + NTP        
      IXLAM = IDELX + NTP        
      NREAD = IXLAM + NTP        
C     IDT IS A COMPLEX POINTER        
C     THE MATRIX PACKED OUT IS NJ LONG STARTING AT DT        
      IDT = (NREAD +2) / 2        
      NEXT = IDT*2 + 2*NJ + 1        
C        
C     FILL IN DATA        
C        
      IF(NEXT .GT. ECORE) GO TO 998        
      NREAD = NREAD -1        
      CALL READ(*999,*999,INPUT,WORK,NREAD,1,N)        
C        
C     CHECK FOR ENOUGH SCRATCH STORAGE        
C        
      N = INC + NP -1        
      LENGTH = 1        
C        
C     PUT OUT SKJ        
C        
      ITI = 1        
      ITO = 3        
      II = ISK        
      NSK = NSK + 2        
      NN = NSK        
      K = 0        
      KS = 0        
      NBXR=IZ(INC+K)        
      DO 5 I=1,NTP        
      A(1) = 2.0 * WORK(IEE+KS) * WORK(IDELX+I-1)        
      A(2) = (WORK(IEE+KS) * WORK(IDELX+I-1)**2)/ 2.0        
      CALL PACK( A,SKJ,TSKJ)        
      II = II +2        
      IF(I.EQ.NTP) GO TO 5        
      NN = NN +2        
      IF(I.EQ.IZ(INB+K)) K = K+1        
      IF(I.EQ.NBXR) GO TO 4        
      GO TO 5        
    4 KS = KS +1        
      NBXR = NBXR + IZ(INC+K)        
    5 CONTINUE        
      ISK = II        
      NSK = NN        
      ITI = 3        
      ITO = 3        
      II = 1        
      NN = NJ        
      CALL GEND(WORK(INC),WORK(INB),WORK(IYS),WORK(IZS),        
     1          WORK(ISG),WORK(ICG),DT(IDT),WORK(1),MATOUT)        
      NROW = NROW + NTP        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     NOT ENOUGH CORE        
  998 CALL MESAGE(-8,0,NAME)        
C     INPUT NOT POSITIONED PROPERLY OR INCORRECTLY WRITTEN        
  999 CALL MESAGE(-7,0,NAME)        
      RETURN        
      END        
