      SUBROUTINE PULL (BCD,OUT,ICOL,NCHAR,FLAG)        
C        
C     THIS ROUTINE EXTRACTS BCD DATA (OUT) FROM A STRING,(BCD)        
C     STARTING AT POSITION ICOL        
C        
      EXTERNAL        ORF        
      LOGICAL         FIRST        
      INTEGER         BCD(1),OUT(1),FLAG,CPERWD,BLANK,ORF        
      COMMON /SYSTEM/ IDUM(38),NBPC,NBPW,NCPW        
      DATA    CPERWD/ 4 /, BLANK / 4H     /, FIRST / .TRUE. /        
C        
      NWDS  = (NCHAR-1)/CPERWD + 1        
      IF (.NOT.FIRST) GO TO 5        
      FIRST = .FALSE.        
      NX    = NCPW - CPERWD        
      IXTRA = NX*NBPC        
      IBL   = 0        
      IB1   = KRSHFT(BLANK,NCPW-1)        
      IF (NX .EQ. 0) GO TO 5        
      DO 2 I = 1,NX        
      IBL = ORF(IBL,KLSHFT(IB1,I-1))        
    2 CONTINUE        
    5 DO 10 I = 1,NWDS        
   10 OUT(I) = IBL        
C        
      IWD = (ICOL-1)/CPERWD + 1        
      M1  = (ICOL-(IWD-1)*CPERWD-1)*NBPC        
      M2  = CPERWD*NBPC - M1        
C        
      DO 20 I = 1,NWDS        
      IBCD   = IWD + I - 1        
      ITEMP  = KRSHFT(BCD(IBCD),IXTRA/NBPC)        
      OUT(I) = ORF(OUT(I),KLSHFT(ITEMP,(M1+IXTRA)/NBPC))        
      ITEMP  = KRSHFT(BCD(IBCD+1),(M2+IXTRA)/NBPC)        
      OUT(I) = ORF(OUT(I),KLSHFT(ITEMP,IXTRA/NBPC))        
   20 CONTINUE        
      IF (NWDS*CPERWD .EQ. NCHAR) RETURN        
C        
C     REMOVE EXTRA CHARACTERS FROM LAST OUT WORD        
C        
      NBL   = (NWDS-1)*CPERWD + NCPW - NCHAR        
      LWORD = KRSHFT(OUT(NWDS),NBL)        
      OUT(NWDS) = KLSHFT(LWORD,NBL)        
C        
      ITEMP = 0        
      DO 40 I = 1,NBL        
      ITEMP = ORF(ITEMP,KLSHFT(IB1,I-1))        
   40 CONTINUE        
      OUT(NWDS) = ORF(OUT(NWDS),ITEMP)        
C        
      RETURN        
      END        
