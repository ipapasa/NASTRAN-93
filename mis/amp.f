      SUBROUTINE AMP        
C        
C     THIS IS THE DMAP DRIVER FOR AMP        
C        
C     DMAP CALLING SEQUENCE        
C        
C     AMP  AJJL,SKJ,D1JK,D2JK,GTKA,PHIDH,D1JE,D2JE,USETA,AERO/        
C          QHHL,QJHL/V,N,NOVE/V,N,XQHHL  $        
C        
C     D1JE AND D2JE MAY BE PURGED        
C        
C     QHHL AND QJHL ARE APPEND TYPE FILES        
C        
C     QJHL MAY BE PURGED        
C        
C     DATA BLOCK ASSIGNMENTS                           COMPUTED BY   USE
C        
C     SCR1   --OLD QHHL                                AMPA        A,D  
C     SCR2   --OLD QJHL                                AMPA        A,C  
C     SCR3   --INDEX OF WORK TO BE DONE                AMPA        A,MOD
C     SCR4   --DJH1                                    AMPB        B,C  
C     SCR5   --DJH2                                    AMPB        B,C  
C     SCR6   --GKI                                     AMPB        B,D  
C     SCR7   --DJH                                     AMPC        C,C  
C     SCR8   --QJHUA                                   AMPC        C,D  
C     SCR9   --SCRATCH FILE                                       B,C,D 
C     SCR10  --SCRATCH FILE                                       B,C,D 
C     SCR11  --SCRATCH FILE                                       B,C,D 
C     SCR12  --SCRATCH FILE                                       C     
C     SCR13  --SCRATCH FILE                                       C     
C     SCR14  --SCRATCH FILE                                       C     
C        
C     VARIABLES        
C     NAME          MEANING        
C     -------      ---------------        
C     NCOL          NUMBER OF COLUMNS IN SUBMATRIX OF AJJL        
C     NSUB          ACTUAL NUMBER OF SUBMATRICES ON AJJL        
C     XM            CURRENT M        
C     XK            CURRENT K        
C     AJJCOL        COLUMN NUMBER IN AJJL WHERE CURRENT SUBMATRIX STARTS
C     QHHCOL        COLUMN NUMBER IN QHH AND QJH WHERE SUBMATRIX STARTS 
C                        0 MEANS RECOMPUTE        
C     NGP           NUMBER OF GROUPS IN AJJL        
C     NGPD          PAIRS FOR EACH GROUP - 1--THEORY -1 =D.L.        
C                                          2--NUMBER OF COLUM        
C                                          2--NUMBER OF COLS IN GROUP   
C     NOH           NUMBER OF H D.O.F.        
C     IDJH          FLAG TO RECOMPUTE DJH IF K CHANGES        
C     IMAX          NUMBER OF M-K PAIRS        
C     IANY          FLAG TO INDICATE SOME CALCULATION MUST BE PERFORMED 
C     ITL           MAXIMUM TIME FOR ANY LOOP        
C     XKO           OLD VALUE OF K        
C        
C        
      INTEGER  AJJL,SKJ,D1JK,D2JK,GTKA,PHIDH,D1JE,D2JE,USETA,AERO,QHHL, 
     1  QJHL,      SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,     SCR8,SCR9,   
     2  SCR10,SCR11,SCR12,SCR13,SCR14,SYSBUF,XQHHL,AJJCOL,QHHCOL,       
     3  MCB(7),NAME(2)        
      INTEGER QHJL        
      COMMON /SYSTEM/SYSBUF,NOUT        
      COMMON /BLANK/NOUE,XQHHL,IGUST        
      COMMON /AMPCOM/NCOL,NSUB,XM,XK,AJJCOL,QHHCOL,NGP,NGPD(2,30),      
     1   MCBQHH(7),MCBQJH(7),NOH,IDJH        
     1  ,MCBRJH(7)        
      COMMON /CDCMPX/ISK(32),IB,IBBAR        
CZZ   COMMON /ZZAMB2/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      DATA  AJJL,SKJ,D1JK,D2JK,GTKA,PHIDH,D1JE,D2JE,USETA,AERO/        
     1      101 ,102 ,103 ,104 ,105 ,106 ,107 ,108 ,109 ,110 /        
      DATA  QHHL,QJHL,NAME /201,202,4HAMP ,1H /        
      DATA QHJL /203/        
      DATA  SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR8,SCR9,SCR10,SCR11,   
     1SCR12,SCR13,SCR14/301,302,303,304,305,306,307,308,309,310,311,312,
     2 313,314 /        
C        
C     INITIALIZE        
C        
      IBUF1 = KORSZ(IZ) -SYSBUF+1        
      MCB(1) = PHIDH        
      CALL RDTRL(MCB(1))        
      NOH=MCB(2)        
      MCBRJH(1)=QHJL        
      IB = 0        
      IBBAR = 0        
C        
C     BUILD INDEXES        
C        
      CALL AMPA(AERO,QJHL,QHHL,AJJL,SCR1,SCR2,SCR3,IMAX,IANY)        
C        
C     COMPUTE DJH AND GKI        
C        
C        
C     IF NO NEW VALUES ARE TO BE COMPUTED SKIP AMPB        
C        
      IF(IANY.NE.0)GO TO 90        
      CALL AMPB(PHIDH,GTKA,D1JK,D2JK,D1JE,D2JE,USETA,SCR4,SCR5,SCR6,    
     1 SCR9,SCR10,SCR11)        
   90 CONTINUE        
C        
C     LOOP ON MK PAIRS        
C        
      XKO=-1.0        
      IOP=0        
      ITL=0        
      DO 100 I = 1, IMAX        
      CALL KLOCK(ITS)        
      CALL GOPEN(SCR3,IZ(IBUF1),IOP)        
      IOP=2        
      CALL FREAD(SCR3,XM,4,1)        
      CALL CLOSE(SCR3,2)        
C        
C     COMPUTE QJH        
C        
      IDJH=0        
      IF(XK.EQ.XKO)IDJH=1        
      CALL AMPC(SCR4,SCR5,SCR7,AJJL,QJHL,SCR2,SCR8,SCR9,SCR10,SCR11,    
     1   SCR12,SCR13,SCR14)        
      IF(QHHCOL .EQ. 0) XKO = XK        
C        
C     COMPUTE QHH        
C        
      IF(MCBQHH(1).LE.0)GO TO 50        
      CALL AMPD(SCR8,SCR1,SKJ,SCR6,QHHL,SCR9,SCR10,SCR11,SCR12)        
   50 CONTINUE        
      IF(I.EQ.IMAX)GO TO 100        
C        
C     CHECK TIME        
C        
      CALL KLOCK(ITF)        
      CALL TMTOGO(ITMTO)        
      ITL=MAX0(ITF-ITS,1,ITL)        
      IF(1.1*ITL.GE.ITMTO)GO TO 200        
  100 CONTINUE        
C        
C     FINISH UP        
C        
  110 IF(MCBQHH(1).GT.0)CALL WRTTRL(MCBQHH)        
      IF(MCBQJH(1).GT.0)CALL WRTTRL(MCBQJH)        
      XQHHL=-1        
      IF(IGUST .LE. 0) RETURN        
C        
C     COMPUTE QHJL        
C          NOTE  QHJL IS REALLY QJHL        
C        
C     FIRST COMPUTE GKH ONTO SCR4        
C        
C        
      CALL AMPE(PHIDH,GTKA,SCR4,SCR5,SCR6,USETA)        
C        
C     LOOP ON GROUPS WITHIN MK PAIRS FOR QHJL        
C        
      CALL AMPF(SKJ,SCR4,AJJL,QHJL,SCR3,IMAX,SCR5,SCR6,SCR7,SCR8,SCR9,  
     1 SCR10,SCR11,SCR12,SCR13,SCR1)        
      RETURN        
C        
C     INSUFFICIENT TIME TO COMPLETE        
C        
  200 CALL MESAGE(45,IMAX-I,NAME)        
      GO TO 110        
      END        