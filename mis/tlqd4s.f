      SUBROUTINE TLQD4S        
C        
C     ELEMENT THERMAL LOAD GENERATOR FOR 4-NODE ISOPARAMETRIC        
C     QUADRILATERAL SHELL ELEMENT (QUAD4)        
C     (SINGLE PRECISION VERSION)        
C        
C     COMPLETELY RESTRUCTURED FOR COMPOSITES WITH THE FOLLOWING        
C     LIMITATION -        
C     1. FOR DIFFERENT GRID POINT TEMPERATURES AN AVERAGE        
C        VALUE IS TAKEN.                       HEMANT  2/24/86        
C        
C        
C                 EST LISTING        
C     ---------------------------------------------------------        
C      1          EID        
C      2 THRU 5   SILS, GRIDS 1 THRU 4        
C      6 THRU 9   T (MEMBRANE), GRIDS 1 THRU 4        
C     10          THETA (MATERIAL)        
C     11          TYPE FLAG FOR WORD 10        
C     12          ZOFF  (OFFSET)        
C     13          MATERIAL ID FOR MEMBRANE        
C     14          T (MEMBRANE)        
C     15          MATERIAL ID FOR BENDING        
C     16          I FACTOR (BENDING)        
C     17          MATERIAL ID FOR TRANSVERSE SHEAR        
C     18          FACTOR FOR T(S)        
C     19          NSM (NON-STRUCTURAL MASS)        
C     20 THRU 21  Z1, Z2  (STRESS FIBRE DISTANCES)        
C     22          MATERIAL ID FOR MEMBRANE-BENDING COUPLING        
C     23          THETA (MATERIAL) FROM PSHELL CARD        
C     24          TYPE FLAG FOR WORD 23        
C     25          INTEGRATION ORDER        
C     26          THETA (STRESS)        
C     27          TYPE FLAG FOR WORD 26        
C     28          ZOFF1 (OFFSET)  OVERRIDDEN BY EST(12)        
C     29 THRU 44  CID,X,Y,Z - GRIDS 1 THRU 4        
C     45          ELEMENT TEMPERATURE        
C        
C        
      LOGICAL          BADJAC,MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,       
     1                 TEMPP1,TEMPP2,PCMP,PCMP1,PCMP2,COMPOS        
      INTEGER          INTZ(1),NOUT,NEST(45),ELID,SIL(4),KSIL(4),       
     1                 KCID(4),IGPDT(4,4),FLAG,ROWFLG,NECPT(4),        
     2                 MID(4),INDEX(3,3),INDX(6,3),COMPS,NAM(2),        
     3                 PCOMP,PCOMP1,PCOMP2,SYM,SYMMEM,PID,PIDLOC        
      REAL             GPTH(4),TGRID(4,4),GPNORM(4,4),BGPDT(4,4),       
     1                 MATSET,TMPTHK(4),ECPT(4),EGPDT(4,4),        
     2                 EPNORM(4,4),BGPDM(3,4),ALPHAM(6),TSUB0,STEMP,Z   
      REAL             DGPTH(4),THK,EPS1,XI,ETA,DETJ,HZTA,PSITRN(9),    
     1                 JACOB(9),PHI(9),MOMINR,COEFF,REALI,PI,TWOPI,     
     2                 RADDEG,DEGRAD,SHP(4),DSHP(8),TMPSHP(4),        
     3                 DSHPTP(8),GT(9),G(6,6),GI(36),U(9),TRANS(36),    
     4                 PTINT(2),GGE(9),GGU(9),TBM(9),TEB(9),TEM(9),     
     5                 TUB(9),TUM(9),TEU(9),TBG(9),UGPDM(3,4),CENTE(3), 
     6                 CENT(3),X31,Y31,X42,Y42,AA,BB,CC,EXI,EXJ,XM,YM,  
     7                 THETAM,BMATRX(144),XYBMAT(96),ALPHA(6),ALFAM(3), 
     8                 ALFAB(3),TALFAM(3),TALFAB(3),ALPHAD(6),PT(24),   
     9                 PTG(24),TBAR,TTBAR,TGRAD,THRMOM(3),G2I(9),G2(9), 
     O                 GTEMPS(6),EPSUBT(6),GEPSBT(6),DETU,DETG2,DETERM  
      REAL             ABBD(6,6),STIFF(36),GPROP(25),GLAY(9),GLAYT(9),  
     1                 GBAR(9),GALPHA(3),ALPHAL(3),ALPHAE(3),MINTR,     
     2                 TLAM,THETA,THETAE,TRANSL(9),TSUBO,TMEAN,TEMPEL,  
     3                 DELTA,DELTAT,ZK,ZK1,ZREF,ZSUBI,C,C2,S,S2,        
     4                 FTHERM(6),EPSLNT(6),OFFSET,CONST,UEV,ANGLEI,     
     5                 EDGEL,EDGSHR,UNV        
      COMMON /CONDAS/  PI,TWOPI,RADDEG,DEGRAD        
      COMMON /TRIMEX/  EST(45)        
      COMMON /SYSTEM/  BUFFER(100)        
      COMMON /MATIN /  MATID,INFLAG,ELTEMP        
      COMMON /MATOUT/  RMTOUT(25)        
      COMMON /SGTMPD/  STEMP(8)        
CZZ   COMMON /ZZSSB1/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /BLANK /  NROWSP,IPARAM,COMPS        
      COMMON /COMPST/  IPCMP,NPCMP,IPCMP1,NPCMP1,IPCMP2,NPCMP2        
      COMMON /Q4DT  /  DETJ,HZTA,PSITRN,NNODE,BADJAC,N1        
      COMMON /TERMS /  MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      COMMON /Q4COMS/  ANGLEI(4),EDGSHR(3,4),EDGEL(4),UNV(3,4),        
     1                 UEV(3,4),ROWFLG,IORDER(4)        
C        
      EQUIVALENCE     (Z(1)     ,INTZ(1)), (IGPDT(1,1),BGPDT(1,1))      
      EQUIVALENCE     (EST(1)   ,NEST(1)), (BGPDT(1,1),EST(29)   )      
      EQUIVALENCE     (ELTH     ,EST(14)), (GPTH(1)   ,EST(6)    )      
      EQUIVALENCE     (SIL(1)   ,NEST(2)), (MATSET    ,RMTOUT(25))      
      EQUIVALENCE     (ZOFF     ,EST(12)), (ZOFF1     ,EST(28)   )      
      EQUIVALENCE     (NECPT(1) ,ECPT(1)), (BUFFER(1) ,SYSBUF    )      
      EQUIVALENCE     (BUFFER(2),NOUT   ), (BUFFER(3) ,NOGO      )      
      EQUIVALENCE     (STEMP(7) ,FLAG   ), (ALFAB(1)  ,ALPHA(4)  )      
      EQUIVALENCE     (ALFAM(1) ,ALPHA(1))        
C        
      DATA EPS1     / 1.0E-7 /        
      DATA PCOMP    / 0 /        
      DATA PCOMP1   / 1 /        
      DATA PCOMP2   / 2 /        
      DATA SYM      / 1 /        
      DATA MEM      / 2 /        
      DATA SYMMEM   / 3 /        
      DATA CONST    / 0.57735026918962 /        
      DATA NAM      / 4HTLQD,4H4S      /        
C        
C-----ZERO THE VARIOUS ALPHA ARRAYS        
C        
      DO 10 I =1,6        
      ALPHAM(I) = 0.0        
      ALPHA(I)  = 0.0        
      ALPHAD(I) = 0.0        
   10 CONTINUE        
      DO 20 I =1,3        
      TALFAM(I) = 0.0        
      TALFAB(I) = 0.0        
   20 CONTINUE        
C        
      ELID=NEST(1)        
      LTYPFL=1        
      OFFSET=ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET=ZOFF1        
C        
C     TEST FOR COMPOSITE ELEMENT        
C        
      COMPOS = .FALSE.        
C        
      PID = NEST(13) - 100000000        
      COMPOS = COMPS.EQ.-1 .AND. PID.GT.0        
C        
C-----CHECK FOR THE TYPE OF TEMPERATURE DATA        
C     NOTES-  1- TYPE TEMPP1 ALSO INCLUDES TYPE TEMPP3        
C             2- IF NO TEMPPI CARDS, GRID POINT TEMPERATURES        
C                ONLY ARE PRESENT        
C        
      TEMPP1 = FLAG .EQ. 13        
      TEMPP2 = FLAG .EQ. 2        
C        
      N1=4        
      NNODE=4        
      NDOF=NNODE*6        
      ND2=NDOF*2        
      ND3=NDOF*3        
      ND4=NDOF*4        
      ND5=NDOF*5        
C        
C     FILL IN ARRAY GGU WITH THE COORDINATES OF GRID POINTS        
C     1, 2 AND 4. THIS ARRAY WILL BE USED LATER TO DEFINE        
C     THE USER COORDINATE SYSTEM WHILE CALCULATING        
C     TRANSFORMATIONS INVOLVING THIS COORDINATE SYSTEM.        
C        
      DO 30 I=1,3        
      II=(I-1)*3        
      IJ=I        
      IF (IJ .EQ. 3) IJ=4        
      DO 30 J=1,3        
      JJ=J+1        
   30 GGU(II+J)=BGPDT(JJ,IJ)        
      CALL BETRNS (TUB,GGU,0,ELID)        
C        
C     STORE INCOMING BGPDT FOR ELEMENT C.S. CALCULATION        
C        
      DO 40 I=1,3        
      I1=I+1        
      DO 40 J=1,4        
   40 BGPDM(I,J)=BGPDT(I1,J)        
C        
C     TRANSFORM BGPDM FROM BASIC TO USER C.S.        
C        
      DO 50 I=1,3        
      IP=(I-1)*3        
      DO 50 J=1,4        
      UGPDM(I,J)=0.0        
      DO 50 K=1,3        
      KK=IP+K        
   50 UGPDM(I,J)=UGPDM(I,J)+TUB(KK)*((BGPDM(K,J))-GGU(K))        
C        
C        
C     THE ORIGIN OF THE ELEMENT C.S. IS IN THE MIDDLE OF THE ELEMENT    
C        
      DO 60 J=1,3        
      CENT(J)=0.0        
      DO 60 I=1,4        
   60 CENT(J)=CENT(J)+UGPDM(J,I)/NNODE        
C        
C     STORE THE CORNER NODE DIFF. IN THE USER C.S.        
C        
      X31=UGPDM(1,3)-UGPDM(1,1)        
      Y31=UGPDM(2,3)-UGPDM(2,1)        
      X42=UGPDM(1,4)-UGPDM(1,2)        
      Y42=UGPDM(2,4)-UGPDM(2,2)        
      AA=SQRT(X31*X31+Y31*Y31)        
      BB=SQRT(X42*X42+Y42*Y42)        
C        
C     NORMALIZE XIJ'S        
C        
      X31=X31/AA        
      Y31=Y31/AA        
      X42=X42/BB        
      Y42=Y42/BB        
      EXI=X31-X42        
      EXJ=Y31-Y42        
C        
C     STORE GGE ARRAY, THE OFFSET BETWEEN ELEMENT C.S. AND USER C.S.    
C        
      GGE(1)=CENT(1)        
      GGE(2)=CENT(2)        
      GGE(3)=CENT(3)        
C        
      GGE(4)=GGE(1)+EXI        
      GGE(5)=GGE(2)+EXJ        
      GGE(6)=GGE(3)        
C        
      GGE(7)=GGE(1)-EXJ        
      GGE(8)=GGE(2)+EXI        
      GGE(9)=GGE(3)        
C        
C        
C     THE ARRAY IORDER STORES THE ELEMENT NODE ID IN        
C     INCREASING SIL ORDER.        
C        
C     IORDER(1) = NODE WITH LOWEST  SIL NUMBER        
C     IORDER(4) = NODE WITH HIGHEST SIL NUMBER        
C        
C     ELEMENT NODE NUMBER IS THE INTEGER FROM THE NODE        
C     LIST  G1,G2,G3,G4 .  THAT IS, THE 'I' PART        
C     OF THE 'GI' AS THEY ARE LISTED ON THE CONNECTIVITY        
C     BULK DATA CARD DESCRIPTION.        
C        
C        
      DO 70 I=1,4        
      IORDER(I)=0        
      KSIL(I)=SIL(I)        
   70 CONTINUE        
C        
      DO 90 I=1,4        
      ITEMP=1        
      ISIL=KSIL(1)        
      DO 80 J=2,4        
      IF (ISIL .LE. KSIL(J)) GO TO 80        
      ITEMP=J        
      ISIL=KSIL(J)        
   80 CONTINUE        
      IORDER(I)=ITEMP        
      KSIL(ITEMP)=99999999        
   90 CONTINUE        
C        
C     ADJUST EST DATA        
C        
C        
C     USE THE POINTERS IN IORDER TO COMPLETELY REORDER THE        
C     GEOMETRY DATA INTO INCREASING SIL ORDER.        
C     DON'T WORRY!! IORDER ALSO KEEPS TRACK OF WHICH SHAPE        
C     FUNCTIONS GO WITH WHICH GEOMETRIC PARAMETERS!        
C        
C        
      DO 110 I=1,4        
      KSIL(I)=SIL(I)        
      TMPTHK(I)=GPTH(I)        
      KCID(I)=IGPDT(1,I)        
      DO 100 J=2,4        
      TGRID(J,I)=BGPDT(J,I)        
  100 CONTINUE        
  110 CONTINUE        
      DO 130 I=1,4        
      IPOINT=IORDER(I)        
      SIL(I)=KSIL(IPOINT)        
      GPTH(I)=TMPTHK(IPOINT)        
      IGPDT(1,I)=KCID(IPOINT)        
      DO 120 J=2,4        
      BGPDT(J,I)=TGRID(J,IPOINT)        
  120 CONTINUE        
  130 CONTINUE        
C        
C-----SORT THE GRID POINT TEMPERATURES (IN STEMP(1-4))        
C     IF PRESENT AND MAKE REAL          THE OTHER        
C     KINDS OF TEMPERATURE DATA IF TEMPPI CARDS PRESENT        
C        
      IF (TEMPP1 .OR. TEMPP2) GO TO 150        
C        
      TEMPEL = 0.0        
      DO 140 I =1,4        
      IPNT = IORDER(I)        
      GTEMPS(I) = STEMP(IPNT)        
      TEMPEL = TEMPEL + 0.25 * GTEMPS(I)        
  140 CONTINUE        
      GO TO 170        
C        
  150 IF (TEMPP2) GO TO 160        
C        
      TBAR  = STEMP(1)        
      TGRAD = STEMP(2)        
      GO TO 170        
C        
  160 TBAR = STEMP(1)        
      THRMOM(1) = STEMP(2)        
      THRMOM(2) = STEMP(3)        
      THRMOM(3) = STEMP(4)        
  170 CONTINUE        
C        
C     COMPUTE NODE NORMALS        
C        
      CALL Q4NRMS (BGPDT,GPNORM,IORDER,IFLAG)        
      IF (IFLAG .EQ. 0) GO TO 180        
      J = -230        
      GO TO 1580        
C        
C     DETERMINE NODAL THICKNESSES        
C        
  180 DO 200 I=1,NNODE        
      IF (GPTH(I) .EQ. 0.0) GPTH(I)=ELTH        
      IF (GPTH(I) .GT. 0.0) GO TO 190        
      WRITE (NOUT,1700) ELID        
      NOGO=1        
      GO TO 1600        
  190 DGPTH(I)=GPTH(I)        
  200 CONTINUE        
C        
      MOMINR=0.0        
      IF (NEST(15) .NE. 0) MOMINR=EST(16)        
C        
C        
C     THE COORDINATES OF THE ELEMENT GRID POINTS HAVE TO BE        
C     TRANSFORMED FROM THE BASIC C.S. TO THE ELEMENT C.S.        
C        
C        
      CALL BETRNS (TEU,GGE,0,ELID)        
      CALL GMMATS (TEU,3,3,0,TUB,3,3,0,TEB)        
      CALL GMMATS (TUB,3,3,1,CENT,3,1,0,CENTE)        
C        
      IP = -3        
      DO 210 II=2,4        
      IP=IP+3        
      DO 210 J=1,NNODE        
      EPNORM(II,J)=0.0        
      EGPDT(II,J)=0.0        
      DO 210 K=1,3        
      KK=IP+K        
      K1=K+1        
      CC=(BGPDT(K1,J))-GGU(K)-CENTE(K)        
      EPNORM(II,J)=EPNORM(II,J)+TEB(KK)*GPNORM(K1,J)        
  210 EGPDT( II,J)=EGPDT(II,J)+(TEB(KK)*CC)        
C        
C     BEGIN INITIALIZING MATERIAL VARIABLES        
C        
C     SET INFLAG = 12 SO THAT SUBROUTINE MAT WILL SEARCH FOR -        
C     ISOTROPIC MATERIAL PROPERTIES AMONG THE MAT1 CARDS,        
C     ORTHOTROPIC MATERIAL PROPERTIES AMONG THE MAT8 CARDS, AND        
C     ANISOTROPIC MATERIAL PROPERTIES AMONG THE MAT2 CARDS.        
C        
      INFLAG=12        
      ELTEMP= EST(45)        
      MID(1)=NEST(13)        
      MID(2)=NEST(15)        
      MID(3)=0        
      MID(4)=NEST(22)        
      MEMBRN=MID(1).GT.0        
      BENDNG=MID(2).GT.0 .AND. MOMINR.GT.0.0        
      SHRFLX=MID(3).GT.0        
      MBCOUP=MID(4).GT.0        
      NORPTH=.FALSE.        
C        
C     SET THE INTEGRATION POINTS        
C        
      PTINT(1) = -CONST        
      PTINT(2) =  CONST        
C        
C     IN PLANE SHEAR REDUCTION        
C        
      XI =0.0        
      ETA=0.0        
      KPT=1        
      KPT1=ND2        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 300 I=1,4        
      TMPSHP(I  )=SHP(I)        
      DSHPTP(I  )=DSHP(I)        
  300 DSHPTP(I+4)=DSHP(I+4)        
      DO 310 I=1,4        
      KK=IORDER(I)        
      SHP (I  )=TMPSHP(KK)        
      DSHP(I  )=DSHPTP(KK)        
  310 DSHP(I+4)=DSHPTP(KK+4)        
C        
      DO 320 IZTA=1,2        
      ZTA =PTINT(IZTA)        
      HZTA=ZTA/2.0        
      CALL JACOBS (ELID,SHP,DSHP,DGPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1600        
C        
      CALL GMMATS (PSITRN,3,3,0,JACOB,3,3,1,PHI)        
C        
C     CALL Q4BMGS TO GET B MATRIX        
C     SET THE ROW FLAG TO 2. IT WILL SAVE THE 3RD ROW OF B AT        
C     THE TWO INTEGRATION POINTS.        
C        
      ROWFLG = 2        
      CALL Q4BMGS (DSHP,DGPTH,EGPDT,EPNORM,PHI,XYBMAT(KPT))        
  320 KPT=KPT+KPT1        
C        
C     SET THE ARRAY OF LENGTH 4 TO BE USED IN CALLING TRANSS.        
C     NOTE THAT THE FIRST WORD IS THE COORDINATE SYSTEM ID WHICH        
C     WILL BE SET IN POSITION LATER.        
C        
      DO 330 IEC=2,4        
  330 ECPT(IEC)=0.0        
C        
C     FETCH MATERIAL PROPERTIES        
C        
C     EACH MATERIAL PROPERTY MATRIX G HAS TO BE TRANSFORMED FROM        
C     THE MATERIAL COORDINATE SYSTEM TO THE ELEMENT COORDINATE        
C     SYSTEM. THESE STEPS ARE TO BE FOLLOWED -        
C        
C     1- IF MCSID HAS BEEN SPECIFIED, SUBROUTINE TRANSS IS CALLED       
C        TO CALCULATE TBM MATRIX (MATERIAL TO BASIC TRANSFORMATION).    
C        THIS WILL BE FOLLOWED BY A CALL TO SUBROUTINE BETRNS        
C        TO CALCULATE TEB MATRIX (BASIC TO ELEMENT TRANSFORMATION).     
C        TBM IS THEN PREMULTIPLIED BY TEB TO OBTAIN TEM MATRIX.        
C        THEN USING THE PROJECTION OF X-AXIS, AN ANGLE IS CALCULATED    
C        UPON WHICH STEP 2 IS TAKEN.        
C        
C     2- IF THETAM HAS BEEN SPECIFIED, SUBROUTINE ANGTRS IS CALLED      
C        TO CALCULATE TEM MATRIX (MATERIAL TO ELEMENT TRANSFORMATION).  
C        
C                        T        
C     3-          G  =  U   G   U        
C                  E         M        
C        
C        
      IF (NEST(11) .EQ. 0) GO TO 390        
      MCSID=NEST(10)        
C        
C     CALCULATE TEM USING MCSID        
C        
  340 IF (MCSID .GT. 0) GO TO 360        
      DO 350 I=1,9        
  350 TEM(I)=TEB(I)        
      GO TO 370        
  360 NECPT(1)=MCSID        
      CALL TRANSS (ECPT,TBM)        
C        
C     MULTIPLY TEB AND TBM        
C        
      CALL GMMATS (TEB,3,3,0,TBM,3,3,0,TEM)        
C        
C     CALCULATE THETAM FROM THE PROJECTION OF THE X-AXIS OF THE        
C     MATERIAL C.S. ON TO THE XY PLANE OF THE ELEMENT C.S.        
C        
  370 IMT=-1        
      XM=TEM(1)        
      YM=TEM(4)        
      IF (ABS(XM) .LE. EPS1) IMT=IMT+1        
      IF (ABS(YM) .LE. EPS1) IMT=IMT+2        
      IF (IMT .LT. 2) GO TO 380        
      NEST(2) = MCSID        
      J = -231        
      GO TO 1580        
  380 THETAM= ATAN2(YM,XM)        
      GO TO 400        
C        
C     CALCULATE TEM USING THETAM        
C        
  390 THETAM = (EST(10))*DEGRAD        
      IF (THETAM .EQ. 0.0) GO TO 410        
  400 CALL ANGTRS (THETAM,1,TUM)        
      CALL GMMATS (TEU,3,3,0,TUM,3,3,0,TEM)        
      GO TO 430        
C        
C     DEFAULT IS CHOSEN, LOOK FOR VALUES OF MCSID AND/OR THETAM        
C     ON THE PSHELL CARD.        
C        
  410 IF (NEST(24) .EQ. 0) GO TO 420        
      MCSID=NEST(23)        
      GO TO 340        
C        
  420 THETAM = (EST(23))*DEGRAD        
      GO TO 400        
C        
  430 CONTINUE        
C        
C     BEGIN THE LOOP TO FETCH PROPERTIES FOR EACH MATERIAL ID        
C        
      M=0        
  500 M=M+1        
      IF (M .GT. 4) GO TO 690        
      MATID=MID(M)        
      IF (MATID .EQ. 0) GO TO 500        
C        
      IF (M-1) 530,520,510        
  510 IF (MATID.EQ.MID(M-1)) GO TO 530        
  520 CALL MAT (ELID)        
  530 CONTINUE        
C        
      TSUB0 = RMTOUT(11)        
      IF (MATSET .EQ. 8.0) TSUB0 = RMTOUT(10)        
C        
      COEFF=1.0        
      LPOINT=(M-1)*9+1        
C        
      CALL Q4GMGS (M,COEFF,GI(LPOINT))        
C        
      IF (THETAM .EQ. 0.0) GO TO 550        
C        
      U(1)=TEM(1)*TEM(1)        
      U(2)=TEM(4)*TEM(4)        
      U(3)=TEM(1)*TEM(4)        
      U(4)=TEM(2)*TEM(2)        
      U(5)=TEM(5)*TEM(5)        
      U(6)=TEM(2)*TEM(5)        
      U(7)=TEM(1)*TEM(2)*2.0        
      U(8)=TEM(4)*TEM(5)*2.0        
      U(9)=TEM(1)*TEM(5)+TEM(2)*TEM(4)        
      L=3        
C        
      CALL GMMATS (U(1),L,L,1,GI(LPOINT),L,L,0,GT(1))        
      CALL GMMATS (GT(1),L,L,0,U(1),L,L,0,GI(LPOINT))        
C        
  550 CONTINUE        
C        
      IF (COMPOS) GO TO 500        
C        
C-----TRANSFORM THERMAL EXPANSION COEFFICIENTS AND STORE THEM IN ALPHA  
C        
      IF (M .GT. 2) GO TO 500        
      MORB = (M-1)*3        
      IF (MATSET .EQ. 2.0) GO TO 610        
      IF (MATSET .EQ. 8.0) GO TO 630        
C        
C     MAT1        
C        
      DO 600 IMAT=1,2        
  600 ALPHAM(IMAT+MORB)=RMTOUT(8)        
      ALPHAM(3+MORB) = 0.0        
      GO TO 640        
C        
C     MAT2        
C        
  610 DO 620 IMAT=1,3        
  620 ALPHAM(IMAT+MORB)=RMTOUT(7+IMAT)        
      GO TO 640        
C        
C     MAT8        
C        
  630 ALPHAM(MORB+1)=RMTOUT(8)        
      ALPHAM(MORB+2)=RMTOUT(9)        
      ALPHAM(MORB+3)=0.0        
C        
C-----SKIP THE TRANSFORMATION OF ALPHAM IF MATSET = 1.0        
C     OR THETAM = 0.0        
C        
  640 CONTINUE        
C        
      IF (MATSET .EQ. 1.0) GO TO 650        
      IF (THETAM .NE. 0.0) GO TO 670        
C        
  650 DO 660 IG = 1,3        
      ALPHA(IG+MORB) = ALPHAM(IG+MORB)        
  660 CONTINUE        
      GO TO 500        
C        
C-----THE ALPHAS NEED TO BE PREMULTIPLIED BY U INVERSE.        
C     INCREMENT MORB BY 1 TO INDICATE WHERE TO FILL THE        
C     ARRAYS, AND PUT THE SINGLE PREC. ARRAY OF ALPHAM        
C     INTO THE DOUBLE PREC. ARRAY OF ALPHAD FOR THE CALL        
C     TO GMMATS.        
C        
  670 MORB = MORB + 1        
      DO 680 I =1,6        
      ALPHAD(I) = ALPHAM(I)        
  680 CONTINUE        
      CALL INVERS (3,U,3,BDUM,0,DETU,ISNGU,INDEX)        
      CALL GMMATS (U,3,3,0,ALPHAD(MORB),3,1,0,ALPHA(MORB))        
      GO TO 500        
C        
  690 IF (.NOT.COMPOS) GO TO  1070        
C        
C****        
C      IF LAMINATED COMPOSITE ELEMENT, DETERMINE THE THERMAL        
C      STRAIN VECTOR DUE TO THE APPLIED THERMAL LOADING.        
C      NOTE THE FOLLOWING -        
C         1. DIFFERENT GRID POINT TEMPERATURES ARE NOT SUPPORTED        
C        
C****        
C     LOCATE PID BY CARRYING OUT A SEQUENTIAL SEARCH        
C     OF THE PCOMPS DATA BLOCK, AND ALSO DETERMINE        
C     THE TYPE OF 'PCOMP' BULK DATA ENTRY.        
C****        
C        
C****        
C     POINTER DESCRIPITION        
C     --------------------        
C     IPCMP  - LOCATION OF START OF PCOMP DATA IN CORE        
C     NPCMP  - NUMBER OF WORDS OF PCOMP DATA        
C     IPCMP1 - LOCATION OF START OF PCOMP1 DATA IN CORE        
C     NPCMP1 - NUMBER OF WORDS OF PCOMP1 DATA        
C     IPCMP2 - LOCATION OF START OF PCOMP2 DATA IN CORE        
C     NPCMP2 - NUMBER OF WORDS OF PCOMP2 DATA        
C        
C     ITYPE  - TYPE OF PCOMP BULK DATA ENTRY        
C        
C        
C     LAMOPT - LAMINATION GENERATION OPTION        
C            = SYM  (SYMMETRIC)        
C            = MEM  (MEMBRANE)        
C            = SYMMEM  (SYMMETRIC-MEMBRANE)        
C        
C        
C****        
C        
C        
C**** SET POINTER LPCOMP        
      LPCOMP = IPCMP + NPCMP + NPCMP1 + NPCMP2        
C        
C**** SET POINTERS        
      ITYPE = -1        
C        
      PCMP  = .FALSE.        
      PCMP1 = .FALSE.        
      PCMP2 = .FALSE.        
C        
      PCMP   = NPCMP  .GT. 0        
      PCMP1  = NPCMP1 .GT. 0        
      PCMP2  = NPCMP2 .GT. 0        
C        
C**** CHECK IF NO 'PCOMP' DATA HAS BEEN READ INTO CORE        
C        
      IF (PCMP .OR. PCMP1 .OR. PCMP2) GO TO 700        
      J = -229        
      GO TO 1580        
C        
C**** SEARCH FOR PID IN PCOMP DATA        
C        
  700 IF (.NOT.PCMP) GO TO 750        
C        
      IP = IPCMP        
      IF (INTZ(IP) .EQ. PID) GO TO 740        
      IPC11 = IPCMP1 - 1        
      DO 720 IP = IPCMP,IPC11        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(IPCMP1-1)) GO TO 710        
      GO TO 720        
  710 IF (INTZ(IP+1) .EQ. PID) GO TO 730        
  720 CONTINUE        
      GO TO 750        
C        
  730 IP = IP+1        
  740 ITYPE = PCOMP        
      GO TO 860        
C        
C**** SEARCH FOR PID IN PCOMP1 DATA        
C        
  750 IF (.NOT.PCMP1) GO TO 800        
      IP = IPCMP1        
      IF (INTZ(IP) .EQ. PID) GO TO 790        
      IPC21 = IPCMP2 - 1        
      DO 770 IP = IPCMP1,IPC21        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(IPCMP2-1)) GO TO 760        
      GO TO 770        
  760 IF (INTZ(IP+1) .EQ. PID) GO TO 780        
  770 CONTINUE        
      GO TO 800        
C        
  780 IP = IP+1        
  790 ITYPE = PCOMP1        
      GO TO 860        
C        
C**** SEARCH FOR PID IN PCOMP2 DATA        
C        
  800 IP = IPCMP2        
      IF (INTZ(IP) .EQ. PID) GO TO 840        
      LPC11 = LPCOMP - 1        
      DO 820 IP = IPCMP2,LPC11        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(LPCOMP-1)) GO TO 810        
      GO TO 820        
  810 IF (INTZ(IP+1) .EQ. PID) GO TO 830        
  820 CONTINUE        
      GO TO 850        
C        
  830 IP = IP+1        
  840 ITYPE = PCOMP2        
      GO TO 860        
C        
C        
C**** CHECK IF PID HAS NOT BEEN LOCATED        
C        
  850 IF (ITYPE .NE. -1) GO TO 860        
      J = -229        
      GO TO 1580        
C        
C**** LOCATION OF PID        
C        
  860 PIDLOC = IP        
      LAMOPT = INTZ(PIDLOC+8)        
C        
C        
C**** DETERMINE INTRINSIC LAMINATE PROPERTIES        
C        
C     LAMINATE THICKNESS        
C        
      TLAM = ELTH        
C        
C**** LAMINATE EXTENSIONAL, BENDING AND MEMBRANE-BENDING MATRICES       
C        
      DO 870 LL = 1,6        
      DO 870 MM = 1,6        
      ABBD(LL,MM) = 0.0        
  870 CONTINUE        
C        
C     EXTENSIONAL        
C        
      MATID = MID(1)        
      CALL MAT (ELID)        
C        
      CALL LPROPS (GPROP)        
C        
      DO 880 LL = 1,3        
      DO 880 MM = 1,3        
      II = MM + 3*(LL-1)        
      ABBD(LL,MM) = GPROP(II)*TLAM        
  880 CONTINUE        
C        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 910        
C        
C     BENDING        
C        
      MATID = MID(2)        
      CALL MAT (ELID)        
C        
      CALL LPROPS (GPROP)        
C        
C**** MOMENT OF INERTIA OF LAMINATE        
      MINTR = (TLAM**3)/12.0        
C        
      DO 890 LL = 1,3        
      DO 890 MM = 1,3        
      II = MM + 3*(LL-1)        
      ABBD(LL+3,MM+3) = GPROP(II)*MINTR        
  890 CONTINUE        
C        
      IF (LAMOPT .EQ. SYM) GO  TO 910        
C        
C     MEMBRANE-BENDING        
C        
      MATID = MID(4)        
      CALL MAT (ELID)        
C        
      CALL LPROPS (GPROP)        
C        
      DO 900 LL = 1,3        
      DO 900 MM = 1,3        
      II = MM + 3*(LL-1)        
      ABBD(LL,MM+3) = GPROP(II)*TLAM*TLAM        
      ABBD(LL+3,MM) = GPROP(II)*TLAM*TLAM        
  900 CONTINUE        
C        
  910 CONTINUE        
C        
C**** REFERENCE SURFACE        
      ZREF = -TLAM/2.0        
C        
C**** NUMBER OF LAYERS        
      NLAY = INTZ(PIDLOC + 1)        
C        
C**** SET POINTER        
      IF (ITYPE .EQ. PCOMP ) IPOINT = (PIDLOC + 8 + 4*NLAY)        
      IF (ITYPE .EQ. PCOMP1) IPOINT = (PIDLOC + 8 + NLAY)        
      IF (ITYPE .EQ. PCOMP2) IPOINT = (PIDLOC + 8 + 2*NLAY)        
C        
C****        
C     ALLOW FOR THE ORIENTATION OF THE MATERIAL AXIS FROM        
C     THE ELEMENT AXIS        
C****        
C        
      THETAE = ATAN(TEM(2)/TEM(1))        
      THETAE = THETAE*DEGRAD        
C        
C        
C**** LAMINATE REFERENCE (OR LAMINATION) TEMPERATURE        
      TSUBO = Z(IPOINT+24)        
C        
      IF (TEMPP1 .OR. TEMPP2) GO TO 920        
      TMEAN = TEMPEL        
      GO TO 930        
C        
  920 TMEAN = STEMP(1)        
C        
  930 DELTA = TMEAN - TSUBO        
C        
      DO 940 LL = 1,6        
      FTHERM(LL) = 0.0        
  940 CONTINUE        
C        
C**** ALLOW FOR APPLIED THERMAL MOMENTS        
C        
      IF (.NOT.TEMPP2) GO TO 960        
C        
      DO 950 LL = 1,3        
  950 FTHERM(LL+3) = THRMOM(LL)        
C        
  960 CONTINUE        
C        
C        
C     L O O P  O V E R  N L A Y        
C        
      DO 1050 K = 1,NLAY        
C        
      ZK1 = ZK        
      IF (K .EQ. 1) ZK1 = ZREF        
      IF (ITYPE .EQ. PCOMP ) ZK = ZK1 + Z(PIDLOC + 6 + 4*K)        
      IF (ITYPE .EQ. PCOMP1) ZK = ZK1 + Z(PIDLOC + 7)        
      IF (ITYPE .EQ. PCOMP2) ZK = ZK1 + Z(PIDLOC + 7 + 2*K)        
C        
      ZSUBI = (ZK+ZK1)/2.0        
C        
C**** LAYER THICKNESS        
      TI = ZK - ZK1        
C        
C**** LAYER ORIENTATION        
      IF (ITYPE .EQ. PCOMP ) THETA = Z(PIDLOC + 7 + 4*K)        
      IF (ITYPE .EQ. PCOMP1) THETA = Z(PIDLOC + 8 + K)        
      IF (ITYPE .EQ. PCOMP2) THETA = Z(PIDLOC + 8 + 2*K)        
C        
C        
      THETA = THETA * DEGRAD        
C        
      IF (THETAE .GT. 0.0) THETA = THETA + THETAE        
C        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANSL(1)  = C2        
      TRANSL(2)  = S2        
      TRANSL(3)  = C*S        
      TRANSL(4)  = S2        
      TRANSL(5)  = C2        
      TRANSL(6)  =-C*S        
      TRANSL(7)  =-2.0*C*S        
      TRANSL(8)  = 2.0*C*S        
      TRANSL(9)  = C2-S2        
C        
C**** CALCULATE GBAR = TRANST X GLAY X TRANS        
C        
      DO 1000 IR = 1,9        
      GLAY(IR) = Z(IPOINT+IR)        
 1000 CONTINUE        
C        
      CALL GMMATS (GLAY(1),3,3,0,TRANSL(1),3,3,0,GLAYT(1))        
      CALL GMMATS (TRANSL(1),3,3,1,GLAYT(1),3,3,0,GBAR(1))        
C        
C**** CALCULATE ALPHAE = TRANSL X ALPHA        
C        
C        
C     MODIFY TRANSL FOR TRANSFORMATIONS OF ALPHAS        
C        
      TRANSL(3) = -TRANSL(3)        
      TRANSL(6) = -TRANSL(6)        
      TRANSL(7) = -TRANSL(7)        
      TRANSL(8) = -TRANSL(8)        
C        
      DO 1010 IR = 1,3        
      ALPHAL(IR) = Z(IPOINT+13+IR)        
 1010 CONTINUE        
C        
      CALL GMMATS (TRANSL(1),3,3,0,ALPHAL(1),3,1,0,ALPHAE(1))        
C        
C        
C**** CALCULATE LAMINATE OPERATING TEMPERATURE (ALLOWING FOR        
C     TEMPERATURE GRADIENT IF APPLIED)        
C        
      DELTAT = DELTA        
      IF (TEMPP1) DELTAT = DELTA + ZSUBI*TGRAD        
C        
C**** CALCULATE THERMAL FORCES AND MOMENTS        
C        
      CALL GMMATS (GBAR(1),3,3,0,ALPHAE(1),3,1,0,GALPHA(1))        
C        
      DO 1020 IR = 1,3        
      FTHERM(IR) = FTHERM(IR) + GALPHA(IR)*DELTAT*(ZK - ZK1)        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1020        
      FTHERM(IR+3) = FTHERM(IR+3) -        
     1               GALPHA(IR)*DELTAT*((ZK**2)-(ZK1**2))/2.0        
 1020 CONTINUE        
C        
      IF (LAMOPT.NE.SYM .AND. LAMOPT.NE.SYMMEM) GO TO 1040        
C        
C**** CALCULATE CONTRIBUTION FROM SYMMETRIC LAYERS        
C        
      DELTAT = DELTA        
      IF (TEMPP1) DELTAT = DELTA - ZSUBI*TGRAD        
C        
      DO 1030 IR = 1,3        
      FTHERM(IR) = FTHERM(IR) + GALPHA(IR)*DELTAT*(ZK-ZK1)        
      IF (LAMOPT .EQ. SYMMEM) GO TO 1030        
      FTHERM(IR+3) = FTHERM(IR+3) -        
     1               GALPHA(IR)*DELTAT*((ZK1**2)-(ZK**2))/2.0        
 1030 CONTINUE        
C        
 1040 IF (ITYPE .EQ. PCOMP) IPOINT = IPOINT + 27        
C        
 1050 CONTINUE        
C        
C        
C****        
C     COMPUTE THERMAL STRAIN VECTOR        
C****        
C                 -1        
C     EPSLN = ABBD   X FTHERM        
C        
      CALL INVERS (6,ABBD,6,DUM,0,DETERM,ISING,INDX)        
C        
      DO 1060 LL = 1,6        
      DO 1060 MM = 1,6        
      NN = MM + 6*(LL-1)        
      STIFF(NN) = ABBD(LL,MM)        
 1060 CONTINUE        
C        
      CALL GMMATS (STIFF(1),6,6,0,FTHERM(1),6,1,0,EPSLNT(1))        
C        
 1070 CONTINUE        
C        
C        
C-----INITIALIZE NECESSARY ARRAYS BEFORE STARTING THE        
C     DOUBLE INTEGRATION LOOP        
C        
      DO 1100 I =1,9        
      G2(I) = 0.0        
 1100 CONTINUE        
      DO 1110 I =1,6        
      EPSUBT(I) = 0.0        
 1110 CONTINUE        
      DO 1120 I =1,NDOF        
      PT(I)  = 0.0        
      PTG(I) = 0.0        
 1120 CONTINUE        
C        
C     FILL IN THE 6X6 MATERIAL PROPERTY MATRIX G        
C        
      DO 1130 IG=1,6        
      DO 1130 JG=1,6        
 1130 G(IG,JG)=0.0        
C        
      IF (.NOT.MEMBRN) GO TO 1150        
      DO 1140 IG=1,3        
      IG1=(IG-1)*3        
      DO 1140 JG=1,3        
      JG1=JG+IG1        
      G(IG,JG)=GI(JG1)        
 1140 CONTINUE        
C        
 1150 IF (.NOT.BENDNG) GO TO 1180        
      I = 0        
      DO 1160 IG=4,6        
      IG2=(IG-2)*3        
      DO 1160 JG=4,6        
      JG2=JG+IG2        
      G(IG,JG)=GI(JG2)*MOMINR        
C        
C     SAVE THE G-MATRIX FOR BENDING IN G2        
C        
      I = I + 1        
      G2(I) = G(IG,JG)        
 1160 CONTINUE        
C        
      IF (.NOT.MEMBRN) GO TO 1180        
      IF (MBCOUP) GO TO 1180        
      DO 1170 IG=1,3        
      IG1=(IG-1)*3        
      KG=IG+3        
      DO 1170 JG=1,3        
      JG1=JG+IG1        
      LG=JG+3        
      G(IG,LG)=GI(JG1)        
      G(KG,JG)=GI(JG1)        
 1170 CONTINUE        
 1180 CONTINUE        
C        
C****        
C     HERE BEGINS THE DOUBLE LOOP ON STATEMENT 1470 TO        
C     GAUSS INTEGRATE FOR THE ELEMENT STIFFNESS MATRIX.        
C****        
C        
      DO 1470 IXSI=1,2        
      XI=PTINT(IXSI)        
C        
      DO 1470 IETA=1,2        
      ETA=PTINT(IETA)        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 1200 I=1,4        
      TMPSHP(I  )=SHP(I)        
      DSHPTP(I  )=DSHP(I)        
 1200 DSHPTP(I+4)=DSHP(I+4)        
      DO 1210 I=1,4        
      KK=IORDER(I)        
      SHP (I  )=TMPSHP(KK)        
      DSHP(I  )=DSHPTP(KK)        
 1210 DSHP(I+4)=DSHPTP(KK+4)        
C        
C     CALCULATE THE ELEMENT THICKNESS AT THIS POINT        
C        
      THK=0.0        
      DO 1220 I=1,NNODE        
 1220 THK=THK+DGPTH(I)*SHP(I)        
      REALI=THK*THK*THK/12.0        
C        
C-----CALCULATE T-BAR FOR THIS INTEGRATION POINT        
C     SKIP OVER IF TEMPPI CARDS ARE PRESENT        
C     THEN CALCULATE ALPHA*T FOR EACH CASE        
C        
      IF (COMPOS) GO TO 1370        
C        
      IF (TEMPP1 .OR. TEMPP2) GO TO 1310        
      TBAR = 0.0        
      DO 1300 I =1,NNODE        
 1300 TBAR = TBAR + SHP(I) * GTEMPS(I)        
 1310 CONTINUE        
C        
      TTBAR = TBAR - TSUB0        
C        
      IF (.NOT.MEMBRN) GO TO 1330        
      DO 1320 I =1,3        
 1320 TALFAM(I) = TTBAR * ALFAM(I)        
C        
 1330 IF (.NOT.BENDNG) GO TO 1370        
      IF (.NOT.TEMPP1 .AND. .NOT.TEMPP2) GO TO 1370        
      IF (TEMPP2) GO TO 1350        
      DO 1340 I =1,3        
 1340 TALFAB(I) = -TGRAD * ALFAB(I)        
      GO TO 1370        
C        
 1350 CONTINUE        
      DO 1360 IG2=1,9        
 1360 G2I(IG2) = G2(IG2)*REALI        
      CALL INVERS (3,G2I,3,GDUM,0,DETG2,ISNGG2,INDEX)        
      CALL GMMATS (G2I,3,3,0,THRMOM,3,1,0,TALFAB)        
 1370 CONTINUE        
C        
C     START THE THIRD INTEGRATION LOOP (THRU THE THICKNESS)        
C        
      DO 1460 IZTA=1,2        
      ZTA =PTINT(IZTA)        
      HZTA=ZTA/2.0        
      IBOT=(IZTA-1)*ND2        
C        
      CALL JACOBS (ELID,SHP,DSHP,DGPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1600        
C        
      CALL GMMATS (PSITRN,3,3,0,JACOB,3,3,1,PHI)        
C        
C     CALL Q4BMGS TO GET B MATRIX        
C     SET THE ROW FLAG TO 3. IT WILL RETURN THE FIRST 6 ROWS.        
C        
      ROWFLG = 3        
      CALL Q4BMGS (DSHP,DGPTH,EGPDT,EPNORM,PHI,BMATRX(1))        
      DO 1380 IX=1,NDOF        
 1380 BMATRX(IX+ND2)=XYBMAT(IBOT+IX)        
C        
      IF (.NOT.BENDNG) GO TO 1410        
      DO 1390 IX=1,NDOF        
 1390 BMATRX(IX+ND5)=XYBMAT(IBOT+IX+NDOF)        
C        
C     NOW COMPLETE THE G-MATRIX IF COUPLING EXISTS.        
C        
      IF (.NOT.MBCOUP) GO TO 1410        
      DO 1400 IG=1,3        
      IG4=(IG+8)*3        
      KG=IG+3        
      DO 1400 JG=1,3        
      JG4=JG+IG4        
      JG1=JG4-27        
      LG=JG+3        
      G(IG,LG)=-GI(JG4)*ZTA*6.0+GI(JG1)        
      G(KG,JG)=-GI(JG4)*ZTA*6.0+GI(JG1)        
 1400 CONTINUE        
 1410 CONTINUE        
C        
C-----MULTIPLY DETERMINANT, B-TRANSPOSE, G-MATRIX, & THERMAL        
C     STRAIN MATRIX.        
C        
C                         T        
C         P  =  DETERM * B  * G * EPSILON        
C          T                             T        
C        
      IF (COMPOS) GO TO 1430        
      DO 1420 I =1,3        
      EPSUBT(I) = DETJ * TALFAM(I)        
 1420 EPSUBT(I+3) = - DETJ * TALFAB(I) * HZTA * THK        
      GO TO 1450        
C        
 1430 DO 1440 IR = 1,3        
      EPSUBT(IR  ) = DETJ*EPSLNT(IR)        
 1440 EPSUBT(IR+3) =-DETJ*EPSLNT(IR+3)*THK*HZTA        
 1450 CONTINUE        
C        
      CALL GMMATS (G,6,6,0,EPSUBT,6,1,0,GEPSBT)        
      CALL GMMATS (BMATRX,6,NDOF,-1,GEPSBT,6,1,0,PT)        
C        
 1460 CONTINUE        
 1470 CONTINUE        
C        
C----TRIPLE INTEGRATION LOOP IS NOW FINISHED        
C        
C****        
C     PICK UP THE BASIC TO GLOBAL TRANSFORMATION FOR EACH NODE.        
C****        
      DO 1500 I=1,36        
 1500 TRANS(I)=0.0        
C        
      DO 1540 I=1,NNODE        
      IPOINT=9*(I-1)+1        
      IF (IGPDT(1,I) .LE. 0) GO TO 1510        
C        
      CALL TRANSS (BGPDT(1,I),TBG)        
      GO TO 1530        
C        
 1510 DO 1520 J=1,9        
 1520 TBG(J)=0.0        
      TBG(1)=1.0        
      TBG(5)=1.0        
      TBG(9)=1.0        
C        
 1530 CALL GMMATS (TEB,3,3,0,TBG,3,3,0,TRANS(IPOINT))        
 1540 CONTINUE        
C        
C        
C-----TRANSFORM THE THERMAL LOAD VECTOR INTO THE INDIVIDUAL        
C     GLOBAL COORDINATE SYSTEMS OF EACH NODE. NOTE THAT THE        
C     TRANSFORMATION MATRICES ARE STORED IN  TRANS = TEG,        
C     AND THAT THE 6-DOF LOAD VECTOR FOR EACH NODE USES THE        
C     SAME 3X3 TRANSFORMATION MATRIX FOR THE TRANSLATIONAL        
C     DOF'S (1-3) AND THE ROTATIONAL DOF'S (4-6).        
C        
C                         T        
C               PT  =  TEG   *  PT        
C                 G               E        
C        
      DO 1550 I =1,NNODE        
      IPT  = (I-1)*9 + 1        
      JPT1 = (I-1)*6 + 1        
      JPT2 = JPT1 + 3        
C        
      CALL GMMATS (TRANS(IPT),3,3,1,PT(JPT1),3,1,0,PTG(JPT1))        
      CALL GMMATS (TRANS(IPT),3,3,1,PT(JPT2),3,1,0,PTG(JPT2))        
C        
 1550 CONTINUE        
C        
C        
C-----WE NOW HAVE THE THERMAL LOAD VECTOR IN GLOBAL COORDINATES,        
C     IN PTG. THE NEXT AND LAST STEP IS TO COMBINE IT WITH THE        
C     SYSTEM LOAD VECTOR CONTAINED IN Z.        
C        
      L=0        
      DO 1560 I =1,NNODE        
      K = SIL(I) - 1        
      DO 1560 J =1,6        
      K = K + 1        
      L = L + 1        
      Z(K) = Z(K) + PTG(L)        
 1560 CONTINUE        
      GO TO 1600        
C        
 1580 CALL MESAGE (30,J,NAM)        
      NOGO = 1        
C        
C        
 1600 CONTINUE        
      RETURN        
C        
 1700 FORMAT ('0*** SYSTEM FATAL ERROR. THE ELEMENT THICKNESS FOR',     
     1        ' QUAD4 EID = ',I8,' IS NOT COMPLETELY DEFINED.')        
      END        