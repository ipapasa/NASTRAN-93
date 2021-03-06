      SUBROUTINE TA1A        
C        
C     TA1A BUILDS THE ELEMENT SUMMARY TABLE (EST).        
C     THE EST GROUPS ECT, EPT, BGPDT AND ELEMENT TEMP. DATA FOR EACH    
C     SIMPLE ELEMENT OF THE STRUCTURE. THE EST CONTAINS ONE LOGICAL     
C     RECORD PER SIMPLE ELEMENT TYPE.        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         EORFLG,ENDID ,RECORD,FRSTIM,Q4T3        
      INTEGER         ZEROS(4)     ,BUF(50)      ,NAM(2),GPSAV(34)    , 
     1                PCOMP(2)     ,PCOMP1(2)    ,PCOMP2(2)           , 
     2                IPSHEL(16)        
      REAL            DEFTMP,TLAM  ,ZOFFS ,ZZ(1) ,BUFR(50)            , 
     1                TGRID(33)    ,RPSHEL(16)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM        
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS        
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  , 
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /GPTA1 / NELEM ,LAST  ,INCR  ,ELEM(1)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS        
      COMMON /TA1ETT/ ELTYPE,OLDEL ,EORFLG,ENDID ,BUFFLG,ITEMP ,IDFTMP, 
     1                IBACK ,RECORD,OLDEID        
      COMMON /TA1ACM/ IG(90)        
      COMMON /TWO   / KTWO(32)        
CZZ   COMMON /ZZTAA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF ) , (KSYSTM( 2),NOUT ) ,       
     1                (KSYSTM(10),TEMPID ) , (KSYSTM(56),IHEAT) ,       
     2                (IDFTMP    ,DEFTMP ) , (BUFR(1)   ,BUF(1)),       
     3                (Z(1)      ,ZZ(1)  ) , (IPSHEL( 1),RPSHEL(1))     
      DATA    NAM   / 4HTA1A,4H    /        
      DATA    ZEROS / 4*0   /        
      DATA    BAR   / 34    /        
      DATA    HBDY  / 52    /        
      DATA    QDMEM2/ 63    /        
      DATA    QUAD4 / 64    /        
      DATA    TRIA3 / 83    /        
      DATA    PCOMP / 5502, 55 /        
      DATA    PCOMP1/ 5602, 56 /        
      DATA    PCOMP2/ 5702, 57 /        
      DATA    SYM   / 1     /        
      DATA    MEM   / 2     /        
      DATA    SYMMEM/ 3     /        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      IF (NELEM .GT. 90) GO TO 1190        
      BUF1  = KORSZ(Z) - SYSBUF - 2        
      BUF2  = BUF1 - SYSBUF - 3        
      BUF3  = BUF2 - SYSBUF        
      FRSTIM= .TRUE.        
      LSTPRP= 0        
      KSCALR= 0        
      ITABL = 0        
      NOSIMP=-1        
      NOGOX = 0        
      NOGO  = 0        
      M8    =-8        
      COMPS = 1        
      NOPSHL=-1        
      NPSHEL= 0        
      OLDID = 0        
      CALL SSWTCH (40,L40)        
C        
C     READ THE ELEMENT CONNECTION TABLE.        
C     IF PROPERTY DATA IS DEFINED FOR THE ELEMENT, READ THE EPT INTO    
C     CORE AND SORT IF REQUIRED. THEN FOR EACH ECT ENTRY, LOOK UP AND   
C     ATTACH THE PROPERTY DATA. WRITE ECT+EPT ON SCR1.        
C     IF PROPERTY DATA NOT DEFINED FOR ELEMENT, COPY ECT DATA ON SCR1.  
C     IF NO SIMPLE ELEMENTS IN ECT, RETURN.        
C        
C     FOR THE PLATE AND SHELL ELEMENTS REFERENCING PCOMP, PCOMP1 OR     
C     PCOMP2 BULK DATA ENTRIES, PROPERTY DATA IN THE FORM OF PSHELL     
C     BULK DATA ENTRY IS CALLED AND WRITTEN TO SCR1        
C        
      FILE = ECT        
      CALL OPEN (*540,ECT,Z(BUF1),RDREW)        
      CALL SKPREC (ECT,1)        
      FILE = SCR1        
      CALL OPEN (*1100,SCR1,Z(BUF3),WRTREW)        
      BUF(1) = EPT        
      CALL RDTRL(BUF)        
      NOEPT = BUF(1)        
      IF (BUF(1) .LT. 0) GO TO 10        
      CALL PRELOC (*10,Z(BUF2),EPT)        
C        
C     LOCATE, ONE AT A TIME, SIMPLE ELEMENT TYPE IN ECT. IF PRESENT,    
C     WRITE POINTER ON  SCR1. SET POINTERS AND, IF DEFINED, LOCATE AND  
C     READ ALL PROPERTY DATA FROM EPT.        
C        
   10 CALL ECTLOC (*200,ECT,BUF,I)        
      ID = -1        
      ELTYPE = ELEM(I+2)        
      CALL WRITE (SCR1,I,1,0)        
      Q4T3 = .FALSE.        
      IF (ELTYPE.EQ.QUAD4 .OR. ELTYPE.EQ.TRIA3) Q4T3 = .TRUE.        
      IF (ELEM(I+10) .EQ. 0) KSCALR = 1        
      M  = ELEM(I+5)        
      MM = ELEM(I+8)        
      IF (MM .EQ. 0) GO TO 120        
      MX = MM        
      NOPROP = 0        
      IF (ELEM(I+6) .NE. LSTPRP) GO TO 20        
      IF (ELTYPE    .EQ. QDMEM2) NOPROP = 1        
      GO TO 80        
   20 IF (NOEPT .LT. 0) GO TO 1130        
C        
C     LOCATE PROPERTY CARD        
C        
      LL = 0        
      CALL LOCATE (*50,Z(BUF2),ELEM(I+6),FLAG)        
      NOPROP = 1        
   30 LSTPRP = ELEM(I+6)        
   40 IF (LL+MM .GE. BUF3) CALL MESAGE (-8,0,NAM)        
      IF (NOPROP .EQ. 0) GO TO 80        
      CALL READ (*1110,*55,EPT,Z(LL+1),MM,0,FLAG)        
      LL = LL + MM        
      GO TO 40        
C        
C     CHECK FOR QUAD4 AND TRIA3 ELEMENTS WITH ONLY PCOMP CARDS        
C        
C     SET POINTER FOR NO PSHELL DATA, AND        
C     READ PCOMP, PCOMP1 AND PCOMP2 DATA INTO CORE        
C        
   50 IF (.NOT.Q4T3) GO TO 60        
      NOPSHL = 1        
      GO TO 700        
C        
C     CHECK FOR QUAD4 AND TRIA3 ELEMENTS WITH BOTH PCOMP AND PSHELL     
C     CARDS        
C        
C     IF LL.GT.0 HERE, PSHELL DATA IS PRESENT,        
C     NEED TO CHECK THE PRESENCE OF PCOMP DATA, AND RESET NOPSHL POINTER
C     IF NECCESSARY        
C        
C     EVENTUALLY, WE WILL HAVE        
C        
C     NOPSHL =-1, LOGIC ERROR FOR QUAD4/TRIA3 PROPERTY DATA        
C            = 0, ONLY PSHELL DATA PRESENT        
C            = 1, ONLY PCOMP TYPE DATA PRESENT        
C            = 2, BOTH PSHELL AND PCOMP DATA PRESENT (SEE STA.760)      
C        
   55 IF (.NOT.Q4T3) GO TO 70        
      IF (LL .LE. 0) GO TO 700        
      NOPSHL = 0        
      GO TO 70        
C        
   60 IF (NOPROP .EQ. 0) GO TO 1130        
C        
C     Z(1) THRU Z(LL) CONTAIN PROPERTY DATA        
C        
   70 IF (MM .LE. 4) CALL SORT (0,0,MM,1,Z(1),LL)        
      KN = LL/MM        
      IF (NOPSHL .EQ. 0) GO TO 700        
C        
C     READ ECT DATA FOR ELEMENT. LOOK UP PROPERTY DATA IF CURRENT ELEM. 
C     HAS A PROPERTY ID DIFFERNENT FROM THAT OF THE PREVIOUS ELEMENT.   
C     WRITE ECT + EPT (OR NEW GENERATED PSHELL) DATA ON SCR1.        
C        
   80 CALL READ (*1110,*140,ECT,BUF,M,0,FLAG)        
      NOSIMP = NOSIMP + 1        
      IF (BUF(2) .NE. ID) NOPROP = 1        
      ID = BUF(2)        
      BUF(2) = BUF(1)        
      BUF(1) = M + MM - 2        
      IF (NOPROP .EQ. 0) GO TO 90        
      IF (Q4T3 .AND. NOPSHL.EQ.1) GO TO 800        
      NPSHEL = 0        
      GO TO 600        
   90 CALL WRITE (SCR1,BUF(1),M,0)        
      IF (.NOT.Q4T3) GO TO 100        
      IF (NPSHEL .EQ. 1) GO TO 110        
  100 CALL WRITE (SCR1,Z(KX+2),MM-1,0)        
      NPSHEL = 0        
      NOPROP = 0        
      GO TO 80        
  110 CALL WRITE (SCR1,IPSHEL(1),MM-1,0)        
      NOPROP = 0        
      GO TO 80        
C        
C     EPT DATA NOT DEFINED FOR ELEMENT. COPY ECT DATA ON SCR1.        
C        
  120 BUF(1) = M        
      M1 = M + 1        
  130 CALL READ  (*1110,*140,ECT,BUF(2),M,0,FLAG)        
      CALL WRITE (SCR1,BUF(1),M1,0)        
      NOSIMP = NOSIMP + 1        
      GO TO 130        
  140 CALL WRITE (SCR1,0,0,1)        
      GO TO 10        
C        
C     HERE WHEN ALL ELEMENTS HAVE BEEN PROCESSED.        
C     IF NONE FOUND, EXIT.        
C        
  200 CONTINUE        
      IF (NOEPT .GE. 0) CALL CLOSE (EPT,CLSREW)        
      CALL CLOSE (SCR1,CLSREW)        
      IF (NOSIMP .EQ. -1) RETURN        
      NOSIMP = NOSIMP + 1        
C        
C     READ THE BGPDT INTO CORE (UNLESS ALL SCALAR PROBLEM).        
C     READ THE SIL INTO CORE.        
C        
      NBGP = 0        
      IF (KSCALR .EQ. 0) GO TO 220        
      FILE = BGPDT        
      CALL OPEN   (*1100,BGPDT,Z(BUF1),RDREW)        
      CALL FWDREC (*1110,BGPDT)        
      CALL READ   (*1110,*210,BGPDT,Z(1),BUF2,1,NBGP)        
      CALL MESAGE (M8,0,NAM)        
  210 CALL CLOSE  (BGPDT,CLSREW)        
  220 FILE = SIL        
      CALL OPEN   (*1100,SIL,Z(BUF1),RDREW)        
      CALL FWDREC (*1110,SIL)        
      CALL READ   (*1110,*230,SIL,Z(NBGP+1),BUF2-NBGP,1,NSIL)        
      CALL MESAGE (M8,0,NAM)        
  230 CALL CLOSE  (SIL,CLSREW)        
C        
C     IF TEMP DEPENDENT MATERIALS IN PROBLEM,        
C     OPEN GPTT AND POSITION TO PROPER THERMAL RECORD        
C        
      RECORD = .FALSE.        
      ITEMP  = TEMPID        
      IF (TEMPID .EQ. 0) GO TO 310        
      FILE = GPTT        
      CALL OPEN (*1160,GPTT,Z(BUF3),RDREW)        
      ITMPID = NBGP+NSIL+3        
      CALL READ (*1110,*240,GPTT,Z(ITMPID-2),BUF2-ITMPID,1,NID)        
      CALL MESAGE (-8,0,NAM)        
  240 NTMPID = ITMPID - 5 + NID        
      DO 250 I = ITMPID,NTMPID,3        
      IF (TEMPID .EQ. Z(I)) GO TO 260        
  250 CONTINUE        
      GO TO 1160        
  260 IDFTMP = Z(I+1)        
      IF (IDFTMP .NE. -1) DEFTMP = ZZ(I+1)        
      N = Z(I+2)        
      IF (N .EQ. 0) GO TO 310        
      RECORD =.TRUE.        
      N = N - 1        
      IF (N .EQ. 0) GO TO 280        
      DO 270 I = 1,N        
      CALL FWDREC (*1110,GPTT)        
  270 CONTINUE        
C        
C     READ SET ID AND VERIFY FOR CORRECTNESS        
C        
  280 CALL READ (*1110,*1120,GPTT,ISET,1,0,FLAG)        
      IF (ISET .EQ. TEMPID) GO TO 300        
      WRITE  (NOUT, 290) SFM,ISET,TEMPID        
  290 FORMAT (A25,' 4020, TA1A HAS PICKED UP TEMPERATURE SET',I9,       
     1       ' AND NOT THE REQUESTED SET',I9)        
      CALL MESAGE (-61,0,0)        
C        
C     INITIALIZE /TA1ETT/ VARIABLES        
C        
  300 OLDEID = 0        
      OLDEL  = 0        
      EORFLG =.FALSE.        
      ENDID  =.TRUE.        
C        
C     LOOP THRU THE ECT+EPT DATA        
C     CONVERT INTERNAL GRID POINT INDICES TO SIL VALUES FOR EACH NON-   
C     SCALER ELEMENT, ATTACH THE BGPDT DATA AND,        
C     IF A TEMPERATURE PROBLEM, COMPUTE THE ELEMENT TEMP FROM THE GPTT  
C     DATA OR SUBSTITUTE THE DEFAULT TEMP.        
C     WRITE THE RESULT ON THE EST, ONE RECORD PER ELEMENT TYPE        
C        
  310 CALL OPEN  (*1100,SCR1,Z(BUF1),RDREW)        
      CALL OPEN  (*1100,EST,Z(BUF2),WRTREW)        
      CALL FNAME (EST,BUF)        
      CALL WRITE (EST,BUF,2,1)        
      LOCBGP = 1        
C        
C     RESET SOME OF THE /TA1ACM/ VALUES IF IT IS A -HEAT- FORMULATION   
C        
      IF (IHEAT .LE. 0) GO TO 320        
C        
C     TRIARG ELEMENT (TYPE 36)        
      IG(36) = 14        
C        
C     TRAPRG ELEMENT (TYPE 37)        
      IG(37) = 14        
C        
C     REPLACE QDMEM1 ELEMENT (TYPE 62) BY QDMEM ELEMENT (TYPE 16)       
      IG(62) = 14        
C        
C     REPLACE QDMEM2 ELEMENT (TYPE 63) BY QDMEM ELEMENT (TYPE 16)       
      IG(63) = 14        
C        
C     READ POINTER FROM SCR1. WRITE ELEMENT TYPE ON EST.        
C     SET POINTERS FOR CONVERSION OF GRID NOS TO SIL VALUES.        
C        
  320 CALL READ (*500,*1120,SCR1,I,1,0,FLAG)        
      ELTYPE = ELEM(I+2)        
      CALL WRITE (EST,ELTYPE,1,0)        
C        
C     ELEMENT TYPE  USED TO INDEX INTO /TA1ACM/        
C     AND SET USED  /OPEN CORE/  BLOCKS NEGATIVE        
C        
      IG(ELTYPE) = -IG(ELTYPE)        
      NAME  = ELEM(I   )        
      JSCALR= ELEM(I+10)        
      MM    = ELEM(I+ 9)        
      LX    = ELEM(I+12)        
      IF (ELEM(I+8) .EQ. 0) LX = LX + 1        
      MM    = LX + MM - 1        
      JTEMP = ELEM(I+13)        
      NTEMP = 1        
      IF (JTEMP .EQ. 4) NTEMP = ELEM(I+14) - 1        
C         IHEX1/2/3,TRIM6        
C        
C     READ ECT + EPT DATA FOR ELEMENT FROM SCR1.        
C        
  330 CALL READ (*1110,*400,SCR1,BUF,1,0,FLAG)        
      CALL READ (*1110,*1120,SCR1,BUF(2),BUF(1),0,FLAG)        
C        
      IF (NOGO.NE.0 .OR. NOGOX.NE.0) GO TO 350        
      IF (ELTYPE .NE. BAR) GO TO 350        
C        
C     FOR BAR AND BEAM ELEMENTS, STORE COORDINATES AND        
C     COORDINATE SYSTEM ID FOR ORIENTATION VECTOR.        
C        
      KX = 4*(BUF(3)-1) + LOCBGP        
      IF (BUF(8) .EQ. 1) GO TO 340        
      BUF(8) = BUF(5)        
      IF (BUF(8) .EQ. 0) GO TO 340        
      K = 4*(BUF(8)-1)  + LOCBGP        
      BUFR(5) = ZZ(K+1) - ZZ(KX+1)        
      BUFR(6) = ZZ(K+2) - ZZ(KX+2)        
      BUFR(7) = ZZ(K+3) - ZZ(KX+3)        
      BUF(8)  = 0        
      GO TO 350        
  340 BUF(8)  = Z(KX)        
C        
C     SAVE INTERNAL GRID NOS, THEN CONVERT TO SIL NOS        
C     AND WRITE ECT + EPT DATA ON EST.        
C        
  350 DO 360 L = LX,MM        
      GPSAV(L) = 0        
      IF (BUF(L) .EQ. 0) GO TO 360        
      GPSAV(L) = BUF(L)        
      K = GPSAV(L) + NBGP        
      BUF(L) = Z(K)        
  360 CONTINUE        
      CALL WRITE (EST,BUF(2),BUF(1),0)        
C        
C     IF NOT SCALAR ELEMENT, PICK UP BGPDT DATA AND WRITE ON EST.       
C        
      IF (JSCALR .NE. 0) GO TO 330        
      DO 380 L = LX,MM        
      IF (GPSAV(L) .EQ. 0) GO TO 370        
      K = (GPSAV(L)-1)*4        
      CALL WRITE (EST,Z(K+1),4,0)        
      IF (Z(K+1) .GE. 0) GO TO 380        
      IF (ELTYPE.EQ.HBDY .AND. L.GT.LX+3) GO TO 380        
      NOGO = 1        
      CALL MESAGE (30,131,BUF(2))        
      GO TO 380        
  370 CALL WRITE (EST,ZEROS,4,0)        
  380 CONTINUE        
C        
C     ELEMENT TEMP. IS NOT USED IN CONM1 AND CONM2 (ELEM TYPES 29 30)   
C        
      TGRID(1) = 0.        
      IF (ELTYPE.EQ.29 .OR. ELTYPE.EQ.30) GO TO 390        
C        
C     IF NOT SCALAR ELEMENT, COMPUTE AND WRITE ELEMENT TEMP ON EST.     
C        
      CALL TA1ETD (BUF(2),TGRID,NTEMP)        
      IF (ELTYPE .EQ. BAR) TGRID(1) = (TGRID(1)+TGRID(2))/2.0        
  390 CALL WRITE (EST,TGRID,NTEMP,0)        
      GO TO 330        
C        
C     CLOSE EST RECORD AND RETURN FOR ANOTHER ELEMENT TYPE.        
C        
  400 CALL WRITE (EST,0,0,1)        
      GO TO 320        
C        
C     ALL ELEMENTS HAVE BEEN PROCESSED-- CLOSE FILES, WRITE TRAILER AND 
C     EXIT        
C        
  500 CALL CLOSE (SCR1,CLSREW)        
      CALL CLOSE (EST,CLSREW)        
      CALL CLOSE (GPTT,CLSREW)        
      BUF(1) = EST        
      BUF(2) = NOSIMP        
      IF (NOGOX .NE. 0) NOGO = 1        
      IF (NOGO  .NE. 0) CALL MESAGE (-61,0,0)        
      DO 510 I = 3,7        
  510 BUF(I) = 0        
C        
C     PROCESS /TA1ACM/ LOAD EST TRAILER WITH FLAGS        
C     TO THE USED /OPEN CORE/ BLOCKS        
C        
      DO 530 I = 1,NELEM        
      IF (IG(I) .GE. 0) GO TO 530        
      K = IG(I)        
      DO 520 J = I,NELEM        
  520 IF (IG(J) .EQ. K) IG(J) = -IG(J)        
      J = IG(I)        
      IF (J .GT. 48) CALL MESAGE (-61,I,J)        
      K = (J-1)/16        
      J = J - K*16        
      BUF(K+5) = BUF(K+5) + KTWO(J+16)        
  530 CONTINUE        
      CALL WRTTRL (BUF)        
  540 RETURN        
C        
C     **************************************************        
C        
C     INTERNAL BINARY SEARCH ROUTINE        
C        
  600 KLO = 1        
      KHI = KN        
  610 K   = (KLO+KHI+1)/2        
  620 KX  = (K-1)*MX + ITABL        
      IF (ID-Z(KX+1)) 630,90,640        
  630 KHI = K        
      GO TO 650        
  640 KLO = K        
  650 IF (KHI-KLO-1 ) 690,660,610        
  660 IF (K .EQ. KLO) GO TO 670        
      K   = KLO        
      GO TO 680        
  670 K   = KHI        
  680 KLO = KHI        
      GO TO 620        
  690 IF (Q4T3 .AND. NOPSHL.GE.1) GO TO 800        
      GO TO 1140        
C        
C     **************************************************        
C        
C     PROCESSING FOR LAMINATED COMPOSITES        
C        
C     INTERNAL SUBROUTINE TO READ PCOMP, PCOMP1 AND PCOMP2 DATA INTO    
C     CORE        
C        
C        
C     INITIALIZE VARIABLES AND SET POINTERS        
C        
  700 NPC    = 0        
      NPC1   = 0        
      NPC2   = 0        
      TYPC   = 0        
      TYPC1  = 0        
      TYPC2  = 0        
      N      = BUF3 - LL        
C        
C     LOCATE PCOMP DATA AND READ INTO CORE        
C        
      IPC  = LL + 1        
      CALL LOCATE (*720,Z(BUF2),PCOMP,FLAG)        
      CALL READ   (*1110,*710,EPT,Z(IPC),N,0,NPC)        
      CALL MESAGE (-8,0,NAM)        
  710 IF (NPC .GT. 0) TYPC = 1        
      N = N - NPC        
C        
C     LOCATE PCOMP1 DATA AND READ INTO CORE        
C        
  720 IPC1 = IPC + NPC        
      CALL LOCATE (*740,Z(BUF2),PCOMP1,FLAG)        
      CALL READ   (*1110,*730,EPT,Z(IPC1),N,0,NPC1)        
      CALL MESAGE (-8,0,NAM)        
  730 IF (NPC1 .GT. 0) TYPC1 = 1        
      N = N - NPC1        
C        
C     LOCATE PCOMP2 DATA AND READ INTO CORE        
C        
  740 IPC2 = IPC1 + NPC1        
      CALL LOCATE (*760,Z(BUF2),PCOMP2,FLAG)        
      CALL READ   (*1110,*750,EPT,Z(IPC2),N,0,NPC2)        
      CALL MESAGE (-8,0,NAM)        
  750 IF (NPC2 .GT. 0) TYPC2 = 1        
C        
C     SET SIZE OF LPCOMP. NUMBER OF WORDS READ INTO CORE        
C        
  760 LPCOMP = IPC2 + NPC2        
      IF (LPCOMP-1 .GT. LL) COMPS = -1        
C        
C     CHECK FOR NO PCOMP, PCOMP1 OR PCOMP2 DATA        
C     SET NOPSHL TO 2 IF BOTH 'PCOMP' AND PSHELL DATA ARE PRESENT       
C        
      IF (NOPSHL.EQ.1 .AND. COMPS.EQ. 1) GO TO 1130        
      IF (NOPSHL.EQ.0 .AND. COMPS.EQ.-1) NOPSHL = 2        
      GO TO 80        
C        
C     ***************************************************************   
C        
C     INTERNAL SUBROUTINE TO LOCATE A PARTICULAR PROPERTY ID FROM THE   
C     'PCOMP' DATA AND TO CONVERT THE DATA TO PSHELL DATA FORMAT        
C        
  800 CONTINUE        
C        
C     Z(LL+1) THRU Z(LPCOMP) CONTAIN 'PCOMP' DATA        
C        
C     SET POINTERS        
C        
      KPC    = 4        
      KPC2   = 2        
      LEN    = 0        
      NLAY   = 0        
      EOELOC = 0        
      PIDLOC = 0        
      ITYPE  =-1        
C        
C     SEARCH FOR PID IN PCOMP DATA        
C        
      IF (TYPC .EQ. 0) GO TO 850        
      Z(LPCOMP+1) = IPC        
      NPCOMP = 0        
      N = 2        
C        
      LPC = IPC1 - 1        
      DO 820 IIP = IPC,LPC        
      IF (Z(IIP) .NE. -1) GO TO 820        
      Z(LPCOMP+N  ) = IIP        
      Z(LPCOMP+N+1) = IIP + 1        
      IF (IIP .EQ. LPC) Z(LPCOMP+N+1) = 0        
      N = N + 2        
      NPCOMP = NPCOMP + 1        
  820 CONTINUE        
      IF (LPCOMP+N-2 .GE. BUF3) CALL MESAGE (-8,0,NAM)        
C        
C     LOCATE PARTICULAR PID        
C        
      DO 830 IIP = 1,NPCOMP        
      EOELOC = Z(LPCOMP+2*IIP  )        
      PIDLOC = Z(LPCOMP+2*IIP-1)        
      IF (Z(PIDLOC) .EQ. ID) GO TO 840        
  830 CONTINUE        
      GO TO 850        
C        
  840 LEN  = EOELOC - PIDLOC        
      NLAY = (LEN-8)/KPC        
      ITYPE= 0        
      GO TO 940        
C        
C     SEARCH FOR PID IN PCOMP1 DATA        
C        
  850 IF (TYPC1 .EQ. 0) GO TO 890        
C        
      Z(LPCOMP+1) = IPC1        
      NPCOMP = 0        
      N = 2        
C        
      LPC1 = IPC2 - 1        
      DO 860 IIP1 = IPC1,LPC1        
      IF (Z(IIP1) .NE. -1) GO TO 860        
      Z(LPCOMP+N  ) = IIP1        
      Z(LPCOMP+N+1) = IIP1 + 1        
      IF (IIP1 .EQ. LPC1) Z(LPCOMP+N+1) = 0        
      NPCOMP = NPCOMP + 1        
      N = N + 2        
  860 CONTINUE        
      IF (LPCOMP+N-2 .GE. BUF3) CALL MESAGE (-8,0,NAM)        
C        
C     LOCATE PARTICULAR PID        
C        
      DO 870 IIP1 = 1,NPCOMP        
      EOELOC = Z(LPCOMP+2*IIP1  )        
      PIDLOC = Z(LPCOMP+2*IIP1-1)        
      IF (Z(PIDLOC) .EQ. ID) GO TO 880        
  870 CONTINUE        
      GO TO 890        
C        
  880 LEN  = EOELOC - PIDLOC        
      NLAY = LEN - 8        
      ITYPE= 1        
      GO TO 940        
C        
C     SEARCH FOR PID IN PCOMP2 DATA        
C        
  890 IF (TYPC2 .EQ. 0) GO TO 930        
C        
      Z(LPCOMP+1) = IPC2        
      NPCOMP = 0        
      N = 2        
C        
      LPC2 = LPCOMP - 1        
      DO 900 IIP2 = IPC2,LPC2        
      IF (Z(IIP2) .NE. -1) GO TO 900        
      Z(LPCOMP+N  ) = IIP2        
      Z(LPCOMP+N+1) = IIP2 + 1        
      IF (IIP2 .EQ. LPC2) Z(LPCOMP+N+1) = 0        
      NPCOMP = NPCOMP + 1        
      N = N + 2        
  900 CONTINUE        
      IF (LPCOMP+N-2 .GE. BUF3) CALL MESAGE (-8,0,NAM)        
C        
C     LOCATE PARTICULAR PID        
C        
      DO 910 IIP2 = 1,NPCOMP        
      EOELOC = Z(LPCOMP+2*IIP2  )        
      PIDLOC = Z(LPCOMP+2*IIP2-1)        
      IF (Z(PIDLOC) .EQ. ID) GO TO 920        
  910 CONTINUE        
      GO TO 930        
C        
  920 LEN  = EOELOC - PIDLOC        
      NLAY = (LEN-8)/KPC2        
      ITYPE= 2        
      GO TO 940        
C        
C     CHECK IF PID HAS BEEN FOUND IN 'PCOMP' DATA        
C        
  930 IF (ITYPE .LT. 0) GO TO 1140        
C        
C     DETERMINE DATA TO BE WRITTEN IN THE FORM OF PSHELL AND        
C     WRITE TO SCR1        
C        
C     ITYPE  = 0,  PCOMP  ENTRY        
C            = 1,  PCOMP1 ENTRY        
C            = 2,  PCOMP2 ENTRY        
C        
C     CALCULATE LAMINATE THICKNESS - TLAM        
C        
  940 TLAM = 0.        
C        
C     NOTE - IF Z(PIDLOC+7) IS EQUAL TO SYM OR SYMMEM, THE OPTION       
C            TO MODEL EITHER A SYMMETRICAL OR SYMMETRICAL-MEMBRANE      
C            LAMINATE HAS BEEN EXERCISED.  THEREFORE, THE TOTAL        
C            THICKNESS IS TLAM = 2.0*TLAM        
C        
C     SET LAMOPT        
C        
      LAMOPT = Z(PIDLOC+7)        
C        
C     PCOMP DATA        
C        
      IF (ITYPE .GT. 0) GO TO 960        
      DO 950 K = 1,NLAY        
      II   = (PIDLOC+5) + 4*K        
      TLAM = TLAM + ZZ(II)        
  950 CONTINUE        
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM        
      GO TO 1000        
C        
C     PCOMP1 DATA        
C        
  960 IF (ITYPE .GT. 1) GO TO 970        
      II   = PIDLOC + 6        
      TLAM = ZZ(II)*NLAY        
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM        
      GO TO 1000        
C        
C     PCOMP2 DATA        
C        
  970 DO 980 K = 1,NLAY        
      II   = (PIDLOC+6) + 2*K        
      TLAM = TLAM + ZZ(II)        
  980 CONTINUE        
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM        
C        
C        
C     CREATE NEW PSHELL DATA AND WRITE TO ARRAY IPSHEL        
C     NOTE - PID IS NOT WRITTEN TO IPSHEL        
C        
C     IPSHEL DATA TO BE WRITTEN TO SCR1        
C     ============================================================      
C     IPSHEL( 1)     = MID1     MEMBRANE MATERIAL        
C     IPSHEL( 2)     = T        DEFAULT MEMBRANE THICKNESS        
C     IPSHEL( 3)     = MID2     BENDING MATERIAL        
C     IPSHEL( 4)     = 12I/T**3 BENDING STIFFNESS PARAMETER        
C     IPSHEL( 5)     = MID3     TRANVERSE SHEAR MATERIAL        
C     IPSHEL( 6)     = TS/T     SHEAR THICKNESS FACTOR        
C     IPSHEL( 7)     = NSM      NON-STRUCTURAL MASS        
C     IPSHEL(8,9)    = Z1,Z2    FIBRE DISTANCES        
C     IPSHEL(10)     = MID4     MEMBRANE-BENDING COUPLING MATERIAL      
C     IPSHEL(11)     = MCSID OR THETAM   //DATA FROM PSHELL        
C     IPSHEL(12)     = FLAGM               OVERRIDDEN BY EST(18-19)//   
C     IPSHEL(13)     = INTEGRATION ORDER (SET TO 0)        
C                     (THE INTEGRATION ORDER IS NOT USED IN THE PROGRAM,
C                      BUT THIS WORD IS REQUIRED BECAUSE OF THE DESIGN  
C                      OF THE EST DATA FOR THE CQUAD4/TRIA3 ELEMENTS.)  
C     IPSHEL(14)     = SCSID OR THETAS   //DATA FROM PSHELL        
C     IPSHEL(15)     = FLAGS               OVERRIDDEN BY EST(20-21)//   
C     IPSHEL(16)     = ZOFF        
C        
C     CALCULATE ZOFFS        
C        
 1000 IF (Z(PIDLOC+1) .NE. 0) ZOFFS = ZZ(PIDLOC+1) + 0.5*TLAM        
      IF (Z(PIDLOC+1) .EQ. 0) ZOFFS = 0.0        
      IF (ABS(ZOFFS)  .LE. 0.001) ZOFFS = 0.0        
C        
C     SET POINTER TO INDICATE NEW PSHELL DATA CREATED        
C        
      NPSHEL = 1        
C        
C     INITIALIZE IPSHEL ARRAY        
C        
      DO 1010 KK = 1,16        
      IPSHEL(KK) = 0        
 1010 CONTINUE        
C        
      RPSHEL( 4) = 1.0        
      RPSHEL( 6) = 1.0        
C        
      IPSHEL( 1) = ID + 100000000        
      RPSHEL( 2) = TLAM        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1020        
      IPSHEL( 3) = ID + 200000000        
      IPSHEL( 5) = ID + 300000000        
 1020 RPSHEL( 7) = ZZ(PIDLOC+2)        
      RPSHEL( 9) = 0.5*TLAM        
      RPSHEL( 8) =-RPSHEL(9)        
      IF (LAMOPT.NE.SYM .AND. LAMOPT.NE.MEM .AND. LAMOPT.NE.SYMMEM)     
     1    IPSHEL(10) = ID + 400000000        
      IPSHEL(13) = 0        
      RPSHEL(16) = ZOFFS        
C        
C     DO NOT WRITE TO OUTPUT FILE IF PREVIOUS ID IS SAME AS NEW ID.     
C     OTHERWISE, WRITE THE NEWLY CREATED PSHELL BULK DATA ENTRY TO      
C     OUTPUT FILE IF DIAG 40 IS TURNED ON        
C        
      IF (OLDID .EQ. ID) GO TO 1060        
      IF (  .NOT.FRSTIM) GO TO 1040        
      FRSTIM = .FALSE.        
      IF (L40 .EQ. 0) GO TO 1060        
      CALL PAGE (3)        
      WRITE  (NOUT,1030)        
 1030 FORMAT (//9X,'THE INPUT PCOMP, PCOMP1 OR PCOMP2 BULK DATA',       
     1       ' ENTRIES HAVE BEEN REPLACED BY THE FOLLOWING PSHELL',     
     2       ' AND MAT2 ENTRIES.',//)        
 1040 IF (L40 .EQ. 0) GO TO 1060        
      WRITE (NOUT,1050) ID,IPSHEL( 1),RPSHEL( 2),IPSHEL( 3),        
     1                     RPSHEL( 4),IPSHEL( 5),RPSHEL( 6),        
     2                     RPSHEL( 7),RPSHEL( 8),RPSHEL( 9),        
     3                     IPSHEL(10),RPSHEL(11),RPSHEL(14),        
     4                     RPSHEL(16)        
 1050 FORMAT (' PSHELL',I14,I12,1X,1P,E11.4,I12,1X,1P,E11.4,I12,        
     1       2(1X,1P,E11.4), /9X,2(1X,1P,E11.4),I12,2(1X,F11.1),1X,     
     2       1P,E11.4)        
C        
C     SET OLDID TO ID        
C        
 1060 OLDID = ID        
      GO TO 90        
C        
C     FATAL ERROR MESSAGES        
C        
 1100 J = -1        
      GO TO 1150        
 1110 J = -2        
      GO TO 1150        
 1120 J = -3        
      GO TO 1150        
 1130 BUF(1) = ELEM(I  )        
      BUF(2) = ELEM(I+1)        
      NOGOX  = 1        
      CALL MESAGE (30,11,BUF)        
      KX = ITABL        
      GO TO 30        
 1140 KSAVEW = BUF(3)        
      BUF(3) = ID        
      NOGO = 1        
      CALL MESAGE (30,10,BUF(2))        
      KX = ITABL        
      BUF(3) = KSAVEW        
      GO TO 90        
 1150 CALL MESAGE (J,FILE,NAM)        
 1160 BUF(1) = TEMPID        
      BUF(2) = 0        
      CALL MESAGE (-30,44,BUF)        
      RETURN        
C        
C     ARRAY IG IS FIRST DIMENSIONED IN TA1ABD        
C        
 1190 WRITE  (NOUT,1200) SFM        
 1200 FORMAT (A25,', IG ARRAY IN TA1A TOO SMALL')        
      CALL MESAGE (-61,0,0)        
C        
      END        
