      SUBROUTINE CINVPR (EED,METHOD,NFOUND)        
C        
C     GIVEN REAL OR COMPLEX MATRICIES, CINVPR WILL SOLVE FOR ALL OF     
C     THE EIGENVALUES AND EIGENVECTORS WITHIN A SPECIFIED REGION        
C        
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS        
C        
C     FILEK(7) = MATRIX CONTROL BLOCK FOR THE INPUT STIFFNESS MATRIX K  
C     FILEM(7) = MATRIX CONTROL BLOCK FOR THE INPUT MASS MATRIX M       
C     FILEB(7) = MATRIX CONTROL BLOCK FOR THE INPUT DAMPING MATRIX B    
C     FILELM(7)= MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVALUES        
C     FILEVC(7)= MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVECTORS       
C     DMPFIL   = FILE CONTAINING THE EIGENVALUE SUMMARY        
C     SR1FIL-  = SCRATCH FILES USED INTERNALLY        
C     SR0FIL        
C     EPS      = CONVERGENCE CRITERIA        
C     NOREG    = NUMBER OF REGIONS INPUT        
C     REG(1,I) = X1 FOR REGION I        
C     REG(2,I) = Y1 FOR REGION I        
C     REG(3,I) = X2 FOR REGION I        
C     REG(4,I) = Y2 FOR REGION I        
C     REG(5,I) = L1 FOR REGION I        
C     REG(6,I) = NO. OF DESIRED  ROOTS FOR REGION I        
C     REG(7,I) = NO. OF ESTIMATED ROOTS IN REGION I        
C        
C        
      LOGICAL          NOLEFT        
      INTEGER          METHOD    ,EED      ,EIGC(2)  ,PHIDLI  ,        
     1                 SWITCH    ,SCRFIL   ,IHEAD(10),IREG(7,1)        
      INTEGER          NAME(2)   ,FILELM   ,FILEVC   ,        
     1                 REAL      ,RDP      ,TYPEK    ,TYPEM    ,        
     2                 TYPEB     ,COMFLG   ,IZ(1)    ,DMPFIL   ,        
     3                 TIMED     ,FILEK    ,T1       ,T2       ,        
     4                 FILEB     ,FILEM        
      REAL             L         ,L1       ,MAXMOD        
      DOUBLE PRECISION LAM1      ,DZ(1)    ,MINDIA        
      DOUBLE PRECISION LAMBDA    ,LMBDA    ,DTEMP(2)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /CDCMPX/  IDUM(30)  ,MINDIA        
      COMMON /CINVPX/  FILEK(7)  ,FILEM(7) ,FILEB(7) ,FILELM(7),        
     1                 FILEVC(7) ,DMPFIL   ,SCRFIL(11),NOREG   ,        
     2                 EPS       ,REG(7,10),PHIDLI        
      COMMON /NAMES /  RD        ,RDREW    ,WRT       ,WRTREW  ,        
     1                 REW       ,NOREW    ,EOFNRW    ,RSP     ,        
     1                 RDP        
      COMMON /SYSTEM/  KSYSTM(65)        
CZZ   COMMON /ZZCINV/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /OUTPUT/  HEAD(1)        
      COMMON /CINVXX/  LAMBDA(2) ,SWITCH   ,COMFLG    ,LMBDA(2),        
     1                 ITER      ,TIMED    ,NOCHNG    ,RZERO   ,        
     2                 IND       ,IVECT    ,KREG      ,REAL    ,        
     3                 LEFT      ,NORTHO   ,NOROOT    ,NZERO   ,        
     4                 LAM1(2)   ,MAXMOD   ,NODES     ,NOEST   ,        
     5                 ISTART    ,IND1     ,ITERX     ,ISYM        
      EQUIVALENCE      (KSYSTM(1),ISYS )   ,(IREG(1,1),REG(1,1))        
      EQUIVALENCE      (FILEK(5) ,TYPEK)   ,(FILEM(5),TYPEM)   ,        
     1                 (FILEB(5) ,TYPEB)   ,(IZ(1),Z(1))        
      EQUIVALENCE      (ANODES   ,NODES)   ,(ANOEST,NOEST)     ,        
     1                 (Z(1)     ,DZ(1))   ,(KSYSTM(2),NOUT )        
      DATA     IHEAD/  0,1009,2,7*0 /        
      DATA     EIGC /  207,2        /        
      DATA     NAME /  4HCINV,4HPR  /        
      DATA     SIGN /  1.0          /        
C        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
C     REAL     = 0 - ALL MATRICIES ARE REAL        
C                1 - AT LEAST ONE MATRIX IS COMPLEX        
C     NSHIFT   = NO. OF SHIFT POINTS IN A REGION        
C     NODES    = NO. OF DESIRED ROOTS IN A REGION        
C     NOEST    = NO. OF ESTIMATED ROOTS IN A REGION        
C     SHIFT    = INDEX OF THE CURRENT SHIFT POINT        
C     ISHIFT   = INDEX OF THE CURRENT SHIFT POINT        
C     IMIN     = LOWEST INDEX OF THE COMPLETED SHIFT POINTS        
C     IMAX     = HIGHEST INDEX OF COMPLETED SHIFT POINTS        
C        
C     FILE ALLOCATION        
C        
C     SR1FIL CONTAINS (LAMBDA**2*M + LAMBDA*B + K)        
C     SR2FIL CONTAINS -(B+LAMBDA*M)        
C     SR3FIL CONTAINS THE LOWER TRIANGLE OF THE DECOMPOSED DYNAMIC MTRX 
C     SR4FIL CONTAINS THE UPPER TRIANGLE OF THE DECOMPOSED DYNAMIC MTRX 
C     SR5FIL IS USED AS A SCRATCH FOR CDCOMP        
C     SR6FIL IS USED AS A SCRATCH FOR CDCOMP        
C     SR7FIL IS USED AS A SCRATCH FOR CDCOMP        
C     SR8FIL CONTAINS THE LOWER TRIANGLE L        
C     SR9FIL CONTAINS THE UPPER TRIANGLE U        
C     SR0FIL CONTAINS THE LEFT EIGENVECTORS        
C     S11FIL CONTAINS  -(B + LAMBDA*M)        
C        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
C     IND      = AN INDEX FOR GENERATING VARIOUS STARTING VECTORS       
C     ITER     = TOTAL NUMBER OF ITERATIONS        
C     NODCMP   = TOTAL NUMBER OF DECOMPOSITIONS        
C     NOSTRT   = NUMBER OF STARTING POINTS USED        
C     NOMOVS   = NUMBER OF TIMES A STARTING POINT HAD TO BE MOVED       
C     RZERO    = DISTANCE FROM THE STARTING POINT TO THE CORNER OF THE  
C                PARALELOGRAM        
C     NOCHNG   = COUNT OF THE NUMBER OF MOVES WHILE LOOKING FOR ONE ROO 
C     COMFLG   = 0 -        
C              = 1 -        
C              = 2 -        
C              = 3 -        
C              = 4 -        
C              = 5 -        
C              = 6 -        
C     SWITCH   =        
C     IVECT    =        
C     KREG     = 0-NO VECTORS FOUND IN SEARCH AREA YET        
C                1- A VECTOR HAS BEEN FOUND IN THE SEARCH AREA        
C     ISING    = SINGULARITY FLAG        
C     ITERM    = REASON FOR TERMINATING        
C              = 1 - 2SINGULARITIES IN A ROW        
C              = 2 - 4 MOVES WHILE TRACKING ONE ROOT        
C              = 3 - ALL REGIONS COMPLETED        
C              = 4 - 3*NOEST FOUND        
C              = 5 - ALL ROOTS FOUND        
C              = 8 - 200 ITERATIONS WITH ONE MOVE WITHOUR CONVERGING    
C     TIMED    = TIME TOO FORM AND DECOMPOSE THE DYNAMIC MATRIX        
C     LEFT     = 1 - DECOMPOSE MATRIX FOR THE COMPUTATION OF THE LEFT   
C                EIGENVECTORS        
C        
      CALL SSWTCH (12,IDIAG)        
      IND1 = 0        
      NZ   = KORSZ(Z)        
      CALL KLOCK (ISTART)        
      IBUF = NZ - ISYS - 2        
      IFILE= FILELM(1)        
      CALL OPEN  (*500,FILELM,Z(IBUF),WRTREW)        
      CALL CLOSE (FILELM,REW)        
      IFILE = FILEVC (1)        
      CALL OPEN  (*500,FILEVC,Z(IBUF),WRTREW)        
      CALL CLOSE (FILEVC,REW)        
      CALL GOPEN (DMPFIL,Z(IBUF),WRTREW)        
      CALL CLOSE (DMPFIL,EOFNRW)        
      IFILE = SCRFIL(10)        
      CALL OPEN (*500,IFILE,Z(IBUF),WRTREW)        
      CALL CLOSE (IFILE,REW)        
      NOLEFT = .FALSE.        
      IZ(1)  = 204        
      CALL RDTRL (IZ)        
      IF (IZ(1) .LT. 0) NOLEFT = .TRUE.        
      NORTHO = 0        
      NROW   = 2*FILEK(3)        
      NROW2  = 2*NROW        
      ISYM   = 1        
      IF (FILEK(1).NE.0 .AND. FILEK(4).NE.6) GO TO 2        
      IF (FILEM(1).NE.0 .AND. FILEM(4).NE.6) GO TO 2        
      IF (FILEB(1).NE.0 .AND. FILEB(4).NE.6) GO TO 2        
      ISYM = 0        
    2 CONTINUE        
C        
C     PICK UP REGION PARAMETERS        
C        
      CALL PRELOC (*500,Z(IBUF),EED)        
      CALL LOCATE (*500,Z(IBUF),EIGC(1),FLAG)        
    6 CALL FREAD (EED,IREG,10,0)        
      IF (METHOD.EQ.IREG(1,1) .OR. METHOD.EQ.-1) GO TO 8        
    7 CALL FREAD (EED,IREG,7,0)        
      IF (IREG(6,1) .NE. -1) GO TO 7        
      GO TO 6        
    8 JREG = 1        
      EPS  = .0001        
      IF (REG(1,2) .NE. 0.) EPS = REG(1,2)        
   11 CALL FREAD (EED,IREG(1,JREG),7,0)        
      IF (IREG(6,JREG) .EQ. -1) GO TO 9        
      JREG = JREG + 1        
      IF (JREG .GT. 10) GO TO 9        
      GO TO 11        
    9 CALL CLOSE (EED,REW)        
      NOREG = JREG - 1        
      JREG  = 0        
C        
C     PICK UP PARAMETERS FOR REGION I        
C        
    5 JREG   = JREG + 1        
      ITER   = 0        
      NODCMP = 0        
      NOSTRT = 0        
      NOMOVS = 0        
      X1     = REG(1,JREG)        
      Y1     = REG(2,JREG)        
      X2     = REG(3,JREG)        
      Y2     = REG(4,JREG)        
      L      = REG(5,JREG)        
      ANOEST = REG(6,JREG)        
      ANODES = REG(7,JREG)        
      IF (NODES.EQ. 0) NODES = 3*NOEST        
      NSHIFT = SQRT((X1-X2)**2+(Y1-Y2)**2)/L + 1.        
      L1     = L*.5        
      NOROOT = 0        
C        
C        
C     FIND SHIFT POINT CLOSEST TO THE ORIGIN        
C        
      R = SQRT((X1-X2)**2 + (Y1-Y2)**2)        
      IF (R) 10,10,15        
   10 WRITE  (NOUT,12) UFM        
   12 FORMAT (A23,' 2366, REGION IMPROPERLY DEFINED ON EIGC CARD.')     
      CALL MESAGE (-61,0,0)        
   15 CONTINUE        
      D = (FLOAT(NSHIFT)*L-R)/2.0        
      XX = X1 + D*(X1-X2)/R        
      X2 = X2 + D*(X2-X1)/R        
      X1 = XX        
      YY = Y1 + D*(Y1-Y2)/R        
      Y2 = Y2 + D*(Y2-Y1)/R        
      Y1 = YY        
      IF (IDIAG .EQ. 0) GO TO 7000        
      WRITE  (NOUT,1000) X1,Y1,X2,Y2,L1,NODES,NOEST,NSHIFT        
 1000 FORMAT (1H1,5F10.2,3I5)        
 7000 CONTINUE        
      DELTX = (X1-X2)/FLOAT(NSHIFT)        
      DELTY = (Y1-Y2)/FLOAT(NSHIFT)        
      XX    = X2 + DELTX/2.        
      YY    = Y2 + DELTY/2.        
      RANGE = XX**2  + YY**2        
      N     = NSHIFT - 1        
      SHIFT = 1.        
      IF (DELTX .NE. 0.) GO TO 20        
      ANUM1 = L1        
      ANUM2 = 0.        
      GO TO 25        
   20 SLOPE = DELTY/DELTX        
      ARG   = SQRT(1.+SLOPE**2)        
      ANUM1 = SLOPE*L1/ARG        
      ANUM2 = L1/ARG        
   25 CONTINUE        
      IF (N .EQ. 0) GO TO 40        
      DO 30 I = 1,N        
      XX    = XX + DELTX        
      YY    = YY + DELTY        
      RANG  = XX**2 + YY**2        
      IF (RANG .GE. RANGE) GO TO 40        
      RANGE = RANG        
   30 SHIFT = I + 1        
C        
C     COMPUTE COORDINATES OF CORNERS OF THE REGION        
C        
   40 XL2   = X2 + ANUM1        
      YL2   = Y2 - ANUM2        
      IMIN  = SHIFT        
      IMAX  = SHIFT        
C        
C     FIND THE MAXIMUM MODULUS OF THE SEARCH REGION        
C        
      MAXMOD = XL2**2 + YL2**2        
      XX     = X2 - ANUM1        
      YY     = Y2 + ANUM2        
      MAXMOD = AMAX1(MAXMOD,XX**2+YY**2)        
      XX     = X1 + ANUM1        
      YY     = Y1 - ANUM2        
      MAXMOD = AMAX1(MAXMOD,XX**2+YY**2)        
      XX     = X1 - ANUM1        
      YY     = Y1 + ANUM2        
      MAXMOD = AMAX1(MAXMOD,XX**2+YY**2)        
C        
C     INITIALIZE        
C        
      IND    = 0        
      LEFT   = 0        
   45 ISHIFT = SHIFT        
C        
C     EVALUATE THE VALUE OF LAMBDA IN THE CENTER OF THE CURRENT SEARCH  
C     REGION        
C        
      LAMBDA(1) = X2 + (SHIFT-.5)*DELTX        
      LAMBDA(2) = Y2 + (SHIFT-.5)*DELTY        
      IF (LAMBDA(2) .EQ. 0.0D0) LAMBDA(2) = .01*DELTY        
C        
C     COMPUTE DISTANCE TO FARTHEST CORNER OF THE SQUARE SEARCH REGION   
C        
      XX = XL2 + SHIFT*DELTX        
      YY = YL2 + SHIFT*DELTY        
      RZERO = (LAMBDA(1)-XX)**2 + (LAMBDA(2)-YY)**2        
      RZERO = SQRT(RZERO)*1.05        
      IF (IDIAG .EQ. 0) GO TO 7001        
      WRITE  (NOUT,1216)RZERO        
 1216 FORMAT (//,10H RZERO =     ,F10.4)        
 7001 CONTINUE        
      NOSTRT = NOSTRT + 1        
      COMFLG = 0        
   61 LMBDA(1) = LAMBDA(1)        
      LMBDA(2) = LAMBDA(2)        
      NOCHNG = 0        
      SWITCH = 0        
      IVECT  = 0        
      KREG   = 0        
      IND    = IND + 1        
      IF (IABS (IND) .EQ. 13) IND = 1        
      ISING  = 0        
      GO TO 100        
   80 ISING  = 0        
      SWITCH = 1        
  100 IF (NOCHNG .GE. 4) GO TO 220        
      NOCHNG = NOCHNG + 1        
      CALL KLOCK (T1)        
C        
C     CALL IN ADD LINK TO FORM (LAMBDA**2*M + LAMBDA*B + K)        
C        
      CALL CINVP1        
C        
C     CALL IN CD COMP TO DECOMPOSE THE MATRIX        
C        
      IF (IDIAG .EQ. 0) GO TO 7002        
      WRITE  (NOUT,1001) LAMBDA        
 1001 FORMAT (10H1LAMBDA =   ,2D15.5)        
 7002 CONTINUE        
      NODCMP = NODCMP + 1        
      CALL CINVP2 (*110)        
      CALL KLOCK (T2)        
      GO TO 120        
  110 IF (ISING .EQ. 1) GO TO 210        
C        
C     SINGULAR MATRIX. INCREMENT LAMBDA AND TRY ONCE MORE        
C        
      ISING = 1        
      LAMBDA(1) = LAMBDA(1) + .02*RZERO        
      LAMBDA(2) = LAMBDA(2) + .02*RZERO        
      GO TO 100        
C        
C     DETERMINE THE TIME REQUIRED TO FORM AND DECOMPOSE THE DYNAMIC     
C     MATRIX        
C        
  120 TIMED = T2 - T1        
      IF (TIMED .EQ. 0) TIMED = 1        
C        
C     CALL IN MAIN LINK TO ITERATE FOR EIGENVALUES        
C        
  121 CALL CINVP3        
      IF (LEFT   .EQ. 1) GO TO 130        
      IF (COMFLG .EQ. 2) GO TO 125        
      IF (COMFLG .EQ. 1) GO TO 80        
      GO TO 140        
  125 NOMOVS = NOMOVS + 1        
      GO TO 61        
C        
C     CALL IN LINK TO COMPUTE THE LEFT EIGENVECTOR        
C        
  130 DTEMP(1)  = LAMBDA(1)        
      DTEMP(2)  = LAMBDA(2)        
      LAMBDA(1) = LAM1(1)        
      LAMBDA(2) = LAM1(2)        
  131 SWITCH    = -1        
      CALL CINVP1        
C        
C     DECOMPOSE THE DYNAMIC MATRIX AT THE EIGENVALUE TO OBTAIN THE LEFT 
C     EIGENVECTOR BY THE DETERMINATE METHOD        
C        
      IF (IDIAG .EQ. 0) GO TO 132        
      WRITE (NOUT,1001) LAMBDA        
  132 CALL CINVP2 (*138)        
C        
C     BUILD LOAD FOR FBS        
C        
      D1 = NROW/2        
      D2 = NORTHO        
      DO 133 I = 1,NROW,2        
      K  = (I+1)/2        
      DZ(I) = SIGN*MINDIA/(1.D0+(1.D0-FLOAT(K)/D1)*D2)        
  133 DZ(I+1) = 0.0D0        
      SIGN = -SIGN        
      CALL CDIFBS (DZ(1),Z(IBUF))        
      LAMBDA(1) = DTEMP(1)        
      LAMBDA(2) = DTEMP(2)        
      SWITCH = 0        
C        
C     NORMALIZE AND STORE THE LEFT EIGENVECTOR        
C        
      CALL CNORM1 (DZ(1),FILEK(2))        
      IF (IDIAG .EQ. 0) GO TO 135        
      WRITE  (NOUT,134) (DZ(I),I=1,NROW)        
  134 FORMAT (///,15H LEFT VECTOR   ,//,(10D12.4))        
  135 CONTINUE        
      IF (NOLEFT .OR. ISYM.EQ.0) GO TO 136        
      IFILE = PHIDLI        
      CALL OPEN  (*500,IFILE,Z(IBUF),WRT)        
      CALL WRITE (IFILE,DZ(1),NROW2,1)        
      CALL CLOSE (IFILE,NOREW)        
  136 IFILE = SCRFIL(10)        
      CALL GOPEN (IFILE,Z(IBUF),RD)        
      CALL BCKREC (IFILE)        
      CALL FREAD (IFILE,DZ(NROW+2),NROW2,1)        
      CALL BCKREC (IFILE)        
      CALL CLOSE (IFILE,NOREW)        
C        
C     COMPUTE REAL LEFT VECTOR SCALED        
C        
      CALL CX TRN Y (DZ(1),DZ(NROW+2),DTEMP)        
      CALL CDIVID (DZ(1),DZ(1),DTEMP,NROW)        
      CALL OPEN (*500,IFILE,Z(IBUF),WRT)        
      CALL WRITE (IFILE,DZ(1),NROW2,1)        
      CALL CLOSE (IFILE,REW)        
      GO TO 121        
  138 LAMBDA(1) = 1.01*LAMBDA(1)        
      LAMBDA(2) = 1.01*LAMBDA(2)        
      GO TO 131        
  140 IF (COMFLG .GE. 3) GO TO 200        
      IF (COMFLG .EQ. 0) GO TO 160        
      IF (IDIAG  .EQ. 0) GO TO 150        
      WRITE  (NOUT,145) NOREG,JREG        
  145 FORMAT (2I10)        
  150 IF (NOREG .EQ. JREG) RETURN        
      GO TO 5        
C        
C     FIND NEXT SHIFT POINT WHICH IS CLOSEST TO THE ORIGIN        
C        
  160 IF (IMIN .NE. 1) GO TO 170        
      IF (IMAX .EQ. NSHIFT) GO TO 250        
  165 SHIFT = SHIFT + 1.        
      IMAX  = IMAX  + 1        
      LAMBDA(1) = LMBDA(1) + DELTX        
      LAMBDA(2) = LMBDA(2) + DELTY        
      GO TO 45        
  170 IF (IMAX .NE. NSHIFT) GO TO 180        
  175 SHIFT = SHIFT - 1.        
      IMIN  = IMIN  - 1        
      LAMBDA(1) = LMBDA(1) - DELTX        
      LAMBDA(2) = LMBDA(2) - DELTY        
      GO TO 45        
  180 XX   = LMBDA(1) - DELTX        
      YY   = LMBDA(2) - DELTY        
      RANG = XX**2 + YY**2        
      XX   = LMBDA(1) + DELTX        
      YY   = LMBDA(2) + DELTY        
      RANGE= XX**2 + YY**2        
      IF (RANGE-RANG) 175,175,165        
  200 ITERM = COMFLG        
      GO TO 260        
C        
C     SINGULARITY ENCOUNTERED TWICE IN A ROW        
C        
  210 ITERM = 1        
      GO TO 260        
C        
C     4 MOVES WHILE TRACKING ONE ROOT        
C        
  220 ITERM = 2        
      GO TO 260        
C        
C     REGIONS COMPLETED        
C        
  250 ITERM = 3        
C        
C     SET UP THE SUMMARY FILE        
C        
  260 IFILE = DMPFIL        
      CALL OPEN  (*500,DMPFIL,Z(IBUF),WRT)        
      CALL WRITE (DMPFIL,IHEAD(1),10,0)        
      I       = 0        
      IZ(I+2) = NORTHO        
      IZ(I+3) = NOSTRT        
      IZ(I+4) = NOMOVS        
      IZ(I+5) = NODCMP        
      IZ(I+6) = ITER        
      IZ(I+7) = ITERM        
      DO 270 I = 8,12        
 270  IZ(I) = 0        
      I = 2        
      CALL WRITE (DMPFIL,IZ(I),40,0)        
      CALL WRITE (DMPFIL,HEAD(1),96,1)        
      CALL WRITE (DMPFIL,IZ(1),0,1)        
      CALL CLOSE (DMPFIL,EOFNRW)        
C        
C     WRITE DUMMY TRAILER        
      IXX = FILEK(1)        
      FILEK(1) = DMPFIL        
      CALL WRTTRL (FILEK(1))        
      FILEK(1) = IXX        
      NFOUND = NORTHO        
      IF (IDIAG .EQ. 0) GO TO 350        
      J = 12        
      WRITE  (NOUT,300)(IZ(I),I=1,J)        
  300 FORMAT (///,12I10)        
  350 CONTINUE        
      IF (ITERM .EQ. 5) RETURN        
      GO TO 150        
C        
  500 CALL MESAGE (-1,IFILE,NAME)        
      RETURN        
      END        
