      SUBROUTINE CMSFIL        
C        
C     THIS SUBROUTINE GENERATES THE WORKING SUBSTRUCTURE FILE AND       
C     APPLIES ALL TRANSFORMATIONS        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         TDAT,XTRAN,XCSTM,IAUTO        
      INTEGER         AAA(2),ANDF,RSHIFT,BUFEX,OUTT,        
     1                SCBDAT,BUF4,SCORE,TRN,SYM,COMBO,NAM(2),Z,SCMCON,  
     2                SCCSTM,CSTMID,CGID,BUF2,BUF3,BUF1,ECPT1,TWOJM1    
      DIMENSION       RZ(1),ECPT(4),DOFN(6),LIST(32),TG(3,3),TG6(6,6),  
     1                TSAVE(6,6),TMAT(6,6),TC(3,3),TT(3,3),XX(3)        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC,SCCSTM,SCR3        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INTP,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6)        
      COMMON /GTMATX/ LOC1,KLTRAN,TRN,TT6(6,6),TC6(6,6)        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (ECPT1,ECPT(1)), (RZ(1),Z(1))        
      DATA    AAA   / 4H CMS, 4HFIL  /        
      DATA    NHBGSS, NHCSTM,NHEQSS  / 4HBGSS,4HCSTM,4HEQSS /        
C        
      BUFEX  = LCORE - BUF1 + BUF2        
      LCORE  = BUFEX - 1        
      IF (LCORE .LT. 0) GO TO 620        
      LLCO   = LCORE        
      IOEFIL = 310        
      IFILE  = SCBDAT        
      CALL OPEN (*600,SCBDAT,Z(BUF4),0)        
C        
C     READ GTRAN DATA INTO OPEN CORE        
C        
      IF (TDAT(3) .OR. TDAT(6)) CALL SKPFIL (SCBDAT,1)        
      IF (.NOT.TDAT(6)) GO TO 20        
      KSGTRN = SCORE        
      CALL READ (*610,*10,SCBDAT,Z(KSGTRN),LLCO,1,KLGTRN)        
      GO TO 620        
   10 LLCO   = LLCO - KLGTRN        
      KFGTRN = KSGTRN + KLGTRN - 1        
      GO TO 30        
C        
C     READ TRANS DATA INTO OPEN CORE        
C        
   20 KSTRAN = SCORE        
      GO TO 40        
   30 KSTRAN = KFGTRN + 1        
   40 IF (TDAT(3) .OR. TDAT(6)) CALL SKPFIL (SCBDAT,1)        
      IF (.NOT. TDAT(3)) GO TO 60        
      CALL READ (*610,*50,SCBDAT,Z(KSTRAN),LLCO,1,KLTRAN)        
      GO TO 620        
   50 LOC1   = KSTRAN        
      LLCO   = LLCO - KLTRAN        
      XTRAN  = .TRUE.        
      KFTRAN = KSTRAN + KLTRAN - 1        
      GO TO 70        
   60 LOC1   = 0        
      XTRAN  = .FALSE.        
   70 CALL CLOSE (SCBDAT,1)        
      IFILE  = SCSFIL        
      CALL OPEN (*600,SCSFIL,Z(BUF4),1)        
      IFILE  = SCCSTM        
      CALL OPEN (*600,SCCSTM,Z(BUF3),1)        
      KKC    = 0        
C        
C     LOOP ON EACH PSEUDOSTRUCTURE        
C        
      IFILE  = SCR3        
      CALL OPEN (*600,SCR3,Z(BUF1),1)        
      IFILE  = IOEFIL        
      CALL OPEN (*600,IOEFIL,Z(BUFEX),1)        
      LLCOLD = LLCO        
C        
      DO 550 I = 1,NPSUB        
      LLCO   = LLCOLD        
      NAM(1) = COMBO(I,1)        
      NAM(2) = COMBO(I,2)        
      TRN    = COMBO(I,3)        
      SYM    = COMBO(I,4)        
      NCOMP  = COMBO(I,5)        
C        
C     READ BGSS FOR I-TH PSEUDOSTRUCTURE        
C        
      KSBGSS = KSTRAN        
      IF (XTRAN) KSBGSS = KSTRAN + KLTRAN        
      CALL SFETCH (NAM,NHBGSS,1,ITEST)        
      NGRP   = 1        
      CALL SJUMP (NGRP)        
      CALL SUREAD (Z(KSBGSS),LLCO,KLBGSS,ITEST)        
      IF (KLBGSS.EQ.LLCO .AND. ITEST.NE.2) GO TO 620        
      LLCO   = LLCO - KLBGSS        
      KFBGSS = KSBGSS + KLBGSS - 1        
      NIP    = KLBGSS/4        
C        
C     READ CSTM FOR THIS PSEUDOSTRUCTURE        
C        
      CALL SFETCH (NAM,NHCSTM,1,ITEST)        
      XCSTM  = .FALSE.        
      LOC2   = 0        
      IF (ITEST .EQ. 3) GO TO 80        
      KSCSTM = KFBGSS + 1        
      NGRP   = 1        
      CALL SJUMP (NGRP)        
      CALL SUREAD (Z(KSCSTM),LLCO,KLCSTM,ITEST)        
      IF (KLCSTM.EQ.LLCO .AND. ITEST.NE.2) GO TO 620        
      LLCO   = LLCO - KLCSTM        
      LOC2   = KSCSTM        
      XCSTM  = .TRUE.        
      KFCSTM = KSCSTM + KLCSTM - 1        
   80 CONTINUE        
C        
C     DEFINE OPEN CORE ARRAYS FOR NEW CID AND HPTR        
C        
      KSNCID = KFBGSS + 1        
      IF (LOC2 .NE. 0) KSNCID = KFCSTM + 1        
      KLNCID = NIP        
      LLCO   = LLCO - KLNCID        
      KFNCID = KSNCID + KLNCID - 1        
C        
      KSHPTR = KFNCID + 1        
      KLHPTR = NIP        
      LLCO   = LLCO - KLHPTR        
      KFHPTR = KSHPTR + KLHPTR - 1        
C        
C     SET ARRAYS TO ZERO        
C        
      DO 90 J = KSNCID,KFNCID        
      Z(J) = 0        
   90 CONTINUE        
      DO 100 J = KSHPTR,KFHPTR        
      Z(J) = 0        
  100 CONTINUE        
C        
C     GET THE TRANS AND SYMT MATRIX FOR THIS PSEUDOSTRUCTURE        
C        
      CALL GTMAT1 (SYM,TT)        
C        
C     TRANSFORM THE COORDINATES IN THE BGSS, NOTE THAT THE ORIGINS      
C     FOR TRANSLATION ARE STORED IN ARRAY ORIGIN.        
C        
      IF (TRN+SYM .EQ. 0) GO TO 130        
      DO 120 J = KSBGSS,KFBGSS,4        
      IF (Z(J) .EQ. -1) GO TO 120        
      CALL GMMATS (TT,3,3,0 ,RZ(J+1),3,1,0 ,XX)        
      DO 110 JJ = 1,3        
      RZ(J+JJ) = XX(JJ) + ORIGIN(I,JJ)        
  110 CONTINUE        
  120 CONTINUE        
  130 CONTINUE        
C        
C     TRANSFORM DEGREES OF FREEDOM FOR EACH EQSS CONTAINED        
C     IN THE PSEUDOSTRUCTURE.        
C        
      CALL WRITE (SCR3,TT6,36,1)        
      NHMAT = 1        
      CALL SFETCH (NAM,NHEQSS,1,ITEST)        
      KNEQSS = KFHPTR + 1        
      CALL SUREAD (Z(KNEQSS),4,KLEQSS,ITEST)        
      CALL SUREAD (Z(KNEQSS),-1,KLEQSS,ITEST)        
      LLCO  = LLCO - 2*NCOMP        
      IFILE = SCMCON        
      CALL OPEN (*600,SCMCON,Z(BUF2),1)        
      DO 350 J = 1,NCOMP        
      KSEQSS = KFHPTR + 2*NCOMP        
      CALL SUREAD (Z(KSEQSS),LLCO,KLEQSS,ITEST)        
      IF (KLEQSS .EQ. 0) GO TO 340        
      IF (KLEQSS.EQ.LLCO .AND. ITEST.NE.2) GO TO 620        
      KFEQSS = KSEQSS + KLEQSS - 1        
C        
C     LOOP ON EACH IP IN THE EQSS AND GENERATE TRANSFORMATION MATRIX    
C        
      DO 330 JJ = KSEQSS,KFEQSS,3        
      IP    = Z(JJ+1)        
      ICOMP = Z(JJ+2)        
C        
C     GET CSTM FOR THIS IP        
C        
      CSTMID = Z(KSBGSS+4*IP-4)        
      ECPT1  = CSTMID        
      IF (CSTMID .LT. 0) ECPT1 = 0        
      DO 140 JDH = 1,3        
      ECPT(JDH+1) = RZ(KSBGSS+4*IP-4+JDH)        
  140 CONTINUE        
      CALL GTMAT2 (LOC2,KLCSTM,ECPT,TC)        
C        
C     TEST FOR POSSIBLE GTRAN        
C        
      IGTRAN = 0        
      IF (.NOT.TDAT(6)) GO TO 170        
      CGID = 1000000*J + Z(JJ)        
      DO 150 K = KSGTRN,KFGTRN,5        
      IF (Z(K+3).EQ.CGID .AND. Z(K).EQ.I .AND. Z(K+1).EQ.J) GO TO 160   
  150 CONTINUE        
C        
C     NO GTRAN        
C        
      GO TO 170        
  160 CALL GTMAT3 (Z(K+4),TG,TG6,IKIND)        
      IGTRAN = 1        
      GO TO 180        
  170 CALL GTMAT3 (-1,TG,TG6,IKIND)        
C        
C     ALL TRANSFORMATIONS HAVE BEEN FOUND, COMPUTE THE FINAL MATRIX TMAT
C        
  180 CALL GMMATS (TG6  ,6,6,1,TT6,6,6,0,TSAVE)        
      CALL GMMATS (TSAVE,6,6,0,TC6,6,6,0,TMAT )        
C        
C     DECODE DEGREES OF FREEDOM AND FORM VECTOR        
C        
      CALL DECODE (ICOMP,LIST,NDOF)        
C        
C     FIND NEW DEGREES OF FREEDOM AND UPDATE EQSS        
C        
      IF (CSTMID.NE.0 .AND. IGTRAN.EQ.0) GO TO 220        
      DO 200 I1 = 1,6        
      DOFN(I1) = 0.0        
      DO 190 I2 = 1,NDOF        
      L = LIST(I2) + 1        
      IF (ABS(TMAT(L,I1)) .LT. 1.0E-4) GO TO 190        
      DOFN(I1) = 1.0        
      GO TO 200        
  190 CONTINUE        
  200 CONTINUE        
      ICODE = 0        
      DO 210 I1 = 1,6        
      ICODE = ICODE + DOFN(I1)*2**(I1-1)        
  210 CONTINUE        
      GO TO 230        
  220 ICODE   = ICOMP        
  230 Z(JJ+2) = ICODE        
C        
C     WRITE IP,C ON SCRATCH TO COMPUTE NEW SIL,C        
C        
      CALL WRITE (SCMCON,IP,1,0)        
      CALL WRITE (SCMCON,ICODE,1,0)        
C        
C     UPDATE CID NUMBERS        
C        
      IADD   = KSBGSS + 4*IP - 4        
      IADD1  = KSNCID + IP - 1        
      IKKIND = IKIND  + 1        
      GO TO (240,240,250,250,240,240,260,260,290,290,290,290,270,270,   
     1       280,280,290,290,290,290,290,290,290,290,290,290,290,290,   
     2       280,280,280,280,280,280,280), IKKIND        
  240 Z(IADD1) = Z(IADD)        
      IF (Z(IADD) .EQ. -1) Z(IADD1) = -100000000        
      IF (Z(IADD) .EQ. -2) Z(IADD1) = -200000000        
      GO TO 290        
C        
C     COMMENTS FROM G.CHAN/UNISYS  9/92        
C     250 AND 240 ARE IDENTICAL HERE. IS IT POSSIBLY AN ERROR HERE?     
C        
  250 Z(IADD1) = Z(IADD)        
      IF (Z(IADD) .EQ. -1) Z(IADD1) = -100000000        
      IF (Z(IADD) .EQ. -2) Z(IADD1) = -200000000        
      GO TO 290        
  260 Z(IADD1) = 0        
      GO TO 290        
  270 Z(IADD1) = -TRN        
      GO TO 290        
  280 Z(IADD1) = -Z(K+4)        
  290 CONTINUE        
C        
C     SET POINTERS FOR H MATRIX        
C        
      ITIS = 0        
      IADD2 = KSHPTR + IP - 1        
      IF (CSTMID   .LT. 0) GO TO 300        
      IF (Z(IADD2) .GT. 2) GO TO 330        
      IF (IKKIND.EQ. 3 .OR. IKKIND.EQ.4 .OR. IKKIND.EQ.13 .OR.        
     1    IKKIND.EQ.14) ITIS = 1        
      IF (IKKIND.EQ. 1 .OR. IKKIND.EQ.2 .OR. IKKIND.EQ. 5 .OR.        
     1    IKKIND.EQ. 6) ITIS = 2        
      IF (ITIS - 1) 320,300,310        
  300 Z(IADD2) = 0        
      GO TO 330        
  310 Z(IADD2) = 1        
      GO TO 330        
  320 CONTINUE        
      NHMAT = NHMAT + 1        
      Z(IADD2) = NHMAT        
      CALL WRITE (SCR3,TMAT,36,1)        
  330 CONTINUE        
C        
C     INSERT MULTIPLE IP CODE        
C        
      IF (NCOMP .NE. 1) CALL EQSCOD (KSEQSS,KLEQSS,Z(1))        
C        
C     WRITE EQSS ON FILE SCSFIL        
C        
  340 CALL WRITE (SCSFIL,Z(KSEQSS),KLEQSS,1)        
      TWOJM1 = 2*(J-1)        
      IF (ANDF(RSHIFT(IPRINT,19),1) .EQ. 1)        
     1    CALL CMIWRT (1,NAM,Z(KNEQSS+TWOJM1),KSEQSS,KLEQSS,Z,Z)        
  350 CONTINUE        
      CALL EOF (SCR3)        
      CALL CLOSE (SCMCON,1)        
C        
C     GENERATE NEW SIL,C LIST        
C        
      IFILE = SCMCON        
      CALL OPEN (*600,SCMCON,Z(BUF2),0)        
      CALL READ (*360,*360,SCMCON,Z(KSEQSS),LLCO,1,NNN)        
      GO TO 620        
  360 CALL SORT (0,0,2,1,Z(KSEQSS),NNN)        
      KSEJ = KSEQSS + NNN - 1        
      I1 = KSEQSS        
      I2 = KSEQSS + 2        
  370 IF (I2-KSEQSS .GE. NNN) GO TO 400        
      IF (Z(I1)   .EQ. Z(I2)) GO TO 380        
      I1 = I1 + 2        
      I2 = I2 + 2        
      GO TO 370        
  380 DO 390 J = I2,KSEJ        
  390 Z(J-2) = Z(J)        
      KSEJ = KSEJ - 2        
      NNN  = NNN  - 2        
      GO TO 370        
  400 CONTINUE        
      Z(KSEQSS) = 1        
      DO 410 J = 3,NNN,2        
      JJ = J - 1        
      ICODE = Z(KSEQSS+JJ-1)        
      CALL DECODE (ICODE,LIST,NDOF)        
      Z(KSEQSS+JJ) = Z(KSEQSS+JJ-2) + NDOF        
  410 CONTINUE        
      CALL WRITE  (SCSFIL,Z(KSEQSS),NNN,1)        
      CALL SUREAD (Z(KSEQSS),LLCO,KLEQSS,ITEST)        
      CALL WRITE  (IOEFIL,Z(KSEQSS),KLEQSS,1)        
      CALL CLOSE  (SCMCON,1)        
C        
C     PRINT EQSS SIL LIST IF REQUESTED        
C        
      IF (ANDF(RSHIFT(IPRINT,19),1) .EQ. 1)        
     1    CALL CMIWRT (8,NAM,0,KSEQSS,KLEQSS,Z,Z)        
C        
C     UPDATE CSTM NUMBERING SYSTEM        
C     KKC IS TRANSFORMED SYSTEM COORD. ID        
C        
      IP  = 0        
      DO 540 I6 = KSNCID,KFNCID        
      IP  = IP + 1        
      LOC = KSBGSS + 4*(IP-1)        
      IF (Z(I6) .EQ. 100000000) GO TO 540        
      IF (Z(I6)) 430,520,420        
  420 I1  = KSCSTM        
      I2  = KFCSTM        
      GO TO 440        
  430 IF (Z(I6) .EQ. -100000000) GO TO 530        
      I1  = KSTRAN        
      I2  = KFTRAN        
  440 KKC = KKC + 1        
      IF (IAUTO) GO TO 480        
      IF (KKC .GT. 1) GO TO 460        
      CALL PAGE1        
      CALL PAGE2 (5)        
      WRITE  (OUTT,450)        
  450 FORMAT (//45X,'SUMMARY OF OVERALL SYSTEM COORDINATES', //36X,     
     1      'PSEUDO STRUCTURE ID.   SYSTEM COORD.ID    USER COORD.ID',/)
  460 CALL PAGE2 (1)        
      WRITE  (OUTT,470) I,KKC,Z(LOC)        
  470 FORMAT (43X,I6,14X,I6,11X,I6)        
  480 LOOK4 = Z(I6)        
      DO 500  J6 = I1,I2,14        
      IF (IABS(Z(I6)) .NE. Z(J6)) GO TO 500        
      IF (Z(I6) .LE. 0) GO TO 490        
      CALL GMMATS (TT,3,3,0,Z(J6+5),3,3,0,TC)        
      CALL WRITE (SCCSTM,KKC,1,0)        
      CALL WRITE (SCCSTM,Z(J6+1),4,0)        
      CALL WRITE (SCCSTM,TC,9,0)        
      GO TO 500        
  490 CONTINUE        
      CALL WRITE (SCCSTM,KKC,1,0)        
      CALL WRITE (SCCSTM,Z(J6+1),13,0)        
  500 CONTINUE        
C        
C     FIND OTHER CIDS THAT ARE THE SAME        
C        
      IIP = 0        
      DO 510 J6 = KSNCID,KFNCID        
      IIP = IIP + 1        
      IF (Z(J6).NE. LOOK4) GO TO 510        
      LOC = KSBGSS + 4*(IIP-1)        
      Z(LOC) = KKC        
      Z(J6) = 100000000        
  510 CONTINUE        
      GO TO 540        
  520 Z(LOC) = 0        
      GO TO 540        
  530 Z(LOC) = -1        
      IF (Z(I6) .EQ. -200000000) Z(LOC) = -2        
  540 CONTINUE        
C        
C     WRITE PROCESSED BGSS        
C        
      CALL WRITE (SCSFIL,Z(KSBGSS),KLBGSS,1)        
      IF (ANDF(RSHIFT(IPRINT,18),1) .EQ.  1)        
     1    CALL CMIWRT (2,NAM,NAM,KSBGSS,KLBGSS,Z(1),Z(1) )        
C        
C     WRITE ARRAY OF H POINTERS        
C        
      CALL WRITE (SCSFIL,Z(KSHPTR),KLHPTR,1)        
      CALL EOF (SCSFIL)        
  550 CONTINUE        
C        
      CALL CLOSE (SCR3,1)        
      CALL CLOSE (SCSFIL,1)        
      CALL WRITE (SCCSTM,TMAT,0,1)        
      CALL CLOSE (SCCSTM,1)        
      CALL CLOSE (IOEFIL,1)        
      LCORE = BUFEX + BUF1 - BUF2        
      RETURN        
C        
  600 IMSG = -1        
      GO TO 630        
  610 IMSG = -2        
      GO TO 630        
  620 IMSG = -8        
  630 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
