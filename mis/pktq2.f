      SUBROUTINE PKTQ2 (NPTS)        
C        
C     THIS ROUTINE CALCULATES PHASE II OUTPUT FOR PLA4 FOR COMBINATION  
C     ELEMENTS        
C        
C     **** PHASE II OF STRESS DATA RECOVERY *********        
C        
C     NPTS = 3 IMPLIES STRIA1 OR STRIA2  (PHASE II)        
C     NPTS = 4 IMPLIES SQUAD1 OR SQUAD2  (PHASE II)        
C        
      DIMENSION       NSIL(4),NPH1OU(1),SI(36)        
      COMMON /PLA4UV/ IVEC,Z(24)        
      COMMON /PLA4ES/ PH1OUT(300)        
      COMMON /PLA42S/ STRESS(3),TEMP,DELTA,NPOINT,I,J,NPT1,VEC(5),TEM,  
     1                Z1OVRI, Z2OVRI,DUM1(308)        
      EQUIVALENCE     (NSIL(1),PH1OUT(2)),(NPH1OU(1),PH1OUT(1)),        
     1                (SI(1),PH1OUT(9))        
C        
C     PHASE I OUTPUT FROM THE MEMBRANE IS THE FOLLOWING        
C     NOTE..BEGIN = 30*NPTS+8        
C        
C     PH1OUT(BEGIN+ 1)               ELEMENT ID        
C     PH1OUT(BEGIN+ 2 THRU BEGIN +5) 3 SILS AND DUMMY OR 4 SILS        
C     PH1OUT(BEGIN+ 6 THRU BEGIN +9) DUMMY        
C     PH1OUT(BEGIN+10 THRU BEGIN +9*NPTS+9) 3 OR 4 S SUB I 3X3 ARRAYS   
C        
C        
C     FIND SIG X, SIG Y, SIG XY, FOR MEMBRANE CONSIDERATION        
C        
      IF (NPH1OU(30*NPTS+10) .EQ. 0) RETURN        
C        
C                       I=NPTS        
C     STRESS VECTOR = (SUMMATION(S )(U ))        
C                       I=1       I   I        
C        
      DO 60 I = 1,NPTS        
C        
C     POINTER TO I-TH SIL IN PH1OUT        
C        
      NPOINT = 30*NPTS + 9 + I        
C        
C     POINTER TO DISPLACEMENT VECTOR IN VARIABLE CORE        
C        
      NPOINT = IVEC + NPH1OU(NPOINT) - 1        
C        
C     POINTER TO S SUB I 3X3        
C        
      NPT1 = 30*NPTS + 9 + 9*I        
C        
      CALL GMMATS (PH1OUT(NPT1),3,3,0, Z(NPOINT),3,1,0, VEC(1))        
C        
      DO 50 J = 1,3        
   50 STRESS(J) = STRESS(J) + VEC(J)        
C        
   60 CONTINUE        
C        
      RETURN        
      END        
