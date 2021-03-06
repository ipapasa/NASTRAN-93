      SUBROUTINE NSINFO (JUMP)        
C        
C     THIS ROUTINE READS AND PROCESSES DATA IN THE NASINFO FILE        
C        
C     JUMP = 2, NSINFO IS CALLED BY NASCAR TO OPEN NASINFO FILE AND     
C               PROCESS THE SYSTEM PRESET PARAMETERS IN THE 2ND SECTION 
C               OF THE FILE, AND THE BCD WORDS (USED ONLY BY NUMTYP     
C               SUBROUTINE) IN THE 3RD SECTION        
C     JUMP = 3, NSINFO IS CALLED BY TTLPGE TO PROCESS THE INSTALLATION- 
C               CENTER-TO-USER MESSAGES STORED IN THE 4TH SECTION OF    
C               THE NASINFO FILE        
C     JUMP = 4, NSINFO IS CALLED BY XCSA TO ECHO DIAG 48 MESSAGE STORED 
C               IN THE 5TH SECITON OF THE NASINFO FILE.        
C        
C     SINCE DIAG48 MAY NOT BE CALLED, NASINFO FILE IS CLOSED BY XCSA    
C        
C     WRITTEN BY G.CHAN/UNISYS    6/1990        
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER         NAME(2),NTAB(5),CARDX(4),CARD(20),DIAG48(4)       
      REAL            TIME        
      CHARACTER*7     NASINF(8)        
      CHARACTER*14    NAS14(4)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ SYS(100)        
      COMMON /NTIME / NT,TIME(16)        
      COMMON /OUTPUT/ DUM(64),PGHDG3(32)        
      COMMON /NUMTPX/ NBCD,BCD(1)        
      COMMON /BLANK / IBLNK(60)        
      EQUIVALENCE     (NASINF(1),NAS14(1)), (CARDX(1),CARD(1))        
      EQUIVALENCE     (SYS(1),SYSBUF), (SYS( 2),NOUT), (SYS( 9),NLPP  ),
     1                (SYS(14),MXLNS), (SYS(19),EHCO), (SYS(31),HICORE),
     2                (SYS(35),LPRUS), (SYS(37),LU  ), (SYS(36),NPRUS ),
     3                (SYS(20),PLTOP), (SYS(92),DICT), (SYS(76),NOSBE ),
     4                (SYS(77),BNDIT), (SYS(91),LPCH)        
      DATA    NTAB  / 1, 5, -2, -3, 5   /  ,   TTPG     / 0            /
      DATA    NASINF/ 'NASINFO','.DOC   '  ,   '*NASINF','O.     '     ,
     1                'NASINFO','       '  ,   'XXXXXXX','XXXXX  '     /
      DATA    EQU   , R  ,  S  ,  BNK      ,   EQUALS   , NAME         /
     1        1H=   , 1HR,  1HS,  4H       ,   4H====   , 4HNSIN,2HFO  /
      DATA    RELSE , TPG,  POP,  TIM,  MXL,   BSZ      , S3S   ,SKP3  /
     1        4HELEA, 3HTPG,3HPOP,3HTIM,3HMXL, 3HBSZ    , 3HS3S ,0     /
      DATA    LPP   , HIC,  BND,  ECH,  NOS,   PRU,  NPR,  PCH,  END   /
     1        3HLPP , 3HHIC,3HBND,3HECH,3HNOS, 3HPRU,3HNPR,3HPCH,3HEND /
      DATA    S88   , S89,  S90,  S92,  S94,   S96,  S97,  S98,  S99   /
     1        3HS88 , 3HS89,3HS90,3HS92,3HS94, 3HS96,3HS97,3HS98,3HS99 /
      DATA    DIAG48                         , DD   ,DIC  ,COD  ,KEY   /
     1        4H D I, 4H A G, 4H   4, 2H 8   , 3H$. ,3HDIC,3HCOD,3HKEY /
C        
      GO TO (550,200,350,400), JUMP        
C        
C     JUMP = 2        
C     ========        
C        
C     OPEN NASINFO FILE, AND SET LU, THE 37TH WORD OF /SYSTEM/        
C        
C     CURRENTLY 'NASINFO' IS USED FOR ALL MACHINES OF TYPE 5 AND HIGHER 
C        
 200  LU  = 12        
      IF (MACH .EQ. 3) LU = 1        
      I = MIN0(MACH,5)        
      N = NTAB(I)        
      IF (N .EQ.  0) STOP ' N=0 IN NSINFO'        
      IF (N .LT.  0) OPEN (UNIT=LU,FILE=NAS14(-N),STATUS='OLD',ERR=280) 
      IF (N .GT.  0) OPEN (UNIT=LU,FILE=NASINF(N),STATUS='OLD',ERR=280  
     1                    ,SHARED,READONLY)     ! <== VAX        
C        
C     SEARCH FOR FIRST EQUAL-LINE        
C        
 210  READ (LU,220,ERR=275,END=275) CARDX        
 220  FORMAT (20A4)        
      IF (CARD(1).NE.EQUALS .AND. CARD(2).NE.EQUALS) GO TO 210        
C        
C     READ AND PROCESS THE 2ND SECTION OF NASINFO FILE        
C        
 230  READ (LU,235,END=500) SYMBOL,EQ,VALUE        
 235  FORMAT (A4,A1,I7)        
      IF (SYMBOL .EQ. BNK) GO TO 230        
      IF (EQ     .NE. EQU) GO TO 520        
      IF (SYMBOL .EQ. TIM) GO TO 250        
      IF (SYMBOL .EQ. END) GO TO 290        
      IF (VALUE  .EQ. -99) GO TO 230        
      IF (SYMBOL .EQ. S3S) GO TO 240        
      IF (SYMBOL .EQ. BSZ) SYSBUF  = VALUE        
      IF (SYMBOL .EQ. LPP) NLPP    = VALUE        
      IF (SYMBOL .EQ. HIC) HICORE  = VALUE        
      IF (SYMBOL .EQ. MXL) MXLNS   = VALUE        
      IF (SYMBOL .EQ. TPG) TTPG    = VALUE        
      IF (SYMBOL .EQ. ECH) ECHO    = VALUE        
      IF (SYMBOL .EQ. PCH) LPCH    = VALUE        
      IF (SYMBOL .EQ. DIC) DICT    = VALUE        
      IF (SYMBOL .EQ. BND) BNDIT   = VALUE        
      IF (SYMBOL .EQ. POP) PLTOP   = VALUE        
      IF (SYMBOL .EQ. PRU) LPRUS   = VALUE        
      IF (SYMBOL .EQ. NPR) NPRUS   = VALUE        
      IF (SYMBOL .EQ. NOS) NOSBE   = VALUE        
      IF (SYMBOL .EQ. COD) CODE    = VALUE        
      IF (SYMBOL .EQ. KEY) KEY     = VALUE        
      SYMB1 = KHRFN1(BNK,1,SYMBOL,1)        
      IF (SYMB1  .NE.   S) GO TO 230        
      IF (SYMBOL .EQ. S88) SYS(88) = VALUE        
      IF (SYMBOL .EQ. S89) SYS(89) = VALUE        
      IF (SYMBOL .EQ. S90) SYS(90) = VALUE        
      IF (SYMBOL .EQ. S92) SYS(92) = VALUE        
      IF (SYMBOL .EQ. S94) SYS(94) = VALUE        
      IF (SYMBOL .EQ. S96) SYS(96) = VALUE        
      IF (SYMBOL .EQ. S97) SYS(97) = VALUE        
      IF (SYMBOL .EQ. S98) SYS(98) = VALUE        
      IF (SYMBOL .EQ. S99) SYS(99) = VALUE        
      GO TO 230        
C        
C     SKIP JUMP 3 PRINTOUT        
C        
 240  SKP3 = 1        
      GO TO 230        
C        
C     READ IN 16 GINO TIME CONSTANTS (NT=16)        
C        
 250  IF (VALUE .NE. NT) GO TO 270        
      READ (LU,260,END=500) TIME        
 260  FORMAT (12X,8F7.2, /12X,8F7.2)        
      GO TO 230        
 270  READ (LU,235,END=500) SYMBOL        
      READ (LU,235,END=500) SYMBOL        
      GO TO 230        
C        
C     NASINFO DOES NOT EXIST (or IS WRITE-PROTECTED), SET LU TO ZERO    
C        
 275  CLOSE (UNIT=LU)        
      CALL MESAGE (2,0,NAME)        
 280  IF (N .GT. 0) N = -(N+1)/2        
      WRITE  (NOUT,285) UWM,NAS14(-N)        
 285  FORMAT (A25,' 3001, ATTEMPT TO OPEN DATA SET ',A14,' WHICH DOES', 
     1       ' NOT EXIST')        
      IF (MACH.EQ.5 .OR. MACH.EQ.21) WRITE (NOUT,286)        
 286  FORMAT (5X,'or IS WRITE-PROTECTED')        
      LU = 0        
      GO TO 550        
C        
C     READ PASS THE 2ND EQUAL-LINE. CONTINUE INTO 3RD SECTION        
C        
 290  READ (LU,220,END=500) CARDX        
      IF (CARD(1).NE.EQUALS .AND. CARD(2).NE.EQUALS) GO TO 290        
C        
      CALL CODKEY (CODE,KEY)        
C        
C     THIS 3RD SECTION CONTAINS BCD WORDS WHICH ARE REALLY REAL NUMBERS.
C     (THE BINARAY REPRESENTATIONS OF SOME REAL NUMBERS AND THEIR       
C     CORRESPONDING BCD WORDS ARE EXACTLY THE SAME. SUBROUTINE NUMTYP   
C     MAY IDENTIFY THEM AS TYPE BCD. ANY WORD ON THE BCD LIST WILL BE   
C     REVERTED BACK TO AS TYPE REAL. THE LIST IS MACHINE DEPENDENT)     
C        
C     SKIP FIRST 5 COMMENT LINES        
C        
      READ (LU,220,END=500)        
      READ (LU,220)        
      READ (LU,220)        
      READ (LU,220)        
      READ (LU,220)        
C        
 300  READ (LU,305,END=500) MACHX,NBCD        
 305  FORMAT (I2,I3)        
      IF (MACHX .EQ. MACH) GO TO 320        
      IF (NBCD .EQ. 0) GO TO 300        
      DO 310 I = 1,NBCD,19        
      READ (LU,325)        
 310  CONTINUE        
      GO TO 300        
 320  IF (NBCD .EQ. 0) GO TO 340        
      JB = 1        
      DO 330 I = 1,NBCD,19        
      JE = JB + 18        
      READ (LU,325) (BCD(J),J=JB,JE)        
 325  FORMAT (5X,19(A4,1X))        
 330  CONTINUE        
C        
C     READ PASS THE 3RD EQUAL-LINE, THEN RETURN        
C        
 340  READ (LU,220,END=500) CARDX        
      IF (CARD(1).NE.EQUALS .AND. CARD(2).NE.EQUALS) GO TO 340        
      IF (TTPG .NE. 0) JUMP = TTPG        
      GO TO 550        
C        
C     JUMP = 3        
C     ========        
C        
C     READ AND ECHO OUT INSTALLATION-CENTER-TO-USER MESSAGES, SAVED IN  
C     THE 4TH SECTION OF NASINFO FILE        
C     TERMINATE MESSAGES BY THE LAST EQUAL-LINE.        
C        
C     IN THIS MESSAGE SECTION ONLY, SKIP INPUT LINE IF A '$.  ' SYMBOL  
C     IS IN FIRST 4 COLUMNS.        
C        
 350  IF (LU.EQ.0 .OR. SKP3.EQ.1) GO TO 550        
      CALL PAGE1        
 360  READ (LU,220,END=500) CARD        
      IF (CARD(1) .EQ.     DD) GO TO 360        
      IF (CARD(1) .NE. EQUALS) GO TO 380        
      IF (CARD(2) .EQ. EQUALS) GO TO 550        
      CALL PAGE1        
      WRITE  (NOUT,370)        
 370  FORMAT (//)        
      GO TO 360        
 380  WRITE  (NOUT,390) CARD        
 390  FORMAT (25X,20A4)        
      GO TO 360        
C        
C     JUMP = 4        
C     ========        
C        
C     PROCESS DIAG48 MESSAGE, SAVED IN THE 5TH SECTION OF NASINFO FILE  
C        
 400  CALL SSWTCH (20,L20)        
      IF (LU .EQ. 0) GO TO 480        
      DO 410 I = 10,20        
 410  PGHDG3(I) = BNK        
      PGHDG3(6) = DIAG48(1)        
      PGHDG3(7) = DIAG48(2)        
      PGHDG3(8) = DIAG48(3)        
      PGHDG3(9) = DIAG48(4)        
      LINE  = NLPP + 1        
      COUNT = 0        
C        
C     READ AND PRINT RELEASE NEWS        
C     PRINT LAST TWO YEARS OF NEWS ONLY, IF DIAG 20 IS ON        
C     (MECHANISM - GEAR TO THE 'nn RELEASE' LINE AND '========' LINES)  
C        
      ONE = 1        
      IF (L20 .EQ. 1) ONE = 0        
 420  READ (LU,220,END=540) CARD        
      IF (CARD(1).EQ.EQUALS .AND. CARD(2).EQ.EQUALS) GO TO 470        
      IF (ONE .EQ. -1) GO TO 440        
      IF (CARD(2).NE.RELSE  .OR.  CARD(4).NE.   BNK) GO TO 440        
      COUNT = COUNT + ONE        
      IF (COUNT .LE. 2) GO TO 440        
 430  READ (LU,220,END=540) CARDX        
      IF (CARD(1).NE.EQUALS .OR. CARD(2).NE.EQUALS) GO TO 430        
      GO TO 470        
 440  IF (LINE .LT. NLPP) GO TO 460        
      CALL PAGE1        
      IF (LINE .EQ. NLPP) GO TO 450        
      LINE = 3        
      GO TO 460        
 450  WRITE (NOUT,370)        
      LINE = 5        
 460  LINE = LINE + 1        
      WRITE (NOUT,390) CARD        
      GO TO 420        
C        
C     READ AND PRINT THE REST OF SECTION 5        
C        
 470  IF (ONE .EQ. -1) GO TO 540        
      ONE  = -1        
      LINE = NLPP + 1        
      GO TO 420        
C        
 480  WRITE  (NOUT,490) UIM        
 490  FORMAT (A29,', DIAG48 MESSAGES ARE NOT AVAILABLE DUE TO ABSENCE ',
     1       'OF THE NASINFO FILE')        
      GO TO 540        
C        
C     ERROR        
C        
 500  WRITE  (NOUT,510) SFM        
 510  FORMAT (A25,' 3002, EOF ENCOUNTERED WHILE READING NASINFO FILE')  
      STOP 'JOB TERMINATED IN SUBROUTINE NSINFO'        
C     CALL MESAGE (-37,0,NAME)    ! THIS CALL HERE DOES NOT WORK IN IBM 
 520  WRITE  (NOUT,530) SYMBOL,EQ,VALUE        
 530  FORMAT ('0*** ERROR IN NASINFO FILE - LINE - ',A4,A1,I7)        
      GO TO 230        
C        
 540  IF (L20 .EQ. 0) GO TO 550        
      CLOSE (UNIT=LU)        
      CALL PEXIT        
 550  RETURN        
      END        
