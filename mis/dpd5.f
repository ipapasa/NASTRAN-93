      SUBROUTINE DPD5        
C        
C     DPD5 ASSEMBLEMS        
C     (1) THE EIGENVALUE EXTRACTION DATA BLOCK (EED), AND        
C     (2) THE TRANSFER FUNCTION LIST (TFL).        
C        
C     REVISED  9/1989, BY G.C./UNISYS        
C     NO COLUMN AND ROW WORD PACKING IN TFL FILE FOR MACHINES WITH 32   
C     BIT WORD SIZE, OR LESS        
C        
      EXTERNAL        ANDF  ,ORF   ,LSHIFT        
      LOGICAL         PACK        
      INTEGER         GPL   ,SIL   ,USET  ,USETD ,GPLD  ,SILD  ,DPOOL  ,
     1                DLT   ,FRL   ,TFL   ,TRL   ,PSDL  ,EED   ,SCR1   ,
     2                SCR2  ,SCR3  ,SCR4  ,BUF   ,BUF1  ,BUF2  ,BUF3   ,
     3                BUF4  ,FLAG  ,FILE  ,EPOINT,SEQEP ,Z     ,LOADS  ,
     4                ORF   ,DLOAD ,FREQ1 ,FREQ  ,TIC   ,TSTEP ,TF     ,
     5                PSD   ,EIGR  ,EIGB  ,EIGC  ,NGRID ,EQDYN ,SDT    ,
     6                UA    ,UD    ,EIGP  ,ANDF  ,TWO        
      INTEGER         IMSG(2)        
      DIMENSION       BUF(24)   ,EPOINT(2)    ,SEQEP(2)     ,MCB(7)    ,
     1                NAM(2)    ,LOADS(32)    ,DLOAD(2)     ,FREQ1(2)  ,
     2                FREQ(2)   ,ZZ(1)        ,BUFR(20)     ,NOLIN(21) ,
     3                TIC(2)    ,TSTEP(2)     ,TF(2)        ,PSD(2)    ,
     4                MSG(3)    ,EIGR(2)      ,EIGB(2)      ,EIGC(2)   ,
     5                EIGP(2)        
      COMMON /MACHIN/ MACH  ,IHALF ,JHALF        
      COMMON /BLANK / LUSET ,LUSETD,NOTFL ,NODLT ,NOPSDL,NOFRL ,NONLFT ,
     1                NOTRL ,NOEED ,NOSDT ,NOUE        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      COMMON /DPDCOM/ DPOOL ,GPL   ,SIL   ,USET  ,GPLD  ,SILD  ,USETD  ,
     1                DLT   ,FRL   ,NLFT  ,TFL   ,TRL   ,PSDL  ,EED    ,
     2                SCR1  ,SCR2  ,SCR3  ,SCR4  ,BUF   ,BUF1  ,BUF2   ,
     3                BUF3  ,BUF4  ,EPOINT,SEQEP ,L     ,KN    ,NEQDYN ,
     4                LOADS ,DLOAD ,FREQ1 ,FREQ  ,NOLIN ,NOGO  ,        
     5                MSG   ,TIC   ,TSTEP ,TF    ,PSD   ,EIGR  ,EIGB   ,
     6                EIGC  ,MCB   ,NAM   ,EQDYN ,SDT   ,INEQ        
      COMMON /BITPOS/ UM    ,UO    ,UR    ,USG   ,USB   ,UL    ,UA     ,
     1                UF    ,US    ,UN    ,UG    ,UE    ,UP    ,UNE    ,
     2                UFE   ,UD        
      COMMON /SETUP / IFILE(6)        
CZZ   COMMON /ZZDPDX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /TWO   / TWO(32)        
      COMMON /SYSTEM/ IBUF  ,NOUT        
      EQUIVALENCE     (Z(1) ,ZZ(1)), (BUF(1) ,BUFR(1)), (MSG(2),NGRID)  
      DATA    EIGP  / 257   ,4/        
C        
C     (1) PROCESS EDD        
C     ===============        
C        
C     OPEN EED AND WRITE HEADER.        
C     INITIALIZE TO LOOP THROUGH EIG CARDS.        
C        
C     OPEN DYNAMICS POOL.        
C        
      FILE = DPOOL        
      CALL PRELOC (*310,Z(BUF1),DPOOL)        
C        
      FILE = EED        
      CALL OPEN (*170,EED,Z(BUF2),WRTREW)        
      FILE = DPOOL        
      CALL FNAME (EED,BUF)        
      CALL WRITE (EED,BUF,2,1)        
      IN = 0        
      DO 20 J = 2,7        
   20 MCB(J) = 0        
      L = 12        
      MSG(1) = 75        
C        
C     LOCATE EIGB CARDS IN DYNAMICS POOL. IF PRESENT, TURN NOEED FLAG   
C     OFF, WRITE ID ON EED AND TURN ON TRAILER BIT.        
C        
      CALL LOCATE (*30,Z(BUF1),EIGB,FLAG)        
      NOEED = 1        
      CALL WRITE (EED,EIGB,2,0)        
      CALL WRITE (EED,0,1,0)        
      J = (EIGB(2)-1)/16        
      K =  EIGB(2) - 16*J        
      MCB(J+2) = ORF(MCB(J+2),TWO(K+16))        
      ASSIGN 23 TO NBACK        
      L = 12        
      MASK = TWO(UA)        
C        
C     READ EIGB CARDS. IF GRID NO. IS PRESENT, CONVERT TO SIL VALUE.    
C     WRITE DATA ON EED.        
C        
   22 CALL READ (*320,*24,DPOOL,BUF,18,0,FLAG)        
      GO TO 120        
   23 CALL WRITE (EED,BUF,12,0)        
      CALL WRITE (EED,BUF(14),6,0)        
      GO TO 22        
   24 CALL WRITE (EED,0,0,1)        
C        
C     LOCATE EIGC CARDS IN DYNAMICS POOL. IF PRESENT, TURN OFF NOEED    
C     FLAG, WRITE ID ON EED AND TURN ON TRL BIT.        
C        
   30 CALL LOCATE (*80,Z(BUF1),EIGC,FLAG)        
      NOEED = 1        
      CALL WRITE (EED,EIGC,2,0)        
      CALL WRITE (EED,0,1,0)        
      J = (EIGC(2)-1)/16        
      K =  EIGC(2) - 16*J        
      MCB(J+2) = ORF(MCB(J+2),TWO(K+16))        
      ASSIGN 50 TO NBACK        
      L = 6        
      MASK = TWO(UD)        
C        
C     READ EIGC CARDS. IF GRID NO. IS PRESENT, CONVERT TO SIL VALUE.    
C     WRITE DATA ON EED.        
C        
   40 CALL READ (*320,*70,DPOOL,BUF,10,0,FLAG)        
      GO TO 120        
   50 CALL WRITE (EED,BUF,7,0)        
      CALL WRITE (EED,BUF(8),3,0)        
   60 CALL READ  (*320,*320,DPOOL,BUF,7,0,FLAG)        
      CALL WRITE (EED,BUF,7,0)        
      IF (BUF(1) .NE. -1) GO TO 60        
      GO TO 40        
   70 CALL WRITE (EED,0,0,1)        
C        
C     LOCATE EIGP CARDS. IF PRESENT, TURN NOEED FLAG OFF,        
C     WRITE ID ON EED AND TURN ON TRAILER BIT. COPY DATA ON EED.        
C        
   80 CALL LOCATE (*89,Z(BUF1),EIGP,FLAG)        
      NOEED = 1        
      CALL WRITE (EED,EIGP,2,0)        
      CALL WRITE (EED,0,1,0)        
      J = (EIGP(2)-1)/16        
      K =  EIGP(2) - 16*J        
      MCB(J+2) = ORF(MCB(J+2),TWO(K+16))        
   81 CALL READ  (*320,*82,DPOOL,BUF,4,0,FLAG)        
      CALL WRITE (EED,BUF,4,0)        
      GO TO 81        
   82 CALL WRITE (EED,0,0,1)        
C        
C     LOCATE EIGR CARDS IN DYNAMICS POOL. IF PRESENT, TURN OFF NOEED    
C     FLAG, WRITE ID ON EED AND TURN ON TRL BIT.        
C        
   89 CALL LOCATE (*160,Z(BUF1),EIGR,FLAG)        
      NOEED = 1        
      CALL WRITE (EED,EIGR,2,0)        
      CALL WRITE (EED,0,1,0)        
      J = (EIGR(2)-1)/16        
      K =  EIGR(2) - 16*J        
      MCB(J+2) = ORF(MCB(J+2),TWO(K+16))        
      ASSIGN 100 TO NBACK        
      L = 12        
      MASK = TWO(UA)        
C        
C     READ EIGR CARDS. IF GRID NO. IS PRESENT, CONVERT TO SIL VALUE.    
C     WRITE DATA ON EED.        
C        
   90 CALL READ (*320,*110,DPOOL,BUF,18,0,FLAG)        
      GO TO 120        
  100 CALL WRITE (EED,BUF,12,0)        
      CALL WRITE (EED,BUF(14),6,0)        
      GO TO 90        
  110 CALL WRITE (EED,0,0,1)        
      GO TO 160        
C        
C     CODE TO CONVERT GRID NO. AND COMPOIENT CODE TO SIL NO.        
C     SIL NO. IS IN A SET FOR EIGR, EIGB - IN D SET FOR EIGC.        
C     WRITE DATA ON EED.        
C        
  120 IF (BUF(L) .EQ. 0) GO TO NBACK, (23,50,100)        
      IF (IN .NE. 0) GO TO 140        
      FILE = USETD        
      CALL OPEN (*310,USETD,Z(BUF3),RDREW)        
      CALL FWDREC (*320,USETD)        
      IUSETD = NEQDYN+2        
      CALL READ (*320,*130,USETD,Z(IUSETD),BUF3-IUSETD,1,N)        
      CALL MESAGE (-8,0,NAM)        
  130 CALL CLOSE (USETD,CLSREW)        
      IN = 1        
  140 IMSG(1) = BUF(1)        
      IMSG(2) = BUF(L)        
      CALL DPDAA        
      NUSETD = IUSETD + BUF(L) - 1        
      BUF(L) = 0        
      DO 150 J = IUSETD,NUSETD        
      IF (ANDF(Z(J),MASK) .NE. 0) BUF(L)= BUF(L) + 1        
  150 CONTINUE        
      IF (ANDF(Z(NUSETD),MASK) .NE. 0) GO TO NBACK, (23,50,100)        
      NOGO = 1        
      CALL MESAGE (30,107,IMSG)        
      GO TO NBACK, (23,50,100)        
C        
C     COMPLETE EIG CARD PROCESSING.        
C        
  160 CONTINUE        
      CALL CLOSE (EED,CLSREW)        
      MCB(1) = EED        
      CALL WRTTRL (MCB)        
C        
C        
C     (2) PRECESS TFL FILE        
C     ====================        
C        
C     SELECT PACK OR NO-PACK LOGIC        
C        
  170 PACK = .TRUE.        
      I45 = 4        
      I23 = 3        
      IF (IHALF .GT. 16) GO TO 175        
      PACK = .FALSE.        
      I45 = 5        
      I23 = 2        
  175 CONTINUE        
C        
C     OPEN TFL. WRITE HEADER. INITIALIZE TO READ TF CARDS.        
C        
      DO 180 J = 2,7        
  180 MCB(J) = 0        
      CALL LOCATE (*300,Z(BUF1),TF,FLAG)        
      NOTFL = 0        
      FILE  = TFL        
      CALL OPEN (*300,TFL,Z(BUF2),WRTREW)        
      CALL FNAME (TFL,BUF)        
      CALL WRITE (TFL,BUF,2,1)        
      MSG(1) = 68        
      L   = 2        
      ID  = 0        
      ITFL= NEQDYN + 2        
      I   = ITFL        
      ISW = 0        
      LAST= 0        
C        
C     READ FIXED SECTION OF TF CARD. CONVERT GRID POINT AND COMP. TO    
C     SIL NO. TEST FOR NEW TRANSFER FUNCTION SET.        
C        
  190 CALL READ (*320,*200,DPOOL,BUF,6,0,FLAG)        
      MSG(3) = BUF(1)        
      CALL DPDAA        
      IROW = BUF(2)        
      IF (BUF(1) .EQ. ID) GO TO 250        
      NOTFL = NOTFL + 1        
      IF (ID .NE. 0) GO TO 210        
      ID = BUF(1)        
      GO TO 250        
C        
C     SORT TRANSFER EQUATIONS AND WRITE ON TFL ONE RECORD PER TRANSFER  
C     FUNCTION SET. FIRST WORD OF RECORD IS SETID.        
C        
  200 LAST = 1        
  210 CALL WRITE (TFL,ID,1,0)        
      IF (ISW .EQ. 0) GO TO 220        
      CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (SCR1,CLSREW)        
      CALL OPEN  (*310,SCR1,Z(BUF2),RDREW)        
      IFILE(1) = SCR2        
      IFILE(2) = SCR3        
      IFILE(3) = SCR4        
      N = BUF3 - ITFL        
      IF (     PACK) CALL SORTI  (SCR1,TFL,4,1,Z(ITFL),N)        
      IF (.NOT.PACK) CALL SORTI2 (SCR1,TFL,5,1,Z(ITFL),N)        
      CALL CLOSE  (SCR1,CLSREW)        
      GO TO 230        
  220 N = I - ITFL        
      IF (     PACK) CALL SORTI  (0,0,4,1,Z(ITFL),N)        
      IF (.NOT.PACK) CALL SORTI2 (0,0,5,1,Z(ITFL),N)        
      CALL WRITE  (TFL,Z(ITFL),N,1)        
  230 I  = ITFL        
      ID = BUF(1)        
      ISW= 0        
      IF (LAST .NE. 0) GO TO 290        
      GO TO 250        
C        
C     READ GRID POINT, COMP AND VALUES. CONVERT POINT AND COMP. TO SIL  
C     NO. STORE IN CORE. IF SPILL, WRITE ON SCR1.        
C        
  240 CALL READ (*320,*310,DPOOL,BUF(2),5,0,FLAG)        
      IF (BUF(2) .EQ. -1) GO TO 190        
      CALL DPDAA        
C        
C     INTEGER PACKING LOGIC (MACHINES WITH 36 BITS WORDS, OR MORE) -    
C     PACK COLN AND ROW INTO ONE WORD IF BOTH CAN BE STORED IN HALF WORD
C     THEN FOLLOWED BY 3 COEFFICIENTS, TOTALLY 4 WORDS        
C        
C     NON-INTEGER PACKING LOGIC (MACHINES WITH 32 BITS WORDS) -        
C     THE COLUMN AND ROW ARE NOT PACKED, AND THEREFORE NOT BOUNED TO    
C     65536 SIZE LIMIT. 1ST WORD IS COLUMN, 2ND WORD IS ROW, THEN       
C     FOLLOWED BY 3 COEFFICIENTS, TOTALLY 5 WORDS        
C     THE SUBROUTINE SORTI2 IS USED WHEN SORTING TFL BY 2 KEY WORDS     
C        
  250 IF (.NOT.PACK) GO TO 252        
      IF (BUF(2).GE.JHALF .OR. IROW.GE.JHALF) GO TO 340        
      BUF(3) = LSHIFT(BUF(2),IHALF)        
      BUF(3) = ORF(BUF(3),IROW)        
      GO TO 255        
  252 BUF(3) = IROW        
  255 IF (ISW .NE. 0) GO TO 280        
      IF (I+I45 .GT. BUF3) GO TO 270        
      DO 260 J = I23,6        
      Z(I) = BUF(J)        
  260 I = I + 1        
      GO TO 240        
  270 ISW = 1        
      FILE= SCR1        
      CALL OPEN (*310,SCR1,Z(BUF3),WRTREW)        
      N = I - ITFL        
      CALL WRITE (SCR1,Z(ITFL),N,0)        
  280 CALL WRITE (SCR1,BUF(I23),I45,0)        
      GO TO 240        
C        
C     HERE WHEN ALL TRANSFER FUNCTION SETS COMPLETE.        
C     CLOSE FILE AND WRITE TRAILER.        
C        
  290 CALL CLOSE (TFL,CLSREW)        
      MCB(2) = NOTFL        
      MCB(1) = TFL        
      CALL WRTTRL (MCB)        
  300 CALL CLOSE  (DPOOL,CLSREW)        
      RETURN        
C        
C     FATAL ERRORS        
C        
  310 N = -1        
      GO TO 330        
  320 N = -2        
  330 CALL MESAGE (N,FILE,NAM)        
  340 WRITE  (NOUT,350) IHALF,BUF(2),IROW        
  350 FORMAT ('0*** COLUMN OR ROW SIL NO. EXCEEDS',I3,' BITS WORD ',    
     1        'PACKING LIMIT',2I9)        
      CALL MESAGE (-37,NAM,NAM)        
      RETURN        
      END        
