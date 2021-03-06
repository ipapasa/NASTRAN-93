      SUBROUTINE KBAR        
C        
C     THIS ROUTINE COMPUTES THE TWO 6X6 MATRICES K(NPVT,NPVT) AND       
C     K(NPVT,J) FOR A BAR ELEMENT HAVING END POINTS NUMBERED NPVT AND J.
C        
C                  ECPT FOR THE BAR        
C        
C     ECPT( 1)  -  IELID       ELEMENT ID. NUMBER        
C     ECPT( 2)  -  ISILNO(2)   * SCALAR INDEX NOS. OF THE GRID POINTS   
C     ECPT( 3)  -   ...        *        
C     ECPT( 4)  -  SMALLV(3)   $ REFERENCE VECTOR        
C     ECPT( 5)  -   ...        $        
C     ECPT( 6)  -   ...        $        
C     ECPT( 7)  -  ICSSV       COOR. SYS. ID FOR SMALLV VECTOR        
C     ECPT( 8)  -  IPINFL(2)   * PIN FLAGS        
C     ECPT( 9)  -   ...        *        
C     ECPT(10)  -  ZA(3)       $ OFFSET VECTOR FOR POINT A        
C     ECPT(11)  -   ...        $        
C     ECPT(12)  -   ...        $        
C     ECPT(13)  -  ZB(3)       * OFFSET VECTOR FOR POINT B        
C     ECPT(14)  -   ...        *        
C     ECPT(15)  -   ...        *        
C     ECPT(16)  -  IMATID      MATERIAL ID.        
C     ECPT(17)  -  A           CROSS-SECTIONAL AREA        
C     ECPT(18)  -  I1          $ AREA MOMENTS OF INERTIA        
C     ECPT(19)  -  I2          $        
C     ECPT(20)  -  FJ          TORSIONAL CONSTANT        
C     ECPT(21)  -  NSM         NON-STRUCTURAL MASS        
C     ECPT(22)  -  FE          FORCE ELEMENT DESCRIPTIONS (FORCE METHOD)
C     ECPT(23)  -  C1          * STRESS RECOVERY COEFFICIENTS        
C     ECPT(24)  -  C2          *        
C     ECPT(25)  -  D1          *        
C     ECPT(26)  -  D2          *        
C     ECPT(27)  -  F1          *        
C     ECPT(28)  -  F2          *        
C     ECPT(29)  -  G1          *        
C     ECPT(30)  -  G2          *        
C     ECPT(31)  -  K1          $ AREA FACTORS FOR SHEAR        
C     ECPT(32)  -  K2          $        
C     ECPT(33)  -  I12         AREA MOMENT OF INERTIA        
C     ECPT(34)  -  MCSIDA      COOR. SYS. ID. FOR GRID POINT A        
C     ECPT(35)  -  GPA(3)      * BASIC COORDINATES FOR GRID POINT A     
C     ECPT(36)  -   ...        *        
C     ECPT(37)  -   ...        *        
C     ECPT(38)  -  MCSIDB      COOR. SYS. ID. FOR GRID POINT B        
C     ECPT(39)  -  GPB(3)      $ BASIC COORDINATES FOR GRID POINT B     
C     ECPT(40)  -   ...        $        
C     ECPT(41)  -   ...        $        
C     ECPT(42)  -  ELTEMP      AVG. ELEMENT TEMPERATURE        
C        
C     SEE SUBROUTINE KELBOW ON THE DISCUSSION OF K1 AND K2, THE AERA    
C     FACTORS FOR SHEAR CORRECTION        
C        
      LOGICAL          HEAT      ,ABASIC    ,BBASIC    ,BASIC    ,      
     1                 AOFSET    ,BOFSET    ,OFFSET        
      REAL             K1        ,K2        ,I1        ,I2       ,      
     1                 I12       ,NSM        
      DOUBLE PRECISION TA(18)    ,TB(9)     ,SMALV0(6) ,DELA     ,      
     1                 DELB      ,KE        ,KEP       ,VECI     ,      
     2                 VECJ      ,VECK      ,FL        ,FLL      ,      
     3                 EI1       ,EI2       ,GAK1      ,GAK2     ,      
     4                 R1        ,R2        ,SK1       ,SK2      ,      
     5                 SK3       ,SK4       ,AEL       ,GJL      ,      
     6                 LR1       ,LR2       ,L         ,LSQ      ,      
     7                 LCUBE     ,DP(8)     ,BETA      ,LB       ,      
     8                 L2B3      ,L2B6      ,DAMPC        
      DIMENSION        VECI(3)   ,VECJ(3)   ,VECK(3)   ,ECPT(100),      
     1                 IECPT(100),IPIN(10)        
      COMMON /SYSTEM/  ISYS        
      COMMON /SMA1IO/  IFCSTM    ,IFMPT     ,IFDIT     ,IDUM1    ,      
     1                 IFECPT    ,IGECPT    ,IFGPCT    ,IGGPCT   ,      
     2                 IFGEI     ,IGGEI     ,IFKGG     ,IGKGG    ,      
     3                 IF4GG     ,IG4GG     ,IFGPST    ,IGGPST   ,      
     4                 INRW      ,OUTRW     ,CLSNRW    ,CLSRW    ,      
     5                 NEOR      ,EOR       ,MCBKGG(7) ,MCB4GG(7)       
C        
C     SMA1 VARIABLE CORE BOOKKEEPING PARAMETERS        
C        
      COMMON /SMA1BK/  ICSTM     ,NCSTM     ,IGPCT     ,NGPCT    ,      
     1                 IPOINT    ,NPOINT    ,I6X6K     ,N6X6K    ,      
     2                 I6X64     ,N6X64        
C        
C     SMA1 PROGRAM CONTROL PARAMETERS        
C        
      COMMON /SMA1CL/  IOPT4     ,K4GGSW    ,NPVT      ,LEFT     ,      
     1                 FROWIC    ,LROWIC    ,NROWSC    ,TNROWS   ,      
     2                 JMAX      ,NLINKS    ,LINK(10)  ,IDETCK   ,      
     3                 DODET     ,NOGO        
      COMMON /SMA1HT/  HEAT        
      COMMON /SMA1ET/  IELID     ,ISILNO(2) ,SMALLV(3) ,ICSSV    ,      
     1                 IPINFL(2) ,ZA(3)     ,ZB(3)     ,IMATID   ,      
     2                 A         ,I1        ,I2        ,FJ       ,      
     3                 NSM       ,FE        ,C1        ,C2       ,      
     4                 D1        ,D2        ,F1        ,F2       ,      
     5                 G1        ,G2        ,K1        ,K2       ,      
     6                 I12       ,           MCSIDA    ,GPA(3)   ,      
     7                 MCSIDB    ,GPB(3)    ,TEMPEL        
C        
C     SMA1 LOCAL VARIABLES        
C        
      COMMON /SMA1DP/  KE(144)   ,KEP(144)  ,DELA(6)   ,DELB(6)        
C        
C     INPUT AND OUTPUT BLOCKS FOR SUBROUTINE MAT        
C        
      COMMON /MATIN/   MATIDC    ,MATFLG    ,ELTEMP    ,STRESS        
C        
      COMMON /MATOUT/  E         ,G         ,NU        ,RHO      ,      
     1                 ALPHA     ,TSUBO     ,GSUBE     ,SIGT     ,      
     2                 SIGC      ,SIGS        
      COMMON /HMTOUT/  FK        
C        
      EQUIVALENCE      (IELID,ECPT(1),IECPT(1)) , (TA(10),TB(1)) ,      
     1                 (ECPT(71),DP(1))        
C        
C     DETERMINE WHICH POINT IS THE PIVOT POINT.        
C        
      IPVT = 1        
      IF (ISILNO(1) .EQ. NPVT) GO TO 20        
      IPVT = 2        
      IF (ISILNO(2) .NE. NPVT) CALL MESAGE (-30,34,IECPT(1))        
C        
C     SET UP POINTERS TO COOR. SYS. IDS., OFFSET VECTORS, AND PIN FLAGS.
C     ICSIDA AND ICSIDB ARE COOR. SYS. IDS.        
C        
   20 JCSIDA = 34        
      JCSIDB = 38        
      JOFSTA = 10        
      JOFSTB = 13        
      JPINA  =  8        
      JPINB  =  9        
      ICSIDA = IECPT(34)        
      ICSIDB = IECPT(38)        
C        
C     NORMALIZE THE REFERENCE VECTOR WHICH LIES IN THE FIRST PRINCIPAL  
C     AXIS PLANE  (FMMS - 36 P. 4)        
C     WE STORE SMALLV IN SMALV0 SO THAT ARITHMETIC WILL BE DOUBLE       
C     PRECISION        
C        
      DO 50 I = 1,3        
   50 SMALV0(I) = SMALLV(I)        
      FL = DSQRT(SMALV0(1)**2 + SMALV0(2)**2 + SMALV0(3)**2)        
      IF (FL .LE. 0.0D0) GO TO 1010        
      DO 60 I = 1,3        
   60 SMALV0(I) = SMALV0(I)/FL        
C        
C     DETERMINE IF POINT A AND B ARE IN BASIC COORDINATES OR NOT.       
C        
      ABASIC = .TRUE.        
      BBASIC = .TRUE.        
      IF (ICSIDA .NE. 0) ABASIC = .FALSE.        
      IF (ICSIDB .NE. 0) BBASIC = .FALSE.        
C        
C     COMPUTE THE TRANSFORMATION MATRICES TA AND TB IF NECESSARY        
C        
      IF (.NOT. ABASIC) CALL TRANSD (ECPT(JCSIDA),TA)        
      IF (.NOT. BBASIC) CALL TRANSD (ECPT(JCSIDB),TB)        
C        
C     DETERMINE IF WE HAVE NON-ZERO OFFSET VECTORS.        
C        
      AOFSET = .TRUE.        
      J = JOFSTA - 1        
      DO 70 I = 1,3        
      J = J + 1        
      IF (ECPT(J) .NE. 0.0) GO TO 80        
   70 CONTINUE        
      AOFSET = .FALSE.        
   80 BOFSET = .TRUE.        
      J = JOFSTB - 1        
      DO 90 I = 1,3        
      J = J + 1        
      IF (ECPT(J) .NE. 0.0) GO TO 100        
   90 CONTINUE        
      BOFSET = .FALSE.        
C        
C     FORM THE CENTER AXIS OF THE BEAM WITHOUT OFFSETS.        
C     FIRST WE STORE THE COORDINATES IN THE ARRAY DP SO THAT ALL        
C     ARITHMETIC WILL BE DOUBLE PRECISION.        
C        
  100 DP(1) = ECPT(JCSIDA+1)        
      DP(2) = ECPT(JCSIDA+2)        
      DP(3) = ECPT(JCSIDA+3)        
      DP(4) = ECPT(JCSIDB+1)        
      DP(5) = ECPT(JCSIDB+2)        
      DP(6) = ECPT(JCSIDB+3)        
      VECI(1) = DP(1) - DP(4)        
      VECI(2) = DP(2) - DP(5)        
      VECI(3) = DP(3) - DP(6)        
C        
C     TRANSFORM THE OFFSET VECTORS IF NECESSARY        
C        
      IF (.NOT.AOFSET .AND. .NOT.BOFSET)  GO TO 150        
C        
C     TRANSFORM THE OFFSET VECTOR FOR POINT A IF NECESSARY.        
C        
      IDELA = 1        
      J = JOFSTA - 1        
      DO 110 I = 1,3        
      J = J + 1        
  110 DELA(I) = ECPT(J)        
      IF (ABASIC) GO TO 120        
      IDELA = 4        
      CALL GMMATD (TA,3,3,0, DELA(1),3,1,0, DELA(4))        
C        
C     TRANSFORM THE OFFSET VECTOR FOR POINT B IF NECESSARY        
C        
  120 IDELB = 1        
      J = JOFSTB - 1        
      DO 130 I = 1,3        
      J = J + 1        
  130 DELB(I) = ECPT(J)        
      IF (BBASIC) GO TO 140        
      IDELB = 4        
      CALL GMMATD (TB,3,3,0, DELB(1),3,1,0, DELB(4))        
C        
C     SINCE THERE WAS AT LEAST ONE NON-ZERO OFFSET VECTOR RECOMPUTE VECI
C        
  140 VECI(1) = VECI(1) + DELA(IDELA  ) - DELB(IDELB  )        
      VECI(2) = VECI(2) + DELA(IDELA+1) - DELB(IDELB+1)        
      VECI(3) = VECI(3) + DELA(IDELA+2) - DELB(IDELB+2)        
C        
C     COMPUTE THE LENGTH OF THE BIG V (VECI) VECTOR AND NORMALIZE       
C        
  150 VECI(1) = -VECI(1)        
      VECI(2) = -VECI(2)        
      VECI(3) = -VECI(3)        
      FL = DSQRT(VECI(1)**2 + VECI(2)**2 + VECI(3)**2)        
      IF (FL .EQ. 0.0D0) GO TO 1010        
C        
C     NOW THAT LENGTH HAS BEEN COMPUTED, BRANCH IF THIS IS A -HEAT-     
C     FORMULATION.        
C        
      IF (HEAT) GO TO 2000        
      DO 160 I = 1,3        
  160 VECI(I) = VECI(I)/FL        
C        
C     COMPUTE THE SMALL V SUB 0 VECTOR, SMALV0.  ***CHECK THIS LOGIC*** 
C        
      ISV = 1        
      IF (ICSSV .EQ. 0) GO TO 180        
      ISV = 4        
      CALL GMMATD (TA,3,3,0, SMALV0(1),3,1,0, SMALV0(4))        
C        
C     COMPUTE THE K VECTOR, VECK = VECI  X  SMALV0, AND NORMALIZE       
C        
  180 VECK(1) =  VECI(2)*SMALV0(ISV+2) - VECI(3)*SMALV0(ISV+1)        
      VECK(2) =  VECI(3)*SMALV0(ISV  ) - VECI(1)*SMALV0(ISV+2)        
      VECK(3) =  VECI(1)*SMALV0(ISV+1) - VECI(2)*SMALV0(ISV  )        
      FLL = DSQRT(VECK(1)**2 + VECK(2)**2 + VECK(3)**2)        
      IF (FLL .EQ. 0.0D0) GO TO 1010        
      VECK(1) =  VECK(1)/FLL        
      VECK(2) =  VECK(2)/FLL        
      VECK(3) =  VECK(3)/FLL        
C        
C     COMPUTE THE J VECTOR, VECJ = VECK  X  VECI, AND NORMALIZE        
C        
      VECJ(1) =  VECK(2)*VECI(3) - VECK(3)*VECI(2)        
      VECJ(2) =  VECK(3)*VECI(1) - VECK(1)*VECI(3)        
      VECJ(3) =  VECK(1)*VECI(2) - VECK(2)*VECI(1)        
      FLL = DSQRT(VECJ(1)**2 + VECJ(2)**2 + VECJ(3)**2)        
      IF (FLL .EQ. 0.0D0) GO TO 1010        
      VECJ(1) =  VECJ(1)/FLL        
      VECJ(2) =  VECJ(2)/FLL        
      VECJ(3) =  VECJ(3)/FLL        
C        
C     SEARCH THE MATERIAL PROPERTIES TABLE FOR E, G AND THE DAMPING     
C     CONSTANT.        
C        
      MATIDC = IMATID        
      MATFLG = 1        
      ELTEMP = TEMPEL        
      CALL MAT (IECPT(1))        
      DAMPC = G SUB E        
C        
C     SET UP INTERMEDIATE VARIABLES FOR ELEMENT STIFFNESS MATRIX        
C     CALCULATION        
C        
      L = FL        
      LSQ = L**2        
      LCUBE = LSQ*L        
C        
C     STORE ECPT AND MPT VARIABLES IN DOUBLE PRECISION LOCATIONS.       
C        
      DP(1) = E        
      DP(2) = G        
      DP(3) = I1        
      DP(4) = I2        
      DP(5) = A        
      EI1 = DP(1)*DP(3)        
      EI2 = DP(1)*DP(4)        
      IF (K1.EQ.0.0 .OR. I12.NE.0.0) GO TO 210        
      DP(6) = K1        
      GAK1  = DP(2)*DP(5)*DP(6)        
      R1 = (12.0D0*EI1*GAK1)/(GAK1*LCUBE + 12.0D0*L* EI1)        
      GO TO 220        
  210 R1 =  12.0D0*EI1/LCUBE        
  220 IF (K2.EQ.0.0 .OR. I12.NE.0.0) GO TO 230        
      DP(7) = K2        
      GAK2  = DP(2)*DP(5)*DP(7)        
      R2 = (12.0D0*EI2*GAK2)/(GAK2*LCUBE + 12.0D0*L*EI2)        
      GO TO 240        
  230 R2 =  12.0D0*EI2/LCUBE        
C        
C     COMPUTE THE -SMALL- K-S, SK1, SK2, SK3 AND SK4        
C        
  240 SK1 = 0.25D0*R1*LSQ + EI1/L        
      SK2 = 0.25D0*R2*LSQ + EI2/L        
      SK3 = 0.25D0*R1*LSQ - EI1/L        
      SK4 = 0.25D0*R2*LSQ - EI2/L        
C        
C     COMPUTE THE TERMS THAT WILL BE NEEDED FOR THE 12 X 12 MATRIX KE   
C        
      AEL  = DP(5)*DP(1)/L        
      LR1  = L*R1/2.0D0        
      LR2  = L*R2/2.0D0        
      DP(8)= FJ        
      GJL  = DP(2)*DP(8)/L        
C        
C     CONSTRUCT THE 12 X 12 MATRIX KE        
C        
      DO 250 I = 1,144        
  250 KE(I) = 0.0D0        
      KE(  1) =  AEL        
      KE(  7) = -AEL        
      KE( 14) =  R1        
      KE( 18) =  LR1        
      KE( 20) = -R1        
      KE( 24) =  LR1        
      KE( 27) =  R2        
      KE( 29) = -LR2        
      KE( 33) = -R2        
      KE( 35) = -LR2        
      KE( 40) =  GJL        
      KE( 46) = -GJL        
      KE( 51) = -LR2        
      KE( 53) =  SK2        
      KE( 57) =  LR2        
      KE( 59) =  SK4        
      KE( 62) =  LR1        
      KE( 66) =  SK1        
      KE( 68) = -LR1        
      KE( 72) =  SK3        
      KE( 73) = -AEL        
      KE( 79) =  AEL        
      KE( 86) = -R1        
      KE( 90) = -LR1        
      KE( 92) =  R1        
      KE( 96) = -LR1        
      KE( 99) = -R2        
      KE(101) =  LR2        
      KE(105) =  R2        
      KE(107) =  LR2        
      KE(112) = -GJL        
      KE(118) =  GJL        
      KE(123) = -LR2        
      KE(125) =  SK4        
      KE(129) =  LR2        
      KE(131) =  SK2        
      KE(134) =  LR1        
      KE(138) =  SK3        
      KE(140) = -LR1        
      KE(144) =  SK1        
      IF (I12 .EQ. 0.0) GO TO 255        
      DP(8)   =  I12        
      BETA    =  12.0D0*DP(1)*DP(8)/LCUBE        
      LB      =  L*BETA/2.0D0        
      L2B3    =  LSQ*BETA/3.0D0        
      L2B6    =  LSQ*BETA/6.0D0        
      KE( 15) =  BETA        
      KE( 17) = -LB        
      KE( 21) = -BETA        
      KE( 23) = -LB        
      KE( 26) =  BETA        
      KE( 30) =  LB        
      KE( 32) = -BETA        
      KE( 36) =  LB        
      KE( 50) = -LB        
      KE( 54) = -L2B3        
      KE( 56) =  LB        
      KE( 60) = -L2B6        
      KE( 63) =  LB        
      KE( 65) = -L2B3        
      KE( 69) = -LB        
      KE( 71) = -L2B6        
      KE( 87) = -BETA        
      KE( 89) =  LB        
      KE( 93) =  BETA        
      KE( 95) =  LB        
      KE( 98) = -BETA        
      KE(102) = -LB        
      KE(104) =  BETA        
      KE(108) = -LB        
      KE(122) = -LB        
      KE(126) = -L2B6        
      KE(128) =  LB        
      KE(132) = -L2B3        
      KE(135) =  LB        
      KE(137) = -L2B6        
      KE(141) = -LB        
      KE(143) = -L2B3        
C        
C     DETERMINE IF THERE ARE NON-ZERO PIN FLAGS.        
C        
  255 KA = IECPT(JPINA)        
      KB = IECPT(JPINB)        
      IF (KA.EQ.0 .AND. KB.EQ.0) GO TO 325        
C        
C     SET UP THE IPIN ARRAY        
C        
      DO 260 I = 1,5        
      IPIN(I  ) = MOD(KA,10)        
      IPIN(I+5) = MOD(KB,10) + 6        
      IF (IPIN(I+5) .EQ. 6) IPIN(I+5) = 0        
      KA = KA/10        
  260 KB = KB/10        
C        
C     ALTER KE MATRIX DUE TO PIN FLAGS.        
C        
      DO 320 I = 1,10        
      IF (IPIN(I) .EQ. 0) GO TO 320        
      II = 13*IPIN(I) - 12        
      IF (KE(II) .NE. 0.0D0) GO TO 280        
      IL = IPIN(I)        
      II = II - IL        
      DO 270 J = 1,12        
      II = II + 1        
      KE(II) = 0.0D0        
      KE(IL) = 0.0D0        
      IL = IL + 12        
  270 CONTINUE        
      GO TO 320        
  280 DO 300 J = 1,12        
      JI  = 12*(J-1) + IPIN(I)        
      IJ  = 12*(IPIN(I)-1) + J        
      DO 290 LL = 1,12        
      JLL = 12*(J-1) + LL        
      ILL = 12*(IPIN(I)-1) + LL        
      KEP(JLL) = KE(JLL) - (KE(ILL)/KE(II))*KE(JI)        
  290 CONTINUE        
      KEP(IJ ) = 0.0D0        
      KEP(JI ) = 0.0D0        
  300 CONTINUE        
      DO 310 K = 1,144        
  310 KE(K) = KEP(K)        
  320 CONTINUE        
C        
C            E        
C     STORE K       AT KEP(1),...,KEP(36)   AND        
C            NPVT,A        
C        
C            E        
C           K        AT KEP(37),...,KEP(72)        
C            NPVT,B        
C        
  325 J = 0        
      IF (IPVT .EQ. 2) GO TO 327        
      ILOW = 1        
      ILIM = 72        
      GO TO 329        
  327 ILOW = 73        
      ILIM = 144        
  329 DO 340 I = ILOW,ILIM,12        
      LOW = I        
      LIM = LOW + 5        
      DO 330 K = LOW,LIM        
      J = J + 1        
      KEP(J   ) = KE(K  )        
  330 KEP(J+36) = KE(K+6)        
  340 CONTINUE        
C        
C                                                            T        
C     STORE VECI, VECJ, VECK IN KE(1),...,KE(9) FORMING THE A  MATRIX.  
C        
      KE(1) = VECI(1)        
      KE(2) = VECI(2)        
      KE(3) = VECI(3)        
      KE(4) = VECJ(1)        
      KE(5) = VECJ(2)        
      KE(6) = VECJ(3)        
      KE(7) = VECK(1)        
      KE(8) = VECK(2)        
      KE(9) = VECK(3)        
C        
C     ZERO OUT THE ARRAY WHERE THE 3X3 MATRIX H AND THE W  AND W  6X6   
C     MATRICES WILL RESIDE.                              A      B       
C        
      DO 350 I = 28,108        
  350 KE(I) = 0.0D0        
      IPASS = 1        
      IWBEG = 0        
C        
C     SET UP POINTERS        
C        
      IF (IPVT-1) 365,360,365        
  360 BASIC  = ABASIC        
      JCSID  = JCSIDA        
      OFFSET = AOFSET        
      JOFSET = JOFSTA        
      IKEL   = 1        
      INDEX  = ISILNO(1)        
      GO TO 368        
  365 BASIC  = BBASIC        
      JCSID  = JCSIDB        
      OFFSET = BOFSET        
      JOFSET = JOFSTB        
      IKEL   = 37        
      INDEX  = ISILNO(2)        
C        
C     SET UP THE -G- MATRIX. IG POINTS TO THE BEGINNING OF THE G MATRIX.
C     G = AT X TI        
C        
  368 IG = 1        
      IF (BASIC) GO TO 370        
      CALL TRANSD (ECPT(JCSID),KE(10))        
      CALL GMMATD (KE(1),3,3,0, KE(10),3,3,0, KE(19))        
      IG = 19        
C        
C     IF THERE IS A NON-ZERO OFFSET FOR THE POINT, SET UP THE D 3X3     
C     MATRIX.        
C        
  370 IF (.NOT.OFFSET) GO TO 380        
      KE(10) =  0.0D0        
      KE(11) =  ECPT(JOFSET+2)        
      KE(12) = -ECPT(JOFSET+1)        
      KE(13) = -KE(11)        
      KE(14) =  0.0D0        
      KE(15) =  ECPT(JOFSET)        
      KE(16) = -KE(12)        
      KE(17) = -KE(15)        
      KE(18) =  0.0D0        
C        
C     FORM THE 3X3 PRODUCT H = G X D, I.E., KE(28) = KE(IG) X KE(10)    
C        
      CALL GMMATD (KE(IG),3,3,0, KE(10),3,3,0, KE(28))        
C        
C        
C     FORM THE W  MATRIX OR THE W  MATRIX IN KE(37) OR KE(73) DEPENDING 
C               A                B        
C     UPON WHICH POINT - A OR B - IS UNDER CONSIDERATION.  G WILL BE    
C     STORED IN THE UPPER LEFT AND LOWER RIGHT CORNERS.  H, IF NON-ZERO,
C     WILL BE STORED IN THE UPPER RIGHT CORNER.        
C        
  380 KE(IWBEG+37) = KE(IG  )        
      KE(IWBEG+38) = KE(IG+1)        
      KE(IWBEG+39) = KE(IG+2)        
      KE(IWBEG+43) = KE(IG+3)        
      KE(IWBEG+44) = KE(IG+4)        
      KE(IWBEG+45) = KE(IG+5)        
      KE(IWBEG+49) = KE(IG+6)        
      KE(IWBEG+50) = KE(IG+7)        
      KE(IWBEG+51) = KE(IG+8)        
      KE(IWBEG+58) = KE(IG  )        
      KE(IWBEG+59) = KE(IG+1)        
      KE(IWBEG+60) = KE(IG+2)        
      KE(IWBEG+64) = KE(IG+3)        
      KE(IWBEG+65) = KE(IG+4)        
      KE(IWBEG+66) = KE(IG+5)        
      KE(IWBEG+70) = KE(IG+6)        
      KE(IWBEG+71) = KE(IG+7)        
      KE(IWBEG+72) = KE(IG+8)        
      IF (.NOT. OFFSET) GO TO 390        
      KE(IWBEG+40) = KE(28)        
      KE(IWBEG+41) = KE(29)        
      KE(IWBEG+42) = KE(30)        
      KE(IWBEG+46) = KE(31)        
      KE(IWBEG+47) = KE(32)        
      KE(IWBEG+48) = KE(33)        
      KE(IWBEG+52) = KE(34)        
      KE(IWBEG+53) = KE(35)        
      KE(IWBEG+54) = KE(36)        
C        
C                       T      E        
C     FORM THE PRODUCT W   X  K   AND STORE IN KEP(73)        
C                       NPVT        
C        
  390 CALL GMMATD (KE(37),6,6,1, KEP(IKEL),6,6,0, KEP(73))        
C        
C     COMPUTE THE FINAL ANSWER AND STORE IN KEP(109)        
C        
      CALL GMMATD (KEP(73),6,6,0, KE(IWBEG+37),6,6,0, KEP(109))        
C        
C     INSERT THIS 6X6        
C        
      CALL SMA1B (KEP(109),INDEX,-1,IFKGG,0.0D0)        
      IF (IOPT4.EQ.0 .OR. GSUBE.EQ.0.0) GO TO 400        
      K4GGSW = 1        
      CALL SMA1B (KEP(109),INDEX,-1,IF4GG,DAMPC)        
C        
C     IF IPASS = 2, WE ARE DONE.  OTHERWISE COMPUTE THE OFF-DIAGONAL 6X6
C        
  400 IF (IPASS .EQ. 2) GO TO 500        
      IWBEG = 36        
      IPASS = 2        
      DO 410 I = 28,36        
  410 KE(I) = 0.0D0        
      IF (IPVT-1) 360,365,360        
  500 RETURN        
C        
 1010 CALL MESAGE (30,26,IECPT(1))        
C        
C     SET FLAG FOR FATAL ERROR WHILE ALLOWING ERROR MESSAGES TO        
C     ACCUMULATE        
C        
      NOGO = 1        
      RETURN        
C        
C     HEAT FORMULATION CONTINUES HERE.  GET MATERIAL PROPERTY -K- FROM  
C     HMAT        
C        
 2000 MATFLG = 1        
      MATIDC = IECPT(16)        
      ELTEMP = ECPT(42)        
      CALL HMAT (IELID)        
C        
      FL = DBLE(FK)*DBLE(ECPT(17))/FL        
      IF (NPVT .EQ. IECPT(3)) FL = -FL        
      DO 2020 I = 1,2        
      CALL SMA1B (FL,IECPT(I+1),NPVT,IFKGG,0.0D0)        
      FL = -FL        
 2020 CONTINUE        
      RETURN        
      END        
