      SUBROUTINE XPURGE        
C        
C     THIS SUBROUTINE PURGES AND EQUATES FILES WITHIN FIAT AND DPD      
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT    ,ANDF    ,ORF        
      DIMENSION       PURGE1( 2),DDBN( 1),DFNU( 1),FCUM( 1),FCUS( 1),   
     1                FDBN  ( 1),FEQU( 1),FILE( 1),FKND( 1),FMAT( 1),   
     2                FNTU  ( 1),FPUN( 1),FON ( 1),FORD( 1),MINP( 1),   
     3                MLSN  ( 1),MOUT( 1),MSCR( 1),SAL ( 1),SDBN( 1),   
     4                SNTU  ( 1),SORD( 1)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /SYSTEM/ IBUFSZ,OUTTAP,DUM(21),ICFIAT,DUMM(14),NBPC,NBPW,  
     1                NCPW        
      COMMON /OSCENT/ X(1)        
      COMMON /XFIAT / FIAT(7)        
      COMMON /XFIST / FIST        
      COMMON /XDPL  / DPD(6)        
      COMMON /XVPS  / VPS(1)        
      COMMON /XSFA1 / MD(401),SOS(1501),COMM(20),XF1AT(5)        
      COMMON /IPURGE/ J,K,NSAV,PRISAV,HOLD        
      EQUIVALENCE              (DPD  (1),DNAF    ),(DPD  (2),DMXLG   ), 
     1     (DPD  (3),DCULG   ),(DPD  (4),DDBN (1)),(DPD  (6),DFNU (1)), 
     2     (FIAT (1),FUNLG   ),(FIAT (2),FMXLG   ),(FIAT (3),FCULG   ), 
     3     (FIAT (4),FEQU (1)),(FIAT (4),FILE (1)),(FIAT (4),FORD (1)), 
     4     (FIAT (5),FDBN (1)),(FIAT (7),FMAT (1)),(MD   (1),MLGN    ), 
     5     (MD   (2),MLSN (1)),(MD   (3),MINP (1)),(MD   (4),MOUT (1)), 
     6     (MD   (5),MSCR (1)),(SOS  (1),SLGN    ),(SOS  (2),SDBN (1)), 
     7     (SOS  (4),SAL  (1)),(SOS  (4),SNTU (1)),(SOS  (4),SORD (1)), 
     8     (XF1AT(1),FNTU (1)),(XF1AT(1),FON  (1)),(XF1AT(2),FPUN (1)), 
     9     (XF1AT(3),FCUM (1)),(XF1AT(4),FCUS (1)),(XF1AT(5),FKND (1))  
      EQUIVALENCE              (COMM (1),ALMSK   ),(COMM (2),APNDMK  ), 
     1     (COMM (3),CURSNO  ),(COMM (4),ENTN1   ),(COMM (5),ENTN2   ), 
     2     (COMM (6),ENTN3   ),(COMM (7),ENTN4   ),(COMM (8),FLAG    ), 
     3     (COMM (9),FNX     ),(COMM(10),LMSK    ),(COMM(11),LXMSK   ), 
     4     (COMM(12),MACSFT  ),(COMM(13),RMSK    ),(COMM(14),RXMSK   ), 
     5     (COMM(15),S       ),(COMM(16),SCORNT  ),(COMM(17),TAPMSK  ), 
     6     (COMM(18),THCRMK  ),(COMM(19),ZAP     )        
      DATA  PURGE1  /4HXPUR   ,4HGE     /        
C        
CIBMI 6/93
      CALL XSFADD
      K = -1        
      GO TO 10        
C        
C        
      ENTRY XEQUIV        
C     ============        
C        
CIBMI 6/93
      CALL XSFADD
      K = +1        
      PRISAV= 0        
      SECCHN= 0        
   10 ENTN1 = ICFIAT        
      LMT1  = FUNLG* ENTN1        
      LMT2  = LMT1 + 1        
      LMT3  = FCULG* ENTN1        
      IF (FCULG .GE. FMXLG) GO TO 610        
      NFCULG= LMT3 + 1        
      INCR  = 1        
C        
C     S = O 400000000000     Z 80000000        
C        
   20 S = LSHIFT(1,NBPW-1)        
C        
C     INITIALIZE FOR FIRST SET OF DATA BLOCKS        
C        
      NWDS = X(1)        
      I = 7        
  100 NDBS = X(I)        
C        
C     FIND POSITION OF VPS POINTER WORD        
C        
      JPT = I + 2*NDBS + 1        
      IF (K .EQ. 1) JPT = JPT + 1        
      IVPS  = X(JPT)        
      IEXEC = -1        
      IF (IVPS .GT. 0) IEXEC = VPS(IVPS)        
C        
C     TEST CONDITIONAL INDICATOR (NOT HERE, BELOW TO PERMIT UNPURGE-    
C     UNEQUIV        
C        
      GO TO 200        
C        
C     INCREMENT AND LOOK AT NEXT SET OF DATA BLOCKS        
C        
  150 I = JPT + 1        
      IF (I .LT. NWDS) GO TO 100        
      RETURN        
C        
C     TEST FOR PURGE OR EQUIV        
C        
  200 J = I + 1        
      IF (K .GT. 0) GO TO 400        
C        
C     PURGE LOGIC FOLLOWS        
C        
  220 XJ1 = X(J  )        
      XJ2 = X(J+1)        
      DO 260 N = 1,LMT3,ENTN1        
      IF (XJ1.NE.FDBN(N) .OR. XJ2.NE.FDBN(N+1)) GO TO 260        
      IF (N  .LE. LMT1) GO TO 240        
      IF (IEXEC .GE. 0) GO TO 230        
      FILE(N) = ZAP        
      GO TO 280        
C        
  230 IF (ANDF(RMSK,FILE(N)) .NE. ZAP) GO TO 300        
C        
C     UNPURGE (CLEAR THE ENTRY)        
C        
      LMT4 = N + ENTN1 - 1        
      DO 235 M = N,LMT4        
  235 FILE(M) = 0        
      GO TO 300        
  240 IF (IEXEC .GE. 0) GO TO 300        
      HOLD = ANDF(RXMSK,FILE(N))        
      LMT4 = N + ENTN1 - 1        
      DO 250 M = N,LMT4        
  250 FILE(M) = 0        
      FILE(N) = HOLD        
C        
      GO TO 270        
  260 CONTINUE        
  270 IF (IEXEC .GE. 0) GO TO 300        
      FILE(NFCULG  ) = ZAP        
      FDBN(NFCULG  ) = XJ1        
      FDBN(NFCULG+1) = XJ2        
      FCULG = FCULG + INCR        
      IF (FCULG .GE. FMXLG) GO TO 620        
      NFCULG = NFCULG + ENTN1        
C        
  280 CALL XPOLCK (XJ1,XJ2,FN,L)        
      IF (FN .EQ. 0) GO TO 300        
      DDBN(L  ) = 0        
      DDBN(L+1) = 0        
C        
  300 J = J + 2        
      IF (J-2.EQ.I+1 .AND. K.GT.0) J = J + 1        
      IF (J .LT. JPT) GO TO 220        
      GO TO 150        
C        
C     EQUIV LOGIC FOLLOWS        
C        
  400 XJ1 = X(J  )        
      XJ2 = X(J+1)        
      DO 450 N = 1,LMT3,ENTN1        
      IF (XJ1.NE.FDBN(N) .OR. XJ2.NE.FDBN(N+1)) GO TO 450        
      IF (J .NE. I+1) GO TO 420        
C        
C     PRIMARY        
C        
      PRISAV = ANDF(RXMSK,FILE(N))        
      IF (IEXEC .GE. 0) GO TO 550        
C        
C     IF PRIMARY FILE IS PURGED OR HAS ZERO TRAILERS, PURGE SECONDARYS  
C        
      IF (ANDF(RMSK,PRISAV) .EQ. ZAP) GO TO 300        
      IF (FMAT(N).NE.0 .OR.  FMAT(N+1).NE.0 .OR. FMAT(N+2).NE.0)        
     1    GO TO 405        
      IF (ENTN1.EQ.11 .AND. (FMAT(N+5).NE.0 .OR. FMAT(N+6).NE.0 .OR.    
     1    FMAT(N+7).NE.0)) GO TO 405        
      GO TO 300        
  405 FEQU(N) = ORF(S,FEQU(N))        
      NSAV = N        
      CALL XPOLCK (XJ1,XJ2,FNSAV,LSAV)        
      IF (FNSAV .NE. 0) DFNU(LSAV) = ORF(S,DFNU(LSAV))        
C        
C     IF PRIMARY FILE CONTAINS OTHER UNEQUIV D.B.- CLEAR THEM        
C        
      DO 415 JX = 1,LMT3,ENTN1        
      IF (FEQU(JX).LT.0 .OR. JX.EQ.N) GO TO 415        
      IF (PRISAV .NE. ANDF(RXMSK,FILE(JX))) GO TO 415        
      LMT4 = JX + ENTN1 - 1        
      DO 410 M = JX,LMT4        
  410 FILE(M) = 0        
      IF (JX .LE. LMT1) FILE(JX) = PRISAV        
  415 CONTINUE        
      GO TO 550        
C        
C     SECONDARY        
C        
  420 IF (IEXEC .GE. 0) GO TO 425        
      IF (PRISAV.EQ. 0) GO TO 435        
      IF (FILE(N).LT.0 .AND. ANDF(RXMSK,FILE(N)).NE.PRISAV)        
     1    SECCHN = ANDF(RMSK,FILE(N))        
      IF (N .LE. LMT1) GO TO 430        
      FILE(N  ) = ORF(ANDF(LXMSK,FILE(N)),PRISAV)        
      FEQU(N  ) = ORF(S,FEQU(N))        
      FMAT(N  ) = FMAT(NSAV  )        
      FMAT(N+1) = FMAT(NSAV+1)        
      FMAT(N+2) = FMAT(NSAV+2)        
      IF (ENTN1 .NE. 11) GO TO 480        
      FMAT(N+5) = FMAT(NSAV+5)        
      FMAT(N+6) = FMAT(NSAV+6)        
      FMAT(N+7) = FMAT(NSAV+7)        
      GO TO 480        
  425 IF (FEQU(N).GE.0 .OR. PRISAV.NE.ANDF(RXMSK,FILE(N))) GO TO 550    
C        
C     UNEQUIV (CLEAR SEC EQUIV ENTRY)        
C        
      LMT4 = N + ENTN1 - 1        
      DO 427 M = N,LMT4        
  427 FILE(M) = 0        
      IF (N .LE. LMT1) FILE(N) = PRISAV        
      CALL XPOLCK (XJ1,XJ2,FN,L)        
      IF (FN .EQ. 0) GO TO 550        
      DDBN(L  ) = 0        
      DDBN(L+1) = 0        
      GO TO 550        
  430 FILE(NFCULG) = ORF(ANDF(LXMSK,FILE(N)),PRISAV)        
  435 HOLD = ANDF(RXMSK,FILE(N))        
      LMT4 = N + ENTN1 -1        
      DO 440 M = N,LMT4        
  440 FILE(M) = 0        
      IF (N .LE. LMT1) FILE(N) = HOLD        
      IF (PRISAV .EQ. 0) GO TO 480        
      GO TO 470        
C        
C     FILE IS NOT IN FIAT -- CHECK PARM FOR TYPE OF EQUIV        
C        
  450 CONTINUE        
      IF (IEXEC .LT. 0) GO TO 458        
C        
C     ELIMINATE EQUIV FILES -- CHECK FOR PRIMARY FILE        
C        
      IF (J .NE. I+1) GO TO 455        
C        
C     PRIMARY FILE        
C        
      CALL XPOLCK (XJ1,XJ2,FNSAV,LSAV)        
C        
C     LEAVE EQUIV FLAG FOR XDPH        
C        
      GO TO 550        
C        
C     SECONDARY FILE --  BREAK EQUIV        
C        
  455 CALL XPOLCK (XJ1,XJ2,SNSAV,SSAV)        
C        
C     CHECK IF FILE EXISTS AND IS EQUIVED TO PRIMARY FILE        
C        
      IF (SNSAV.EQ.0 .OR. FNSAV.NE.SNSAV) GO TO 550        
      DDBN( SSAV  ) = 0        
      DDBN( SSAV+1) = 0        
      GO TO 550        
C        
C     CHECK FOR PRIMARY FILE        
C        
  458 IF (J .NE. I+1) GO TO 460        
C        
C     -IF PRIMARY, IT MUST BE ON POOL        
C        
      CALL XPOLCK (XJ1,XJ2,FNSAV,LSAV)        
      IF (FNSAV .EQ. 0) GO TO 300        
      DFNU(LSAV) = ORF(S,DFNU(LSAV))        
      GO TO 550        
C        
C     -IF SECONDARY, WAS PRIMARY IN FIAT        
C        
  460 IF (PRISAV .EQ. 0) GO TO 480        
C        
C     -PRIMARY WAS IN FIAT, SET UP SECONDARY IN FIAT        
C        
      FILE(NFCULG  ) = PRISAV        
  470 FEQU(NFCULG  ) = ORF(S,FEQU(NFCULG))        
      FDBN(NFCULG  ) = XJ1        
      FDBN(NFCULG+1) = XJ2        
      FMAT(NFCULG  ) = FMAT(NSAV  )        
      FMAT(NFCULG+1) = FMAT(NSAV+1)        
      FMAT(NFCULG+2) = FMAT(NSAV+2)        
      IF (ENTN1 .NE. 11) GO TO 475        
      FMAT(NFCULG+5) = FMAT(NSAV+5)        
      FMAT(NFCULG+6) = FMAT(NSAV+6)        
      FMAT(NFCULG+7) = FMAT(NSAV+7)        
  475 FCULG = FCULG + INCR        
      IF (FCULG .GE. FMXLG) GO TO 630        
      NFCULG = NFCULG + ENTN1        
C        
C     WAS SECONDARY FILE IN FIAT ALREADY EQUIV TO OTHERS        
C        
  480 IF (SECCHN .EQ. 0) GO TO 490        
C        
C     SEC. FILE WAS EQUIV - DRAG ALONG ALL EQUIVS        
C        
      DO 485 IJ = 1,LMT3,ENTN1        
      IF (FILE(IJ) .GE. 0) GO TO 485        
      IF (IJ       .EQ. N) GO TO 485        
      IF (ANDF(RMSK,FILE(IJ)) .NE. SECCHN) GO TO 485        
C        
C     CREATE AN ENTRY IN OSCENT TO EXPLICITLY EQUIV THIS DB        
C        
      M1   = NWDS + 1        
      NWDS = NWDS + 6        
      X(M1  ) = 2        
      X(M1+1) = XJ1        
      X(M1+2) = XJ2        
      IF (K .NE. 1) GO TO 482        
      X(M1+3) = 0        
      NWDS = NWDS + 1        
      M1   = M1   + 1        
  482 CONTINUE        
      X(M1+3) = FDBN(IJ  )        
      X(M1+4) = FDBN(IJ+1)        
      X(M1+5) = IVPS        
  485 CONTINUE        
C        
C     IS SECONDARY FILE ON POOL        
C        
  490 CALL XPOLCK (XJ1,XJ2,FN,L)        
      IF (FN .EQ. 0) GO TO 500        
C        
C     WAS SEC. FILE ON POOL ALREADY EQUIV TO OTHERS        
C        
      IF (DFNU(L).GE.0 .OR. FNSAV.EQ.FN) GO TO 495        
C        
C     SEC. FILE ON POOL WAS EQUIV - DRAG ALONG ALL EQUIVS        
C        
      LMT4 = DCULG* ENTN4        
      M    = LMT4 + 1        
      DO 494 IJ = 1,LMT4,ENTN4        
      IF (DFNU(IJ).GE.0  .OR. IJ.EQ.L) GO TO 494        
      IF (ANDF(RMSK,DFNU(IJ)) .NE. FN) GO TO 494        
      IF (FNSAV .EQ. 0) GO TO 491        
      DDBN(M  ) = DDBN(IJ  )        
      DDBN(M+1) = DDBN(IJ+1)        
C     DDBN(M  ) = DFNU(LSAV)        
      DFNU(M  ) = DFNU(LSAV)        
      DCULG = DCULG + 1        
      IF (DCULG .GT. DMXLG) GO TO 910        
      M = M + ENTN4        
      GO TO 493        
C        
C     CREATE AN ENTRY IN OSCENT TO EXPLICITLY EQUIV THIS DB        
C        
  491 M1   = NWDS + 1        
      NWDS = NWDS + 6        
      X(M1  ) = 2        
      X(M1+1) = XJ1        
      X(M1+2) = XJ2        
      IF (K .NE. 1) GO TO 492        
      X(M1+3) = 0        
      NWDS = NWDS + 1        
      M1   = M1 + 1        
  492 CONTINUE        
      X(M1+3) = DDBN(IJ  )        
      X(M1+4) = DDBN(IJ+1)        
      X(M1+5) = IVPS        
  493 DDBN(IJ  ) = 0        
      DDBN(IJ+1) = 0        
  494 CONTINUE        
C        
C     IF SECONDARY FILE IS ON POOL AND PRIMARY IS NOT - DELETE SEC REF  
C        
  495 IF (FNSAV .NE. 0) GO TO 530        
      DDBN(L  ) = 0        
      DDBN(L+1) = 0        
      GO TO 550        
C        
C     IF SECONDARY FILE IS NOT ON POOL AND PRIMARY IS - ADD SEC REF     
C        
  500 IF (FNSAV .EQ. 0) GO TO 550        
  520 M = DCULG*ENTN4 + 1        
      DDBN(M  ) = XJ1        
      DDBN(M+1) = XJ2        
      DFNU(M  ) = DFNU(LSAV)        
      DCULG = DCULG + 1        
      IF (DCULG .GT. DMXLG) GO TO 910        
      GO TO 550        
C        
C     BOTH PRIMARY AND SECONDARY ON POOL - IF NOT SAME FILE,        
C     DELETE OLD SEC REF AND ADD NEW SEC REF        
C        
  530 IF (FNSAV .EQ. FN) GO TO 550        
      DDBN(L  ) = 0        
      DDBN(L+1) = 0        
      GO TO 520        
C        
  550 J = J + 2        
      IF (J-2 .EQ. I+1) J = J + 1        
      SECCHN = 0        
      IF (J .LT. JPT) GO TO 400        
      PRISAV = 0        
      GO TO 150        
C        
C     POTENTIAL FIAT OVERFLOW- LOOK FOR OTHER SLOTS IN FIAT TAIL        
C        
  610 ASSIGN 20 TO IBACK        
      GO TO 640        
  620 ASSIGN 280 TO IBACK        
      GO TO 640        
  630 ASSIGN 480 TO IBACK        
  640 IF (FCULG .GT. FMXLG) GO TO 900        
      DO 650 NN = LMT2,LMT3,ENTN1        
      IF (FILE(NN).LT.0 .OR. ANDF(ZAP,FILE(NN)).EQ.ZAP) GO TO 650       
      IF (FMAT(NN).NE.0 .OR. FMAT(NN+1).NE.0 .OR. FMAT(NN+2).NE.0)      
     1    GO TO 650        
      IF (ENTN1.EQ.11 .AND. (FMAT(NN+5).NE.0 .OR. FMAT(NN+6).NE.0 .OR.  
     1    FMAT(NN+7).NE.0)) GO TO 650        
      NFCULG = NN        
      INCR   = 0        
      GO TO 660        
  650 CONTINUE        
      NFCULG = NFCULG + ENTN1        
      INCR   = 1        
  660 GO TO IBACK, (20,280,480)        
C        
C     ERROR MESSAGES        
C        
  900 WRITE  (OUTTAP,901) SFM        
  901 FORMAT (A25,' 1201, FIAT OVERFLOW.')        
      GO TO 1000        
  910 WRITE  (OUTTAP,911) SFM        
  911 FORMAT (A25,' 1202, DPL OVERFLOW.')        
 1000 CALL MESAGE (-37,0,PURGE1)        
      RETURN        
      END        
