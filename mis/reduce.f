      SUBROUTINE REDUCE        
C        
C     REDUCE BUILDS THE FOLLOWING DATA BLOCKS        
C        
C     1.  PVX  -  THE REDUCTION PARTITIONING VECTOR        
C     2.  USX  -  THE USET EQUIVALENT VECTOR        
C     3.  INX  -  THE REDUCTION TRANSFORMATION IDENTITY PARTITION       
C        
C     THE FOLLOWING BULK DATA CARDS ARE READ        
C        
C     1.  BDYC        
C     2.  BDYS        
C     3.  BDYS1        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      LOGICAL         INBSET,FSET,BAD,LONLY        
      REAL            RZ(1)        
      DIMENSION       MODNAM(2),IJK(6),IHD(96),BDYS(2),BDYS1(2),        
     1                BDYC(2),MNEM(4),NAMOLD(14),NAMNEW(2),ARAY(6),     
     2                ISID(100),CSET(6),IPSET(6),LISTO(32),LISTN(32),   
     3                MCB(7),IBITS(6)        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
CZZ   COMMON /ZZREDU/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /PACKX / TYPIN,TYPOUT,IROW,NROW,INCR        
      COMMON /SYSTEM/ SYSBUF,OUTT,X1(6),NLPP,X2(2),LINE,X3(2),IDATE(3)  
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /CMBFND/ IINAM(2),IIIERR        
      COMMON /TWO   / TPOW(32)        
      COMMON /BLANK / STEP,DRY,PORA        
      EQUIVALENCE     (RZ(1),Z(1) )        
      DATA    IHD   / 4H    , 8*4H****,        
     1        4H S U, 4H B S, 4H T R, 4H U C, 4H T U, 4H R E, 4H    ,   
     2        4HM O , 4HD U , 4HL E , 4H   R, 4H E D, 4H U C, 4H E *,   
     3        9*4H**** , 64*4H      /        
      DATA    NHEQSS, NHBGSS,NHCSTM,NHPLTS/4HEQSS,4HBGSS,4HCSTM,4HPLTS/ 
      DATA    MODNAM/ 4HREDU,4HCE   /        
      DATA    PAPP  , LODS, LOAP    /4HPAPP,4HLODS,4HLOAP/        
C     --------------------        
C     CODES TO LOCATE BULK DATA        
C     --------------------        
      DATA    BDYC/ 910,9 / , BDYS/ 1210,12 / , BDYS1/ 1310,13 /        
C     --------------------        
C     CASE CONTROL MNEMONICS        
C     --------------------        
      DATA    MNEM/ 4HNAMA , 4HNAMB , 4HBOUN , 4HOUTP /        
C     --------------------        
C     GINO FILES FOR DATA BLOCKS AND SCRATCH        
C     --------------------        
      DATA    CASECC/ 101 / , GEOM4/ 102 /        
      DATA    PVX   / 201 / , USX  / 202 / , INX/ 203 /        
      DATA    SCR1  / 301 / , SCR2 / 302 / , I3 / 3   /        
C        
C        
C     I.  COMPUTE OPEN CORE AND DEFINE GINO AND SOF BUFFERS        
C     *****************************************************        
C        
      IF (DRY .EQ. -2) RETURN        
      IBA = 128        
      IBO = 4        
      IBF = 64        
      NZWD= KORSZ(Z(1))        
      IF (NZWD .LE. 0 ) CALL MESAGE (-8,0,MODNAM)        
C        
      LONLY= .FALSE.        
      BUF1 = NZWD - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      IB1  = BUF3 - SYSBUF        
      IB2  = IB1  - SYSBUF        
      IB3  = IB2  - SYSBUF        
C        
C     SCORE IS STARTING ADDRESS OF OPEN CORE AND NZ THE LENGTH        
C        
      SCORE = 1        
      NZ = IB3 - 1        
C        
C     INITIALIZE ACTIVITY ON THE SOF        
C        
      LITM = LODS        
      IF (PORA .EQ. PAPP) LITM = LOAP        
      CALL SOFOPN (Z(IB1),Z(IB2),Z(IB3))        
      DO 2111 I = 1,96        
      IHEAD(I) = IHD(I)        
 2111 CONTINUE        
C        
C     II.  PROCESS THE CASE CONTROL DATA BLOCK ( CASECC )        
C     ***************************************************        
C        
      DO 260 I = 1,14        
      NAMOLD(I) = 0        
  260 CONTINUE        
      IFILE = CASECC        
      CALL OPEN (*2001,CASECC,Z(BUF2),0)        
      PRTOPT = 0        
      NREC = STEP        
      IF (NREC) 200,201,200        
  200 DO 202 I = 1,NREC        
      CALL FWDREC (*2002,CASECC)        
  202 CONTINUE        
C        
C     BEGIN READING CASECC        
C        
  201 INBSET = .FALSE.        
      CALL READ (*2002,*2003,CASECC,Z(1),2,0,NNN)        
      NWDSCC = Z(I3-1)        
      DO 203 I = 1,NWDSCC,3        
      CALL READ (*2002,*2003,CASECC,Z(1),3,0,NNN)        
C        
C     CHECK FOR CASE CONTROL MNEMONICS        
C        
      DO 204 J = 1,4        
      IF (Z(1) .EQ. MNEM(J)) GO TO 205        
  204 CONTINUE        
      GO TO 203        
  205 GO TO (206,207,208,209), J        
  206 NAMOLD(1) = Z(I3-1)        
      NAMOLD(2) = Z(I3  )        
      GO TO 203        
  207 NAMNEW(1) = Z(I3-1)        
      NAMNEW(2) = Z(I3  )        
      GO TO 203        
  208 INBSET = .TRUE.        
      BSET = Z(I3)        
      GO TO 203        
  209 PRTOPT = ORF(PRTOPT,Z(I3))        
  203 CONTINUE        
      IF (DRY .EQ. 0) PRTOPT = 0        
      IF (ANDF(PRTOPT,1) .NE. 1) GO TO 2199        
      CALL PAGE1        
      WRITE  (OUTT,280) (NAMOLD(I),I=1,2),NAMNEW,BSET,(NAMOLD(I),I=1,2) 
  280 FORMAT (//41X,'S U M M A R Y    O F    C U R R E N T    P R O ',  
     1       'B L E M', //43X,        
     2       'NAME OF PSEUDOSTRUCTURE TO BE REDUCED    - ',2A4, //43X,  
     3       'NAME GIVEN TO RESULTANT PSEUDOSTRUCTURE  - ',2A4, //43X,  
     4       'BOUNDARY SET IDENTIFICATION NUMBER       - ',I8,  //43X,  
     5       'NAMES OF COMPONENT SUBSTRUCTURES CONTAINED IN ',2A4/)     
 2199 CONTINUE        
      CALL CLOSE (CASECC,1)        
C        
C     CHECK FOR ALLOWABILITY OF INPUT        
C        
      BAD = .FALSE.        
      CALL SFETCH (NAMOLD,NHEQSS,3,ITEST)        
      IF (ITEST .EQ. 4) GO TO 290        
  261 CALL SFETCH (NAMNEW,NHEQSS,3,ITEST)        
      IF (ITEST.NE.4 .AND. DRY.NE.0) GO TO 291        
      IF (ITEST.EQ.4 .AND. DRY.EQ.0) GO TO 297        
  262 IF (.NOT.INBSET) GO TO 292        
  263 IF (.NOT.BAD) GO TO 300        
      GO TO 2100        
C        
C     IF NO ERRORS, CONTINUE PROCESSING        
C        
C        
  290 WRITE (OUTT,293) UFM,(NAMOLD(I),I=1,2)        
      BAD = .TRUE.        
      GO TO 261        
  291 CALL SFETCH (NAMNEW,LITM,3,ITEST)        
      IF (ITEST .NE. 3) GO TO 296        
      LONLY = .TRUE.        
      GO TO 300        
  296 CONTINUE        
      WRITE (OUTT,294) UFM,(NAMNEW(I),I=1,2)        
      BAD = .TRUE.        
      GO TO 262        
  292 WRITE (OUTT,295) UFM        
      BAD = .TRUE.        
      GO TO 263        
  297 WRITE  (OUTT,298) UFM,NAMNEW        
  298 FORMAT (A23,' 6613, FOR RUN=GO, THE REDUCED SUBSTRUCTURE ',2A4,   
     1       ' MUST ALREADY EXIST.')        
      BAD = .TRUE.        
      GO TO 262        
  293 FORMAT (A23,' 6601, REQUEST TO REDUCE PSEUDOSTRUCTURE ',2A4,      
     1       ' INVALID. DOES NOT EXIST ON THE SOF.')        
  294 FORMAT (A23,' 6602, THE NAME ',2A4,' CAN NOT BE USED FOR THE ',   
     1       'REDUCED PSEUDOSTRUCTURE. IT ALREADY EXISTS ON THE SOF.')  
  295 FORMAT (A23,' 6603, A BOUNDARY SET MUST BE SPECIFIED FOR A ',     
     1       'REDUCE OPERATION.')        
C        
C     READ FIRST GROUP OF EQSS FOR THE STRUCTURE BEING REDUCED,        
C     PLACE THE NAMES OF THE COMPONENT SUBSTRUCTURES INTO THE        
C     FIRST NWDS WORDS OF OPEN CORE.        
C        
  300 KS1 = SCORE        
      CALL SFETCH (NAMOLD,NHEQSS,1,ITEST)        
      CALL SUREAD (Z(KS1),-1,NOUT,ITEST )        
C        
C     NCSUB IS THE NUMBER OF COMPONENT SUBSTRUCTURES        
C     NIPOLD IS THE NUMBER OF IP S IN THE STRUCTURE BEING REDUCED       
C        
      NCSUB = Z(KS1+2)        
      NOUT  = NOUT - 4        
      DO 302 I = 1,NOUT        
      II = I - 1        
      Z(KS1+II) = Z(KS1+4+II)        
  302 CONTINUE        
      NWDS = NOUT        
      SCORE= KS1 + NWDS        
      KF1  = SCORE - 1        
      NZ   = NZ - NWDS        
      IF (ANDF(PRTOPT,1) .NE. 1) GO TO 282        
      WRITE  (OUTT,281) (Z(JJ),JJ=KS1,KF1)        
  281 FORMAT (48X,2A4,4X,2A4,4X,2A4,4X,2A4)        
  282 CONTINUE        
C        
C     III. READ BOUNDARY SET ( BDYC ) BULK DATA INTO OPEN CORE FOR      
C     THE REQUESTED SET ( BSET ) FROM THE GEOM4 INPUT DATA BLOCK.       
C     ************************************************************      
C        
      KS2   = SCORE        
      IFILE = GEOM4        
      CALL PRELOC (*2001,Z(BUF1),GEOM4)        
      CALL LOCATE (*490,Z(BUF1),BDYC,FLAG)        
  401 CALL READ (*2002,*490,GEOM4,ID,1,0,NNN)        
      IF (ID .EQ. BSET) GO TO 402        
  403 CALL READ (*2002,*2003,GEOM4,ARAY,3,0,NNN)        
      IF (ARAY(3) .EQ. -1) GO TO 401        
      GO TO 403        
C        
C     CORRECT BOUNDARY SET HAS BEEN FOUND, STORE DATA IN SECOND NWBS WOR
C     OF OPEN CORE.        
C        
  402 NWBS = 0        
  405 BAD  = .FALSE.        
      CALL READ (*2002,*2003,GEOM4,Z(KS2+NWBS),3,0,NNN)        
      IF (Z(KS2+NWBS+2) .EQ. -1) GO TO 440        
C        
C     MUST CHECK THAT THE SUBSTRUCTURE IS A PHASE1 BASIC SUBSTRUCTURE   
C     AND THAT IT IS A COMPONENT OF THE STRUCTURE BEING REDUCED.        
C        
C     CHECK FOR COMPONENT        
C        
      DO 410 I = 1,NWDS,2        
      II = I - 1        
      IF (Z(KS1+II).EQ.Z(KS2+NWBS) .AND. Z(KS1+II+1).EQ.Z(KS2+NWBS+1))  
     1    GO TO 420        
  410 CONTINUE        
C        
C     NOT A COMPONENT        
C        
      WRITE (OUTT,491) UFM,Z(KS2+NWBS),Z(KS2+NWBS+1)        
      BAD = .TRUE.        
  491 FORMAT (A23,' 6604, A BOUNDARY SET HAS BEEN SPECIFIED FOR ',2A4,  
     1       ', BUT IT IS NOT A COMPONENT OF THE', /31X,'PSEUDOSTRUC',  
     2       'TURE BEING REDUCED. THE BOUNDARY SET WILL BE IGNORED.')   
C        
  420 IF (BAD) GO TO 405        
      NWBS = NWBS + 3        
      GO TO 405        
  440 SCORE = KS2 + NWBS        
      KF2 = SCORE - 1        
      NZ  = NZ - NWBS        
C        
C     SORT ON SET ID        
C        
      CALL SORT (0,0,3,3,Z(KS2),NWBS)        
      IF (ANDF(RSHIFT(PRTOPT,1),1) .NE. 1) GO TO 2299        
      II = 0        
 2203 CALL PAGE1        
      WRITE  (OUTT,2202) BSET        
 2202 FORMAT (//44X,'SUMMARY OF COMBINED BOUNDARY SET NUMBER',I9, //55X,
     1       'BASIC',11X,'BOUNDARY', /52X,'SUBSTRUCTURE',8X,'SET ID',   
     2       /56X,'NAME',12X,'NUMBER',/)        
      LINE = LINE + 7        
 2206 LINE = LINE + 1        
      IF (LINE .GT. NLPP) GO TO 2203        
      WRITE  (OUTT,2205) Z(KS2+II),Z(KS2+II+1),Z(KS2+II+2)        
 2205 FORMAT (54X,2A4,9X,I8)        
      II = II + 3        
      IF (II .GT. NWBS - 3) GO TO 2299        
      GO TO 2206        
 2299 CONTINUE        
      GO TO 500        
  490 WRITE (OUTT,493) IFM,BSET        
      GO TO 2200        
  493 FORMAT (A23,' 6606, BOUNDARY SET ,I8,61H SPECIFIED IN CASE ',     
     1       'CONTROL HAS NOT BEEN DEFINED BY BULK DATA.')        
C        
C     IV. READ BDYS BULK DATA PROCESSING ONLY THE SET ID S REFERENCED ON
C     THE BDYC CARD.  IF DATA DOES NOT EXIST, GO TO BDYS1 PROCESSING SEC
C     ******************************************************************
C        
  500 J = 0        
      IERR = 0        
      CALL LOCATE (*580,Z(BUF1),BDYS,FLAG)        
  502 CALL READ (*2002,*600,GEOM4,IDHID,1,0,NNN)        
C        
C     CHECK REQUESTED ID        
C        
      DO 501 I = KS2,KF2,3        
      IF (IDHID .EQ. Z(I+2)) GO TO 503        
  501 CONTINUE        
  505 CALL READ (*2002,*2003,GEOM4,ARAY,2,0,NNN)        
      IF (ARAY(1).NE.-1 .AND. ARAY(2).NE.-1) GO TO 505        
      GO TO 502        
  503 CALL READ (*2002,*2003,GEOM4,ARAY,2,0,NNN)        
      IF (ARAY(1).EQ.-1 .AND. ARAY(2).EQ.-1) GO TO 502        
      Z(SCORE+J  ) = IDHID        
      Z(SCORE+J+1) = ARAY(1)        
      Z(SCORE+J+2) = ARAY(2)        
      J = J + 3        
      GO TO 503        
  580 IERR = IERR + 1        
C        
C     V. READ BDYS1 BULK DATA AND MERGE WITH BDYS IN OPEN CORE.        
C     *********************************************************        
C        
  600 CALL LOCATE (*620,Z(BUF1),BDYS1,FLAG)        
  606 CALL READ (*2002,*602,GEOM4,ARAY(1),2,0,NNN)        
C        
C     CHECK ID        
C        
      DO 603 I = KS2,KF2,3        
      IF (ARAY(1) .EQ. Z(I+2)) GO TO 604        
  603 CONTINUE        
  605 CALL READ (*2002,*2003,GEOM4,ARAY(3),1,0,NNN)        
      IF (ARAY(3) .NE. -1) GO TO 605        
      GO TO 606        
  604 CALL READ (*2002,*2003,GEOM4,ARAY(3),1,0,NNN)        
      IF (ARAY(3) .EQ. -1) GO TO 606        
      Z(SCORE+J  ) = ARAY(1)        
      Z(SCORE+J+1) = ARAY(3)        
      Z(SCORE+J+2) = ARAY(2)        
      J = J + 3        
      GO TO 604        
  620 IERR = IERR + 1        
  602 CALL CLOSE (GEOM4,1)        
      IF (IERR .NE. 2) GO TO 650        
      WRITE (OUTT,691) UFM,BSET        
      GO TO 2200        
  691 FORMAT (A23,' 6607, NO BDYS OR BDYS1 BULK DATA HAS BEEN INPUT TO',
     1       ' DEFINE BOUNDARY SET',I8)        
C        
C     SORT COMPLETE BOUNDARY SET DATA ON SET ID IN OPEN CORE        
C        
  650 CALL SORT (0,0,3,1,Z(SCORE),J)        
C        
C     TRANSLATE COMPONENT NUMBER TO BIT PATTERN        
C        
      IT = SCORE + J - 1        
      DO 651 I = SCORE,IT,3        
      CALL ENCODE (Z(I+2))        
  651 CONTINUE        
      IF (ANDF(RSHIFT(PRTOPT,2),1) .NE. 1) GO TO 2399        
      IINC = 0        
 2303 CALL PAGE1        
      WRITE  (OUTT,2302)        
 2302 FORMAT (1H0,46X,44HTABLE OF GRID POINTS COMPOSING BOUNDARY SETS, /
     1    /52X,8HBOUNDARY ,/52X , 34H SET ID      GRID POINT       DOF ,
     2    /52X,34H NUMBER      ID  NUMBER       CODE ,/ )        
      LINE = LINE + 7        
 2305 LINE = LINE + 1        
      IF (LINE .GT. NLPP) GO TO 2303        
      ICODE = Z(SCORE+IINC+2)        
      CALL BITPAT (ICODE, IBITS)        
      WRITE (OUTT,2304) Z(SCORE+IINC),Z(SCORE+IINC+1),        
     1                  IBITS(1),IBITS(2)        
 2304 FORMAT (52X,I8,6X,I8,7X,A4,A2)        
      IINC = IINC + 3        
      IF (IINC .GT. J-3) GO TO 2399        
      GO TO 2305        
 2399 CONTINUE        
C        
C     WRITE BOUNDARY SET DATA ON TO FILE SCR1, ONE LOGICAL RECORD FOR EA
C     SET ID.        
C        
      CALL OPEN (*2001,SCR1,Z(BUF2),1)        
      IST  = SCORE + 3        
      IFIN = SCORE + J - 1        
      N    = 1        
      NSID = 1        
      ISID(1) = Z(SCORE)        
      CALL WRITE (SCR1,Z(SCORE+1),2,0)        
      DO 660 I = IST,IFIN,3        
      IF (Z(I) .EQ. ISID(N)) GO TO 661        
      N    = N + 1        
      NSID = NSID + 1        
      ISID(N) = Z(I)        
      CALL WRITE (SCR1,ARAY,0,1)        
  661 CALL WRITE (SCR1,Z(I+1),2,0)        
  660 CONTINUE        
      CALL WRITE (SCR1,ARAY,0,1)        
      CALL CLOSE (SCR1,1)        
C        
C        
C     SCR1 NOW CONTAINS BOUNDARY SET DATA FOR ALL GRID POINTS        
C        
C     CHECK THAT ALL REQUESTED SID S HAVE BEEN FOUND        
C        
      NRSID = NWBS/3        
      J = 0        
      DO 670 I = KS2,KF2,3        
      Z(SCORE+J) = Z(I+2)        
      J = J + 1        
  670 CONTINUE        
      DO 675 I = 1,NRSID        
      II = I - 1        
      DO 676 J = 1,NSID        
      IF (ISID(J) .EQ. Z(SCORE+II)) GO TO 677        
  676 CONTINUE        
      GO TO 675        
  677 Z(SCORE+II) = 0        
  675 CONTINUE        
      IBAD = 0        
      DO 678 I = 1,NRSID        
      II = I - 1        
      IF (Z(SCORE+II) .EQ. 0) GO TO 678        
      INDEX = (I-1)*3        
      WRITE (OUTT,692) UFM,Z(KS2+INDEX+2),Z(KS2+INDEX),Z(KS2+INDEX+1)   
      IBAD = 1        
  678 CONTINUE        
      IF (IBAD .EQ. 1) GO TO 2300        
  692 FORMAT (A23,' 6608, THE REQUEST FOR BOUNDARY SET ',I8,        
     1       ' SUBSTRUCTURE ',2A4,' WAS NOT DEFINED.')        
C        
C     VI. PROCESS THE EQSS FROM THE SOF FOR EACH COMPONENT SUBSTRUCTURE.
C     ******************************************************************
C        
      CALL OPEN (*2001,SCR1,Z(BUF3),0)        
      CALL OPEN (*2001,SCR2,Z(BUF2),1)        
      CALL SFETCH (NAMOLD,NHEQSS,1,ITEST)        
      NGRP = 1        
      CALL SJUMP (NGRP)        
C        
C     READ AND PROCESS EQSS        
C        
      BAD = .FALSE.        
      DO 701 I = 1,NCSUB        
      II = 2*(I-1)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      IF (ANDF(RSHIFT(PRTOPT,3),1) .NE. 1) GO TO 2499        
      CALL CMIWRT (1,NAMOLD,Z(KS1+II),SCORE,NOUT,Z,Z)        
 2499 CONTINUE        
C        
C     FIND A BOUNDARY SET FOR THE COMPONENT        
C        
      INXT = 1        
      FSET = .FALSE.        
  737 DO 702 J = INXT,NWBS,3        
      JJ = J - 1        
      IF (Z(KS2+JJ).EQ.Z(KS1+II) .AND. Z(KS2+JJ+1).EQ.Z(KS1+II+1))      
     1    GO TO 704        
  702 CONTINUE        
      IF (FSET) GO TO 735        
C        
C     NO BOUNDARY SET FOR COMPONENT - IMPLIES ENTIRE SUBSTRUCTURE WILL B
C     REDUCED - POSSSIBLE ERROR.        
C        
      IF (NOUT .NE. 0) WRITE(OUTT,791) UIM,Z(KS1+II),Z(KS1+II+1),       
     1                                 (NAMOLD(J),J=1,2)        
  791 FORMAT (A29,' 6609, NO BOUNDARY SET HAS BEEN SPECIFIED FOR ',     
     1       'COMPONENT ',2A4,' OF PSEUDOSTRUCTURE ',2A4, /35X,        
     2       'ALL DEGREES OF FREEDOM WILL BE REDUCED.')        
      CALL WRITE (SCR2,ARAY(1),0,1)        
      GO TO 701        
C        
C     COMPONENT HAS A BOUNDARY SET, CALL EQSCOD TO ACCOUNT FOR POSSIBLE 
C     MULTIPLE IP NUMBERS.        
C        
  704 IF (FSET) GO TO 736        
      CALL EQSCOD (SCORE,NOUT,Z)        
C        
C     DEFINE ARRAY TO CB - DEGREES OF FREEDOM RETAINED AS BOUNDARY POINT
C        
      IST  = SCORE + NOUT        
      IFIN = IST + NOUT/3 - 1        
      DO 705 J = IST,IFIN        
      Z(J) = 0        
  705 CONTINUE        
C        
C     LOCATE BOUNDARY SET ON SCR1        
C        
  736 INXT = JJ + 4        
      FSET = .TRUE.        
      NSET = Z(KS2+JJ+2)        
      DO 706 J = 1,NSID        
      IF (NSET .EQ. ISID(J)) GO TO 766        
  706 CONTINUE        
  766 NREC = J - 1        
      IF (NREC .EQ. 0) GO TO 716        
      DO 707 JJ = 1,NREC        
      CALL FWDREC (*2002,SCR1)        
  707 CONTINUE        
C        
C     READ BOUNDARY DATA AND UPDATE CB        
C        
  716 CALL READ (*2002,*730,SCR1,ARAY,2,0,NNN)        
C        
C     LOCATE GRID ID IN EQSS AND SETS OF VALUES IF THE GRID IS MULTIPLY 
C        
      IF (NOUT .EQ. 0) GO TO 717        
      CALL GRIDIP (ARAY(1),SCORE,NOUT,IPSET,CSET,NO,Z,LOC)        
      IF (IIIERR .NE. 1) GO TO 718        
  717 BAD = .TRUE.        
      WRITE  (OUTT,714) UFM,ARAY(1),NSET,Z(KS1+II),Z(KS1+II+1)        
  714 FORMAT (A23,' 6611, GRID POINT',I9,' SPECIFIED IN BOUNDARY SET',  
     1       I9,' FOR SUBSTRUCTURE ',2A4,' DOES NOT EXIST.')        
  718 IADD = LOC        
      IF (NO .GT. 1) GO TO 710        
      ICOMP = Z(IADD+2) - LSHIFT(RSHIFT(Z(IADD+2),26),26)        
      GO TO 711        
  710 ICOMP = 0        
      DO 712 J = 1,NO        
      CSET(J) = CSET(J) - LSHIFT(RSHIFT(CSET(J),26),26)        
      ICOMP = ORF(ICOMP,CSET(J))        
  712 CONTINUE        
C        
C     CHECK THAT THE RETAINED DOF ARE A SUBSET OF THE ORIGINAL.        
C        
  711 IF (ANDF( ARAY(2),ICOMP ).EQ.ARAY(2).OR.IIIERR.EQ.1) GO TO 715    
      WRITE  (OUTT,792) UWM,ARAY(1),Z(KS1+II),Z(KS1+II+1)        
  792 FORMAT (A25,' 6610, DEGREES OF FREEDOM AT GRID POINT',I9,        
     1       ' COMPONENT SUBSTRUCTURE ',2A4, /31X,'INCLUDED IN A ',     
     2       'BOUNDARY SET DO NOT EXIST. REQUEST WILL BE IGNORED.')     
      ARAY(2) = ARAY(2) - (ORF(ARAY(2),ICOMP)-ICOMP)        
C        
C     UPDATE CB ARRAY        
C        
  715 IF (NO .GT. 1) GO TO 757        
      NENT = (IADD-SCORE)/3        
      Z(IST+NENT) = ORF(Z(IST+NENT),ARAY(2))        
      GO TO 716        
  757 NENT = (IADD-SCORE)/3        
      DO 758 J = 1,NO        
      Z(IST+NENT+J-1) = ORF(Z(IST+NENT+J-1),ARAY(2))        
  758 CONTINUE        
      GO TO 716        
C        
C     BOUNDARY SET COMPLETE, IS THERE ANOTHER        
C        
  730 CALL REWIND (SCR1)        
      GO TO 737        
C        
C     WRITE IP AND CB ON SCR2        
C        
  735 I1 = SCORE        
      I2 = I1 + NOUT - 1        
      II = -1        
      DO 740 J = I1,I2,3        
      II = II + 1        
      ARAY(1) = ANDF(Z(J+2),Z(IST+II))        
      IF (ARAY(1) .NE. 0) CALL WRITE (SCR2,Z(J+1),1,0)        
      IF (ARAY(1) .NE. 0) CALL WRITE (SCR2,ARAY(1),1,0)        
  740 CONTINUE        
      CALL WRITE (SCR2,ARAY(1),0,1)        
  701 CONTINUE        
      CALL CLOSE (SCR1,1)        
      CALL CLOSE (SCR2,1)        
      IF (BAD) GO TO 2300        
C        
C     VII. PROCESS MASTER SIL LIST AND ALLOCATE SPACE FOR CNEW        
C     ********************************************************        
C        
      J = 0        
  800 CALL SUREAD (Z(SCORE+J),2,NOUT,ITEST)        
      IF (ITEST .EQ. 3) GO TO 810        
      J = J + 3        
      GO TO 800        
  810 NW = J - 3        
      DO 820 I = 1,NW,3        
      JJ = I - 1        
      Z(SCORE+JJ+2) = 0        
  820 CONTINUE        
      CALL OPEN (*2001,SCR2,Z(BUF2),0)        
  840 CALL READ (*860,*850,SCR2,ARAY,2,0,NNN)        
      ILOC = 3*ARAY(1) - 3        
      Z( SCORE+ILOC+2 ) = ORF(Z(SCORE+ILOC+2),ARAY(2))        
      GO TO 840        
C        
C     READ NEXT COMPONENT        
C        
  850 GO TO 840        
C        
C     PROCESSING COMPLETE        
C        
  860 CALL CLOSE (SCR2,1)        
      KS3   = SCORE        
      SCORE = SCORE + NW        
      KF3   = SCORE - 1        
C        
C     VIII. DEFINE PARTITIONING VECTORS PVX AND USX        
C     *********************************************        
C        
      CALL GOPEN (PVX,Z(BUF2),1)        
C        
C     GENERATE PVX DATA BLOCK IN CORE        
C        
      JJJ = 0        
      DO 900 I = 1,NW,3        
      ICODE = Z(KS3+I)        
      CALL DECODE (ICODE,LISTO,NROW)        
      DO 910 J = 1,NROW        
      RZ(SCORE+JJJ+J-1) = 0.0        
  910 CONTINUE        
      ICODE = Z(KS3+I+1)        
      CALL DECODE (ICODE,LISTN,NNEW)        
      DO 920 J = 1,NROW        
      LISTO(J) = LISTO(J) + 1        
  920 CONTINUE        
      IF (NNEW .EQ. 0) GO TO 960        
      DO 930 J = 1,NNEW        
      LISTN(J) = LISTN(J) + 1        
  930 CONTINUE        
C        
C     FIND DOF THAT REMAIN AT GIVEN IP        
C        
      DO 941 J  = 1,NNEW        
      DO 942 JJ = 1,NROW        
      IF (LISTN(J) .EQ. LISTO(JJ)) GO TO 943        
  942 CONTINUE        
      GO TO 941        
  943 IJK(J) = JJ        
  941 CONTINUE        
      DO 950 J = 1,NNEW        
      IK = IJK(J)        
      RZ(SCORE+JJJ+IK-1) = 1.0        
  950 CONTINUE        
  960 JJJ = JJJ + NROW        
  900 CONTINUE        
C        
C     SET PARAMETERS AND CALL PACK        
C        
      MCB(1) = PVX        
      MCB(2) = 0        
      MCB(3) = JJJ        
      MCB(4) = 2        
      MCB(5) = 1        
      MCB(6) = 0        
      MCB(7) = 0        
      TYPIN  = 1        
      TYPOUT = 1        
      INCR   = 1        
      IROW   = 1        
      NROW   = JJJ        
      CALL PACK (RZ(SCORE),PVX,MCB)        
      CALL WRTTRL (MCB)        
      CALL CLOSE (PVX,1)        
      IF (LONLY) GO TO 1070        
C        
C     PROCESS USX USET EQUIVALENT        
C        
      CALL OPEN  (*2001,USX,Z(BUF2),1)        
      CALL FNAME (USX,ARAY )        
      CALL WRITE (USX,ARAY,2,0)        
      CALL WRITE (USX,0.0 ,1,0)        
      CALL WRITE (USX,0.0 ,1,1)        
      MCB(1) = USX        
      MCB(2) = 0        
      MCB(3) = JJJ        
      MCB(4) = 0        
      MCB(5) = IBA + IBO + IBF        
      MCB(6) = 0        
      MCB(7) = 0        
      DO 975 J = 1,JJJ        
      JJ = J - 1        
      IF (RZ(SCORE+JJ) .EQ. 0.0) Z(SCORE+JJ) = IBF + IBO        
      IF (RZ(SCORE+JJ) .EQ. 1.0) Z(SCORE+JJ) = IBF + IBA        
  975 CONTINUE        
      CALL WRITE (USX,Z(SCORE),JJJ,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE (USX,1)        
C        
C     IX. PROCESS THE SOF FOR THE REDUCED STRUCTURE        
C     *********************************************        
C        
C        
C     PROCESS THE EQSS FOR EACH COMPONENT SUBSTRUCTURE        
C        
      CALL OPEN (*2001,SCR1,Z(BUF1),1)        
      CALL SFETCH (NAMOLD,NHEQSS,1,ITEST)        
C        
C     UPDATE (SIL,C) REPLACING SIL WITH IPNEW        
C        
      IPNEW = 1        
      DO 1002 I = KS3,KF3,3        
      IF (Z(I+2)) 1003,1004,1003        
 1004 Z(I) = 0        
      GO TO 1002        
 1003 Z(I)  = IPNEW        
      IPNEW = IPNEW + 1        
 1002 CONTINUE        
      NIPNEW = IPNEW - 1        
      NGRP   = 1        
      CALL SJUMP (NGRP)        
      DO 1020 J = 1,NCSUB        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
C        
C     WRITE EQSS ENTRY ON SCR1 IF THE OLD IP NUMBER STILL EXISTS IN THE 
C     REDUCED STRUCTURE, ALSO UPDATE DOF CODE.        
C        
      IF (NOUT .EQ. 0) GO TO 1015        
      DO 1010 I = 1,NOUT,3        
      II  = I - 1        
      IPO = Z(SCORE+II+1)        
      IADD= KS3 + (IPO-1)*3        
      IF (Z(IADD) .EQ. 0) GO TO 1010        
      ARAY(1) = Z(SCORE+II)        
      ARAY(2) = Z(IADD  )        
      ARAY(3) = Z(IADD+2)        
      CALL WRITE (SCR1,ARAY,3,0)        
 1010 CONTINUE        
 1015 CALL WRITE (SCR1,0,0,1)        
 1020 CONTINUE        
C        
C     GENERATE NEW MASTER (SIL,C) LIST        
C        
      ISIL = 1        
      DO 1030 I = KS3,KF3,3        
      IF (Z(I) .EQ. 0) GO TO 1030        
      ICODE = Z(I+2)        
      CALL DECODE (ICODE,LISTN,NDOF)        
      ARAY(1) = ISIL        
      ARAY(2) = Z(I+2)        
      CALL WRITE (SCR1,ARAY,2,0)        
      ISIL = ISIL + NDOF        
 1030 CONTINUE        
      CALL WRITE (SCR1,ARAY,0,1)        
      CALL CLOSE (SCR1,1)        
      IF (DRY .EQ. 0) GO TO 8612        
C        
C     WRITE FIRST GROUP OF EQSS        
C        
      CALL OPEN (*2001,SCR1,Z(BUF1),0)        
      CALL SETLVL (NAMNEW,1,NAMOLD,ITEST,28)        
      IF (ITEST .EQ. 8) GO TO 6518        
      ITEST = 3        
      CALL SFETCH (NAMNEW,NHEQSS,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (NAMNEW,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (NCSUB,1,ITEST)        
      ITEST = 1        
      CALL SUWRT (NIPNEW,1,ITEST)        
      DO 1040 I = KS1,KF1,2        
      ITEST = 1        
      CALL SUWRT (Z(I),2,ITEST)        
 1040 CONTINUE        
      ITEST = 2        
      CALL SUWRT (Z(I),0,ITEST)        
 1043 CALL READ (*1041,*1042,SCR1,Z(SCORE),NZ,0,NNN)        
      GO TO 2004        
 1042 CALL SUWRT (Z(SCORE),NNN,2)        
      GO TO 1043        
 1041 ITEST = 3        
      CALL SUWRT (ARAY,0,ITEST)        
      CALL CLOSE (SCR1,1)        
C        
C     WRITE BGSS FILE        
C        
      CALL SFETCH (NAMOLD,NHBGSS,1,ITEST)        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      J = 0        
C        
C     THE CID S THAT BELONG TO POINTS THAT ARE COMPLETELY REDUCED       
C     WILL BE ACCUMULATED IN BUF3.        
C        
      JJJ1 = 2        
      DO 1050 I = 1,NOUT,4        
      II = I - 1        
      IF (Z(KS3+JJJ1)) 1052,1051,1052        
 1052 IF (Z(SCORE+II) .EQ. 0) GO TO 1053        
      Z(BUF3+J) = Z(SCORE+II)        
      J = J + 1        
      GO TO 1053        
 1051 Z(SCORE+II) = -1*TPOW(2)        
 1053 JJJ1 = JJJ1 + 3        
 1050 CONTINUE        
      NCSRED = J        
      ITEST = 3        
      CALL SFETCH (NAMNEW,NHBGSS,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (NAMNEW,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (NIPNEW,1,ITEST)        
      DO 1055 I = 1,NOUT,4        
      II = I - 1        
      IF (Z(SCORE+II) .EQ. -TPOW(2)) GO TO 1055        
      ITEST = 1        
      CALL SUWRT (Z(SCORE+II),4,ITEST)        
 1055 CONTINUE        
      ITEST = 2        
      CALL SUWRT (ARAY,0,ITEST)        
      ITEST = 3        
      CALL SUWRT (ARAY,0,ITEST)        
C        
C     PROCESS THE CSTM FILES        
C        
      IF (NCSRED .NE. 0) GO TO 1063        
      CALL SFETCH (NAMOLD,NHCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 1070        
      CALL SUREAD (Z(SCORE),-2,NOUT,ITEST)        
      Z(SCORE  ) = NAMNEW(1)        
      Z(SCORE+1) = NAMNEW(2)        
      ITEST = 3        
      CALL SFETCH (NAMNEW,NHCSTM,2,ITEST)        
      ITEST = 3        
      CALL SUWRT (Z(SCORE),NOUT,ITEST)        
      GO TO 1070        
 1063 CALL SFETCH (NAMOLD,NHCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 1070        
      NGRP = 1        
      CALL SJUMP (NGRP)        
C        
C     SORT THE DELETED CID S        
C        
      CALL SORT (0,0,1,1,Z(BUF3),NCSRED)        
C        
C     READ ALL RETAINED CSTM DATA INTO OPEN CORE        
C        
      J = 0        
 1065 CALL SUREAD (Z(SCORE+J),14,NOUT,ITEST)        
      IF (ITEST .EQ. 2) GO TO 1066        
      IF (Z(SCORE+J) .EQ. 0) GO TO 1065        
      KID = Z(SCORE+J)        
      CALL BISLOC (*1065,KID,Z(BUF3),1,NCSRED,JP)        
      J = J + 14        
      GO TO 1065        
 1066 ITEST = 3        
      CALL SFETCH (NAMNEW,NHCSTM,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (NAMNEW,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (Z(SCORE),J,ITEST)        
      ITEST = 3        
      CALL SUWRT (ARAY,0,ITEST)        
 1070 CONTINUE        
C        
C     PROCESS LODS ITEM        
C        
      CALL SFETCH (NAMOLD,LITM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 1080        
      CALL SUREAD (Z(SCORE),-2,NOUT,ITEST)        
      Z(SCORE  ) = NAMNEW(1)        
      Z(SCORE+1) = NAMNEW(2)        
      ITEST = 3        
      CALL SFETCH (NAMNEW,LITM,2,ITEST)        
      ITEST = 3        
      CALL SUWRT (Z(SCORE),NOUT,ITEST)        
 1080 CONTINUE        
      IF (LONLY) GO TO 8511        
C        
C     PROCESS PLTS ITEM        
C        
      CALL SFETCH (NAMOLD,NHPLTS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 1090        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      Z(SCORE  ) = NAMNEW(1)        
      Z(SCORE+1) = NAMNEW(2)        
      ITEST = 3        
      CALL SFETCH (NAMNEW,NHPLTS,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (Z(SCORE),NOUT,ITEST)        
      ITEST = 3        
      CALL SUWRT (Z(SCORE),0,ITEST)        
 1090 CONTINUE        
C        
C     PROCESS OUTPUT REQUESTS        
C        
      IF (ANDF(RSHIFT(PRTOPT,4),1) .NE. 1) GO TO 8211        
C        
C     WRITE EQSS FOR NEW STRUCTURE        
C        
      CALL SFETCH (NAMNEW,NHEQSS,1,ITEST)        
      CALL SUREAD (Z(SCORE),4,NOUT,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      IST = SCORE + NOUT        
      DO 8212 I = 1,NCSUB        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      IADD = SCORE + 2*(I-1)        
      CALL CMIWRT (1,NAMNEW,Z(IADD),IST,NOUT,Z,Z)        
 8212 CONTINUE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (8,NAMNEW,0,IST,NOUT,Z,Z)        
 8211 IF (ANDF(RSHIFT(PRTOPT,5),1) .NE. 1) GO TO 8311        
C        
C     WRITE NEW BGSS        
C        
      CALL SFETCH (NAMNEW,NHBGSS,1,ITEST)        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      IST = SCORE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (2,NAMNEW,NAMNEW,IST,NOUT,Z,Z)        
 8311 IF (ANDF(RSHIFT(PRTOPT,6),1) .NE. 1) GO TO 8411        
C        
C     WRITE CSTM ITEM        
C        
      CALL SFETCH (NAMNEW,NHCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 8411        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      IST = SCORE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (3,NAMNEW,NAMNEW,IST,NOUT,Z,Z)        
 8411 IF (ANDF(RSHIFT(PRTOPT,7),1) .NE. 1) GO TO 8511        
C        
C     WRITE PLTS ITEM        
C        
      CALL SFETCH (NAMNEW,NHPLTS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 8511        
      IST = SCORE        
      CALL SUREAD (Z(IST),3,NOUT,ITEST)        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (4,NAMNEW,NAMNEW,IST,NOUT,Z,Z)        
 8511 IF (ANDF(RSHIFT(PRTOPT,8),1) .NE. 1) GO TO 8611        
C        
C     WRITE LODS ITEM        
C        
      CALL SFETCH (NAMNEW,LODS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 8611        
      CALL SUREAD (Z(SCORE),4,NOUT,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      IST   = SCORE + NOUT        
      ITYPE = 5        
      IF (LITM .EQ. LOAP) ITYPE = 7        
      DO 8512 I = 1,NCSUB        
      IADD = SCORE+2*(I-1)        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (ITYPE,NAMNEW,Z(IADD),IST,NOUT,Z,Z)        
      ITYPE = 6        
 8512 CONTINUE        
 8611 CONTINUE        
      IF (LONLY) GO TO 1105        
C        
C     X. GENERATE THE INX OUTPUT DATA BLOCK        
C     *************************************        
C        
 8612 CALL GOPEN (INX,Z(BUF2),1)        
      MCB(1) = INX        
      MCB(2) = 0        
      MCB(3) = ISIL - 1        
      MCB(4) = 1        
      MCB(5) = 1        
      MCB(6) = 0        
      MCB(7) = 0        
      TYPIN  = 1        
      TYPOUT = 1        
      INCR   = 1        
      ISILM1 = ISIL - 1        
      DO 1100 I = 1,ISILM1        
      IROW = I        
      NROW = I        
      CALL PACK (1.0,INX,MCB)        
 1100 CONTINUE        
      CALL WRTTRL (MCB)        
      CALL CLOSE (INX,1)        
 1105 CALL SOFCLS        
      RETURN        
C        
 2100 WRITE  (OUTT,2101) UFM        
 2101 FORMAT (A23,' 6535, MODULE REDUCE TERMINATING DUE TO ABOVE ',     
     1       'SUBSTRUCTURE CONTROL ERRORS.')        
      GO TO 2400        
C        
 2200 WRITE  (OUTT,2201) UFM        
 2201 FORMAT (A23,' 6536, MODULE REDUCE TERMINATING DUE TO ABOVE ',     
     1       'ERRORS IN BULK DATA.')        
      CALL CLOSE (GEOM4,1)        
      GO TO 2400        
C        
 2300 WRITE  (OUTT,2301) UFM        
 2301 FORMAT (A23,' 6537, MODULE REDUCE TERMINATING DUE TO ABOVE ',     
     1       'ERRORS.')        
 2400 DRY = -2        
      CALL SOFCLS        
      RETURN        
C        
 6518 WRITE  (OUTT,6519) UFM        
 6519 FORMAT (A23,' 6518, ONE OF THE COMPONENT SUBSTRUCTURES HAS BEEN ',
     1       'USED IN A PREVIOUS COMBINE OR REDUCE.')        
      GO TO 2300        
 2001 IMSG = -1        
      GO TO 2998        
 2002 IMSG = -2        
      GO TO 2998        
 2003 IMSG = -3        
      GO TO 2998        
 2004 IMSG = -8        
 2998 CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
      END        
