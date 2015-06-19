      SUBROUTINE ASPRO (DMAP,VAR,NVAR,OBITS,SOL)        
C        
C     THIS CODE  PERFORMS THE  ROUTINE PROCESSING OF THE  DMAP ALTERS   
C     FOR ASDMAP.  KEY TABLES ARE-        
C        
C      DMAP  -  RAW  18 WORD PER CARD BCD DATA ON INPUT, VARIABLE       
C               CHARACTERS ARE ADDED AND  FIELDS AND CARDS ARE DELETED  
C               DEPENDING ON USER INPUT IN  VAR(IABLE) AND OPTION FLAGS.
C        
C      VAR      CONTROL DATA AND USER INPUT DATA, 3 WORDS, BCD + DATA   
C        
C      PTBS     POSITIONS-TO-BE-SET TABLE, CONTENTS-PER ENTRY        
C        
C                    1   CARD NUMBER IN DMAP        
C                    2   FIRST CHARACTER OF MODIFIED FIELD        
C                    3   FIRST CHARACTER FOR ADDED VARIABLE        
C                    4   NUMBER OF VARIABLE CHARACTERS        
C                    5   KEY OF VARIABLE TO BE INSERTED        
C                    6   MATRIX OPTION FLAG , 1= K, 2=M, 4=P  ETC       
C                    7   OUTPUT CONTROL FLAG, AVOIDS SAME DATA BLOCK    
C                        OUTPUT FROM TWO MODULES        
C        
C      OCT      OPTIONAL CARDS TABLE - EACH ENTRY =        
C                   DMAP CARD NO. , DELETE BITS ,  KEEP BITS        
C        
C      OBITS -  BITS ARE ON FOR REQUIRED MATRICES  =  SUM OF NUMBERS    
C                   K=1 , M=2 , P=4 , PA=8 , B=16 , K4=32        
C        
      EXTERNAL        ANDF        
      LOGICAL         RMV,RMVALL        
      INTEGER         ANDF,DBS(2,50),DMAP(18,1),FLAG,II(2),NAME(4),     
     1                OBITS,OCT(3,50),PTBS(7,200),VAR(3,200),VWORD,SOL, 
     2                ALTER,BLANK,AST,SLAS,OBALL,RFMASK(40)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /ASDBD / IRDM,NRDM,IXTRA,NXTRA,IOCT,NOCT,IPTBS,NPTBS,      
     1                IPH,NPH,IDAT(1)        
CZZ   COMMON /ZZASDX/ SBD(2)        
      COMMON /ZZZZZZ/ SBD(2)        
      COMMON /SYSTEM/ IDUM1,IOUT,NOGO        
      EQUIVALENCE     (NDBS,SBD(1)),(DBS(1,1),SBD(2))        
      DATA    ALTER / 4HALTE /,      BLANK  / 4H     /        
      DATA    AST   / 4H*    /,      SLAS   / 4H/    /        
      DATA    RFMASK/ 65536,131072,262144,0,0,0,0,524288,1048576,31*0 / 
      DATA    OBALL / 63     /        
C        
      RMVALL = .TRUE.        
      NXDEL  = 0        
      NOLD   = 0        
C        
C     DELETE CARDS USING OCT TABLE.        
C        
      IF (NOCT .EQ. 0) GO TO 45        
      M = IOCT - 1        
      DO 10 J = 1,NOCT        
      DO 10 I = 1,3        
      M = M + 1        
      OCT(I,J) = IDAT(M)        
   10 CONTINUE        
      DO 40 I = 1,NOCT        
      ICD = OCT(1,I)        
      IF (OCT(3,I) .EQ. 0) GO TO 20        
      IF (ANDF(OCT(3,I),OBITS)       .EQ. 0) GO TO 35        
   20 IF (ANDF(OCT(2,I),RFMASK(SOL)) .EQ. 0) GO TO 40        
   35 DMAP(1,ICD) = -1        
   40 CONTINUE        
   45 IF (NPTBS .EQ. 0) GO TO 2000        
      M = IPTBS - 1        
      DO 46 J = 1,NPTBS        
      DO 46 I = 1,7        
      M = M + 1        
      PTBS(I,J) = IDAT(M)        
   46 CONTINUE        
      DO 1000 I = 1,NPTBS        
      ICD = PTBS(1,I)        
      IF (DMAP(1,ICD) .EQ. -1) GO TO 1000        
      IF (ICD .EQ. 0) GO TO 1000        
      RMV = .FALSE.        
C        
C     CHECK IF  OPTION IS ON        
C        
      KOPT = PTBS(6,I)        
      IF (ANDF(KOPT,OBITS) .EQ. 0) RMV = .TRUE.        
      IF (ANDF(KOPT,OBALL) .EQ. 0) RMV = .FALSE.        
      IF (ANDF(KOPT,RFMASK(SOL)) .NE. 0) RMV = .TRUE.        
      NCHAR = PTBS(4,I)        
      NC    = 0        
      FLAG  = 0        
      VWORD = BLANK        
      ICOL  = PTBS(3,I)        
C        
C     FIND  VARIABLE  IF  REQUIRED        
C        
      IF (RMV) GO TO 300        
      KEY = PTBS(5,I)        
      I3  = NVAR/3        
      DO 60 J = 1,I3        
      IF (VAR(1,J) .EQ. KEY) GO TO 70        
      IF (KEY.EQ.J .AND. VAR(1,J).EQ.ALTER) GO TO 450        
   60 CONTINUE        
C        
C     VARIABLE HAS NOT BEEN SET        
C        
      VWORD = BLANK        
      RMV   = .TRUE.        
      GO TO 300        
C        
C     VARIABLE  IS FOUND , IT IS IN VAR(2,J) AND/OR VAR(3,J)        
C        
   70 VWORD   = VAR(2,J)        
      NAME(1) = VAR(2,J)        
      NAME(2) = VAR(3,J)        
C        
C     TEST FOR REAL OR INTEGER        
C        
      IF (VWORD .EQ.  0) GO TO 300        
      IF (VWORD .EQ. -1) GO TO 74        
      IF (VWORD .EQ. -2) GO TO 3010        
C        
C     WORD IS REAL (TEMPORARY ERROR)        
C        
      GO TO 75        
C        
C     WORD IS AN INTEGER        
C        
   74 NAME(1) = NAME (2)        
      NAME(2) = 0        
      FLAG    = 1        
   75 IF (PTBS(7,I) .EQ. 0) GO TO 500        
      NC    = PTBS(3,I) - PTBS(2,I)        
      II(1) = BLANK        
      II(2) = BLANK        
      IF (NC .GT. 0) GO TO 80        
      IF (NC .LT. 0) GO TO 3010        
      II(1) = NAME(1)        
      II(2) = NAME(2)        
      GO TO 100        
C        
C     CONSTRUCT WHOLE DATA BLOCK NAME        
C        
   80 CALL PULL (DMAP(1,ICD),II,PTBS(2,I),NC,0)        
      CALL PUSH (NAME,II,NC+1,NCHAR,FLAG)        
C        
C     CHECK OUTPUT DATA BLOCKS AGAINST PREVIOUS OUTPUTS        
C        
  100 IF (NDBS .EQ. 0) GO TO 142        
C        
      DO 140 L = 1, NDBS        
      IF (II(1).EQ.DBS(1,L) .AND. II(2).EQ.DBS(2,L)) GO TO 150        
  140 CONTINUE        
  142 IF (PTBS(7,I) .GT. 0) GO TO 200        
C        
C     VARIABLE IS OK , ADD NAME TO LIST        
C        
      NDBS = NDBS + 1        
      DBS(1,NDBS) = II(1)        
      DBS(2,NDBS) = II(2)        
      GO TO 500        
  150 IF (PTBS(7,I) .GT. 0) GO TO 500        
C        
C     DATA BLOCK IS OUTPUT, REMOVE IF ALLREADY DEFINED.        
C        
  200 RMV  =.TRUE.        
C        
C     REMOVE WHOLE  NAME HERE  , CHECK FOR PARAMETER        
C        
  300 II(1)   = 0        
      NAME(1) = BLANK        
      NAME(2) = BLANK        
      NAME(3) = BLANK        
      NAME(4) = BLANK        
      FLAG    = 0        
      CALL PULL (DMAP(1,ICD),II,PTBS(2,I),1,0)        
      IF (II(1).EQ.SLAS .OR. II(1).EQ.AST) GO TO 500        
      ICOL  = PTBS(2,I)        
      NCHAR = NCHAR + PTBS(3,I) - PTBS(2,I)        
      GO TO 500        
C        
C     CHECK IF ALTER CARD, OUTPUT AS BCD AND TWO INTEGERS        
C        
  450 DMAP(1,ICD) = ALTER        
      DMAP(2,ICD) = VAR(2,J)        
      DMAP(3,ICD) = VAR(3,J)        
      RMVALL = .FALSE.        
      NXDEL  = 0        
      IF (VAR(2,J) .EQ. 0) RMVALL = .TRUE.        
      GO TO 910        
C        
C     ADD VARIABLES TO BCD DMAP        
C        
  500 CALL PUSH (NAME,DMAP(1,ICD),ICOL,NCHAR,FLAG)        
C        
      IF (.NOT.RMV) RMVALL = .FALSE.        
C        
C     IF ALL VARIABLES ARE REMOVED FROM ONE CARD, DELETE THE CARD       
C        
      NNEW = PTBS(1,I+1)        
      IF (ICD .EQ. NNEW) GO TO 1000        
C        
C     NEXT  COMMAND GOES TO NEW CARD,  CHECK IF CONTINUATION        
C        
  905 CALL PULL (DMAP(1,ICD+1),II,1,4,0)        
C        
      IF (II(1) .NE. BLANK) GO TO 910        
C        
C     CONTINUATION FOUND        
C        
      NXDEL = NXDEL + 1        
      IF (NNEW .EQ. ICD+1) GO TO 1000        
      ICD = ICD+1        
      GO TO 905        
C        
C     FINISHED WITH  LOGICAL CARD        
C        
  910 IF (.NOT.RMVALL) GO TO 940        
      DMAP(1,ICD) = -1        
      IF (NXDEL .LE. 0) GO TO 1000        
      DO 930 L = 1,NXDEL        
      J = ICD-L        
      DMAP(1,J) = -1        
  930 CONTINUE        
  940 RMVALL = .TRUE.        
C        
C     END OF LOOP ON VARIABLE CHARACTERS        
C        
      NXDEL = 0        
C        
 1000 CONTINUE        
C        
C     PROCESS CARDS TO BE DELETED FROM SEQUENCE        
C        
 2000 IKEEP = 0        
      DO 2500 ICD = 1,NRDM        
C        
      IF (DMAP(1,ICD) .EQ. -1) GO TO 2500        
C        
C     KEEP CARD        
C        
      IKEEP = IKEEP + 1        
      DO 2450 J = 1,18        
      DMAP(J,IKEEP) = DMAP(J,ICD)        
 2450 CONTINUE        
 2500 CONTINUE        
      NRDM = IKEEP        
      RETURN        
 3010 WRITE  (IOUT,3020) SFM,DMAP(1,ICD)        
 3020 FORMAT (A25,' 6010, ILLEGAL VARIABLE TO BE SET IN DMAP STATEMENT',
     1        3X,A4)        
C        
      NOGO = 1        
      RETURN        
      END        