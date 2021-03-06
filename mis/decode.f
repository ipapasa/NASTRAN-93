      SUBROUTINE DECODE (CODE,LIST,N)        
C        
C     DECODE DECODES THE BITS IN A WORD AND RETURNS A LIST OF INTEGERS  
C     CORRESPONDING TO THE BIT POSITIONS WHICH ARE ON. NUMBERING        
C     CONVENTION IS RIGHT (LOW ORDER) TO LEFT (HIGH ORDER) 00 THRU 31.  
C        
C     ARGUMENTS        
C        
C     CODE - INPUT  - THE WORD TO BE DECODED        
C     LIST - OUTPUT - AN ARRAY OF DIMENSION .GE. 32 WHERE THE INTEGERS  
C                     CORRESPONDING TO BIT POSITIONS ARE STORED        
C     N    - OUTPUT - THE NUMBER OF ENTRIES IN THE LIST  I.E. THE NO.   
C                     OF 1-BITS IN THE WORD        
C        
C        
      EXTERNAL     ANDF        
      INTEGER      CODE,ANDF,TWO,LIST(1)        
      COMMON /TWO/ TWO(32)        
C        
      N = 0        
      DO 8 I = 1,32        
      IF (ANDF(TWO(33-I),CODE) .EQ. 0) GO TO 8        
      N = N + 1        
      LIST(N) = I - 1        
    8 CONTINUE        
C        
      RETURN        
      END        
