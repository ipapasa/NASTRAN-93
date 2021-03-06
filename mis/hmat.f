      SUBROUTINE HMAT (ID)        
C        
C     MAT ROUTINE FOR USE IN -HEAT- FORMULATIONS ONLY.        
C        
C         CALL PREHMA (Z)  SETUP CALL MADE BY SMA1A, EMGTAB, ETC.       
C        
C         CALL HMAT (ELID)  ELEMENT ROUTINE CALLS        
C        
C        
C     REVISED BY G.CHAN/UNISYS        
C     5/90 - THE THERMAL CONDUCTIVITY OR CONVECTIVE FILM COEFFICIENT K, 
C            IS TIME DEPENDENT IF MATT4 REFERS TO TABLEM5. TIME STEP IS 
C            DEFINED VIA TSTEP IN /HMATDD/. IF TIME STEP IS NOT USED,   
C            TSTEP SHOULD BE -999.        
C            (TSTEP IS INITIALIZED TO -999. WHEN PREHMA IS CALLED)      
C     7/92 - NEW REFERENCE TO OPEN CORE ARRAY SUCH THAT THE SOURCE CODE 
C            IS UP TO ANSI FORTRAN 77 STANDARD.        
C        
      LOGICAL         ANY4    ,ANY5    ,ANYT4   ,ANYT5   ,LINEAR  ,     
     1                ANYTAB        
      INTEGER         NAME(2) ,SYSBUF  ,OUTPT   ,FLAG    ,CORE    ,     
     1                DIT     ,OLDMID  ,OLDFLG  ,CLSREW  ,CLS     ,     
     2                TYPE    ,MAT4(2) ,MAT5(2) ,MATT4(2),MATT5(2),     
     3                TSET    ,OFFSET  ,TABLST(16)        
      REAL            CARD(10),RZ(1)        
      CHARACTER       UFM*23  ,UWM*25  ,UIM*29  ,SFM*25        
      COMMON /XMSSG / UFM     ,UWM     ,UIM     ,SFM        
CZZ   COMMON /XNSTRN/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /MATIN / MATID   ,INFLAG  ,ELTEMP  ,DUM(1)  ,S       ,C    
      COMMON /HMTOUT/ BUF(7)        
      COMMON /NAMES / RD      ,RDREW   ,WRT     ,WRTREW  ,CLSREW  ,CLS  
      COMMON /HMATDD/ IHMATX  ,NHMATX  ,MPT     ,DIT     ,LINEAR  ,     
     1                ANYTAB  ,TSTEP        
      COMMON /SYSTEM/ KSYSTM(65)        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF) ,(KSYSTM( 2),OUTPT ) ,        
     1                (KSYSTM(10),TSET  ) ,(KSYSTM(56),ITHERM) ,        
     2                (F4,N4)    ,(F5,N5)        
      DATA    NAME  / 4HHMAT,4H    /, NOEOR  / 0 /        
      DATA    MAT4  / 2103  ,21    /        
      DATA    MAT5  / 2203  ,22    /        
      DATA    MATT4 / 2303  ,23    /        
      DATA    MATT5 / 2403  ,24    /        
      DATA    TABLST/ 5, 105,1,1,  205,2,2, 305,3,3, 405,4,4, 505,5,5 / 
C        
C     CALL BUG (4HHMTI,0,MATID,6)        
C        
      IF (ICHECK .NE. 123456789) CALL ERRTRC ('HMAT    ',0)        
      GO TO 200        
C        
C        
      ENTRY PREHMA (RZ)        
C     =================        
C        
      IF (ITHERM) 500,500,10        
   10 ICHECK = 123456789        
      OFFSET = LOCFX(RZ(1)) - LOCFX(Z(1))        
      IF (OFFSET .LT. 0) CALL ERRTRC ('HMAT    ',10)        
      TSTEP  = -999.        
      IHMAT  = IHMATX + OFFSET        
      NHMAT  = NHMATX + OFFSET        
      LBUF   = NHMAT  - SYSBUF        
      CORE   = LBUF   - IHMAT        
      IF (CORE .LT. 10) CALL MESAGE (-8,0,NAME)        
      CALL PRELOC (*125,Z(LBUF),MPT)        
C        
C     LOCATE MAT4 CARDS AND BLAST THEM INTO CORE.        
C        
      ANYTAB =.FALSE.        
      ANY4   =.FALSE.        
      IMAT4  = IHMAT + 1        
      NMAT4  = IHMAT        
      CALL LOCATE (*40,Z(LBUF),MAT4,FLAG)        
      CALL READ (*480,*30,MPT,Z(IMAT4),CORE,NOEOR,IWORDS)        
      CALL MESAGE (-8,0,NAME)        
   30 NMAT4 =  NMAT4 + IWORDS        
   40 MAT4S = (NMAT4 - IMAT4 + 1)/3        
      IF (MAT4S .GT. 0) ANY4 = .TRUE.        
C        
C     LOCATE MATT4 CARDS AND BLAST THEM INTO CORE IF THERE WERE ANY MAT4
C        
      ANYT4  =.FALSE.        
      IMATT4 = NMAT4 + 1        
      NMATT4 = NMAT4        
      IF (.NOT.ANY4 .OR. (TSET.EQ.0 .AND. TSTEP.LT.0.)) GO TO 60        
      CALL LOCATE (*60,Z(LBUF),MATT4,FLAG)        
      CALL READ (*480,*50,MPT,Z(IMATT4),CORE,NOEOR,IWORDS)        
      CALL MESAGE (-8,0,NAME)        
   50 NMATT4 =  NMATT4 + IWORDS        
   60 MATT4S = (NMATT4 - IMATT4 + 1)/2        
      IF (MATT4S .GT. 0) ANYT4 = .TRUE.        
C        
C     LOCATE MAT5 CARDS AND BLAST THEM INTO CORE.        
C        
      ANY5  =.FALSE.        
      IMAT5 = NMATT4 + 1        
      NMAT5 = NMATT4        
      CALL LOCATE (*80,Z(LBUF),MAT5,FLAG)        
      CALL READ (*480,*70,MPT,Z(IMAT5),CORE,NOEOR,IWORDS)        
      CALL MESAGE (-8,0,NAME)        
   70 NMAT5 =  NMAT5 + IWORDS        
   80 MAT5S = (NMAT5 - IMAT5 + 1)/8        
      IF (MAT5S .GT. 0) ANY5 = .TRUE.        
C        
C     LOCATE MATT5 CARDS AND BLAST THEM INTO CORE IF THERE WERE ANY MAT5
C        
      ANYT5  =.FALSE.        
      IMATT5 = NMAT5 + 1        
      NMATT5 = NMAT5        
      IF (.NOT.ANY5 .OR. (TSET.EQ.0 .AND. TSTEP.LT.0.)) GO TO 100       
      CALL LOCATE (*100,Z(LBUF),MATT5,FLAG)        
      CALL READ (*480,*90,MPT,Z(IMATT5),CORE,NOEOR,IWORDS)        
      CALL MESAGE (-8,0,NAME)        
   90 NMATT5 =  NMATT5 + IWORDS        
  100 MATT5S = (NMATT5 - IMATT5 + 1)/7        
      IF (MATT5S .GT. 0) ANYT5 = .TRUE.        
      CALL CLOSE (MPT,CLSREW)        
C        
C     IF A TEMPERATURE SET IS SPECIFIED -DIT- IS NOW READ INTO CORE,    
C     PROVIDING ANY MATT4 OR MATT5 CARDS WERE PLACED INTO CORE.        
C        
      IF ((TSET.EQ.0 .AND. TSTEP.LT.0.) .OR.        
     1   (.NOT.ANYT4 .AND. .NOT.ANYT5)) GO TO 130        
C        
C     BUILD LIST OF TABLE NUMBERS POSSIBLE FOR REFERENCE        
C        
      KK = 0        
      ITABNO = NMATT5 + 1        
      NTABNO = ITABNO        
C        
      IF (MATT4S .LE. 0) GO TO 110        
      DO 108 I = IMATT4,NMATT4,2        
      F4 = Z(I+1)        
      IF (N4) 108,108,102        
  102 IF (KK) 107,107,103        
  103 DO 105 J = ITABNO,NTABNO        
      F5 = Z(J)        
      IF (N4 .EQ. N5) GO TO 108        
  105 CONTINUE        
C        
C     ADD NEW TABLE ID TO LIST        
C        
  107 NTABNO = NTABNO + 1        
      Z(NTABNO) = Z(I+1)        
      KK = 1        
  108 CONTINUE        
C        
  110 IF (MATT5S .LE. 0) GO TO 120        
      DO 118 I = IMATT5,NMATT5,7        
      J1 = I + 1        
      J2 = I + 6        
      DO 117 J = J1,J2        
      F4 = Z(J)        
      IF (N4) 117,117,111        
  111 IF (KK) 115,115,113        
  113 DO 114 K = ITABNO,NTABNO        
      F5 = Z(K)        
      IF (N4 .EQ. N5) GO TO 117        
  114 CONTINUE        
C        
C     ADD NEW TABLE ID TO LIST        
C        
  115 NTABNO = NTABNO + 1        
      Z(NTABNO) = Z(J)        
      KK = 1        
  117 CONTINUE        
  118 CONTINUE        
C        
  120 N4 = NTABNO - ITABNO        
      Z(ITABNO) = F4        
C        
C     CALL BUG (4HTABL,120,Z(ITABNO),NTABNO-ITABNO+1)        
C        
      IF (N4) 130,130,122        
  122 CALL SORT (0,0,1,1,Z(ITABNO+1),N4)        
C        
C     OK READ IN DIRECT-INPUT-TABLE (DIT)        
C        
      IDIT  = NTABNO + 1        
      IGBUF = NHMAT - SYSBUF - 2        
      LZ    = IGBUF - IDIT  - 1        
      IF (LZ .LT. 10) CALL MESAGE (-8,0,NAME)        
      CALL PRETAB (DIT,Z(IDIT),Z(IDIT),Z(IGBUF),LZ,LUSED,Z(ITABNO),     
     1             TABLST)        
      NDIT  = IDIT + LUSED        
      NHMAT = NDIT + 1        
C        
C     CALL BUG (4HDITS,123,Z(IDIT),NDIT-IDIT+1)        
C        
      GO TO 140        
C        
C     WRAP UP THE PRE-HMAT SECTION        
C        
  125 NHMAT = IHMAT - 1        
      ANY4  =.FALSE.        
      ANY5  =.FALSE.        
      GO TO 140        
  130 NHMAT  = NMATT5        
  140 OLDMID = 0        
      OLDFLG = 0        
      OLDSIN = 0.0        
      OLDCOS = 0.0        
      OLDTEM = 0.0        
      OLDSTP = 0.0        
      S      = 0.0        
      C      = 0.0        
      DUM(1) = 0.0        
      ELTEMP = 0.0        
      NHMATX = NHMAT - OFFSET        
C        
C     CHECK FOR DUPLICATE MATID-S ON BOTH MAT4 AND MAT5 CARDS.        
C        
      IF (.NOT.ANY4 .OR. .NOT.ANY5) GO TO 490        
      J4 = IMAT4        
      J5 = IMAT5        
      F4 = Z(J4)        
      F5 = Z(J5)        
  150 IF (N4 - N5) 160,180,170        
C        
C     MAT4 ID IS LESS THAN MAT5 ID        
C        
  160 J4 = J4 + 3        
      IF (J4 .GT. NMAT4) GO TO 490        
      F4 = Z(J4)        
      GO TO 150        
C        
C     MAT5 ID IS LESS THAN MAT4 ID.        
C        
  170 J5 = J5 + 8        
      IF (J5 .GT. NMAT5) GO TO 490        
      F5 = Z(J5)        
      GO TO 150        
C        
C     ID OF MAT4 IS SAME AS THAT OF MAT5        
C        
  180 WRITE  (OUTPT,190) UWM,N4        
  190 FORMAT (A25,' 2155, MAT4 AND MAT5 MATERIAL DATA CARDS HAVE SAME ',
     1       'ID =',I14, /5X,'MAT4 DATA WILL BE SUPPLIED WHEN CALLED ', 
     2       'FOR THIS ID.')        
      GO TO 170        
C        
C                 DATA RETURNED IF MAT-ID       DATA RETURNED IF MAT-ID 
C     INFLAG      IS ON A MAT4 CARD             IS ON A MAT5 CARD.      
C     ================================================================= 
C        
C       1           1- K                               1- KXX        
C                   2- CP                              2- CP        
C        
C       2           1- K                               1- KXXB        
C                   2- 0.0                             2- KXYB        
C                   3- K                               3- KYYB        
C                   4- CP                              4- CP        
C        
C       3           1- K                               1- KXX        
C                   2- 0.0                             2- KXY        
C                   3- 0.0                             3- KXZ        
C                   4- K                               4- KYY        
C                   5- 0.0                             5- KYZ        
C                   6- K                               6- KZZ        
C                   7- CP                              7- CP        
C        
C       4           1- CP                              1- CP        
C        
C        
C        
C        
C     DATA LOOK UP SECTION.  FIND MAT-ID IN CARD IMAGES.        
C        
C        
  200 IF (INFLAG - OLDFLG) 260,210,260        
  210 IF (MATID  - OLDMID) 260,220,260        
  220 IF (ELTEMP - OLDTEM) 260,225,260        
  225 IF (TSTEP  - OLDSTP) 260,230,260        
  230 IF (TYPE  .EQ.    4) GO TO 250        
      IF (S      - OLDSIN) 260,240,260        
  240 IF (C      - OLDCOS) 260,250,260        
C        
C     ALL INPUTS SEEM TO BE SAME THUS RETURN IS MADE.        
C        
  250 GO TO 490        
C        
C     FIND POINTER TO SECOND WORD OF CARD IMAGE WITH MAT-ID DESIRED.    
C     AMONG EITHER MAT4S OR MAT5S.        
C        
  260 OLDFLG = INFLAG        
      OLDMID = MATID        
      OLDCOS = C        
      OLDSIN = S        
      OLDTEM = ELTEMP        
      OLDSTP = TSTEP        
      LINEAR = .TRUE.        
      IF (.NOT.ANY4) GO TO 270        
      CALL BISLOC (*270,MATID,Z(IMAT4),3,MAT4S,JPOINT)        
      J = IMAT4 + JPOINT        
      TYPE = 4        
      GO TO 280        
  270 IF (.NOT. ANY5) GO TO 460        
      CALL BISLOC (*460,MATID,Z(IMAT5),8,MAT5S,JPOINT)        
      J = IMAT5 + JPOINT        
      TYPE = 5        
C        
C     IF A THERMAL SET IS REQUESTED (TSET.NE.0) THEN A FACTOR, WHICH IS 
C     A FUNCTION OF THE AVERAGE ELEMENT TEMPERATURE, ELTEMP, (OR TIME   
C     STEP, TSTEP) AND THE TABULATED VALUE IN TABLEMI, IS USED AS A     
C     MULTIPLIER TO THE K-TERMS IN MAT4 OR MATT5        
C        
C     IF THE MATERIAL ID IS FOUND ON A -MAT4- AN ATTEMPT IS MADE TO FIND
C     A CORRESPONDING -MATT4- CARD.  LIKEWISE THIS IS DONE IF THE       
C     MATERIAL ID IS FOUND ON A -MAT5- CARD WITH RESPECT TO A -MATT5-   
C     CARD. IF THE -MAT4- OR -MAT5- HAS A RESPECTIVE -MATT4- OR -MATT5- 
C     CARD, THEN THE THERMAL CONDUCTIVITY OR THE CONVECTIVE FILM COEFF. 
C     K, IS TEMPERATURE DEPENDENT IF TABLEM1, TABLEM2, TABLEM3 AND      
C     TABLEM4 ARE REFERENECED. K IS TIME DEPENDENT IF TABLEM5 IS USED.  
C     THE K-TERMS OF THE -MAT4- OR -MAT5- CARDS WILL BE MODIFIED BY     
C     USING -ELTEMP- AND THE -DIT- AS SPECIFIED IN THE RESPECTIVE FIELDS
C     OF THE RESPECTIVE -MATT4- OR -MATT5- CARD.  A ZERO T(K) IN A      
C     PARTICULAR FIELD OF THE RESPECTIVE -MATT4- OR -MATT5- CARD IMPLIES
C     NO TEMPERATURE DEPENDENCE FOR THAT RESPECTIVE K VALUE.        
C     -DIT- TABLES TABLEM1, TABLEM2, TABLEM3, TABLEM4 AND TABLEM5 MAY BE
C     USED.        
C        
C        
C     MOVE MAT CARD INTO SPECIAL BUF WHERE IT CAN BE MODIFIED IF        
C     NECESSARY        
C        
  280 DO 290 I = 1,10        
      CARD(I) = Z(J)        
      J = J + 1        
  290 CONTINUE        
C        
C     CHECK FOR EXISTENCE OF A THERMAL SET REQUEST OR TIME STEP.        
C        
      IF ((TSET.EQ.0 .AND. TSTEP.LT.0.) .OR. INFLAG.EQ.4) GO TO 350     
C        
C     IF -MAT4- CARD, FIND THE -MATT4- CARD        
C     (IF NO MATT4 ASSUME NO TEMPERATURE OR TIME DEPENDENCE)        
C        
      IF (TYPE .EQ. 5) GO TO 300        
      IWORDS = 2        
      IMAT   = IMATT4        
      MATS   = MATT4S        
      GO TO 310        
  300 IWORDS = 7        
      IMAT   = IMATT5        
      MATS   = MATT5S        
  310 IF (MATS) 350,350,315        
  315 CALL BISLOC (*350,MATID,Z(IMAT),IWORDS,MATS,JPOINT)        
      ITEMP =  IMAT + JPOINT        
      NTEMP = ITEMP + IWORDS - 2        
C        
C     Z(I) FIELDS SPECIFYING A NON-ZERO TABLE IMPLY TEMPERATURE (OR     
C     TIME) DEPENDENCE ON CORRESPONDING FIELDS OF THE MAT4 OR MAT5      
C     STORED IN THE ARRAY -CARD-.        
C        
      KK = 0        
      DO 340 I = ITEMP,NTEMP        
      KK = KK + 1        
      F4 = Z(I)        
      IF (N4) 340,340,320        
C        
C     OK TEMPERATURE (OR TIME) DEPENDENCE.        
C        
  320 IF (TSET  .GT.  0) X = ELTEMP        
      IF (TSTEP .GE. 0.) X = TSTEP        
      CALL TAB (N4,X,FACTOR)        
      CARD(KK) = CARD(KK)*FACTOR        
      LINEAR = .FALSE.        
  340 CONTINUE        
C        
C     BRANCH ON INFLAG.        
C        
  350 IF (INFLAG.LT.1 .OR. INFLAG.GT.4) GO TO 440        
      GO TO (360,380,400,420), INFLAG        
C        
C     INFLAG = 1        
C        
  360 IF (TYPE .EQ. 5) GO TO 370        
      BUF(1) = CARD(1)        
      BUF(2) = CARD(2)        
      GO TO 490        
  370 BUF(1) = CARD(1)        
      BUF(2) = CARD(7)        
      GO TO 490        
C        
C     INFLAG = 2        
C        
  380 IF (TYPE .EQ. 5) GO TO 390        
      BUF(1) = CARD(1)        
      BUF(2) = 0.0        
      BUF(3) = BUF(1)        
      BUF(4) = CARD(2)        
      GO TO 490        
  390 CSQ = C*C        
      SSQ = S*S        
      CS  = C*S        
      CS2KXY = CS *2.0*CARD(2)        
      BUF(1) = CSQ* CARD(1) - CS2KXY   +  SSQ*CARD(4)        
      BUF(2) = CS *(CARD(1) - CARD(4)) + (CSQ - SSQ)*CARD(2)        
      BUF(3) = SSQ* CARD(1) + CS2KXY   +  CSQ*CARD(4)        
      BUF(4) = CARD(7)        
      GO TO 490        
C        
C     INFLAG = 3        
C        
  400 IF (TYPE .EQ. 5) GO TO 410        
      BUF(1) = CARD(1)        
      BUF(2) = 0.0        
      BUF(3) = 0.0        
      BUF(4) = BUF(1)        
      BUF(5) = 0.0        
      BUF(6) = BUF(1)        
      BUF(7) = CARD(2)        
      GO TO 490        
  410 BUF(1) = CARD(1)        
      BUF(2) = CARD(2)        
      BUF(3) = CARD(3)        
      BUF(4) = CARD(4)        
      BUF(5) = CARD(5)        
      BUF(6) = CARD(6)        
      BUF(7) = CARD(7)        
      GO TO 490        
C        
C     INFLAG = 4.  RETURN ONLY CP.        
C        
  420 IF (TYPE .EQ. 5) GO TO 430        
      BUF(1) = CARD(2)        
      GO TO 490        
  430 BUF(1) = CARD(7)        
      GO TO 490        
C        
C     ERROR CONDITIONS        
C        
  440 WRITE  (OUTPT,450) SFM,INFLAG        
  450 FORMAT (A25,' 2156, ILLEGAL INFLAG =',I14,' RECEIVED BY HMAT.')   
      GO TO 520        
  460 WRITE  (OUTPT,470) UFM,MATID        
  470 FORMAT (A23,' 2157, MATERIAL ID =',I14,        
     1       ' DOES NOT APPEAR ON ANY MAT4 OR MAT5 MATERIAL DATA CARD.')
      GO TO 520        
  480 CALL MESAGE (-2,MPT,NAME)        
      GO TO 520        
C        
C     RETURN LOGIC        
C        
  490 CONTINUE        
C        
C     CALL BUG (4HHMAT,490,BUF,7)        
C        
      RETURN        
C        
C     ERROR - HMAT CALLED IN NON-THERMAL PROBLEM.        
C        
  500 WRITE  (OUTPT,510) SFM        
  510 FORMAT (A25,' 3062, HMAT MATERIAL ROUTINE CALLED IN A NON-HEAT-', 
     1       'TRANSFER PROBLEM.')        
  520 CALL MESAGE (-61,0,0)        
      RETURN        
      END        
