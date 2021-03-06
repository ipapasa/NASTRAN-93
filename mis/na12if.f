      SUBROUTINE NA1 2 IF (*,A,N,B,INT)        
C        
C     VAX, IBM AND UNIVAC VERSION (CHARACTER FUNCTION PROCESSING)        
C     ===========================        
C        
      COMMON /XREADX/NOUT        
      INTEGER        A(1)        
      CHARACTER*1    BK,    PT,    TJ,   T(24), C(1), NUM(10)        
      CHARACTER*12   TEMP,  NEXT,  BLNK        
      EQUIVALENCE    (TEMP,T(1)), (NEXT,T(13)), (I,XI)        
      DATA           BK,    PT,    BLNK  / ' ', '.', '            ' /        
      DATA           NUM / '0','1','2','3','4','5','6','7','8','9'  /        
C        
C     ARRAY A, IN NA1 BCD WORDS (OR C IN CHARACTERS), IS DECODED TO        
C     AN INTEGER OR TO A F.P. NUMBER IN B.        
C     INT SHOULD BE SET TO +1 IF CALLER IS EXPECTING B TO BE AN INTEGER,        
C     OR SET TO -1 IF B IS TO BE A F.P. NUMBER.   SET INT TO ZERO IF        
C     CALLER IS NOT SURE.  IN THIS LAST CASE, INT WILL BE SET TO +1 OR
C     -1 BY NA12IF/NK12IF ACCORDING TO THE INPUT DATA TYPE.        
C     THESE ROUTINES HANDLE UP TO 12 DIGITS INPUT DATA (N .LE. 12)        
C     (NO SYSTEM ENCODE/DECODE FUNCTIONS ARE USED)        
C        
C     ENTRY POINTS   NA1 2 IF  (BCD-INTEGER/FP VERSION)        
C                    NK1 2 IF  (CHARACTER-INTEGER/FP VERSION)        
C        
C     WRITTEN BY G.CHAN/SPERRY IN AUG. 1985        
C     PARTICULARLY FOR XREAD ROUTINE, IN SUPPORT OF ITS NEW FREE-FIELD        
C     INPUT FORMAT.  THIS SUBROUTINE IS MACHINE INDEPENDENT        
C        
      IF (N .GT. 12) GO TO 150        
      CALL B2K (A,TEMP,N)        
      GO TO 20        
C        
      ENTRY NK1 2 IF (*,C,N,B,INT)        
C     ****************************        
C        
      IF (N .GT. 12) GO TO 150        
      DO 15 I=1,N        
 15   T(I)=C(I)        
C        
 20   IF (INT .GE. 1) GO TO 110        
 25   NT=1        
      K =24        
      J =N        
      NEXT=BLNK        
      DO 50 I=1,12        
      IF (I    .GT.  N) GO TO 30        
      TJ=T(J)        
      IF (TJ .EQ. BK) GO TO 50        
      IF (TJ .EQ. PT) NT=NT-2        
      T(K)=TJ        
      GO TO 40        
 30   T(K)=BK        
 40   K=K-1        
 50   J=J-1        
C        
      IF (NT.LT.-1 .OR. INT*NT.LT.0) GO TO 170        
      IF (INT .EQ. 0) INT=NT        
      IF (INT) 60,170,80        
 60   READ (NEXT,70) B        
 70   FORMAT (F12.0)        
      RETURN        
 80   READ (NEXT,90) I        
 90   FORMAT (I12)        
 100  B=XI        
      RETURN        
C        
C     QUICK WAY TO GET THE INTEGER        
C        
 110  I=0        
      J=0        
 120  J=J+1        
      IF (J .GT. N) GO TO 100        
      TJ=T(J)        
      IF (TJ .EQ. BK) GO TO 120        
      DO 130 K=1,10        
      IF (TJ .EQ. NUM(K)) GO TO 140        
 130  CONTINUE        
C     WRITE (NOUT,135) INT,(T(J),J=1,N)        
C135  FORMAT (5X,'*** NA12IF/@135   INT,N,T =',I3,I8,2X,12A1)        
      GO TO 25        
 140  I=I*10 + K-1        
      GO TO 120        
C        
 150  B=0.        
      WRITE (NOUT,160) N        
 160  FORMAT (5X,'*** N.GT.12/NA12IF',I6)        
 170  RETURN 1        
      END        
