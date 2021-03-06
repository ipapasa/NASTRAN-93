      SUBROUTINE XFLORD        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO COMPUTE THE LTU (LAST TIME USED)
C     VALUE AND THE NTU (NEXT TIME USED) VALUE FOR THE INPUT AND OUTPUT 
C     FILE SECTIONS OF THE OSCAR ENTRIES.        
C        
C          ... DESCRIPTION OF PROGRAM VARIABLES ...        
C     LPTOP  = POINTER/SEQUENCE NUMBER OF FIRST ENTRY IN A DMAP LOOP.   
C     LPBOT  = LAST ENTRY IN A LOOP.        
C     IOPNT  = POINTER TO FILE NAME IN I/O SECTION OF OSCAR ENTRY.      
C     LPORD  = POINTER TO IORDNL TABLE ENTRY CORRESPONDING TO LPTOP.    
C     IORDNO = FILE ORDINAL NUMBER        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      DIMENSION       PTDIC(1),XNAM(12),ITMP(1),IORDNL(1800),ICPDPL(1), 
     1                OSCAR(2),OS(5)        
      COMMON /SYSTEM/ BUFSZ,OPTAPE,NOGO,DUM1(20),ICFIAT,DUM2(57),ICPFLG 
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
     3                NCHKPT,NPURGE,NEQUIV,        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XDPL  / DPL(3)        
      COMMON /XGPI5 / IAPP,START,ALTER(2),SOL,SUBSET,IFLAG,        
     1                IESTIM,ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)        
      COMMON /XGPI6 / MEDTP,DUM5(5),DIAG14        
      COMMON /XGPI7 / FPNT,LFILE,FILE(1)        
      COMMON /XGPI8 / ICPTOP,ICPBOT,LCPDPL        
      COMMON /XFIAT / IFIAT(3)        
      COMMON /XFIST / IFIST(1)        
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP,        
     1                ISAVE,ITAPE,IAPPND,INTGR,LOSGN,NOFLGS        
      COMMON /XOLDPT/ PTDTOP,PTDBOT,LPTDIC,NRLFL,SEQNO        
      COMMON /TWO   / TWO(4)        
      EQUIVALENCE     (CORE(1),LOSCAR  , OS(1)),        
     1                (OSPRC  ,OS(2)  ), (OSBOT   ,OS(3)),        
     2                (OSPNT  ,OS(4)  ), (OSCAR(1),OS(5),PTDIC(1)),     
     3                (DMAP(1),ITMP(1)), (OSCAR(1),ICPDPL(1)),        
     4                (LMPL   ,LORDNL ), (MPLPNT,IORBOT),        
     5                (DPL(1) ,NDPFIL ), (DPL(2),MAXDPL),        
     6                (DPL(3) ,LSTDPL ), (TWO(4),REUSE )        
      DATA    NORDN1/ 4HIORD/,  NORDN2/ 4HNL  /,        
     1        NXVPS / 4HXVPS/,  NCPDP1/ 4HICPD/, NCPDP2/4HPL  /,        
     2        XNAM  / 4HXTIM ,  4HE   , 4HXSAV , 4HE   ,        
     3                4HXUOP ,  4H    , 4HXCHK , 4H    ,        
     4                4HXPUR ,  4HGE  , 4HXEQU , 4HIV  /        
      DATA    NTHPAS/ 0     /,  DLYERR/ 0     /        
C        
      OR(I,J)  = ORF(I,J)        
      AND(I,J) = ANDF(I,J)        
      COMPL(L) = COMPLF(L)        
C        
C     USE AREA IN OPEN CORE BETWEEN PTDIC AND MED ARRAYS FOR STORING    
C     MISSING FILE DATA        
C        
      IFLAG  = 0        
      ICPTOP = PTDBOT + 3        
      ICPBOT = ICPTOP - 3        
      LCPDPL = MEDTP  - ICPTOP        
      IF (START .EQ. IMST) DLYERR = 1        
      IRENTR = AND(MASKHI,SEQNO)        
      IDMPCT = RSHIFT(SEQNO,16)        
C        
C     PREPARE FOR NTH PASS THRU OSCAR        
C     *******************************        
C        
   10 IF (NOGO .GT. 1) GO TO 960        
      OSPNT = 1        
      OSPRC = OSPNT        
      IORBOT= 0        
      IFEQ  = 0        
C        
C     INCREMENT NUMBER OF PASSES MADE THRU OSCAR        
C        
      NTHPAS = 1 + NTHPAS        
C        
C     ENTER DPL FILE NAMES IN IORDNL TABLE        
C        
      I = LSTDPL*3 + 1        
      IDPL = I        
      IF (LSTDPL .EQ. 0) GO TO 30        
      DO 20 K = 4,I,3        
      IORBOT = IORBOT + 4        
      IORDNL(IORBOT  ) = DPL(K  )        
      IORDNL(IORBOT+1) = DPL(K+1)        
      IORDNL(IORBOT+2) = 0        
   20 IORDNL(IORBOT+3) = 0        
C        
C     ENTER FIAT NAMES IN IORDNL TABLE        
C        
   30 I = IFIAT(3)*ICFIAT - 2        
      DO 40 K = 4,I,ICFIAT        
      IF (IFIAT(K+1) .EQ. 0) GO TO 40        
      IORBOT = IORBOT + 4        
      IFIAT(K) = OR(LSHIFT(IORBOT,16),AND(IFIAT(K),ORF(MASKHI,LOSGN)))  
      IORDNL(IORBOT  ) = IFIAT(K+1)        
      IORDNL(IORBOT+1) = IFIAT(K+2)        
      IORDNL(IORBOT+2) = 0        
      IORDNL(IORBOT+3) = 0        
   40 CONTINUE        
C        
C     FOR UNMODIFIED RESTART BEGIN OSCAR PROCESSING AT RE-ENTRY POINT IF
C     THIS IS FIRST PASS THRU OSCAR        
C        
      IF (NTHPAS .GT. 1) GO TO 60        
      IF (START.NE.IUNST . OR. IRENTR.EQ.0) GO TO 60        
      DO 50 J = 1,IRENTR        
      IF (OSCAR(OSPNT+1) .GE. IRENTR) GO TO 60        
      OSPRC = OSPNT        
      OSPNT = OSPNT + OSCAR(OSPNT)        
   50 CONTINUE        
C        
C     GET NEXT OSCAR ENTRY        
C     ********************        
C        
C     BRANCH ON OSCAR ENTRY TYPE IF EXECUTE FLAG IS UP        
C        
   60 IF (OSCAR(OSPNT+5) .GE. 0) GO TO 70        
      I = AND(OSCAR(OSPNT+2),MASKHI)        
      LSTBOT = IORBOT        
      GO TO (310,390,520,80), I        
C        
C     GET NEXT OSCAR ENTRY        
C        
   70 IF (OSPNT .GE. OSBOT) GO TO 650        
      IF (OSCAR(OSPNT+5).LT.0 .AND. AND(OSCAR(OSPNT+2),MASKHI).LE.2)    
     1    OSPRC = OSPNT        
      OSPNT = OSPNT + OSCAR(OSPNT)        
      GO TO 60        
C        
C     PROCESS TYPE E OSCAR ENTRY        
C     **************************        
C        
C     BRANCH ON NAME        
C        
   80 DO 90 I = 1,11,2        
      IF (OSCAR(OSPNT+3) .NE. XNAM(I)) GO TO 90        
      J = (I+1)/2        
      GO TO (70,70,100,100,70,190), J        
   90 CONTINUE        
C        
C     ENTRY IS XUOP OR XCHK - MAKE SURE FILES HAVE BEEN DEFINED OR      
C     PREPURGED.        
C        
  100 I1 = OSPNT + 7        
      I2 = OSCAR(OSPNT+6)*2 + I1 - 2        
      IOPNT = I1        
  110 IF (IORBOT .LE. 0) GO TO 130        
      DO 120 J = 4,IORBOT,4        
      IF (OSCAR(IOPNT).NE.IORDNL(J) .OR. OSCAR(IOPNT+1).NE.IORDNL(J+1)) 
     1    GO TO 120        
      IF (START.NE.IUNST .OR. J.GT.IDPL) GO TO 170        
      NNFIND = -1        
      CALL XFLDEF (OSCAR(IOPNT),OSCAR(IOPNT+1),NNFIND)        
      GO TO 170        
  120 CONTINUE        
C        
C     FILE NOT IN ORDNAL TABLE - SEE IF IT IS IN PREVIOUS PURGE OR      
C     EQUIV ENTRY        
C        
  130 K1 = 2        
      K1 = OSCAR(K1)        
      K2 = OSCAR(OSPNT+1) - 1        
      KK = 1        
      DO 160 K = K1,K2        
      IF (OSCAR(KK+3).NE.XNAM(9) .AND. OSCAR(KK+3).NE.XNAM(11))        
     1    GO TO 160        
C        
C     PURGE OR EQUIV ENTRY FOUND - SEARCH FOR FILE NAME MATCH        
C        
      L1 = KK + 7        
      L3 = KK + OSCAR(KK)        
C        
C     GET FIRST/NEXT FILE LIST        
C        
  140 L2 = OSCAR(L1-1)*2 + L1 - 2        
      INCRLP = 2        
      IF (OSCAR(KK+3) .NE. XNAM(11)) GO TO 145        
      L2 = L2 + 1        
      INCRLP = 3        
  145 CONTINUE        
      DO 150 L = L1,L2,INCRLP        
      IF (OSCAR(L).EQ.OSCAR(IOPNT) .AND. OSCAR(L+1).EQ.OSCAR(IOPNT+1))  
     1    GO TO 180        
      IF (L .EQ. L1+INCRLP) GO TO 153        
  150 CONTINUE        
      GO TO 159        
  153 L4 = L1 + INCRLP        
      INCRLP = 2        
      L4 = L4 + INCRLP        
      DO 155 L = L4,L2,INCRLP        
      IF (OSCAR(L).EQ.OSCAR(IOPNT) .AND. OSCAR(L+1).EQ.OSCAR(IOPNT+1))  
     1    GO TO 180        
  155 CONTINUE        
  159 L1 = L2 + 4        
      IF (L1 .LT. L3) GO TO 140        
  160 KK = OSCAR(KK) + KK        
C        
C     FILE IS NOT PURGED OR DEFINED - SEE IF IT IS ON PROBLEM TAPE      
C        
      NOFIND = -1        
      GO TO 450        
C        
C     FILE IS IN ORDNAL TABLE - ENTER RANGE        
C        
  170 IF (IORDNL(J+3)) 180,175,175        
  175 IORDNL(J+3) = LSHIFT(OSCAR(OSPNT+1),16)        
  180 IOPNT = IOPNT + 2        
      IF (IOPNT .LE. I2) GO TO 110        
      GO TO 70        
C        
C     PROCESS EQUIV INSTRUCTION        
C        
  190 L1 = OSPNT + 7        
      NWDH = OSCAR(OSPNT) - 6        
  230 NDATAB = OSCAR(L1-1)        
      IPRIME = 0        
      DO 195 KHR = 1,NDATAB        
C        
C     CHECK FOR DATA BLOCK IN IORDNL        
C        
      IF (IORBOT .LE. 0) GO TO 200        
      DO 205 I = 4,IORBOT,4        
      IF (IORDNL(I).NE.OSCAR(L1) .OR. IORDNL(I+1).NE.OSCAR(L1+1))       
     1    GO TO 205        
      IF (START.NE.IUNST .OR. I.GT.IDPL) GO TO 210        
      NNFIND = -1        
      CALL XFLDEF (OSCAR(L1),OSCAR(L1+1),NNFIND)        
      GO TO 210        
  205 CONTINUE        
C        
C     FILE NOT IN IORDNL, SEE IF ON PTDIC OR REGEN        
C        
  200 IF (START.EQ.ICST .OR. IPRIME.NE.0) GO TO 220        
      NOFIND = 1        
      CALL XFLDEF (OSCAR(L1),OSCAR(L1+1),NOFIND)        
      IF (NOFIND) 10,215,220        
  220 IF (DLYERR.NE.0 .OR. IPRIME.NE.0) GO TO 215        
C        
C     PRIMARY EQUIV FILE NOT DEFINED        
C        
      CALL XGPIDG (32,OSPNT,OSCAR(L1),OSCAR(L1+1))        
      GO TO 210        
C        
C     PUT FILE IN IORDNL, FLAG FOURTH WORD FOR EQUIV        
C        
  215 IORBOT = IORBOT + 4        
      IF (IORBOT - LORDNL) 225,780,780        
  225 IORDNL(IORBOT  ) = OSCAR(L1)        
      IORDNL(IORBOT+1) = OSCAR(L1+1)        
      IORDNL(IORBOT+2) = 0        
      IORDNL(IORBOT+3) = ISGNON        
  210 IF (IPRIME .NE. 0) GO TO 211        
      LSTUSE = AND(MASKHI,IORDNL(I+2))        
      IF (LSTUSE .EQ. 0) GO TO 212        
      NTU = OR(OSCAR(OSPNT+1),AND(IORDNL(I+2),ITAPE))        
      OSCAR(LSTUSE) = OR(AND(OSCAR(LSTUSE),MASKLO),NTU)        
  212 IORDNL(I+2) = OR(OSCAR(L1+2),AND(IORDNL(I+2),ITAPE))        
      IORDNL(I+3) = LSHIFT(OSCAR(OSPNT+1),16)        
      OSCAR(L1+2) = OR(AND(OSCAR(L1+2),MASKHI),LSHIFT(I,16))        
  211 L1 = L1 + 2        
      IF (IPRIME .EQ. 0) L1 = L1 + 1        
      IPRIME = 1        
  195 CONTINUE        
      NWDH = NWDH - 2*NDATAB - 3        
      IF (NWDH .LE. 0) GO TO 70        
      L1 = L1 + 2        
      GO TO 230        
C        
C     PROCESS TYPE F OSCAR ENTRY        
C     **************************        
C        
C     SCAN OSCAR OUTPUT FILE SECTION,ENTER NAMES IN IORDNL TABLE.       
C        
  310 K = OSPNT + 6        
      K = OSCAR(K)*3   + 2 + K        
      I = OSCAR(K-1)*3 - 3 + K        
      IOPNT = K        
      ASSIGN 380 TO IRTURN        
C        
C     GET FIRST/NEXT FILE NAME FROM OSCAR        
C        
  320 IF (OSCAR(IOPNT) .EQ. 0) GO TO 380        
C        
C     SEE IF FILE NAME IS ALREADY IN ORDNAL TABLE        
C        
      IF (IORBOT .LE. 0) GO TO 340        
      DO 330 K = 4,IORBOT,4        
      IF (IORDNL(K).NE.OSCAR(IOPNT) .OR. IORDNL(K+1).NE.OSCAR(IOPNT+1)) 
     1    GO TO 330        
      IF (START.NE.IUNST .OR. K.GT.IDPL) GO TO 345        
      NNFIND = -1        
      CALL XFLDEF (OSCAR(IOPNT),OSCAR(IOPNT+1),NNFIND)        
      GO TO 345        
  330 CONTINUE        
      GO TO 340        
  345 IF (IORDNL(K+3)) 346,820,820        
  346 KXT = K        
      GO TO 347        
C        
C     INCREMENT TO NEXT ORDNAL ENTRY AND ENTER FILE NAME AND LU POINTER.
C        
  340 IORBOT = IORBOT + 4        
      IF (IORBOT - LORDNL) 350,780,780        
  350 IORDNL(IORBOT  ) = OSCAR(IOPNT  )        
      IORDNL(IORBOT+1) = OSCAR(IOPNT+1)        
C        
C     SEE IF TAPE FLAG IS SET FOR THIS FILE        
C        
      KXT = IORBOT        
  347 LSTUSE = IOPNT + 2        
      IF (AND(OSCAR(OSPNT+2),MASKHI) .GT. 2) LSTUSE=0        
      IF (FPNT .LT. 1) GO TO 370        
      DO 360 K = 1,FPNT,3        
      IF (OSCAR(IOPNT).EQ.FILE(K) .AND. OSCAR(IOPNT+1).EQ.FILE(K+1))    
     1    LSTUSE = OR(LSTUSE,AND(FILE(K+2),ITAPE))        
  360 CONTINUE        
  370 IORDNL(KXT+2) = LSTUSE        
      IORDNL(KXT+3) = LSHIFT(OSCAR(OSPNT+1),16)        
C        
C     IORDNL POINTER  TO OSCAR IF TYPE F OR O FORMAT        
C        
      IF (AND(OSCAR(OSPNT+2),MASKHI) .LE. 2)        
     1    OSCAR(IOPNT+2) = OR(LSHIFT(KXT,16),AND(OSCAR(IOPNT+2),MASKHI))
      GO TO IRTURN, (380,510)        
C        
C     O/P FILE PROCESSED  -  INCREMENT TO NEXT O/P FILE        
C        
  380 IOPNT = IOPNT + 3        
      IF (IOPNT .LE. I) GO TO 320        
C        
C     OUTPUT SECTION SCANNED, NOW SCAN INPUT FILE SECTION OF OSCAR.     
C        
C     PROCESS TYPE F OR O OSCAR ENTRY        
C     *******************************        
C        
C     SCAN OSCAR INPUT FILE SECTION,ENTER RANGES IN IORDNL TABLE.       
C        
  390 K = OSPNT + 7        
      I = OSCAR(K-1)*3 -3 + K        
      IOPNT = K        
C        
C     GET FIRST/NEXT FILE NAME FROM OSCAR        
C        
  400 IF (OSCAR(IOPNT) .EQ. 0) GO TO 510        
      NOFIND = 1        
      ASSIGN 510 TO IRTURN        
C        
C     NOW SCAN IORDNAL TABLE FOR FILE NAME        
C        
      J1 = LSTBOT        
      IF (J1 .LE. 0) GO TO 440        
      DO 410 J = 4,J1,4        
      IF (OSCAR(IOPNT).NE.IORDNL(J) .OR. OSCAR(IOPNT+1).NE.IORDNL(J+1)) 
     1    GO TO 410        
      IF (START.NE.IUNST .OR. J.GT.IDPL) GO TO 420        
      NNFIND = -1        
      CALL XFLDEF (OSCAR(IOPNT),OSCAR(IOPNT+1),NNFIND)        
      GO TO 420        
  410 CONTINUE        
      GO TO 440        
C        
C     FOUND FILE IN IORDNL TABLE - ENTER NTU AND TAPE FLAG INTO        
C     OSCAR ENTRY POINTED TO BY IORDNL ENTRY        
C        
  420 LSTUSE = AND(MASKHI,IORDNL(J+2))        
      IF (LSTUSE .EQ. 0) GO TO 430        
      NTU = OR(OSCAR(OSPNT+1),AND(IORDNL(J+2),ITAPE))        
      OSCAR(LSTUSE) = OR(AND(OSCAR(LSTUSE),MASKLO),NTU)        
C        
C     SET RANGE AND LASTUSE POINTER IN IORDNAL ENTRY        
C        
  430 NOFIND = -1        
      IORDNL(J+2) = OR(IOPNT+2,AND(IORDNL(J+2),ITAPE))        
      IORDNL(J+3) = LSHIFT(OSCAR(OSPNT+1),16)        
C        
C     LINK OSCAR I/P FILE TO IORDNL ENTRY        
C        
      OSCAR(IOPNT+2) = OR(AND(OSCAR(IOPNT+2),MASKHI),LSHIFT(J,16))      
C        
C     I/P FILE PROCESSED - MAKE SURE IT WAS DEFINED        
C        
  440 IF (NOFIND) 510,450,450        
C        
C     I/P FILE NOT DEFINED        
C        
  450 IF (START .EQ. ICOLD) GO TO 470        
C        
C     RESTART - SEE IF FILE IS ON PROBLEM TAPE OR CAN BE REGENERATED    
C     BY RE-EXECUTING SOME MODULES.        
C        
      CALL XFLDEF (OSCAR(IOPNT),OSCAR(IOPNT+1),NOFIND)        
      IF (NOFIND) 10,500,470        
C        
C     ERROR - FILE NOT DEFINED(PUT OUT MESSAGE AT END OF XFLORD)        
C     SEE IF FILE IS ALREADY IN ICPDPL TABLE        
C        
  470 IF (DLYERR .NE.      0) GO TO 500        
      IF (ICPBOT .LT. ICPTOP) GO TO 490        
      DO 480 L = ICPTOP,ICPBOT,3        
      IF (OSCAR(IOPNT).EQ.ICPDPL(L) .AND. OSCAR(IOPNT+1).EQ.ICPDPL(L+1))
     1    GO TO 500        
  480 CONTINUE        
C        
C     ENTER FILE IN ICPDPL TABLE        
C        
  490 ICPBOT = ICPBOT + 3        
      IF (ICPBOT+3-ICPTOP .GT. LCPDPL) GO TO 830        
      ICPDPL(ICPBOT  ) = OSCAR(IOPNT  )        
      ICPDPL(ICPBOT+1) = OSCAR(IOPNT+1)        
      ICPDPL(ICPBOT+2) = -OSPNT        
C        
C     ENTER FILE IN ORDNAL TABLE IF NOT CHKPNT MODULE        
C        
  500 IF (OSCAR(OSPNT+3) .NE. XNAM(7)) GO TO 340        
      GO TO 180        
C        
C     CHECK FOR ANOTHER I/P FILE        
C        
  510 IOPNT = IOPNT + 3        
      IF (IOPNT .LE. I) GO TO 400        
C        
C     INPUT FILE SECTION SCANNED,GET NEXT OSCAR ENTRY.        
C        
      GO TO 70        
C        
C     PROCESS TYPE C OSCAR ENTRY        
C     **************************        
C        
C     CHECK FOR LOOPING        
C        
  520 LPTOP = RSHIFT(OSCAR(OSPNT+6),16)        
      IF ((NEXIT.EQ.OSCAR(OSPNT+3)) .OR. (OSCAR(OSPNT+1).LT.LPTOP))     
     1     GO TO 70        
C        
C     FIND BEGINNING OF LOOP AND ADJUST IORDNL RANGES INSIDE LOOP.      
C        
      LPBOT = OSPNT        
      I     = OSCAR(OSPNT+1)        
      OSPNT = 1        
      J1    = OSCAR(OSPNT+1)        
      DO 530 J = J1,I        
      IF (OSCAR(OSPNT+1) .EQ. LPTOP) GO TO 540        
  530 OSPNT = OSCAR(OSPNT) + OSPNT        
  540 LPTOP = OSPNT        
C        
C     LOOP TOP FOUND - IF UNMODIFIED RESTART,EXECUTE ALL MODULES INSIDE 
C     LOOP.        
C        
      IF (OSCAR(LPTOP+5).LT.0 .OR. START.NE.IUNST) GO TO 570        
C        
C     MAKE SURE FIRST INSTRUCTION IN LOOP IS NOT CHKPNT        
C        
      IF (OSCAR(LPTOP+3).EQ.XNAM(7) .AND. OSCAR(LPTOP+4).EQ.XNAM(8))    
     1    GO TO 790        
C        
C     EXECUTE FLAGS NOT ALL SET - SET FLAGS AND BEGIN OSCAR SCAN AGAIN  
C        
  550 J1 = OSCAR(LPTOP+1)        
      DO 560 J = J1,I        
      IF (OSCAR(OSPNT+3).EQ.XNAM(7) .AND. OSCAR(OSPNT+4).EQ.XNAM(8)     
     1   .AND. ICPFLG.EQ.0) GO TO 560        
      IF (OSCAR(OSPNT+5) .LT. 0) GO TO 560        
      IF (IFLAG .EQ. 1) GO TO 5510        
      IFLAG = 1        
      CALL PAGE1        
      CALL XGPIMW (11,IDMPCT,0,0)        
 5510 CALL XGPIMW (4,0,0,OSCAR(OSPNT))        
      OSCAR(OSPNT+5) = OR(ISGNON,OSCAR(OSPNT+5))        
  560 OSPNT = OSCAR(OSPNT) + OSPNT        
      GO TO 10        
C        
C     EXTEND RANGE OF FILES DEFINED OUTSIDE OF LOOP IF USED INSIDE LOOP 
C     GET FIRST/NEXT OSCAR ENTRY INSIDE LOOP        
C        
  570 OSPNT = LPTOP        
      J1 = OSCAR(LPTOP+1)        
      J2 = OSCAR(LPBOT+1)        
      DO 640 J = J1,J2        
      IF (AND(OSCAR(OSPNT+2),MASKHI) .GT. 2) GO TO 640        
C        
C     GET FIRST/NEXT I/P FILE OF OSCAR ENTRY        
C        
      K1 = OSPNT + 7        
      K2 = OSCAR(K1-1)*3 - 3 + K1        
      DO 630 K = K1,K2,3        
      IF (OSCAR(K) .EQ. 0) GO TO 630        
C        
C     SEE IF FILE SAVE IS ON        
C        
      IF (FPNT .LT. 1) GO TO 590        
      DO 580 L = 1,FPNT,3        
      IF (OSCAR(K).NE.FILE(L) .OR. OSCAR(K+1).NE.FILE(L+1)) GO TO 580   
      IF (AND(ISAVE,FILE(L+2)) .EQ. ISAVE) GO TO 620        
      GO TO 590        
  580 CONTINUE        
C        
C     FILE SAVE FLAG NOT ON - SEE IF I/P FILE IS GENERATED INSIDE LOOP  
C        
  590 L1 = OSCAR(OSPNT+1)        
C        
C     GET FIRST/NEXT OSCAR ENTRY INSIDE LOOP        
C        
      N = LPTOP        
      DO 610 L = J1,L1        
      IF (AND(OSCAR(N+2),MASKHI).NE.1 .OR. OSCAR(N+5).GE.0) GO TO 610   
C        
C     GET FIRST/NEXT O/P FILE        
C        
      M1 = OSCAR(N +6)*3 + N + 8        
      M2 = OSCAR(M1-1)*3 - 3 + M1        
      DO 600 M = M1,M2,3        
      IF (OSCAR(M) .EQ. 0) GO TO 600        
      IF (OSCAR(M).EQ.OSCAR(K) .AND. OSCAR(M+1).EQ.OSCAR(K+1))        
     1    GO TO 630        
  600 CONTINUE        
  610 N = OSCAR(N) + N        
C        
C     EXTEND I/P FILE RANGE TO END OF LOOP        
C        
  620 N = RSHIFT(OSCAR(K+2),16)        
      IORDNL(N+3) = LSHIFT(I,16)        
  630 CONTINUE        
      IF (START .NE. IUNST) GO TO 640        
C        
C     FOR UNMODIFIED RESTART, MARK ALL OUTPUT FILES WITHIN THE        
C     LOOP AND BEFORE THE RE-ENTRY POINT FOR REUSE        
C        
      KK1 = K1        
      IF (OSCAR(KK1-6) .GE. IRENTR) GO TO 640        
      IF (AND(OSCAR(KK1-5),MASKHI) .NE. 1) GO TO 640        
      K1 = K2 + 4        
      K2 = 3*OSCAR(K1-1) - 3 + K1        
      DO 635 K = K1,K2,3        
      IF (OSCAR(K) .EQ. 0) GO TO 635        
      NOFIND = -1        
      CALL XFLDEF (OSCAR(K),OSCAR(K+1),NOFIND)        
  635 CONTINUE        
  640 OSPNT = OSCAR(OSPNT) + OSPNT        
C        
C     LOOP SCANNED, GET NEXT OSCAR ENTRY AFTER LOOP ENTRIES        
C        
      OSPNT = LPBOT        
      GO TO 70        
C        
C     OSCAR HAS BEEN PROCESSED        
C     ************************        
C        
  650 IF (DLYERR .EQ. 0) GO TO 653        
      DLYERR = 0        
      GO TO 10        
C        
C     SET  NTU = LTU FOR LAST REFERENCE TO EACH FILE IN OSCAR.        
C        
  653 DO 660 I = 4,IORBOT,4        
      LSTUSE = AND(IORDNL(I+2),MASKHI)        
      IF (LSTUSE .EQ. 0) GO TO 660        
      NTU = OR(AND(ITAPE,IORDNL(I+2)),RSHIFT(IORDNL(I+3),16))        
      OSCAR(LSTUSE) = OR(NTU,AND(OSCAR(LSTUSE),MASKLO))        
  660 CONTINUE        
C        
C     SEARCH FILE TABLE FOR FILES WITH APPEND OR SAVE FLAG UP        
C        
      IF (FPNT .LT. 1) GO TO 690        
      DO 680 J = 1,FPNT,3        
      IF (AND(FILE(J+2),IAPPND).EQ.0 .AND. AND(FILE(J+2),ISAVE).EQ.0)   
     1    GO TO 680        
C        
C     FOR RESTART, MARK APPEND AND SAVE FILES FOR REUSE        
C        
      NOFIND = -1        
      CALL XFLDEF (FILE(J),FILE(J+1),NOFIND)        
      IF (AND(FILE(J+2),ISAVE) .NE. 0) GO TO 680        
C        
C     APPEND FLAG SET - FIND CORRESPONDING IORDNL ENTRY AND SET FLAG    
C        
      DO 670 I = 4,IORBOT,4        
      IF (IORDNL(I).EQ.FILE(J) .AND. IORDNL(I+1).EQ.FILE(J+1))        
     1    IORDNL(I+3) = OR(IAPPND,IORDNL(I+3))        
  670 CONTINUE        
  680 CONTINUE        
C        
C     STORE LTU IN OSCAR FILE ENTRIES        
C        
  690 OSPNT = 1        
  700 IF (OSCAR(OSPNT+5).GE.0 .OR. AND(OSCAR(OSPNT+2),MASKHI).GT.2)     
     1    GO TO 730        
      K = OSPNT + 7        
      J = 1        
      IF (AND(OSCAR(OSPNT+2),MASKHI) .EQ. 1) J = 2        
      DO 720 L = 1,J        
C        
      I = OSCAR(K-1)*3 - 3 + K        
      DO 710 IOPNT = K,I,3        
      IF (OSCAR(IOPNT) .EQ. 0) GO TO 710        
      J1  = RSHIFT(OSCAR(IOPNT+2),16)        
      LTU = AND(OSCAR(IOPNT+2),OR(LOSGN,MASKHI))        
      OSCAR(IOPNT+2) = OR(LTU,IORDNL(J1+3))        
  710 CONTINUE        
  720 K  = I + 4        
  730 IF (OSCAR(OSPNT+3) .NE. XNAM(11)) GO TO 735        
      I  = OSCAR(OSPNT) - 6        
      K  = OSPNT + 7        
  733 J1 = RSHIFT(OSCAR(K+2),16)        
      LTU= AND(OSCAR(K+2),OR(LOSGN,MASKHI))        
      OSCAR(K+2) = OR(LTU,IORDNL(J1+3))        
      I  = I - 2*OSCAR(K-1) - 3        
      IF (I .LE. 0) GO TO 735        
      K  = K + 2*OSCAR(K-1) + 3        
      GO TO 733        
  735 OSPNT = OSPNT + OSCAR(OSPNT)        
      IF (OSPNT - OSBOT) 700,700,740        
C        
C     STORE LTU IN FIAT ENTRIES        
C        
  740 I = IFIAT(3)*ICFIAT - 2        
      DO 770 K = 4,I,ICFIAT        
      IF (IFIAT(K+1) .EQ. 0) GO TO 770        
      J = RSHIFT(AND(IFIAT(K),MASKLO),16)        
C        
C     SEE IF FILE HAS BEEN REFERENCED        
C        
      IF (AND(IORDNL(J+3),COMPL(IAPPND)) .NE. 0) GO TO 760        
C        
C     FILE NOT USED - DROP IT FROM FIAT        
C        
      IFIAT(K) = AND(IFIAT(K),OR(MASKHI,LOSGN))        
      K1 = K + 1        
      K2 = K + ICFIAT - 3        
      DO 750 KK = K1,K2        
  750 IFIAT(KK) = 0        
      GO TO 770        
  760 LTU = AND(IFIAT(K),OR(OR(ISGNON,LOSGN),MASKHI))        
      IFIAT(K) = OR(LTU,IORDNL(J+3))        
  770 CONTINUE        
      GO TO 840        
C        
C     ERROR MESSAGES        
C     **************        
C        
C     IORDNL TABLE OVERFLOW        
C        
  780 CALL XGPIDG (14,NORDN1,NORDN2,AND(OSCAR(OSPNT+5),NOSGN))        
      GO TO 960        
C        
C     CHKPNT IS FIRST INSTRUCTION IN LOOP        
C        
  790 CALL XGPIDG (47,LPTOP,0,0)        
      OSCAR(LPTOP+5) = OR(OSCAR(LPTOP+5),ISGNON)        
      GO TO 550        
C        
C     FILE APPEARS MORE THAN ONCE AS OUTPUT        
C        
C     SUPPRESS MESSAGE ONCE IF FILE IS INITIALLY UNDEFINED        
C        
  820 IF (ICPBOT .LT. ICPTOP) GO TO 8220        
      DO 8210 II = ICPTOP,ICPBOT,3        
      IF (OSCAR(IOPNT).NE.ICPDPL(II) .OR. OSCAR(IOPNT+1).NE.ICPDPL(II+1)
     1   ) GO TO 8210        
      IF (ICPDPL(II+2) .GE. 0) GO TO 8220        
      ICPDPL(II+2) = -ICPDPL(II+2)        
      GO TO 346        
 8210 CONTINUE        
 8220 CALL XGPIDG (-45,OSPNT,OSCAR(IOPNT),OSCAR(IOPNT+1))        
      GO TO 346        
C        
C     ICPDPL TABLE OVERFLOW        
C        
  830 CALL XGPIDG (14,NCPDP1,NCPDP2,0)        
      GO TO 960        
C        
C     CHECK ICPDPL TABLE FOR UNDEFINED FILES        
C        
  840 IF (ICPBOT .LT. ICPTOP) GO TO 860        
      DO 850 I = ICPTOP,ICPBOT,3        
      CALL XGPIDG (-22,IABS(ICPDPL(I+2)),ICPDPL(I),ICPDPL(I+1))        
  850 CONTINUE        
C        
C     IF DIAG 14 IS NOT ON, AND THERE ARE UNDEFINED FILES FROM USER'S   
C     ALTER (DIAG14 IS SET TO 10 BY XGPI AT THIS TIME), SET DIAG14 TO 11
C     TO FLAG XGPI TO PRINT THE DMAP COMPILE LISTING.        
C        
C     IF DIAG 14 IS ON, THE DMAP LISTING IS ALREADY PRINTTED BY XSCNDM, 
C     SHICH IS CALLED BY XOSGEN. XOSGEN IS CALLED BY XGPI BEFORE THIS   
C     XFLORD IS CALLED (ALSO BY XGPI)        
C        
      IF (DIAG14 .EQ.  10) DIAG14 = 11        
      IF (START .NE. ICST) GO TO 865        
      GO TO 960        
C        
C     NO UNDEFINED FILES - CHECK FOR RESTART        
C        
  860 IF (START .EQ. ICST) GO TO 960        
C        
C     RESTART - USE LAST XVPS ENTRY IN PTDIC FOR RESTART.        
C     EXCLUDE FIRST NXVPS ENTRY        
C        
  865 PTDTOP = PTDTOP + 3        
      NOFIND = -1        
      CALL XFLDEF (NXVPS,NBLANK,NOFIND)        
      PTDTOP = PTDTOP - 3        
C        
C     OVERLAY PTDIC TABLE WITH ICPDPL TABLE        
C        
      ICPTOP = PTDTOP        
      ICPBOT = ICPTOP - 3        
      LCPDPL = LPTDIC        
C        
C     SCAN PTDIC FOR REUSE FLAGS        
C        
      DO 870 J = PTDTOP,PTDBOT,3        
      IF (AND(PTDIC(J+2),REUSE) .EQ. 0) GO TO 870        
C        
C     REUSE FLAG UP - ENTER FILE IN ICPDPL        
C        
      ICPBOT = ICPBOT + 3        
      ICPDPL(ICPBOT  ) = PTDIC(J  )        
      ICPDPL(ICPBOT+1) = PTDIC(J+1)        
      ICPDPL(ICPBOT+2) = PTDIC(J+2)        
  870 CONTINUE        
C        
C     ORDER FILES IN ICPDPL BY REEL/FILE NUMBER        
C        
      IF (ICPBOT .LT. ICPTOP) GO TO 960        
C        
C     DO NOT DISTURB EXISTING ORDER        
C        
      IF (ICPBOT .EQ. ICPTOP) GO TO 900        
      K = ICPTOP        
  881 L = K        
  882 IF (AND(ICPDPL(K+2),NOFLGS) .LE. AND(ICPDPL(K+5),NOFLGS))        
     1    GO TO 890        
C        
C     SWITCH        
C        
      DO 891 M = 1,3        
      J = K + M + 2        
      ITMP(1) = ICPDPL(J)        
      ICPDPL(J) = ICPDPL(J-3)        
      ICPDPL(J-3) = ITMP(1)        
  891 CONTINUE        
      K = K - 3        
      IF (K .GE. ICPTOP) GO TO 882        
  890 K = L + 3        
      IF (K .LT. ICPBOT) GO TO 881        
  900 CONTINUE        
C        
C     ENTER PURGED FILE IN FIAT IF THERE IS NO POSSIBLE WAY TO GENERATE 
C     FILE        
C        
      J1 = 2        
      J1 = OSCAR(J1)        
      J2 = OSCAR(OSBOT+1)        
      DO 950 I = ICPTOP,ICPBOT,3        
      IF (AND(ICPDPL(I+2),MASKHI) .NE. 0) GO TO 960        
      OSPNT = 1        
      DO 940 J = J1,J2        
      IF (AND(MASKHI,OSCAR(OSPNT+2)).GT.2 .OR. OSCAR(OSPNT+5).GE.0)     
     1    GO TO 940        
C        
C     SEE IF PURGED FILE IS IN I/P SECTION        
C        
      K1 = OSPNT + 7        
      K2 = OSCAR(K1-1)*3 - 3 + K1        
      DO 910 K = K1,K2,3        
      IF (OSCAR(K).EQ.ICPDPL(I) .AND. OSCAR(K+1).EQ.ICPDPL(I+1))        
     1    GO TO 930        
  910 CONTINUE        
C        
C     PURGED FILE IS NOT IN I/P SECTION - SEARCH O/P SECTION FOR IT.    
C        
      IF (AND(MASKHI,OSCAR(OSPNT+2)) .NE. 1) GO TO 940        
      K1 = OSCAR(OSPNT+6)*3  + OSPNT + 8        
      K2 = OSCAR(K1-1)*3 - 3 + K1        
      DO 920 K = K1,K2,3        
      IF (OSCAR(K).EQ.ICPDPL(I) .AND. OSCAR(K+1).EQ.ICPDPL(I+1))        
     1    GO TO 950        
  920 CONTINUE        
      GO TO 940        
C        
C     PURGED FILE FIRST USED AS INPUT - THEREFORE IT CANNOT BE GENERATED
C     ENTER PURGED FILE IN FIAT        
C        
  930 L = IFIAT(3)*ICFIAT + 4        
      IFIAT(3  ) = IFIAT(3) + 1        
      IFIAT(L  ) = OR(MASKHI,OSCAR(K+2))        
      IFIAT(L+1) = OSCAR(K  )        
      IFIAT(L+2) = OSCAR(K+1)        
      GO TO 950        
  940 OSPNT = OSCAR(OSPNT) + OSPNT        
  950 CONTINUE        
  960 RETURN        
      END        
