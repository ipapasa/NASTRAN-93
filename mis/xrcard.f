      SUBROUTINE XRCARD (OUT,NFLAG,IN)        
C        
C     MODIFIED BY G.CHAN/UNISYS FOR EFFICIENCY,        2/1988        
C     LAST REVISED, 8/1989, IMPROVED EFFICIENCY BY REDUCING CHARACTER   
C     OPERATIONS (VERY IMPORTANT FOR CDC MACHINE)        
C        
C     REVERT TO NASTRAN ORIGIANL XRCARD ROUTINE (NOW CALLED YRCARD)     
C     IF DIAG 42 IS TURNED ON        
C     (THIS NEW XRCARD IS SEVERAL TIMES FASTER THAN YRCARD)        
C        
C        
      IMPLICIT INTEGER  (A-Z)        
      EXTERNAL        LSHIFT   ,RSHIFT   ,COMPLF        
      LOGICAL         ALPHA    ,DELIM    ,EXPONT   ,POWER    ,MINUS   , 
     1                NOGO     ,DEBUG        
      INTEGER         IDOUBL(2),TYPE(72) ,NT(15)   ,IN(18)   ,OUT(2)    
      INTEGER         PLUS1    ,MINUS1   ,BLANK1   ,DOT1     ,E1      , 
     1                D1       ,NUM1(10) ,CHAR1(72),DOLLR1   ,COMMA1  , 
     2                EQUAL1   ,SLASH1   ,OPARN1   ,CPARN1   ,ASTK1   , 
     3                CHAR1N   ,CHAR1I   ,CHARN2   ,CHARS(23),ZERO1   , 
     4                PRECIS   ,PSIGN        
      REAL            FLPT        
      DOUBLE PRECISION          DDOUBL        
      CHARACTER*1     SAVE1(8) ,KHAR1(72)        
      CHARACTER*8     SAVE8    ,BLANK8   ,NUMRIC        
      CHARACTER*23    CHAR23   ,UFM        
      CHARACTER*72    CHAR72        
      COMMON /XMSSG / UFM        
      COMMON /LHPWX / LOWPW    ,HIGHPW        
      COMMON /SYSTEM/ BUFSZ    ,NOUT     ,NOGO        
      EQUIVALENCE     (KHAR1(1),CHAR72), (SAVE8 ,SAVE1( 1)),        
     1                (FLPT    ,INTG  ), (DDOUBL,IDOUBL(1)),        
     2                (CHARS(1),DOLLR1), (CHARS( 8),CPARN1),        
     3                (CHARS(2),PLUS1 ), (CHARS( 9),E1    ),        
     4                (CHARS(3),EQUAL1), (CHARS(10),D1    ),        
     5                (CHARS(4),MINUS1), (CHARS(11),DOT1  ),        
     6                (CHARS(5),COMMA1), (CHARS(12),BLANK1),        
     7                (CHARS(6),SLASH1), (CHARS(13),ASTK1 ),        
     8                (CHARS(7),OPARN1), (CHARS(14),NUM1(1)),        
     9                (NUM1(10),ZERO1 )        
      DATA    CHAR23/ '$+=-,/()ED. *1234567890'/,   BLANK8/ '       ' / 
      DATA    DOLLR1,  BLANK4,  DIAG  ,   DEBUG ,   NUMRIC            / 
     1        0,       4H    ,  4HDIAG,  .FALSE.,  'NUMERIC'          / 
      DATA    EQUAL4,  SLASH4,  OPARN4,   ASTK4                       / 
     1        4H=   ,  4H/   ,  4H(   ,   4H*                         / 
C        
      IF (DOLLR1 .NE. 0) GO TO 20        
      CALL K2B (CHAR23,CHARS,23)        
      A77777 = COMPLF(0)        
      A67777 = RSHIFT(LSHIFT(A77777,1),1)        
      PREV   = BLANK4        
      CALL SSWTCH (42,L42)        
      IF (DEBUG) WRITE (NOUT,10)        
   10 FORMAT (//5X,'INPUT DEBUG IN XRCARD ROUTINE')        
C        
C         KXX=0        
C        
C     USE ORIGINAL XRCARD ROUTINE IF DIAG 42 IS TURNED ON        
C        
   20 IF (PREV .EQ. DIAG) CALL SSWTCH (42,L42)        
      IF (L42 .EQ. 0) GO TO 30        
      CALL YRCARD (OUT,NFLAG,IN)        
      RETURN        
C        
C     CONVERT 18 BCD WORDS IN 'IN' TO 72 CHARACTER STRING, AND SET TYPE 
C        
C  30 WRITE  (CHAR72,35) IN        
C  35 FORMAT (18A4)        
C  40 FORMAT ( 2A4)        
   30 CALL BCDKH7 (IN,CHAR72)        
      CALL K2B (CHAR72,CHAR1,72)        
      IF (DEBUG) WRITE (NOUT,45) CHAR72        
   45 FORMAT (/,' INPUT- ',A72)        
C        
C         KXX = KXX + 1        
C         IF (KXX .GT. 10) DEBUG = .TRUE.        
C         IF (KXX .GT. 20) DEBUG = .FALSE.        
C        
      DO 80 N = 1,72        
      CHAR1N = CHAR1(N)        
      IF (CHAR1N .EQ. BLANK1 ) GO TO 60        
      DO 50 K = 1,10        
      IF (CHAR1N .EQ. NUM1(K)) GO TO 70        
   50 CONTINUE        
      TYPE(N) =-1        
      GO TO 80        
   60 TYPE(N) = 0        
      GO TO 80        
   70 TYPE(N) = 1        
   80 CONTINUE        
      N = 73        
   90 N = N - 1        
      IF (TYPE(N) .EQ. 0) GO TO 90        
      LAST  = N + 1        
      IF (LAST .GT. 72) LAST = 72        
      ALPHA = .FALSE.        
      DELIM = .TRUE.        
      IOUT  = 0        
      N     = 0        
      ASAVE = 1        
      OUT(ASAVE) = 0        
      SAVE8 = BLANK8        
  100 IF (N .EQ. LAST) GO TO 510        
      IF (NFLAG-IOUT .LT. 5) GO TO 660        
      MINUS = .FALSE.        
      N = N + 1        
      CHAR1N = CHAR1(N)        
      IF (TYPE(N)) 110,  100,   210        
C                  BCD  BLANK NUMERIC        
C        
  110 IF (CHAR1N.EQ.PLUS1 .OR. CHAR1N.EQ.MINUS1 .OR. CHAR1N.EQ.DOT1)    
     1    GO TO 200        
      IF (CHAR1N .EQ. DOLLR1) GO TO 180        
C        
C     GOOD ALPHA FIELD OR DELIMITER        
C        
      IF (ALPHA) GO TO 120        
      IF ((CHAR1N.EQ.COMMA1 .OR. CHAR1N.EQ.DOLLR1) .AND. (.NOT.DELIM))  
     1    GO TO 180        
      IF (CHAR1N.EQ.CPARN1 .AND. .NOT.DELIM) GO TO 180        
      IOUT  = IOUT + 1        
      ASAVE = IOUT        
      OUT(ASAVE) = 0        
      ALPHA = .TRUE.        
  120 IF  (CHAR1N.EQ.OPARN1 .OR. CHAR1N.EQ.SLASH1 .OR. CHAR1N.EQ.EQUAL1 
     1.OR. CHAR1N.EQ.COMMA1 .OR. CHAR1N.EQ.ASTK1  .OR. CHAR1N.EQ.DOLLR1)
     2     GO TO 180        
      IF (CHAR1N .EQ. CPARN1) GO TO 180        
      ASSIGN 125 TO IRTN        
      IMHERE = 125        
      GO TO 170        
  125 OUT(ASAVE) = OUT(ASAVE) + 1        
      IOUT  = IOUT + 2        
      DELIM = .FALSE.        
      OUT(IOUT-1) = BLANK4        
      OUT(IOUT  ) = BLANK4        
      ICHAR = 0        
      GO TO 150        
  130 IF (N .EQ. LAST) GO TO 510        
      N = N + 1        
      CHAR1N = CHAR1(N)        
      IF (TYPE(N)) 140,  160,    150        
C                  BCD BLANK NUMERIC        
C        
  140 IF  (CHAR1N.EQ.OPARN1 .OR. CHAR1N.EQ.SLASH1 .OR. CHAR1N.EQ.EQUAL1 
     1.OR. CHAR1N.EQ.COMMA1 .OR. CHAR1N.EQ.ASTK1  .OR. CHAR1N.EQ.DOLLR1)
     2     GO TO 180        
      IF (CHAR1N .EQ. CPARN1) GO TO 180        
C        
C     RECONSTRUCT CHARACTERS INTO SAVE1 SPACE, UP TO 8 CHARACTERS ONLY  
C        
  150 IF (ICHAR .EQ. 8) GO TO 130        
      ICHAR = ICHAR + 1        
      SAVE1(ICHAR) = KHAR1(N)        
      IMHERE = 150        
      IF (DEBUG) WRITE (NOUT,171) SAVE8,IMHERE,ICHAR,IOUT        
C        
C     GO FOR NEXT CHARACTER        
C        
      IF (ICHAR .LT. 8) GO TO 130        
      ASSIGN 130 TO IRTN        
      IMHERE = 155        
      GO TO 170        
C        
C     A BLANK CHARACTER IS ENCOUNTERED WHILE PROCESSING ALPHA STRING    
C     IF THIS IS AT THE BEGINNING OF A NEW BCD WORD, GO TO 100        
C     IF THIS IS AT THE END OF A BCD WORD, GO TO 170 TO WRAP IT UP      
C        
  160 IF (ICHAR .EQ. 0) GO TO 100        
      ASSIGN 100 TO IRTN        
      IMHERE = 160        
C     GO TO 170        
C        
C     MOVE CHARACTER DATA IN SAVE8 TO OUT(IOUT-1) AND OUT(IOUT) IN BCD  
C     WORDS        
C        
C 170 IF (SAVE8 .NE. BLANK8) READ (SAVE8,40) OUT(IOUT-1),OUT(IOUT)      
  170 IF (SAVE8 .NE. BLANK8) CALL KHRBC2 (SAVE8,OUT(IOUT-1))        
      IF (.NOT.DEBUG) GO TO 175        
      WRITE (NOUT,171) SAVE8,IMHERE,ICHAR,IOUT        
      WRITE (NOUT,172) IOUT,OUT(IOUT-1),OUT(IOUT),DELIM,        
     1                 IOUT,OUT(IOUT-1),OUT(IOUT)        
  171 FORMAT ('   SAVE8= /',A8,'/   @',I3,',  ICHAR,IOUT=',2I3)        
  172 FORMAT ('   IOUT,OUT  =',I4,2H /,2A4,'/  DELIM=',L1,        
     1            /14X,    '=',I4,2H /,2I25,'/')        
  175 SAVE8 = BLANK8        
      GO TO IRTN, (100,125,130,185)        
C        
C     DELIMITER HIT        
C        
  180 ASSIGN 185 TO IRTN        
      IMHERE = 180        
      GO TO 170        
  185 IF (.NOT. DELIM) GO TO 190        
      IF (IOUT .EQ. 0) IOUT = 1        
      IOUT = IOUT + 2        
      OUT(ASAVE)  = OUT(ASAVE) + 1        
      OUT(IOUT-1) = BLANK4        
      OUT(IOUT  ) = BLANK4        
  190 IF (CHAR1N .EQ. DOLLR1) GO TO 520        
      DELIM = .TRUE.        
      IF (CHAR1N .EQ. CPARN1) DELIM = .FALSE.        
      IF (CHAR1N .EQ. COMMA1) GO TO 100        
      IF (CHAR1N .EQ. CPARN1) GO TO 100        
C        
C     OUTPUT DELIMITER        
C        
      IOUT = IOUT + 2        
      OUT(ASAVE) = OUT(ASAVE) + 1        
      OUT(IOUT) = BLANK4        
      IF (CHAR1N .EQ. OPARN1) OUT(IOUT) = OPARN4        
      IF (CHAR1N .EQ. SLASH1) OUT(IOUT) = SLASH4        
      IF (CHAR1N .EQ. EQUAL1) OUT(IOUT) = EQUAL4        
      IF (CHAR1N .EQ.  ASTK1) OUT(IOUT) =  ASTK4        
      IF (OUT(IOUT) .EQ. BLANK4) GO TO 590        
      OUT(IOUT-1) = A77777        
      IF (DEBUG) WRITE (NOUT,195) IOUT,OUT(IOUT),DELIM,CHAR1N        
  195 FORMAT (5X,'IOUT,OUT/@195 =',I4,2H ',A4,8H' DELIM=,L1,2H ',A1,    
     1        1H')        
      SAVE8 = BLANK8        
      GO TO 100        
C        
C     PLUS, MINUS, OR DOT ENCOUNTERED        
C        
  200 IF (CHAR1N .EQ. MINUS1) MINUS = .TRUE.        
      IF (CHAR1N .NE.   DOT1) N = N + 1        
      IF (N .GT. LAST) GO TO 530        
C        
C     NUMERIC        
C        
  210 ALPHA = .FALSE.        
      DELIM = .FALSE.        
      IT    = 0        
      NT(1) = 0        
      DO 260 I = N,LAST        
      IF (TYPE(I)) 290,270,220        
C        
C     INTEGER CHARACTER        
C        
  220 CHAR1I = CHAR1(I)        
      DO 230 K = 1,9        
      IF (CHAR1I .EQ. NUM1(K)) GO TO 250        
  230 CONTINUE        
      K  = 0        
  250 IT = IT + 1        
      IF (IT .LT. 16) NT(IT) = K        
  260 CONTINUE        
C        
C     FALL HERE IMPLIES WE HAVE A SIMPLE INTEGER        
C        
  270 NUMBER = 0        
      DO 280 I = 1,IT        
      IF (((A67777-NT(I))/10) .LT. NUMBER) GO TO 550        
  280 NUMBER = NUMBER*10  +  NT(I)        
      IF (MINUS) NUMBER = - NUMBER        
      IOUT = IOUT + 2        
      OUT(IOUT-1) =-1        
      OUT(IOUT  ) = NUMBER        
      IF (.NOT.DEBUG) GO TO 285        
      IMHERE = 280        
      WRITE (NOUT,171) NUMRIC,IMHERE        
      WRITE (NOUT,282) IOUT,OUT(IOUT-1),OUT(IOUT),DELIM        
  282 FORMAT (10X,I4,1H),2I8,'    DELIM=',L1)        
  285 N = N + IT - 1        
      GO TO 100        
C        
C     FLOATING PT. NUMBER, DELIMITER, OR ERROR IF FALL HERE        
C        
C     COUNT THE NUMBER OF DIGITS LEFT BEFORE CARD END OR DELIMITER HIT  
C        
  290 N1 = I        
      DO 300 N2 = N1,LAST        
      CHARN2 = CHAR1(N2)        
      IF (CHARN2.EQ.OPARN1 .OR. CHARN2.EQ.SLASH1 .OR.        
     1    CHARN2.EQ.EQUAL1 .OR. CHARN2.EQ.COMMA1 .OR.        
     2    CHARN2.EQ.DOLLR1 .OR. TYPE(N2).EQ.0) GO TO 310        
      IF (CHARN2 .EQ. CPARN1) GO TO 310        
  300 CONTINUE        
      N2 = LAST + 1        
  310 IF (N1 .EQ. N2) GO TO 270        
C        
C     CHARACTER N1 NOW MUST BE A DECIMAL FOR NO ERROR        
C        
      IF (CHAR1(N1) .NE. DOT1) GO TO 570        
      POWER = .FALSE.        
      N1 = N1 + 1        
      N2 = N2 - 1        
      PLACES = 0        
      EXPONT = .FALSE.        
      IPOWER = 0        
      PSIGN  = ZERO1        
      PRECIS = ZERO1        
      IF (N2 .LT. N1) GO TO 410        
      DO 400 I = N1,N2        
      CHAR1I = CHAR1(I)        
      IF (TYPE(I)) 360,570,320        
C        
C     FLOATING PT. NUMBER        
C        
  320 DO 330 K = 1,9        
      IF (CHAR1I .EQ. NUM1(K)) GO TO 340        
  330 CONTINUE        
      K = 0        
  340 IF (EXPONT) GO TO 350        
      IT = IT + 1        
      IF (IT .LT. 16) NT(IT) = K        
      PLACES = PLACES + 1        
      GO TO 400        
C        
C     BUILD POWER HERE        
C        
  350 POWER  = .TRUE.        
      IPOWER = IPOWER*10 + K        
      IF (IPOWER .GT. 1000) GO TO 630        
      GO TO 400        
C        
C     START EXPONENTS HERE        
C        
  360 IF (EXPONT) GO TO 380        
      EXPONT = .TRUE.        
      IF (CHAR1I.NE.PLUS1 .AND. CHAR1I.NE.MINUS1) GO TO 370        
      PRECIS = E1        
      PSIGN  = CHAR1I        
      GO TO 390        
  370 IF (CHAR1I.NE.E1 .AND. CHAR1I.NE.D1) GO TO 610        
      PRECIS = CHAR1I        
      GO TO 390        
C        
C     SIGN OF POWER        
C        
  380 IF (POWER) GO TO 610        
      IF (PSIGN.NE.ZERO1 .OR.        
     1   (CHAR1I.NE.PLUS1 .AND. CHAR1I.NE.MINUS1)) GO TO 610        
      PSIGN = CHAR1I        
      POWER = .TRUE.        
  390 IF (I .EQ. LAST) GO TO 530        
  400 CONTINUE        
  410 N = N2        
C        
C     ALL DATA COMPLETE FOR FLOATING POINT NUMBER        
C     ONLY 15 FIGURES WILL BE ACCEPTED        
C        
      IF (IT .LE. 15) GO TO 420        
      IPOWER = IPOWER + IT - 15        
      IT = 15        
  420 IF (PSIGN .EQ. MINUS1) IPOWER = -IPOWER        
      IPOWER = IPOWER - PLACES        
      NUMBER = 0        
      IF (IT .LT. 7) GO TO 430        
      N2 = 7        
      GO TO 440        
  430 N2 = IT        
  440 DO 450 I = 1,N2        
  450 NUMBER = NUMBER*10 + NT(I)        
      DDOUBL = DBLE(FLOAT(NUMBER))        
      IF (IT .LE. 7) GO TO 470        
      NUMBER = 0        
      N2 = IT - 7        
      DO 460 I = 1,N2        
      IT = I + 7        
  460 NUMBER = NUMBER*10 + NT(IT)        
      DDOUBL = DDOUBL*10.0D0**N2 + DBLE(FLOAT(NUMBER))        
  470 IF (MINUS) DDOUBL = -DDOUBL        
C        
C     POWER HAS TO BE WITHIN RANGE OF MACHINE        
C        
      ICHEK = IPOWER + IT        
      IF (DDOUBL .EQ. 0.0D0) GO TO 490        
      IF (ICHEK .LT.LOWPW+1 .OR. ICHEK .GT.HIGHPW-1 .OR.        
     1    IPOWER.LT.LOWPW+1 .OR. IPOWER.GT.HIGHPW-1) GO TO 640        
      DDOUBL = DDOUBL*10.0D0**IPOWER        
  490 IF (PRECIS .EQ. D1) GO TO 500        
      FLPT = DDOUBL        
      IOUT = IOUT + 2        
      OUT(IOUT-1) =-2        
      OUT(IOUT  ) = INTG        
      GO TO 100        
  500 IOUT = IOUT + 3        
      OUT(IOUT-2) =-4        
      OUT(IOUT-1) = IDOUBL(1)        
      OUT(IOUT  ) = IDOUBL(2)        
      GO TO 100        
C        
C     PREPARE TO RETURN        
C        
  510 IF (.NOT. DELIM) GO TO 520        
C     IF (SAVE8 .NE. BLANK8) READ (SAVE8,40) OUT(IOUT-1),OUT(IOUT)      
      IF (SAVE8 .NE. BLANK8) CALL KHRBC2 (SAVE8,OUT(IOUT-1))        
      OUT(IOUT+1) = 0        
      GO TO 525        
  520 OUT(IOUT+1) = A67777        
  525 PREV = OUT(2)        
      RETURN        
C        
C     ERRORS        
C        
  530 WRITE  (NOUT,540) UFM        
  540 FORMAT (A23,'300, INVALID DATA COLUMN 72')        
      GO TO  680        
  550 WRITE  (NOUT,560) UFM        
  560 FORMAT (A23,'300, INTEGER DATA OUT OF MACHINE RANGE')        
      GO TO  680        
  570 WRITE  (NOUT,580) UFM,N1        
  580 FORMAT (A23,'300, INVALID CHARACTER FOLLOWING INTEGER IN COLUMN', 
     1       I4)        
      GO TO  680        
  590 WRITE  (NOUT,600) UFM,CHAR1N        
  600 FORMAT (A23,'300, FORGOTTEN DELIMITER - ',A1,',  PROGRAM ERROR')  
      GO TO  680        
  610 WRITE  (NOUT,620) UFM,I        
  620 FORMAT (A23,'300, DATA ERROR-UNANTICIPATED CHARACTER IN COLUMN',  
     1       I4)        
      GO TO  680        
  630 CONTINUE        
  640 WRITE  (NOUT,650) UFM        
  650 FORMAT (A23,'300, DATA ERROR - MISSING DELIMITER OR REAL POWER ', 
     1        'OUT OF MACHINE RANGE')        
      GO TO  680        
  660 WRITE  (NOUT,670) UFM        
  670 FORMAT (A23,'300, ROUTINE XRCARD FINDS OUTPUT BUFFER TOO SMALL ', 
     1        'TO PROCESS CARD COMPLETELY')        
  680 NOGO = .TRUE.        
      WRITE  (NOUT,690) CHAR72        
  690 FORMAT (/5X,1H',A72,1H','  ERROR IN XRCARD ROUTINE')        
      OUT(1) = 0        
      RETURN        
C        
      END        
