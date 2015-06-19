      SUBROUTINE EMGFIN        
C        
C     THIS ROUTINE OF THE -EMG- MODULE WRAPS UP THE WORK OF THE MODULE. 
C        
      LOGICAL         ERROR, HEAT, LINEAR        
      INTEGER         CLS, CLSREW, RDREW, WRTREW, DATE, MCB(7), PRECIS, 
     1                EST, DICTN, FLAGS, SCR3, SCR4, VAFILE, SUB(2),    
     2                IX(6), SIL(32)        
      REAL            INPI(10), Z(2), RX(200), COREY(201)        
      COMMON /BLANK / NOKMB(3), NOK4GG, CMASS, DUMMY(11), VOLUME, SURFAC
      COMMON /HMATDD/ SKP(4), LINEAR        
      COMMON /EMGPRM/ ICORE, JCORE, NCORE, DUM12(12), FLAGS(3), PRECIS, 
     1                ERROR, HEAT, ICMBAR, LCSTM, LMAT, LHMAT        
      COMMON /NAMES / RD, RDREW, WRT, WRTREW, CLSREW, CLS        
      COMMON /EMGFIL/ EST, CSTM, MPT, DIT, GEOM2, MATRIX(3), DICTN(3)   
      COMMON /OUTPUT/ HEAD(96)        
      COMMON /SYSTEM/ IBUF, NOUT, SKIP6(6), NLPP, SKIP2(2), LINE,       
     1                SK1P2(2), DATE(3)        
      COMMON /MACHIN/ MACH        
CZZ   COMMON /ZZEMGX/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      EQUIVALENCE     (COREX(1),COREY(1),RX(1),IX(1)), (Z(1),COREY(201))
      DATA    VAFILE, SCR4  / 207,    304           /        
      DATA    D2,     D3    / 4H2-D , 4H3-D         /        
      DATA    SUB,    SCR3  / 4HEMGF, 4HIN   , 303  /        
      DATA    INPI  / 4HINPT, 4HINP1, 4HINP2, 4HINP3, 4HINP4,        
     1                4HINP5, 4HINP6, 4HINP7, 4HINP8, 4HINP9/        
C        
C     CLOSE ALL FILES, EXCEPT SCR4        
C        
      DO 10 I = 1,3        
      NOKMB(I) = -FLAGS(I) - 1        
      IF (FLAGS(I)+1 .EQ. 0) FLAGS(I) = 0        
      IF (FLAGS(I)   .EQ. 0) NOKMB(I) =-1        
      CALL CLOSE (MATRIX(I),CLSREW)        
      CALL CLOSE (DICTN(I),CLSREW)        
   10 CONTINUE        
      CALL CLOSE (EST,CLSREW)        
C        
C     HEAT ONLY - SET NONILINEAR FLAG BASED ON VALUE PREVIOUSLY SET BY  
C     HMAT ROUTINE        
C        
      IF (HEAT .AND. .NOT.LINEAR) NOKDGG = +1        
      IF (HEAT .AND.      LINEAR) NOKDGG = -1        
C        
C  WRITE TRAILERS FOR FILES PREPARED.        
C        
      IF (ERROR) GO TO 340        
      DO 40 I = 1,3        
C        
C     PRECISION IS STORED IN FIRST DATA WORD OF TRAILER.        
C        
      IF (FLAGS(I) .EQ. 0) GO TO 40        
      MCB(1) = MATRIX(I)        
      CALL RDTRL (MCB)        
      IF (MCB(1)) 40,40,20        
   20 MCB(2) = PRECIS        
      MCB(3) = 0        
      MCB(4) = 0        
      MCB(5) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL WRTTRL (MCB)        
C        
      MCB(1) = DICTN(I)        
      CALL RDTRL (MCB)        
      IF (MCB(1)) 40,40,30        
   30 MCB(2) = PRECIS        
      MCB(3) = 0        
      MCB(4) = 0        
      MCB(5) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL WRTTRL (MCB)        
   40 CONTINUE        
      IF (VOLUME.LE.0.0 .AND. SURFAC.LE.0.0) GO TO 330        
C        
C     COMPUTE AND PRINT VOLUMES AND SURFACE AREAS FOR THE 2-D AND 3-D   
C     ELEM. IF USER REQUESTED VIA PARAM CARD.        
C        
      CALL CLOSE (SCR4,CLSREW)        
      IBUF1 = ICORE + 200        
      IBUF2 = IBUF1 + IBUF        
      CALL OPEN (*350,SCR4,Z(IBUF1),RDREW)        
      TVOL2 = 0.0        
      TVOL3 = 0.0        
      TMAS2 = 0.0        
      TMAS3 = 0.0        
      NREC  = 0        
      LINE  = NLPP        
      INP   = 0        
C        
C     CHECK ANY REQUEST TO SAVE VOLUME AND AREA COMPUTATIONS ON OUTPUT  
C     FILE SET INP TO APPROPRIATE VALUE IF IT IS AN INPI FILE        
C        
      MCB(1) = VAFILE        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) GO TO 70        
      CALL FNAME (VAFILE,Z(1))        
      DO 55 I = 1,10        
      IF (Z(1) .EQ. INPI(I)) GO TO 60        
   55 CONTINUE        
      GO TO 65        
   60 INP = I + 13        
      IF (INP.EQ.14 .AND. MACH.EQ.2) INP = 24        
      VAFILE = SCR3        
      MCB(1) = SCR3        
   65 CALL OPEN (*360,VAFILE,Z(IBUF2),WRTREW)        
      CALL WRITE (VAFILE,Z(1),    2,0)        
      CALL WRITE (VAFILE,HEAD(1),96,0)        
      CALL WRITE (VAFILE,DATE(1), 3,1)        
      NREC = 1        
   70 CALL READ (*210,*90,SCR4,RX,201,1,I)        
      WRITE  (NOUT,80)        
   80 FORMAT (' *** WARNING,   RX TOO SMALL IN EMGFIN ***')        
   90 NGPT = IX(6)        
      IF (NGPT .LT.    3) GO TO 70        
      IF (LINE .LT. NLPP) GO TO 130        
      LINE = 5        
      CALL PAGE1        
      WRITE  (NOUT,100) (I,I=1,6)        
  100 FORMAT (17X,'V O L U M E S,  M A S S E S,  A N D  S U R F A C E ',
     1        ' A R E A S  O F  2-  A N D  3-  D  E L E M E N T S',     
     2        ///10X,7HELEMENT,8X,3HEID,8X,6HVOLUME,7X,4HMASS,1X,       
     3        6(3X,7HSURFACE,I2), /10X, 29(4H----),/)        
      IF (VOLUME .LE. 0.0) WRITE (NOUT,110)        
      IF (SURFAC .LE. 0.0) WRITE (NOUT,120)        
      IF (VOLUME.LE.0.0 .OR. SURFAC.LE.0.0) LINE=LINE+2        
  110 FORMAT (10X,42H(NO MASS AND VOLUME COMPUTATION REQUESTED),/)      
  120 FORMAT (10X,39H(NO SURFACE AREA COMPUTATION REQUESTED),/)        
  130 L = 5        
C        
C     ENTRIES IN RX ARRAY, AS SAVED IN SCR4 BY KTRIQD,KTETRA,IHEXI,     
C     EMGPRO        
C        RX( 1),RX(2) = ELEMENT BCD NAME        
C        IX( 3) = ELEMENT ID        
C        RX( 4) = VOLUME (SOLID), OR THICKNESS (PLATE)        
C        RX( 5) = TOTAL MASS (SOLID), OR DENSITY (PLATE)        
C        IX( 6) = NO. OF GRID POINTS, = NGPT        
C        IX(7)...IX(6+NGPT) = SIL OF THE GRID POINTS        
C        RX( 7+NPGT) = CID OF 1ST GRID POINT        
C        RX( 8+NPGT) = X COORD. OF 1ST GRID POINT        
C        RX( 9+NPGT) = Y COORD. OF 1ST GRID POINT        
C        RX(10+NPGT) = Z COORD. OF 1ST GRID POINT        
C        IX(11+NPGT...) = REPEAT FOR OTHER GRID POINTS        
C        
C     CALL SFAREA TO COMPUTE AREAS, 6 VALUES ARE RETURNED IN RX(6...11) 
C     AND NO. OF SURFACES IN NGPT        
C     VOLUME AND MASS ARE ALSO COMPUTED FOR THE PLATE ELEMENTS.        
C        
      DO 140 I = 1,NGPT        
  140 SIL(I) = IX(6+I)        
      LN = NGPT        
      CALL SFAREA (LN,RX,IX(NGPT+7))        
      L = 5        
      IF (SURFAC .GT. 0.0) L = 5 + LN        
      IF (VOLUME .GT. 0.0) WRITE (NOUT,160) (IX(I),I=1,3),(RX(I),I=4,L) 
      IF (VOLUME .LE. 0.0) WRITE (NOUT,170) (IX(I),I=1,3),(RX(I),I=6,L) 
  160 FORMAT (10X,2A4,I10, 2X,8E12.4)        
  170 FORMAT (10X,2A4,I10,26X,6E12.4)        
      LINE = LINE + 1        
C        
      IF (NREC .EQ. 0) GO TO 190        
      NREC = NREC + 1        
      IX(5) = (LN*100) + NGPT        
      CALL WRITE (VAFILE,RX(1),L,0)        
      N4 = NGPT*4        
      N7 = N4 + 7        
      J  = 1        
      DO 180 I = 7,N7,4        
      IX(I) = SIL(J)        
  180 J = J + 1        
      CALL WRITE (VAFILE,RX(NGPT+7),N4,1)        
C        
C     A RECORD IS SAVED IN VAFILE FOR EACH ELEM., HAVING THE FOLLOWING  
C     DATA        
C        
C        WORDS  1,2 ELEMENT BCD NAME        
C                 3 ELEMENT ID, INTEGER        
C                 4 VOLUME (3-D ELEMS), ZERO (2-D ELEMS), REAL        
C                 5 (NO. OF SURFACES, N)*100 + NO. OF GRID PTS, INTEGER 
C                 6 AREA OF FIRST SURFACE, REAL        
C        7 THRU 5+N REPEAT FOR N SURFACES, REAL        
C             5+N+1 SIL OF FIRST GRID POINT, INTEGER        
C         5+N+2,3,4 X,Y,Z COORDINATES OF THE FIRST GRID POINT, REAL     
C               ... REPEAT LAST 4 WORDS FOR OTHER GRID POINTS, REAL     
C        
  190 IF (VOLUME .LE. 0.0) GO TO 70        
      IF (NGPT   .GT.   1) GO TO 200        
      TVOL2 = TVOL2 + RX(4)        
      TMAS2 = TMAS2 + RX(5)        
      GO TO 70        
  200 TVOL3 = TVOL3 + RX(4)        
      TMAS3 = TMAS3 + RX(5)        
      GO TO 70        
  210 CALL CLOSE (SCR4,CLSREW)        
      IF (NREC .EQ. 0) GO TO 230        
      CALL CLOSE (VAFILE,CLSREW)        
      MCB(2) = NREC        
      DO 220 I = 3,7        
  220 MCB(I) = 0        
      CALL WRTTRL (MCB(1))        
  230 IF (VOLUME .LE. 0.0) GO TO 330        
      IF (TVOL2  .GT. 0.0) WRITE (NOUT,240) TVOL2,TMAS2,D2        
      IF (TVOL3  .GT. 0.0) WRITE (NOUT,240) TVOL3,TMAS3,D3        
  240 FORMAT (/6X,24H* TOTAL VOLUME AND MASS=,2E12.4,3H  (,A4,        
     1        9HELEMENTS))        
      IF (NREC .LE. 0) GO TO 330        
C        
C     IF OUTPUT FILE REQUESTED BY USER IS AN INPI FILE, COPY FROM VAFILE
C     TO INPI, A FORTRAN WRITTEN BINARY FILE        
C        
      IF (INP .EQ. 0) GO TO 280        
      CALL OPEN (*360,VAFILE,Z(IBUF2),RDREW)        
  260 CALL READ (*280,*270,VAFILE,Z(1),IBUF2,1,J)        
      GO TO 370        
  270 WRITE (INP) (Z(I),I=1,J)        
      GO TO 260        
  280 CALL CLOSE (VAFILE,CLSREW)        
      CALL FNAME (207,Z(1))        
      WRITE  (NOUT,300) Z(1),Z(2),DATE        
  300 FORMAT ('0*** VOLUMES AND EXTERNAL SURFACE AREAS WERE SAVED IN ', 
     1        'OUTPUT FILE ',2A4,4H ON ,I2,1H/,I2,3H/19,I2)        
      IF (INP .EQ. 0) WRITE (NOUT,310)        
      IF (INP .NE. 0) WRITE (NOUT,320) INP        
  310 FORMAT (1H+,91X,21H(A GINO WRITTEN FILE))        
  320 FORMAT (1H+,91X,28H(A FORTRAN BINARY FILE, UNIT,I3,1H))        
  330 VOLUME = 0.0        
      SURFAC = 0.0        
      RETURN        
C        
  340 IF (VOLUME.NE.0. .OR. SURFAC.NE.0.) CALL CLOSE (SCR4,CLSREW)      
      GO TO 330        
  350 CALL MESAGE (-1,SCR4,SUB)        
  360 J = -1        
      GO TO 380        
  370 J = -8        
  380 CALL MESAGE (J,VAFILE,SUB)        
      RETURN        
      END        