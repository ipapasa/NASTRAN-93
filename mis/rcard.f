      SUBROUTINE RCARD (OUT,FMT,NFLAG,IN)        
CDIR$ INTEGER=64        
C        
C     CDIR$ IS CRAY COMPILER DIRECTIVE. 64 BIT INTEGER IS USED LOCALLY  
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         LSHIFT,RSHIFT,COMPLF        
      LOGICAL          PASS,SEQGP,DECIML,LMINUS,EXPONT,DOUBLE,BLKON,NOGO
      REAL             FL1        
      DOUBLE PRECISION XDOUBL        
      DIMENSION        BCD(16),VAL(16),NUM(10),OUT(1),TYPE(16),FMT(1),  
     1                 IN(1),NT(16),NDOUBL(2),LINE(20),CHARS(7)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /LHPWX /  LOWPW,HIGHPW        
      COMMON /SYSTEM/  IBUFSZ,F6,NOGO,DUM1(7),NPAGES,NLINES,DUM2(10),   
     1                 LSYSTM        
      EQUIVALENCE      (FL1     ,INT1 ), (XDOUBL,NDOUBL(1)),        
     1                 (NUM(10) ,ZERO ), (CHARS(1),BLANK  ),        
     2                 (CHARS(2),STAR ), (CHARS(3),PLUS   ),        
     3                 (CHARS(4),MINUS), (CHARS(5),PERIOD ),        
     4                 (CHARS(6),E    ), (CHARS(7),D      )        
      DATA    PASS  /.FALSE. /, BLANKS/ 4H     /, STARS / 4H**** /,     
     1        LINE  / 20*4H           /         , BLANK / 1H     /,     
     2        STAR  / 1H*    /, PLUS  / 1H+    /, MINUS / 1H-    /,     
     3        PERIOD/ 1H.    /, E     / 1HE    /, D     / 1HD    /,     
     4        SEQ   / 3HSEQ  /, P     / 4HP    /, IZERO / 0      /      
      DATA    NUM   / 1H1,1H2 ,1H3,1H4, 1H5,1H6,1H7,1H8,1H9,1H0  /      
C        
      IF (PASS) GO TO 40        
      PASS   = .TRUE.        
      A67777 = COMPLF(0)        
      A67777 = RSHIFT(LSHIFT(A67777,1),1)        
C        
      DO 20 I = 1,10        
      NUM(I) = KHRFN1(IZERO,4,NUM(I),1)        
   20 CONTINUE        
C        
      DO 38 I = 1,7        
   38 CHARS(I) = KHRFN1(IZERO,4,CHARS(I),1)        
      SEQ = KHRFN3(IZERO,SEQ,1,0)        
      P   = KHRFN3(IZERO,P  ,0,0)        
C        
   40 FIELD = 0        
      NWORDS= 2        
      N 8 OR 16 = 8        
      WORD  = 0        
      IOUT  = 0        
      IFMT  = 0        
      SEQGP = .FALSE.        
   50 IF (WORD .EQ. 18) GO TO 680        
C        
C     OPERATE ON 1 FIELD  (2 OR 4 WORDS), GET FIRST NON-BLANK CHARACTER.
C        
      FIELD  = FIELD + 1        
      DECIML = .FALSE.        
      LMINUS = .FALSE.        
      EXPONT = .FALSE.        
      DOUBLE = .FALSE.        
      BLKON  = .FALSE.        
      PLACES = 0        
      IT     = 0        
      SIGN   = 0        
      POWER  = 0        
C        
C     READ 8 OR 16 CHARACTERS OF ONE FIELD        
C        
C     TYPE AS 0 = BLANK, -1 = BCD, +1 = INTEGER        
C        
      N = 0        
      WORD1 = WORD + 1        
      WORD  = WORD + NWORDS        
      DO 110 I = WORD1,WORD        
      DO 100 J = 1,4        
      N = N + 1        
      CHARAC = KHRFN1(IZERO,4,IN(I),J)        
      IF (CHARAC .EQ. BLANK) GO TO 70        
      IF (CHARAC .EQ. ZERO ) GO TO 80        
      DO 60 K = 1,9        
      IF (CHARAC .EQ. NUM(K)) GO TO 90        
   60 CONTINUE        
      TYPE(N)= -1        
      VAL(N) = CHARAC        
      GO TO 100        
   70 TYPE(N)= 0        
      VAL(N) = BLANK        
      GO TO 100        
   80 K = 0        
   90 TYPE(N)= 1        
      VAL(N) = K        
  100 BCD(N) = CHARAC        
  110 CONTINUE        
C        
C     BCD, INTEGER TRANSFER ON FIRST NON-BLANK CHARACTER        
C        
      IF (.NOT.SEQGP) GO TO 120        
      GO TO (120,120,690,120,690,120,690,120,690), FIELD        
C        
  120 DO 130 N = 1,N8OR16        
      IF (TYPE(N)) 150,130,320        
  130 CONTINUE        
C        
C     ALL BLANK FIELD IF FALL HERE        
C        
      IF (FIELD .EQ. 1) GO TO 160        
  140 IOUT = IOUT + 1        
      OUT(IOUT) = 0        
      IFMT = IFMT + 1        
      FMT(IFMT) = 0        
      GO TO 50        
C        
C     **********************************************        
C        
C     ALPHA HIT FOR FIRST CHARACTER        
C        
  150 IF (FIELD.EQ.1 .AND. VAL(N).EQ.STAR) GO TO 270        
      IF (VAL(N) .EQ. PLUS  ) GO TO 290        
      IF (VAL(N) .EQ. PERIOD) GO TO 300        
      IF (VAL(N) .EQ. MINUS ) GO TO 310        
C        
C     PLAIN ALPHA BCD FIELD NOW ASSUMED.        
C     CHECKING FOR DOULBE-FIELD * IF WE ARE IN FIELD 1        
C        
      IF (FIELD .NE. 1) GO TO 160        
      IF (BCD(8).NE.STAR .OR. TYPE(8).NE.-1) GO TO 160        
      NWORDS = 4        
      N8OR16 = 16        
C        
C     REMOVE STAR BEFORE PUTTING 2 BCD WORDS INTO OUT        
C        
      BCD(8) = BLANK        
  160 IOUT   = IOUT + 2        
      IF (TYPE(1)) 170,180,170        
  170 IF (NWORDS.EQ.4 .AND. FIELD.EQ.1) GO TO 180        
      N = WORD - NWORDS        
      OUT(IOUT-1) = IN(N+1)        
      OUT(IOUT  ) = IN(N+2)        
      GO TO 260        
C        
C     CHARACTER N WAS FIRST NON-BLANK CHARACTER        
C        
  180 MAX = N 8 OR 16  -  N  +  1        
      DO 190 I = 1,MAX        
      BCD(I) = BCD(N)        
  190 N = N + 1        
  200 IF (MAX .GE. 8) GO TO 210        
      MAX = MAX + 1        
      BCD(MAX) = BLANK        
      GO TO 200        
  210 WORD1 = 0        
      WORD2 = 0        
      DO 220 I = 1,4        
      WORD1 = KHRFN3(BCD(I  ),WORD1,1,1)        
      WORD2 = KHRFN3(BCD(I+4),WORD2,1,1)        
  220 CONTINUE        
      OUT(IOUT-1) = WORD1        
      OUT(IOUT  ) = WORD2        
  260 IFMT = IFMT + 1        
      FMT(IFMT) = 3        
      IF (FIELD .NE. 1) GO TO 50        
      IF (KHRFN3(IZERO,OUT(IOUT-1),1,0).EQ.SEQ .AND.        
     1    KHRFN3(IZERO,OUT(IOUT  ),0,0).EQ.P) SEQGP = .TRUE.        
      GO TO 50        
C        
C     **********************************************        
C        
C     FIRST CHARACTER  ON CARD IS A STAR        
C        
  270 NWORDS = 4        
      N 8 OR 16 = 16        
  280 IOUT = IOUT + 2        
      OUT(IOUT-1) = 0        
      OUT(IOUT  ) = 0        
      IFMT = IFMT + 1        
      FMT(IFMT) = 3        
      GO TO 50        
C        
C     **********************************************        
C        
C     FIRST CHARACTER IN FIELD IS A PLUS        
C        
  290 IF (FIELD .EQ. 1) GO TO 280        
C        
C     IGNORING PLUS SIGN AND NOW ASSUMING FIELD IS NUMBERIC        
C        
      GO TO 340        
C        
C     **********************************************        
C        
C     FIRST CHARACTER IN FIELD IS A PERIOD        
C        
  300 DECIML = .TRUE.        
      PLACES = 0        
      GO TO 340        
C        
C     **********************************************        
C        
C     FIRST CHARACTER IN FIELD IS A MINUS        
C        
  310 LMINUS = .TRUE.        
      GO TO 340        
C        
C     **********************************************        
C        
C     0 TO 9 NUMERIC HIT        
C        
  320 IF (VAL(N)) 330,340,330        
C        
C     NON-ZERO NUMBER.  SAVING IT NOW IN TABLE NT        
C        
  330 NT(1) = VAL(N)        
      IT = 1        
  340 IF (N .EQ. N 8 OR 16) GO TO 380        
C        
C     PROCESS REMAINING DIGITS        
C        
      NNN = N + 1        
      DO 370 N = NNN,N8OR16        
      IF ((TYPE(N).EQ.0 .OR. VAL(N).EQ.ZERO) .AND. IT.EQ.0 .AND.        
     1    .NOT.DECIML) GO TO 370        
      IF (TYPE(N)) 350,350,360        
C        
C     FALL THRU IMPLIES NON 0 TO 9 CHARACTER        
C        
  350 IF (VAL(N) .NE. PERIOD) GO TO 430        
      IF (DECIML) GO TO 910        
      PLACES = 0        
      DECIML = .TRUE.        
      GO TO 370        
C        
C     0 TO 9 CHARACTER HIT. SAVE IT.        
C        
  360 IT = IT + 1        
      NT(IT) = VAL(N)        
      IF (DECIML) PLACES = PLACES + 1        
  370 CONTINUE        
C        
C     NUMERIC WORD COMPLETED        
C     IF DECIML IS .FALSE. NUMERIC IS A SIMPLE INTEGER        
C        
  380 IF (DECIML) GO TO 570        
C        
C     **********************************************        
C        
C     SIMPLE INTEGER        
C        
  390 NUMBER = 0        
      IF (IT .EQ. 0) GO TO 410        
      DO 400 I = 1,IT        
      IF (((A67777-NT(I))/10) .LT. NUMBER) GO TO 890        
  400 NUMBER = NUMBER*10 + NT(I)        
  410 IF (LMINUS) NUMBER = - NUMBER        
  420 IOUT = IOUT + 1        
      OUT(IOUT) = NUMBER        
      IFMT = IFMT + 1        
      FMT(IFMT) = 1        
      GO TO 50        
C        
C     **********************************************        
C        
C     PROBABLE (E, D, +, -) EXPONENT HIT OR BLANK        
C        
  430 IF (TYPE(N)) 460,440,460        
C        
C     BLANK HIT THUS ONLY AN EXPONENT OR BLANKS PERMITTED FOR BALANCE   
C     OF FIELD        
C        
  440 IF (N .EQ. N 8 OR 16) GO TO 450        
      N = N + 1        
      IF (TYPE(N)) 460,440,960        
C        
C     FALL THRU ABOVE LOOP IMPLIES BALANCE OF FIELD WAS BLANKS        
C        
  450 IF (DECIML) GO TO 570        
      GO TO 390        
C        
C     **********************************************        
C        
C     COMING HERE IMPLIES A NON-BLANK CHARACTER HAS BEEN HIT BEGINNING  
C     AN EXPONENT. IT HAS TO BE A (+, -, D, OR E ) FOR NO ERROR        
C        
  460 IF (VAL(N) .NE. PLUS) GO TO 470        
      EXPONT= .TRUE.        
      SIGN  = PLUS        
      GO TO 500        
  470 IF (VAL(N) .NE. E) GO TO 480        
      EXPONT= .TRUE.        
      GO TO 500        
  480 IF (VAL(N) .NE. MINUS) GO TO 490        
      EXPONT= .TRUE.        
      SIGN  = MINUS        
      GO TO 500        
  490 IF (VAL(N) .NE. D) GO TO 960        
      EXPONT= .TRUE.        
      DOUBLE= .TRUE.        
C        
C     READ INTEGER POWER, WITH OR WITHOUT SIGN        
C        
  500 IF (N .EQ. N 8 OR 16) GO TO 950        
      N = N + 1        
C        
      IF (TYPE(N)) 510,500,520        
  510 IF (VAL(N).NE.PLUS .AND. VAL(N).NE.MINUS) GO TO 520        
      IF (SIGN .NE. 0) GO TO 940        
      SIGN = VAL(N)        
      GO TO 500        
C        
C     FIRST DIGIT OF INTEGER POWER AT HAND NOW        
C        
  520 POWER = 0        
      BLKON = .FALSE.        
C        
  530 IF (TYPE(N)) 930,930,540        
  540 POWER = POWER*10 + VAL(N)        
C        
C     GET ANY MORE DIGITS IF PRESENT        
C        
  550 IF (N .EQ. N 8 OR 16) GO TO 570        
      N = N + 1        
      IF (BLKON) IF (TYPE(N)) 980,550,980        
      IF (TYPE(N)) 530,560,530        
C        
C     BLANK HIT, BALANCE OF FIELD MUST BE BLANKS        
C        
  560 BLKON = .TRUE.        
      GO TO 550        
C        
C     **********************************************        
C        
C     SINGLE OR DOUBLE PRECISION FLOATING POINT NUMBER        
C     COMPLETE AND OUTPUT IT.        
C        
C     15 SIGNIFICANT FIGURES POSSIBLE ON INPUT        
C     CONSIDERED SINGLE PRECISION UNLESS D EXPONENT IS PRESENT        
C        
  570 IF (SIGN .EQ. MINUS) POWER = -POWER        
      POWER = POWER - PLACES        
C        
      NUMBER = 0        
      IF (IT) 580,620,580        
  580 IF (IT .LT. 7) GO TO 590        
      N = 7        
      GO TO 600        
  590 N = IT        
  600 DO 610 I = 1,N        
  610 NUMBER = NUMBER*10 + NT(I)        
  620 XDOUBL = DBLE(FLOAT(NUMBER))        
      IF (IT .LE. 7) GO TO 640        
      NUMBER = 0        
C     N = IT - 7        
C     DO 630 I = 1,N        
C     IT = I + 7        
C 630 NUMBER = NUMBER*10 + NT(IT)        
C     XDOUBL = XDOUBL*10.0D0**N + DBLE(FLOAT(NUMBER))        
      DO 630 I = 8,IT        
  630 NUMBER = NUMBER*10 + NT(I)        
      XDOUBL = XDOUBL*10.0D0**(IT-7) + DBLE(FLOAT(NUMBER))        
  640 IF (LMINUS) XDOUBL = -XDOUBL        
C        
C     CHECK FOR POWER IN RANGE OF MACHINE        
C        
      ICHEK = POWER + IT        
      IF (XDOUBL .EQ. 0.0D0) GO TO 660        
      IF (ICHEK.LT.LOWPW+1 .OR. ICHEK.GT.HIGHPW-1 .OR.        
     1    POWER.LT.LOWPW+1 .OR. POWER.GT.HIGHPW-1) GO TO 860        
C        
      XDOUBL = XDOUBL*10.0D0**POWER        
  660 IFMT = IFMT + 1        
      IF (DOUBLE) GO TO 670        
      FL1  = XDOUBL        
      IOUT = IOUT + 1        
      OUT(IOUT) = INT1        
      FMT(IFMT) = 2        
      GO TO 50        
  670 IOUT = IOUT + 2        
      OUT(IOUT-1) = NDOUBL(1)        
      OUT(IOUT  ) = NDOUBL(2)        
      FMT(IFMT) = 4        
      GO TO 50        
  680 NFLAG = IOUT        
      FMT(IFMT+1) = -1        
      RETURN        
C        
C     **********************************************        
C        
C     FIRST CHARACTER OF FIELD 3, 5, 7,  OR 9 ON SEQGP CARD ENCOUNTERED.
C        
C     IT HAS TO BE A 1 TO 9 FOR NO ERROR        
C        
  690 DO 700 N = 1,N8OR16        
      IF (TYPE(N)) 1000,700,710        
  700 CONTINUE        
      GO TO 140        
C        
C     STORE NUMBER IN NT        
C        
  710 NPOINT = 0        
  720 IT = IT + 1        
      NT(IT) = VAL(N)        
  730 IF (N .EQ. N 8 OR 16) GO TO 800        
      N = N + 1        
C        
C     GET NEXT CHARACTER        
C        
      IF (NPOINT.GT.0 .AND. .NOT.DECIML .AND. .NOT.BLKON) GO TO 790     
      IF (DECIML) GO TO 770        
      IF (BLKON ) GO TO 750        
      IF (TYPE(N)) 740,740,720        
  740 IF (VAL(N)  .EQ. PERIOD) GO TO 760        
  750 IF (TYPE(N) .NE.      0) GO TO 1020        
      BLKON = .TRUE.        
      GO TO 730        
C        
  760 DECIML = .TRUE.        
      NPOINT = NPOINT + 1        
      GO TO 730        
C        
  770 IF (TYPE(N)) 1020,1020,780        
C        
  780 DECIML = .FALSE.        
      GO TO 720        
C        
  790 IF (VAL(N).EQ.PERIOD .AND. TYPE(N).LT.0) GO TO 760        
      GO TO 750        
C        
C     READY TO COMPUTE INTEGER VALUE OF SPECIAL SEQGP INTEGER        
C        
  800 NPOINT = 3 - NPOINT        
      IF (NPOINT) 1010,830,810        
  810 DO 820 K = 1,NPOINT        
      IT = IT + 1        
  820 NT(IT) = 0        
C        
C     COMPUTE NUMBER        
C        
  830 NUMBER = 0        
      IF (IT) 840,420,840        
  840 DO 850 K = 1,IT        
      IF (((A67777-NT(K))/10) .LT. NUMBER) GO TO 1040        
      NUMBER = NUMBER*10 + NT(K)        
  850 CONTINUE        
      GO TO 420        
C        
C        
  860 WRITE  (F6,870) UFM        
  870 FORMAT (A23,' 300, DATA ERROR IN FIELD UNDERLINED.')        
      WRITE  (F6,880)        
  880 FORMAT (10X,42HFLOATING POINT NUMBER OUT OF MACHINE RANGE)        
C     WRITE  (F6,885) POWER,IT,ICHEK,LOWPW,HIGHPW        
C 885 FORMAT (10X,'POWER,IT,ICHEK,LOWPW,HIGHPW =',5I5)        
      GO TO  1060        
  890 WRITE  (F6,870) UFM        
      WRITE  (F6,900)        
  900 FORMAT (10X,38HINTEGER MAGNITUDE OUT OF MACHINE RANGE)        
      GO TO  1060        
  910 WRITE  (F6,870) UFM        
      WRITE  (F6,920)        
  920 FORMAT (10X,22HDATA NOT RECOGNIZEABLE)        
      GO TO  1060        
  930 CONTINUE        
  940 CONTINUE        
  950 CONTINUE        
  960 WRITE  (F6,870) UFM        
      WRITE  (F6,970)        
  970 FORMAT (10X,26HPOSSIBLE ERROR IN EXPONENT)        
      GO TO  1060        
  980 WRITE  (F6,870) UFM        
      WRITE  (F6,990)        
  990 FORMAT (10X,23HPOSSIBLE IMBEDDED BLANK)        
      GO TO  1060        
 1000 CONTINUE        
 1010 CONTINUE        
 1020 WRITE  (F6,870) UFM        
      WRITE  (F6,1030)        
 1030 FORMAT (10X,30HINCORRECT DEWEY DECIMAL NUMBER)        
      GO TO  1060        
 1040 WRITE  (F6,870) UFM        
      WRITE  (F6,1050)        
 1050 FORMAT (10X,49HINTERNAL CONVERSION OF DEWEY DECIMAL IS TOO LARGE) 
 1060 WORD = (FIELD-1)*NWORDS + 2        
      ASSIGN 1090 TO IRETRN        
      WORD2 = STARS        
 1070 LINE(WORD  ) = WORD2        
      LINE(WORD-1) = WORD2        
      IF (NWORDS .EQ. 2  .OR.  FIELD .EQ. 1) GO TO 1080        
      LINE(WORD-2) = WORD2        
      LINE(WORD-3) = WORD2        
 1080 GO TO IRETRN,(1090,1150)        
 1090 IF (NWORDS .EQ. 4) GO TO 1110        
      WRITE  (F6,1100)        
 1100 FORMAT (10X,80H.   1  ..   2  ..   3  ..   4  ..   5  ..   6  ..  
     1 7  ..   8  ..   9  ..  10  .)        
      GO TO 1130        
 1110 WRITE  (F6,1120)        
 1120 FORMAT (10X,80H.   1  ..   2  AND  3  ..   4  AND  5  ..   6  AND 
     1 7  ..   8  AND  9  ..  10  .)        
 1130 WRITE  (F6,1140) (IN(I),I=1,20),LINE        
 1140 FORMAT (10X,20A4)        
      ASSIGN 1150 TO IRETRN        
      WORD2 = BLANKS        
      GO TO 1070        
 1150 IOUT = IOUT + 1        
      NLINES = NLINES + 7        
      OUT(IOUT) = 0        
      IFMT = IFMT + 1        
      FMT(IFMT) = -1        
      NOGO = .TRUE.        
      GO TO 50        
      END        
