      SUBROUTINE XRGDCF (IRESTB)        
C        
C     PURPOSE - XRGDCF PROCESSES THE '****CARD', '****FILE' AND        
C               '****RFMT' CONTROL CARDS WITHIN THE RIGID DMAP        
C               DATA BASE.        
C        
C     AUTHOR  - RPK CORPORATION; DECEMBER, 1983        
C        
C     INPUT        
C       /SYSTEM/        
C         NOUT         UNIT NUMBER FOR THE OUTPUT PRINT FILE        
C       /XRGDXX/        
C         NUM          VALUE OF THE NUMBER OR RANGE OF NUMBERS        
C                      IN THE CURRENT FIELD BEING PROCESSED        
C        
C     OUTPUT        
C       ARGUMENTS        
C         IRESTB       THE MODULE EXECUTION DECISION TABLE        
C       OTHER        
C         /XRGDXX/        
C           ICOL       CURRENT COLUMN NUMBER BEING PROCESSED IN        
C                      THE CARD        
C           IERROR     ERROR FLAG - NON-ZERO IF AN ERROR OCCURRS        
C        
C     LOCAL VARIABLES        
C       IBIT           BIT NUMBER FOR FLAG IN THE MODULE EXEC. DEC.     
C                      TABLE        
C       IEND           LAST NUMBER OF RANGE OF NUMBERS READ FROM        
C                      THE CURRENT FIELD        
C       ISTR           SAME AS IEND EXCEPT FIRST NUMBER        
C       IWORD          SAME AS IBIT BUT REFERS TO THE WORD NUMBER       
C        
C     FUNCTIONS        
C       XRGDCF PROCESSES THE ABOVE TYPES OF CARDS WHICH ALL HAVE        
C       FORMATS AS FOLLOWS:  '****XXXX   M1,M2,..'        
C       WHERE M- IS IN ANY OF THE FOLLOWING FORMS ( NNN  OR NNN-NNN).   
C       NNN IS AN INTEGER NUMBER AND THE '-' REFERS TO A RANGE        
C       WHERE THE RANGE MUST BE IN ASCENDING ORDER.        
C       XRGDCF CALLS XDCODE TO CONVERT THE CARD IMAGE TO 80A1 AND       
C       CALLS XRGDEV TO VALIDATE THE SYNTAX AND TO GET A M-        
C       ENTRY FROM THE CARD.  BASED ON THE VALUE(S) RETURNED IN        
C       NUM, THE CORRESPONDING BITS ARE TURNED ON IN THE MODULE        
C       EXECUTION DECISION TABLE.  PROCESSING CONTINUES UNTIL ALL       
C       FIELDS OF THE CARD HAVE BEEN PROCESSED.        
C        
C        
C     SUBROUTINES CALLED - XDCODE, XRGDEV        
C        
C     CALLING SUBROUTINES - XRGRFM        
C        
C     ERRORS - NONE        
C        
      EXTERNAL        ORF        
      INTEGER         RECORD, ORF   , IRESTB(7)        
      COMMON /SYSTEM/ ISYSBF, NOUT  , DUM(98)        
      COMMON /XRGDXX/ IRESTR, NSUBST, IPHASE, ICOL   , NUMBER, ITYPE ,  
     1                ISTATE, IERROR, NUM(2), IND    , NUMENT        ,  
     2                RECORD(20)    , ICHAR(80)      , LIMIT(2)      ,  
     3                ICOUNT, IDMAP , ISCR  , NAME(2), MEMBER(2)     ,  
     4                IGNORE        
C        
      IERROR = 0        
      ICOL   = 9        
      CALL XDCODE        
 10   CALL XRGDEV        
      IF (IERROR .NE. 0 .OR. ICOL .GT. 80) GO TO 30        
      ISTR   = NUM(1)        
      IEND   = NUM(2)        
      DO 20 K = ISTR,IEND        
      IWORD = (K-1)/31        
      IBIT  = 2**(31*IWORD + 31 - K)        
      IRESTB(IWORD+1) = ORF(IRESTB(IWORD+1),IBIT)        
 20   CONTINUE        
      ICOL = ICOL + 1        
      GO TO 10        
 30   CONTINUE        
      RETURN        
      END        